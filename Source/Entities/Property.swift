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
public struct Property<E: Entity, T: EntityPropertyTypeConvertible> {
    /// Entity type that contains the property this object is describing.
    public typealias EntityType = E

    /// Supported property value type this is describing.
    public typealias ValueType = T

    internal let base: __OBXProperty

    internal init(base: __OBXProperty) {
        self.base = base
    }

    public init(propertyId: UInt64, isPrimaryKey: Bool = false) {
        self.init(base: __OBXProperty(propertyId: propertyId, isPrimaryKey: isPrimaryKey, type: T.entityPropertyType))
    }

    /// Indicates if the property is the entity's primary key.
    public var isPrimaryKey: Bool { return base.isPrimaryKey }

    /// The internal ID of the property, in terms of the database schema.
    public var propertyId: UInt64 { return base.propertyId }
}
