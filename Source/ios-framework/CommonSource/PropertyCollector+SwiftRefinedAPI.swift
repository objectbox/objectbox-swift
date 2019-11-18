//
// Copyright © 2018 ObjectBox Ltd. All rights reserved.
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

// Adapter methods for writing optionals and relations to a FlatBufferBuilder
// Null values are simply not collected
extension FlatBufferBuilder {
    /// :nodoc:
    public func collect(_ value: Bool?, at propertyOffset: UInt16) {
        guard let value = value else { return }
        self.collect(value, at: propertyOffset)
    }

    /// :nodoc:
    public func collect(_ value: Int?, at propertyOffset: UInt16) {
        guard let value = value else { return }
        self.collect(value, at: propertyOffset)
    }

    /// :nodoc:
    public func collect(_ value: Int64?, at propertyOffset: UInt16) {
        guard let value = value else { return }
        self.collect(value, at: propertyOffset)
    }
    
    /// :nodoc:
    public func collect<T>(_ value: EntityId<T>?, at propertyOffset: UInt16) {
        guard let value = value else { return }
        self.collect(value.value, at: propertyOffset)
    }
    
    /// :nodoc:
    public func collect(_ value: Int32?, at propertyOffset: UInt16) {
        guard let value = value else { return }
        self.collect(value, at: propertyOffset)
    }

    /// :nodoc:
    public func collect(_ value: Int16?, at propertyOffset: UInt16) {
        guard let value = value else { return }
        self.collect(value, at: propertyOffset)
    }

    /// :nodoc:
    public func collect(_ value: Int8?, at propertyOffset: UInt16) {
        guard let value = value else { return }
        self.collect(value, at: propertyOffset)
    }

    /// :nodoc:
    public func collect(_ value: Float?, at propertyOffset: UInt16) {
        guard let value = value else { return }
        self.collect(value, at: propertyOffset)
    }

    /// :nodoc:
    public func collect(_ value: Double?, at propertyOffset: UInt16) {
        guard let value = value else { return }
        self.collect(value, at: propertyOffset)
    }
    
    /// :nodoc:
    public func collect(_ value: String?, at propertyOffset: UInt16) {
        guard let value = value else { return }
        self.collect(value, at: propertyOffset)
    }
    
    /// :nodoc:
    public func collect<E: EntityInspectable & __EntityRelatable>(_ relation: ToOne<E>, at propertyOffset: UInt16,
                                                                  store: Store)
        where E == E.EntityBindingType.EntityType {
            guard relation.hasValue else { return }
            let relatedBox = store.box(for: type(of: relation).Target.self)
            do {
                guard let targetId = try relatedBox.put(relation) else { return }
                self.collect(targetId.value, at: propertyOffset)
            } catch {
                objc_exception_throw(error)
            }
    }
}
