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

/// Class used by the code generator to create a model for your Store. Typical usage is:
///
///     let mBuilder = ModelBuilder()
///     let eBuilder = mBuilder.entityBuilder(for: myEntityInfo, id: 1, uid: 1001)
///     // ... set up the entity here
///     mBuilder.lastEntity(id: 1, uid: 1001)
///     mBuilder.lastIndex(id: 0, uid: 0) // This example model has no indexes.
///     let model = mBuilder.finish()
///     // create new Store using the model
///
/// See EntityBuilder documentation for details.
///
/// You usually don't have to deal with this class.
public class ModelBuilder {
    
    private var model: OpaquePointer? /*OBX_model*/
    
    /// Create a new ModelBuilder.
    public init() throws {
        obx_last_error_clear()
        model = obx_model()
        try checkLastError()
    }
    
    deinit {
        if let model = model { // Caller never called finish() on us? Release the memory!
            do {
                try checkLastError(obx_model_free(model))
            } catch {
                ignoreAndLog(error: error)
            }
            self.model = nil
        }
    }
    
    /// Create an entityBuilder for an entity with the given characteristics, local and unique ID, ready for specifying
    /// properties on. Do not use an EntityBuilder previously returned by this method after creating a new one using
    /// this method. This method implicitly ends definition of the previous entity builder.
    public func entityBuilder<T: EntityInspectable>(for type: T.Type = T.self, id schemaEntityID: UInt32,
                                                    uid schemaEntityUID: UInt64)
        throws -> EntityBuilder<T> {
        let err1 = obx_model_entity(model, type.entityInfo.entityName, schemaEntityID, schemaEntityUID)
        try check(error: err1, message: String(utf8String: obx_last_error_message())!)

        return EntityBuilder<T>(entityInfo: type.entityInfo, model: model!)
    }
    
    /// Write the highest entity ID and UID used with into model. (This includes IDs for deleted entities)
    public func lastEntity(id schemaEntityID: UInt32, uid schemaEntityUID: UInt64) {
        obx_model_last_entity_id(model, schemaEntityID, schemaEntityUID)
    }
    
    /// Register the highest index ID and UID used with the model. (This includes IDs for deleted indexes)
    public func lastIndex(id schemaEntityID: UInt32, uid schemaEntityUID: UInt64) {
        obx_model_last_index_id(model, schemaEntityID, schemaEntityUID)
    }
    
    /// Register the highest standalone relation ID and UID used with the model.
    /// (This includes IDs for deleted relations)
    public func lastRelation(id relationID: UInt32, uid relationUid: UInt64) {
        obx_model_last_relation_id(model, relationID, relationUid)
    }
    
    /// Finish model creation and return an OBX_model suitable for passing to Store.
    /// Caller takes over ownership of returned pointer:
    public func finish() -> OpaquePointer {
        let model = self.model!
        self.model = nil
        return model
    }
}
