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
/// You usually don't have to deal with this class.
public protocol EntityBinding {
    /// The type this binding serves as an adapter for.
    associatedtype EntityType: Entity & EntityInspectable
    
    /// The type of the 'id' property in EntityType.
    associatedtype IdType: IdBase

    /// Used by `Box` to create new EntityBinding adapter instances.
    init()
    
    /// Writes the given entity's value to the given PropertyCollector, assigning it the given ID.
    /// `entityId` _must_ not be 0.
    func collect(fromEntity entity: EntityType, id entityId: Id, propertyCollector: PropertyCollector,
                 store: Store)
    
    /// The collected entity has been put and now it's time to attach and put all relations, if this entity is new.
    func postPut(fromEntity entity: EntityType, id entityId: Id,
                 store: Store)
    
    /// Creates a new entity based on data from the given EntityReader.
    /// Returns: The new entity.
    func createEntity(entityReader: EntityReader, store: Store) -> EntityType
    
    /// For class types, this is used to write the new entity ID back to the entity when they are first put into a box.
    /// Note that this function only works on classes, it will quietly do nothing when used on a struct.
    func setEntityIdUnlessStruct(of entity: EntityType, to entityId: Id)

    /// Used to read the ID of an entity.
    func entityId(of entity: EntityType) -> Id

    func setToOneRelation(_ propertyId: obx_schema_id, of entity: EntityType, to entityId: Id?)
}

extension EntityBinding {
    public func postPut(fromEntity entity: EntityType, id idNumber: Id, store: Store) {}

    public func setToOneRelation(_ propertyId: obx_schema_id, of entity: EntityType, to entityId: Id?) {
        fatalError("Attempt to set unknown ToOne relation \(propertyId)")
    }
}
