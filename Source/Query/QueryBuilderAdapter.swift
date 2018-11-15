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

// Provides the functionality to express query conditions in a way that is understood
// by the more clumsy C++/ObjC API.
//
// Look at QueryConditions to see how a native Swift API uses the adapter to call down to the core.
//
// Still, all supported property types and their query methods will be defined here.

internal final class QueryBuilderAdapter<E: Entity> {
    internal typealias EntityType = E

    internal let base: __OBXQueryBuilderAdapter

    internal init(base: __OBXQueryBuilderAdapter) {
        self.base = base
    }

    internal func build() -> Query<EntityType> {
        return Query<EntityType>(base: base.build())
    }
}

// MARK: - Operators

extension QueryBuilderAdapter {

    internal func and(_ condition: __OBXQueryCondition, _ conditions: __OBXQueryCondition ...) -> __OBXQueryCondition {
        var result = [condition]
        result.append(contentsOf: conditions)
        return base.and(result)
    }

    internal func or(_ condition: __OBXQueryCondition, _ conditions: __OBXQueryCondition ...) -> __OBXQueryCondition {
        var result = [condition]
        result.append(contentsOf: conditions)
        return base.or(result)
    }

}

// MARK: - Nullability

extension QueryBuilderAdapter {

    internal func `where`<T>(isNull queryProperty: Property<EntityType, T>) -> __OBXPropertyQueryCondition {
        return base.wherePropertyIsNull(queryProperty.base)
    }

    internal func `where`<T>(isNotNull queryProperty: Property<EntityType, T>) -> __OBXPropertyQueryCondition {
        return base.wherePropertyIsNotNull(queryProperty.base)
    }

}

// MARK: - Id<T>

extension QueryBuilderAdapter {

    internal func `where`(_ queryProperty: Property<EntityType, EntityId>,
                          isEqualTo entityId: EntityId) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isEqualTo: Int64(bitPattern: entityId))
    }

}

// MARK: - Integers
// MARK: Int64

extension QueryBuilderAdapter {

    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isEqualTo integer: Int64) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isEqualTo: integer)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isNotEqualTo integer: Int64) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isNotEqualTo: integer)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isLessThan integer: Int64) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isLessThan: integer)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isGreaterThan integer: Int64) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isGreaterThan: integer)
    }

    /**
     Matches all property values between `lowerBound` and `upperBound`,
     including the bounds themselves. The order of the bounds does not matter.

     - parameter queryProperty: Entity property to compare values of.
     - parameter lowerBound: Lower limiting value, inclusive.
     - parameter upperBound: Upper limiting value, inclusive.
     - returns: Same `QueryBuilder` instance after applying the condition.
     */
    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isBetweenLowerBound lowerBound: Int64,
                          andUpperBound upperBound: Int64) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isBetween: lowerBound, and: upperBound)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isIn range: Range<Int64>) -> __OBXPropertyQueryCondition {
        return self.where(
            queryProperty,
            isBetweenLowerBound: range.lowerBound,
            andUpperBound: max(range.upperBound - 1, range.lowerBound))
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isIn range: ClosedRange<Int64>) -> __OBXPropertyQueryCondition {
        return self.where(
            queryProperty,
            isBetweenLowerBound: range.lowerBound,
            andUpperBound: range.upperBound)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isContainedIn collection: [Int64]) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isContainedIn: collection as [NSNumber])
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isNotContainedIn collection: [Int64]) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isNotContainedIn: collection as [NSNumber])
    }

}

// MARK: Int32

