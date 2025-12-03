//
// Copyright © 2018-2025 ObjectBox Ltd. https://objectbox.io/
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

/// Optional protocol to signal the ObjectBox code generator that a class/struct is an entity
/// (part of the persisted ObjectBox data model).
///
/// ```swift
/// class Person: Entity {
///     var id: Id = 0
///     init() { }
/// }
/// ```
///
/// While not enforced by this protocol, adopting classes or structs must at least provide an ID property of type
/// ``Id``. Classes must also provide a no-argument constructor, like `init()` and all persisted properties must be
/// mutable. For structs, a constructor that accepts all persisted properties must be available.
///
/// Instead of adopting this protocol, an annotation can be used:
///
/// ```swift
/// // objectbox: entity
/// class Person {
///     var id: Id = 0
///     init() { }
/// }
/// ```
///
/// ## Persisted Properties
///
/// All properties that have a supported type are persisted.
///
/// For numbers, ObjectBox supports `Bool`, `Int8`, `Int16`, `Int32`, `Int64`, `Int` and their unsigned variants,
/// as well as `Float` and `Double`.
///
/// It also recognizes `String`, `[String]`, `Date` and `Data` (the latter of which may also be written as `[UInt8]`).
///
/// ## Relations
///
/// To create relations between entities, use `ToOne` and `ToMany` to wrap the target type,
/// like `customer: ToOne<Customer>`.
///
/// ## More information
///
/// For more details see the [documentation](https://swift.objectbox.io/entity-annotations).
public protocol Entity {}

/// Protocol used in generated code to provide metadata required by ObjectBox.
///
/// The code generator will make your entity types conform to this and implement the requirements.
public protocol EntityInspectable {
    /// The type of the generated `EntityBinding`-conformant class used for serializing
    /// and de-serializing this entity.
    associatedtype EntityBindingType: EntityBinding
    
    /// Description of the entity type used by ObjectBox to map objects to data in the store.
    static var entityInfo: EntityInfo { get }
    
    /// Helper object used for serializing/deserializing entities.
    static var entityBinding: EntityBindingType { get }
}

/// Protocol used in generated code to provide an ID getter (wrapped as `EntityId<T>`) of an object.
///
/// The code generator will make your entity types conform to this and implement the requirements.
///
/// Currently only used to check if the ID is 0 in `Box.remove` and the `LazyProxyRelation.State` constructor.
/// The type information (`T` of `EntityId<T>`) is unused. Also note that IDs no longer have to implement `EntityId`.
///
/// For example:
///
/// ```swift
/// class Person: __EntityRelatable {
///     typealias EntityType = Person
///     var _id: EntityId<Person>  {
///         return EntityId<Person>(self.id.value)
///     }
/// }
/// ```
public protocol __EntityRelatable {
    /// Placeholder for the entity type to use with the `_id` getter.
    associatedtype EntityType: Entity
    // swiftlint:disable identifier_name
    /// Used to get the ID value of an object of the associated entity type.
    var _id: EntityId<EntityType> { get }
    // swiftlint:enable identifier_name
}
