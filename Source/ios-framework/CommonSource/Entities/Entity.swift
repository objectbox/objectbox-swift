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

/// Types conforming to this protocol provide persistence metadata.
///
/// The code generator will make your `Entity` types conform to this for you and implement
/// the requirements.
public protocol EntityInspectable {
    /// The type of the generated `EntityBinding`-conformant class used for serializing
    /// and de-serializing this entity.
    associatedtype EntityBindingType: EntityBinding
    
    /// Description of the entity type used by ObjectBox to map objects to data in the store.
    static var entityInfo: EntityInfo { get }
    
    /// Helper object used for serializing/deserializing entities.
    static var entityBinding: EntityBindingType { get }
}

// Entities have to be classes to make `OBXBox`'s Objective-C generics work.

/// Base protocol of anything you want to persist in a box.
///
/// ## Persisted Properties
///
/// All stored properties of a type that conforms to `Entity` will be persisted, if possible.
/// For numbers, ObjectBox recognizes `Bool`, `Int8`, `Int16`, `Int32`, `Int64`, `Int` (plus their unsigned variants),
/// `Float`, and `Double`.
/// It also recognizes `String`, `Date` and `Data` (the latter of which may also be written as `[UInt8]`).
///
/// ## Relations
///
/// To create relations between entities, use `ToOne` and `ToMany` to wrap the target type,
/// like `customer: ToOne<Customer>`.
///
/// Informal requirements: It is assumed that classes implementing this have an init() method
/// and all properties to be serialized are mutable. For struct types, it is assumed that an
/// init method exists that accepts all properties to be serialized.
public protocol Entity {}

/// :nodoc:
///
/// - Note: Used in Alpha 1 only to implement backlinks. When you operate on the level of
///   "a type that conforms to Entity", that's not specific enough; you need to erase the type. This
///   provides specification to get to the concrete EntityId<T>. Will be replaced in future versions.
public protocol __EntityRelatable {
    // swiftlint:disable identifier_name
    /// - Note: Used in Alpha 1 only to implement backlinks and get to the _concrete_ type.
    ///
    /// For example:
    ///
    ///    class Person: Entity {
    ///        typealias EntityType = Person
    ///        // ...
    ///    }
    associatedtype EntityType: EntityInspectable & __EntityRelatable
    /// - Note: Used in Alpha 1 only to implement backlinks and know which _concrete_ `Id` type
    /// is used. Implement as e.g. `_id: EntityId<Person> { return self.id }`.
    var _id: EntityId<EntityType> { get }
    // swiftlint:enable identifier_name
}
