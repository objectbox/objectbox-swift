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

/// The code generator generates concrete instances of EntityBinding objects that perform the actual work of
/// transferring database values into your Swift objects and extracting them for writing out.
///
/// As an ObjectBox user, you don't need to deal with this (directly).
public protocol EntityBinding: AnyObject {
    /// The type this binding serves as an adapter for.
    associatedtype EntityType: Entity & EntityInspectable
    
    /// The type of the 'id' property in EntityType.
    associatedtype IdType: IdBase

    /// Used by `Box` to create new EntityBinding adapter instances.
    init()

    /// Allows to check for a matching/compatible generator version.
    /// Failing this check will raise a fatal error at runtime.
    /// This version refers the bindings the generator generates, not the generator version itself.
    /// It will only change when there are (relevant) changes in the generated binding.
    ///
    /// Version history (with Swift library version which first relied on the version):
    /// 1 (1.4 2020-09-07): Added generatorBindingVersion() - you need to update if you get error like this:
    ///                     Type '...' does not conform to protocol 'EntityBinding'
    func generatorBindingVersion() -> Int
    
    /// Writes the given entity's value to the given FlatBufferBuilder, assigning it the given ID.
    /// `entityId` _must_ not be 0.
    func collect(fromEntity entity: EntityType, id entityId: Id, propertyCollector: FlatBufferBuilder, store: Store)
    throws
    
    /// The collected entity has been put and now it's time to attach and put all relations, if this entity is new.
    func postPut(fromEntity entity: EntityType, id entityId: Id, store: Store) throws
    
    /// Creates a new entity based on data from the given FlatBufferReader.
    /// Returns: The new entity.
    func createEntity(entityReader: FlatBufferReader, store: Store) -> EntityType
    
    /// For class types, this is used to write the new entity ID back to the entity when they are first put into a box.
    /// Note that this function only works on classes, it will quietly do nothing when used on a struct.
    func setEntityIdUnlessStruct(of entity: EntityType, to entityId: Id)

    /// For struct types, this is used to write the new entity ID back to the entity when they are first put into a box.
    /// Note that this function only works on structs, it will raise a fatal error when used on a class.
    func setStructEntityId(of entity: inout EntityType, to entityId: Id)

    /// Used to read the ID of an entity.
    func entityId(of entity: EntityType) -> Id

    /// Modify a ToOne relation using its property ID, used when modifying `ToOne` backlinks.
    func setToOneRelation(_ propertyId: obx_schema_id, of entity: EntityType, to entityId: Id?)
}

extension EntityBinding {
    /// The collected entity has been put and now it's time to attach and put all relations, if this entity is new.
    public func postPut(fromEntity entity: EntityType, id idNumber: Id, store: Store) {}

    /// Modify a ToOne relation using its property ID, used when modifying `ToOne` backlinks.
    public func setToOneRelation(_ propertyId: obx_schema_id, of entity: EntityType, to entityId: Id?) {
        fatalError("Attempt to set unknown ToOne relation \(propertyId)")
    }

    public func setStructEntityId(of entity: inout EntityType, to entityId: Id) {
        fatalError("not a struct type!")
    }

    public func setEntityIdUnlessStruct(of entity: EntityType, to entityId: Id) {
        // Use the struct variants of the put methods on entities of structs.
    }
}