extension QueryBuilderAdapter {

    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isEqualTo integer: Int32) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isEqualTo: integer)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isNotEqualTo integer: Int32) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isNotEqualTo: integer)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isLessThan integer: Int32) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isLessThan: integer)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isGreaterThan integer: Int32) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isGreaterThan: integer)
    }

    /**
     Matches all property values between `lowerBound` and `upperBound`,
     including the bounds themselves. The order of the bounds does not matter.

     - parameter queryProperty: Entity property to compare values of.
     - parameter lowerBound: Lower limiting value, inclusive.
     - parameter upperBound: Upper limiting value, inclusive.
     - returns: Same `QueryBuilder` instance after applying the condition.
     */
    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isBetweenLowerBound lowerBound: Int32,
                          andUpperBound upperBound: Int32) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isBetween: lowerBound, and: upperBound)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isIn range: Range<Int32>) -> __OBXPropertyQueryCondition {
        return self.where(
            queryProperty,
            isBetweenLowerBound: range.lowerBound,
            andUpperBound: max(range.upperBound - 1, range.lowerBound))
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isIn range: ClosedRange<Int32>) -> __OBXPropertyQueryCondition {
        return self.where(
            queryProperty,
            isBetweenLowerBound: range.lowerBound,
            andUpperBound: range.upperBound)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isContainedIn collection: [Int32]) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isContainedIn: collection as [NSNumber])
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isNotContainedIn collection: [Int32]) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isNotContainedIn: collection as [NSNumber])
    }

}

// MARK: Int

extension QueryBuilderAdapter {

    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isEqualTo integer: Int) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isEqualTo: Int64(integer))
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isNotEqualTo integer: Int) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isNotEqualTo: Int64(integer))
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isLessThan integer: Int) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isLessThan: Int64(integer))
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isGreaterThan integer: Int) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isGreaterThan: Int64(integer))
    }

    /**
     Matches all property values between `lowerBound` and `upperBound`,
     including the bounds themselves. The order of the bounds does not matter.

     - parameter queryProperty: Entity property to compare values of.
     - parameter lowerBound: Lower limiting value, inclusive.
     - parameter upperBound: Upper limiting value, inclusive.
     - returns: Same `QueryBuilder` instance after applying the condition.
     */
    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isBetweenLowerBound lowerBound: Int,
                          andUpperBound upperBound: Int) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isBetween: Int64(lowerBound), and: Int64(upperBound))
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isIn range: Range<Int>) -> __OBXPropertyQueryCondition {
        return self.where(
            queryProperty,
            isBetweenLowerBound: range.lowerBound,
            andUpperBound: max(range.upperBound - 1, range.lowerBound))
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isIn range: ClosedRange<Int>) -> __OBXPropertyQueryCondition {
        return self.where(
            queryProperty,
            isBetweenLowerBound: range.lowerBound,
            andUpperBound: range.upperBound)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isContainedIn collection: [Int]) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isContainedIn: collection as [NSNumber])
    }

    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isNotContainedIn collection: [Int]) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isNotContainedIn: collection as [NSNumber])
    }

}

// MARK: - Floating points
// MARK: Double

extension QueryBuilderAdapter {

    internal func `where`(_ queryProperty: Property<EntityType, Double>,
                          isEqualTo value: Double, tolerance: Double) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isEqualTo: value, tolerance: tolerance)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Double>,
                          isLessThan value: Double) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isLessThan: value)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Double>,
                          isGreaterThan value: Double) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isGreaterThan: value)
    }

    /**
     Matches all property values between `lowerBound` and `upperBound`,
     including the bounds themselves. The order of the bounds does not matter.

     - parameter queryProperty: Entity property to compare values of.
     - parameter lowerBound: Lower limiting value, inclusive.
     - parameter upperBound: Upper limiting value, inclusive.
     - returns: Same `QueryBuilder` instance after applying the condition.
     */
    internal func `where`(_ queryProperty: Property<EntityType, Double>,
                          isBetweenLowerBound lowerBound: Double,
                          andUpperBound upperBound: Double) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isBetween: lowerBound, and: upperBound)
    }

}

// MARK: - String and Optional<String>

