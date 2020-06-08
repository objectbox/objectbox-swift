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

/// Metadata of object properties, used by the framework to determine how to store the values.
///
/// These are created by the code generator for you.
///
/// Usually, you only deal with this class when writing queries. The property names you use in your queries are actually
/// instances of Property, and you can use operators and comparison methods like isLessThan() on them to express your
/// queries.
/// Below you see a list of methods that are available to you for property queries, apart from the operators described
/// under [Query Syntax](../query-syntax.html).
public struct Property<E: EntityInspectable & __EntityRelatable, V: EntityPropertyTypeConvertible, R>
where E == E.EntityBindingType.EntityType {
    /// Entity type that contains the property this object is describing.
    public typealias EntityType = E

    /// Supported property value type this is describing.
    public typealias ValueType = V

    /// If this is a ToOne property, this is the type it refers to. Otherwise Void.
    public typealias ReferencedType = R

    internal let base: PropertyDescriptor

    internal init(base: PropertyDescriptor) {
        self.base = base
    }

    public init(propertyId: UInt32, isPrimaryKey: Bool = false) {
        self.init(base: PropertyDescriptor(propertyId: propertyId, isPrimaryKey: isPrimaryKey,
                                           type: V.entityPropertyType))
    }

    /// Indicates if the property is the entity's primary key.
    public var isPrimaryKey: Bool { return base.isPrimaryKey }

    /// The internal ID of the property, in terms of the database schema.
    public var propertyId: UInt32 { return base.propertyId }
}

/// Property represents a "value" and not a relation; TODO Decide if useful (one generic parameter less) or drop it
public typealias ValueProperty<E: EntityInspectable & __EntityRelatable, V: EntityPropertyTypeConvertible> =
        Property<E, V, Void> where E == E.EntityBindingType.EntityType
