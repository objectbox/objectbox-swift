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

import Foundation

// Wraps OBXPropertyQuery for a better Swift API.
//
// Use this to run queries based on entity properties. The Swift API and its generic constraints allow
// to expose a set of useful query commands for each property type, so you cannot accidentally call
// `sum` for a String property.

/// Query for values of a specific property instead of object instances.
///
/// Create using `Query.property(_:)`. Use `Query` if you want to obtain entities.
///
/// `PropertyQuery` will respect the conditions of its base `Query`. So if you want to find the average age of all
/// `Person`s above 30, this is how you can write it:
///
///      let query = personBox.query { Person.age > 29 }
///      let ageQuery = query.property(Person.age)
///      let averageAge = ageQuery.average
///
/// - Note: Property values do currently not consider any sorting order defined in the main `Query` object.
public class PropertyQuery<E: Entity, T: EntityPropertyTypeConvertible> {

    /// The entity type this query is targeting.
    public typealias EntityType = E

    /// The type of the entity's property this query is targeting.
    public typealias ValueType = T

    internal let base: __OBXPropertyQuery

    internal init(base: __OBXPropertyQuery) {
        self.base = base
    }
}

extension PropertyQuery {
    /// The count of objects matching this query.
    public var count: Int {
        return Int(self.base.count())
    }
}

// MARK: - Unique

extension PropertyQuery {
    /// Change this `PropertyQuery` to verify there is only a single value among the query result.
    ///
    /// For find methods returning single values, e.g. `findInt()`, this will additionally verify that the resulting value
    /// is unique. If there is any other resulting value resulting from this query, a runtime exception
    /// will be thrown.
    ///
    /// - Note: Cannot be unset.
    /// - Returns: `self` for chaining
    @discardableResult
    public func unique() -> PropertyQuery<EntityType, ValueType> {
        base.unique()
        return self
    }

    /// Indicates if results are verified to be unique.
    public var isUnique: Bool { return base.isUnique }
}

// MARK: - Distinct

extension PropertyQuery where T: EntityScalarPropertyType {
    /// Enable that only distinct values should be returned (e.g. 1,2,3 instead of 1,1,2,3,3,3).
    ///
    /// - Note: Cannot be unset.
    /// - Returns: `self` for chaining
    @discardableResult
    public func distinct() -> PropertyQuery<EntityType, ValueType> {
        base.distinct()
        return self
    }

    /// True if only distinct values should be returned (e.g. 1,2,3 instead of 1,1,2,3,3,3).
    public var isDistinct: Bool { return base.isDistinct }
}

// MARK: - Integer Aggregates

// `longSum` guarantees Int64, but Int may be Int32 on some platforms;
// so we wrap it in the easy-to-consume Int, except for Int64

extension PropertyQuery where T == Int {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Int {
        return Int(self.base.longSum())
    }

    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Int {
        return Int(self.base.longMax())
    }

    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Int {
        return Int(self.base.longMin())
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        return self.base.average()
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: Values for the given property.
    public func findIntegers() -> [Int] {
        return base.findLongs().map { $0.intValue }
    }

    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    public func findInteger() -> Int? {
        return base.findLong().map { $0.intValue }
    }
}

extension PropertyQuery where T: LongPropertyType {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Int64 {
        return self.base.longSum()
    }

    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Int64 {
        return self.base.longMax()
    }

    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Int64 {
        return self.base.longMin()
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        return self.base.average()
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: Values for the given property.
    public func findLongs() -> [Int64] {
        return findInt64s()
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: Values for the given property.
    public func findInt64s() -> [Int64] {
        return base.findLongs().map { $0.int64Value }
    }

    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    public func findLong() -> Int64? {
        return findInt64()
    }

    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    public func findInt64() -> Int64? {
        return base.findLong().map { $0.int64Value }
    }
}

extension PropertyQuery where T == Int64? {
    /// - returns: `self` for chaining
    @discardableResult
    public func with(nullValue: Int64) -> PropertyQuery<EntityType, ValueType> {
        base.withNullLong(nullValue)
        return self
    }
}

extension PropertyQuery where T == Int32 {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Int {
        return Int(self.base.longSum())
    }

    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Int {
        return Int(self.base.longMax())
    }

    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Int {
        return Int(self.base.longMin())
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        return self.base.average()
    }
}

extension PropertyQuery where T == Int16 {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Int {
        return Int(self.base.longSum())
    }

    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Int {
        return Int(self.base.longMax())
    }

    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Int {
        return Int(self.base.longMin())
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        return self.base.average()
    }
}

extension PropertyQuery where T == Int8 {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Int {
        return Int(self.base.longSum())
    }

    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Int {
        return Int(self.base.longMax())
    }

    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Int {
        return Int(self.base.longMin())
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        return self.base.average()
    }
}

// MARK: - Floating Point Aggregates

extension PropertyQuery where T == Double {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Double {
        return self.base.doubleSum()
    }

    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Double {
        return self.base.doubleMax()
    }

    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Double {
        return self.base.doubleMin()
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        return self.base.average()
    }
}

extension PropertyQuery where T == Float {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Double {
        return self.base.doubleSum()
    }

    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Double {
        return self.base.doubleMax()
    }

    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Double {
        return self.base.doubleMin()
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        return self.base.average()
    }
}

// MARK: - String

extension PropertyQuery where T: StringPropertyType {
    /// - parameter caseSensitiveCompare: Specifies if ["foo", "FOO", "Foo"] counts as 1.
    /// - returns: `self` for chaining
    @discardableResult
    public func distinct(caseSensitiveCompare: Bool = true) -> PropertyQuery<EntityType, ValueType> {
        base.distinct(withCaseSensitiveCompare: caseSensitiveCompare)
        return self
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: String values for the given property.
    public func findStrings() -> [String] {
        return base.findStrings()
    }

    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    public func findString() -> String? {
        return base.findString()
    }
}

extension PropertyQuery where T == String? {
    /// Set a replacement string for `nil` results.
    ///
    /// - returns: `self` for chaining
    @discardableResult
    public func with(nullString: String) -> PropertyQuery<EntityType, ValueType> {
        base.withNullString(nullString)
        return self
    }
}
