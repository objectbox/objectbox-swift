//
// Copyright © 2019 ObjectBox Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// Helper base class to allow us to pass a generic type through a C function callback.
/// Can't be a subtype of Box or Query as that would make it generic again.
internal class InstanceVisitorBase {
    var userError: Swift.Error? ///< Set by subclasses in visit() if an error occurs that needs to be thrown.
    
    /// Called by for(_:, in:) and forEach to request creation of the given entity from raw data and to call back its
    /// caller with the new object in a type-safe manner. Return false or set userError to abort the loop.
    func visit(ptr: UnsafeRawPointer?, size: Int) -> Bool { return false }
}

/// Generic class that can be passed through a C context pointer as its non-generic base class and that takes care
/// of instantiating the entities from the raw data it is given.
/// Used for visit() and forEach() methods on e.g. Box and Query.
internal class InstanceVisitor<E: EntityInspectable>: InstanceVisitorBase
where E == E.EntityBindingType.EntityType {
    var flatBuffer = FlatBufferReader()
    let store: Store
    let visitor: ((E) throws -> Bool)?
    let optionalVisitor: ((E?) throws -> Bool)?
    
    init(type: E.Type = E.self, store: Store, visitor: ((E) throws -> Bool)? = nil,
         optionalVisitor: ((E?) throws -> Bool)? = nil) {
        self.store = store
        self.visitor = visitor
        self.optionalVisitor = optionalVisitor
        assert(visitor != nil || optionalVisitor != nil)
    }
    
    override func visit(ptr unsafePtr: UnsafeRawPointer?, size: Int) -> Bool {
        do {
            var entity: E?
            defer { flatBuffer.setCurrentlyReadTableBytes(nil) }
            if let ptr = unsafePtr {
                flatBuffer.setCurrentlyReadTableBytes(ptr)
                entity = E.entityBinding.createEntity(entityReader: flatBuffer, store: store)
            }
            if let optionalVisitor = optionalVisitor, try !optionalVisitor(entity) {
                return false
            } else if let visitor = visitor, let entity = entity, try !visitor(entity) {
                return false
            }
        } catch {
            userError = error
        }
        return true
    }
}
