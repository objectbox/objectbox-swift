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

// 1. Use the Query type to perform core-compatible Objective-C calls.
// 2. Use the block-based query method to state conditions using operator overloads, like:
//
//    box.query { "AgeRestriction" .= Person.age > 21 && Person.name.startsWith("M") }
//

/// A reusable query returning entities.
///
/// You can store a `Query` once it is set up and re-evaluate it e.g. using `find()` or `all()`.
///
/// Use `PropertyQuery` instead if you want to return aggregate results. Use `property(_:)` to obtain a `PropertyQuery`.
///
/// `PropertyQuery` will respect the conditions of its base `Query`. So it you want to find the average age of all
/// `Person`s above 30, this is how you can write it:
///
///      let query = personBox.query { Person.age > 29 }
///      let ageQuery = query.property(Person.age)
///      let averageAge = ageQuery.average
///
public struct Query<E: Entity> {

    /// The entity type this query is going to target.
    public typealias EntityType = E

    internal let base: __OBXQuery

    internal init(base: __OBXQuery) {
        self.base = base
    }

    /// Find all Objects matching the query between the given offset and limit.
    ///
    /// - Parameters:
    ///   - offset: How many results to skip. (Useful when paginating results.)
    ///   - limit: Maximum number of objects that may be returned (may give fewer).
    /// - Returns: Collection of objects matching the query conditions.
    public func find(offset: UInt64 = 0, limit: UInt64 = 0) -> [EntityType] {
        // swiftlint:disable force_cast
        return base.find(withOffset: offset, andLimit: limit) as! [EntityType]
        // swiftlint:enable force_cast
    }

    /// Find the first Object matching the query.
    public var first: EntityType? {
        return base.findFirst() as? EntityType
    }

    /// Find the single object matching the query.
    ///
    /// When `count > 1`, this will throw.
    ///
    /// - Returns: The one and only object matching the query conditions.
    /// - Throws: `NSError` with `OBXErrorDomain`, for example when there is more than one match.
    public func findUnique() throws -> EntityType {
        // swiftlint:disable force_cast
        return try base.findUnique() as! EntityType
        // swiftlint:enable force_cast
    }

    /// The number of objects matching the query.
    public var count: Int {
        return Int(base.count())
    }

    /// Find all Objects matching the query.
    ///
    /// Alias for `find(offset: 0, limit: 0)`.
    public var all: [EntityType] {
        return find()
    }

    /// Accessor to get a `PropertyQuery` object based on the query conditions.
    ///
    /// You use `Query` to get objects, `PropertyQuery` to get aggregate results for entity properties.
    /// For example, for an `Int` property, you can get the `average`, `sum`, `min`, and `max`, among other things.
    /// 
    /// - Parameter property: Object property to modify the query for.
    /// - Returns: New `PropertyQuery` to configure.
    public func property<T>(_ property: Property<EntityType, T>) -> PropertyQuery<EntityType, T>
        where T: EntityPropertyTypeConvertible {
        return PropertyQuery(base: base.property(property.base))
    }
}
