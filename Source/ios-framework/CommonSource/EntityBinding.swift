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
    
    /// Used by `Box` to create new EntityBinding adapter instances.
    init()
    
    /// Writes the given entity's value to the given PropertyCollector, assigning it the given ID.
    /// `entityId` _must_ not be 0.
    func collect(fromEntity entity: EntityType, id entityId: EntityId, propertyCollector: PropertyCollector,
                 store: Store)
    
    /// Creates a new entity based on data from the given EntityReader.
    /// Returns: The new entity.
    func createEntity(entityReader: EntityReader, store: Store) -> EntityType
    
    /// For class types, this is used to write the new entity ID back to the entity when they are first put into a box.
    func setEntityId(of entity: EntityType, to entityId: EntityId)

    /// Used to read the ID of an entity.
    func entityId(of entity: EntityType) -> EntityId
}