extension QueryBuilderAdapter {

    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isEqualTo string: String,
                             caseSensitive: Bool = true) -> __OBXPropertyQueryCondition
        where S: StringPropertyType {
            return base.where(property: queryProperty.base, isEqualTo: string, caseSensitive: caseSensitive)
    }

    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isNotEqualTo string: String,
                             caseSensitive: Bool = true) -> __OBXPropertyQueryCondition
        where S: StringPropertyType {
            return base.where(property: queryProperty.base, isNotEqualTo: string, caseSensitive: caseSensitive)
    }

    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isLessThan string: String,
                             caseSensitive: Bool = true) -> __OBXPropertyQueryCondition
        where S: StringPropertyType {
            return base.where(property: queryProperty.base, isLessThan: string, caseSensitive: caseSensitive)
    }

    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isGreaterThan string: String,
                             caseSensitive: Bool = true) -> __OBXPropertyQueryCondition
        where S: StringPropertyType {
            return base.where(property: queryProperty.base, isGreaterThan: string, caseSensitive: caseSensitive)
    }

    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isContainedIn collection: [String],
                             caseSensitive: Bool = true) -> __OBXPropertyQueryCondition
        where S: StringPropertyType {
            return base.where(property: queryProperty.base, isContainedIn: collection, caseSensitive: caseSensitive)
    }

    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             startsWith prefix: String,
                             caseSensitive: Bool = true) -> __OBXPropertyQueryCondition
        where S: StringPropertyType {
            return base.where(property: queryProperty.base, startsWith: prefix, caseSensitive: caseSensitive)
    }

    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             endsWith suffix: String,
                             caseSensitive: Bool = true) -> __OBXPropertyQueryCondition
        where S: StringPropertyType {
            return base.where(property: queryProperty.base, endsWith: suffix, caseSensitive: caseSensitive)
    }

    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             contains substring: String,
                             caseSensitive: Bool = true) -> __OBXPropertyQueryCondition
        where S: StringPropertyType {
        return base.where(property: queryProperty.base, contains: substring, caseSensitive: caseSensitive)
    }

}

// MARK: - Date

extension QueryBuilderAdapter {

    internal func `where`(_ queryProperty: Property<EntityType, Date>,
                          isEqualTo date: Date) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isEqualTo: date)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Date>,
                          isNotEqualTo date: Date) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isNotEqualTo: date)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Date>,
                          isBefore date: Date) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isBefore: date)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Date>,
                          isAfter date: Date) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isAfter: date)
    }

    /**
     Matches all property values between `lowerBound` and `upperBound`,
     including the bounds themselves. The order of the bounds does not matter.

     - parameter queryProperty: Entity property to compare values of.
     - parameter lowerBound: Earliest date, inclusive.
     - parameter upperBound: Latest date, inclusive.
     - returns: Same `QueryBuilder` instance after applying the condition.
     */
    internal func `where`(_ queryProperty: Property<EntityType, Date>,
                          isBetweenLowerBound lowerBound: Date,
                          andUpperBound upperBound: Date) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isBetween: lowerBound, and: upperBound)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Date>,
                          isIn range: Range<Date>) -> __OBXPropertyQueryCondition {
        return self.where(
            queryProperty,
            isBetweenLowerBound: range.lowerBound,
            andUpperBound: max(range.upperBound - 1, range.lowerBound))
    }

    internal func `where`(_ queryProperty: Property<EntityType, Date>,
                          isIn range: ClosedRange<Date>) -> __OBXPropertyQueryCondition {
        return self.where(
            queryProperty,
            isBetweenLowerBound: range.lowerBound,
            andUpperBound: range.upperBound)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Date>,
                          isContainedIn collection: [Date]) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isContainedIn: collection)
    }

    internal func `where`(_ queryProperty: Property<EntityType, Date>,
                          isNotContainedIn collection: [Date]) -> __OBXPropertyQueryCondition {
        return base.where(property: queryProperty.base, isNotContainedIn: collection)
    }
}
