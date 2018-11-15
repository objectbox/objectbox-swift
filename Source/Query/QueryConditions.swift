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

// QueryCondition does not wrap a core type directly. Instead, it expects a QueryBuilderAdapter during evaluation.
// The call to the QueryBuilderAdapter is specified in concrete conditions below, each calling to the adapter
// to get a OBQueryCondition from the ObjC core.
//
// This acts as a wrapper around the operators knowing how to get a OBQueryCondition, so to speak.

/// Base representation of conditions of a `Query` when you use the block-based variant.
///
/// The boolean operators `&&` and `||` use this type directly. You combine two `QueryConditions` with the boolean
/// operators into a combined condition, forming a tree structure. Conditions that target entity properties, like
/// value comparisons and equality checks, are of type `PropertyQueryCondition`.
///
/// You can form conditions and use them later, like:
///
///     let alcoholRestriction: QueryCondition<Person> = Person.age > 18 && Person.age < 80
///     // ...
///     let alcoholAllowedQuery = personBox.query {
///         return alcoholRestriction
///             || (Person.firstName == "Johnny" && Person.lastName == "Walker")
///     }
///
public class QueryCondition<E: Entity> {
    public typealias EntityType = E

    internal let expression: (QueryBuilderAdapter<E>) -> __OBXQueryCondition

    internal init(expression: @escaping (QueryBuilderAdapter<E>) -> __OBXQueryCondition) {
        self.expression = expression
    }

    internal func evaluate(queryBuilderAdapter: QueryBuilderAdapter<E>) -> __OBXQueryCondition {
        return expression(queryBuilderAdapter)
    }
}

/// Representation of comparison expression conditions of a `Query`.
///
/// All operators that target entity properties will produce this:
///
///    personBox.query { Person.age > 21 }
///
/// You can apply a short name (called _alias_, see `PropertyAlias`) to later identify specific expressions
/// using the `.=` operator. This is useful to change the values. The example above with an alias would read:
///
///    let query = personBox.query { "AgeRestriction" .= Person.age > 21 }
///    // Change the condition to `Person.age > 18`
///    query.setParameter("AgeRestriction", to: 18)
///
/// You can form conditions and use them later, like:
///
///     let alcoholRestriction: QueryCondition<Person> =
///            "MinAge" .= Person.age > 21
///         && "MaxAge" .= Person.age < 80
///     // ...
///     let alcoholAllowedQuery = personBox.query {
///         return alcoholRestriction
///             || (Person.firstName == "Johnny" && Person.lastName == "Walker")
///     }
///     alcoholAllowedQuery.setParameter("MinAge", to: 18)
///
public class PropertyQueryCondition<E: Entity, T: EntityPropertyTypeConvertible>: QueryCondition<E> {
    public typealias EntityType = E
    public typealias ValueType = T

    /// Condition alias; `nil` by default, not configuring an alias.
    internal var alias: String?

    override func evaluate(queryBuilderAdapter: QueryBuilderAdapter<E>) -> __OBXQueryCondition {
        let result = expression(queryBuilderAdapter)
        return appliedAlias(condition: result)
    }

    private func appliedAlias(condition: __OBXQueryCondition) -> __OBXQueryCondition {
        guard let alias = alias else { return condition }

        if let propertyResult = condition as? __OBXPropertyQueryCondition {
            propertyResult.alias = alias
        } else {
            assertionFailure("Expected OBXPropertyQueryCondition")
        }

        return condition
    }
}

// MARK: Operators

/// :nodoc:
public func && <E>(lhs: QueryCondition<E>, rhs: QueryCondition<E>) -> QueryCondition<E> {
    return QueryCondition<E>(expression: { adapter in
        return adapter.and(lhs.evaluate(queryBuilderAdapter: adapter),
                           rhs.evaluate(queryBuilderAdapter: adapter))
    })
}

/// :nodoc:
public func || <E>(lhs: QueryCondition<E>, rhs: QueryCondition<E>) -> QueryCondition<E> {
    return QueryCondition<E>(expression: { adapter in
        return adapter.or(lhs.evaluate(queryBuilderAdapter: adapter),
                          rhs.evaluate(queryBuilderAdapter: adapter))
    })
}

infix operator ∈ : ComparisonPrecedence
infix operator ∉ : ComparisonPrecedence

// MARK: - Id<T>

/// :nodoc:
public func == <E, T>(lhs: Property<E, Id<T>>, rhs: Id<T>)
    -> PropertyQueryCondition<E, UInt64>
    where E: Entity, T: Entity {
    return lhs.isEqual(to: rhs.value)
}

extension Property where Property.ValueType: IdBase {
    internal var entityIdProperty: Property<EntityType, EntityId> {
        return Property<EntityType, EntityId>(base: self.base)
    }

    public func isEqual(to value: EntityId)
        -> PropertyQueryCondition<EntityType, EntityId> {
            return PropertyQueryCondition(expression: {
                $0.where(self.entityIdProperty, isEqualTo: value)
            })
    }
}

// MARK: - Integer

// MARK: Int32

/// :nodoc:
public func == <E>(lhs: Property<E, Int32>, rhs: Int32)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Int32>, rhs: Int32)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Int32>, rhs: Int32)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Int32>, rhs: Int32)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int32>, rhs: Range<Int32>)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int32>, rhs: ClosedRange<Int32>)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int32>, rhs: [Int32])
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Int32>, rhs: [Int32])
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType == Int32 {
    public func isEqual(to value: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }

    public func isNotEqual(to value: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }

    public func isLessThan(_ value: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isLessThan: value) })
    }

    public func isGreaterThan(_ value: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isGreaterThan: value) })
    }

    /**
     Matches all property values between `lowerBound` and `upperBound`,
     including the bounds themselves. The order of the bounds does not matter.

     - parameter queryProperty: Entity property to compare values of.
     - parameter lowerBound: Lower limiting value, inclusive.
     - parameter upperBound: Upper limiting value, inclusive.
     - returns: `QueryCondition` describing the property match condition.
     */
    public func isBetween(_ lowerBound: Int32, and upperBound: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: {
            $0.where(self, isBetweenLowerBound: lowerBound, andUpperBound: upperBound)
        })
    }

    public func isIn(_ range: Range<Int32>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    public func isIn(_ range: ClosedRange<Int32>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    public func isIn(_ collection: [Int32])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }

    public func isNotIn(_ collection: [Int32])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection) })
    }
}

// MARK: Int64

/// :nodoc:
public func == <E>(lhs: Property<E, Int64>, rhs: Int64)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Int64>, rhs: Int64)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Int64>, rhs: Int64)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Int64>, rhs: Int64)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int64>, rhs: Range<Int64>)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int64>, rhs: ClosedRange<Int64>)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int64>, rhs: [Int64])
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Int64>, rhs: [Int64])
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType == Int64 {
    public func isEqual(to value: Int64)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }

    public func isNotEqual(to value: Int64)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }

    public func isLessThan(_ value: Int64)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isLessThan: value) })
    }

    public func isGreaterThan(_ value: Int64)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isGreaterThan: value) })
    }

    /**
     Matches all property values between `lowerBound` and `upperBound`,
     including the bounds themselves. The order of the bounds does not matter.

     - parameter queryProperty: Entity property to compare values of.
     - parameter lowerBound: Lower limiting value, inclusive.
     - parameter upperBound: Upper limiting value, inclusive.
     - returns: `QueryCondition` describing the property match condition.
     */
    public func isBetween(_ lowerBound: Int64, and upperBound: Int64)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: {
                $0.where(self, isBetweenLowerBound: lowerBound, andUpperBound: upperBound)
            })
    }

    public func isIn(_ range: Range<Int64>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    public func isIn(_ range: ClosedRange<Int64>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    public func isIn(_ collection: [Int64])
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }

    public func isNotIn(_ collection: [Int64])
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection) })
    }
}

// MARK: Int

/// :nodoc:
public func == <E>(lhs: Property<E, Int>, rhs: Int)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Int>, rhs: Int)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Int>, rhs: Int)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Int>, rhs: Int)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int>, rhs: Range<Int>)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int>, rhs: ClosedRange<Int>)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int>, rhs: [Int])
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Int>, rhs: [Int])
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType == Int {
    public func isEqual(to value: Int)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }

    public func isNotEqual(to value: Int)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }

    public func isLessThan(_ value: Int)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isLessThan: value) })
    }

    public func isGreaterThan(_ value: Int)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isGreaterThan: value) })
    }

    /**
     Matches all property values between `lowerBound` and `upperBound`,
     including the bounds themselves. The order of the bounds does not matter.

     - parameter queryProperty: Entity property to compare values of.
     - parameter lowerBound: Lower limiting value, inclusive.
     - parameter upperBound: Upper limiting value, inclusive.
     - returns: `QueryCondition` describing the property match condition.
     */
    public func isBetween(_ lowerBound: Int, and upperBound: Int)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: {
            $0.where(self, isBetweenLowerBound: lowerBound, andUpperBound: upperBound)
        })
    }

    public func isIn(_ range: Range<Int>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    public func isIn(_ range: ClosedRange<Int>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    public func isIn(_ collection: [Int])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }

    public func isNotIn(_ collection: [Int])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection) })
    }
}

// MARK: - Double

/// :nodoc:
public func < <E>(lhs: Property<E, Double>, rhs: Double)
    -> PropertyQueryCondition<E, Double>
    where E: Entity {
    return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Double>, rhs: Double)
    -> PropertyQueryCondition<E, Double>
    where E: Entity {
    return lhs.isGreaterThan(rhs)
}

extension Property where Property.ValueType == Double {
    public func isEqual(to other: Double, tolerance: Double)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: other, tolerance: tolerance) })
    }

    public func isLessThan(_ double: Double)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isLessThan: double) })
    }

    public func isGreaterThan(_ double: Double)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isGreaterThan: double) })
    }

    /**
     Matches all property values between `lowerBound` and `upperBound`,
     including the bounds themselves. The order of the bounds does not matter.

     - parameter queryProperty: Entity property to compare values of.
     - parameter lowerBound: Lower limiting value, inclusive.
     - parameter upperBound: Upper limiting value, inclusive.
     - returns: `QueryCondition` describing the property match condition.
     */
    public func isBetween(_ lowerBound: Double, and upperBound: Double)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: {
            $0.where(self, isBetweenLowerBound: lowerBound, andUpperBound: upperBound)
        })
    }
}

// MARK: - String

/// :nodoc:
public func == <E>(lhs: Property<E, String>, rhs: String)
    -> PropertyQueryCondition<E, String>
    where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, String>, rhs: String)
    -> PropertyQueryCondition<E, String>
    where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, String>, rhs: String)
    -> PropertyQueryCondition<E, String>
    where E: Entity {
    return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, String>, rhs: String)
    -> PropertyQueryCondition<E, String>
    where E: Entity {
    return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, String>, rhs: [String])
    -> PropertyQueryCondition<E, String>
    where E: Entity {
    return lhs.isIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType: StringPropertyType {
    public func isEqual(to string: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, isEqualTo: string, caseSensitive: caseSensitive) })
    }

    public func isNotEqual(to string: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, isNotEqualTo: string, caseSensitive: caseSensitive) })
    }

    public func isLessThan(_ string: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, isLessThan: string, caseSensitive: caseSensitive) })
    }

    public func isGreaterThan(_ string: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, isGreaterThan: string, caseSensitive: caseSensitive) })
    }

    public func isIn(_ collection: [String], caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, isContainedIn: collection, caseSensitive: caseSensitive) })
    }

    public func hasPrefix(_ prefix: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return startsWith(prefix, caseSensitive: caseSensitive)
    }

    public func startsWith(_ prefix: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, startsWith: prefix, caseSensitive: caseSensitive) })
    }

    public func hasSuffix(_ suffix: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return endsWith(suffix, caseSensitive: caseSensitive)
    }

    public func endsWith(_ suffix: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, endsWith: suffix, caseSensitive: caseSensitive) })
    }

    public func contains(_ substring: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, contains: substring, caseSensitive: caseSensitive)})
    }
}

// MARK: - Date

/// :nodoc:
public func == <E>(lhs: Property<E, Date>, rhs: Date)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Date>, rhs: Date)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Date>, rhs: Date)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isBefore(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Date>, rhs: Date)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isAfter(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date>, rhs: Range<Date>)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date>, rhs: ClosedRange<Date>)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date>, rhs: [Date])
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Date>, rhs: [Date])
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType == Date {
    public func isEqual(to date: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: date) })
    }

    public func isNotEqual(to date: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: date) })
    }

    /**
     Matches all property values between `lowerBound` and `upperBound`,
     including the bounds themselves. The order of the bounds does not matter.

     - parameter lowerBound: Earliest date, inclusive.
     - parameter upperBound: Latest date, inclusive.
     - returns: `QueryCondition` describing the property match condition.
     */
    public func isBetween(_ lowerBound: Date, and upperBound: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: {
            $0.where(self, isBetweenLowerBound: lowerBound, andUpperBound: upperBound)
        })
    }

    public func isIn(_ range: Range<Date>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    public func isIn(_ range: ClosedRange<Date>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    public func isIn(_ collection: [Date])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }

    public func isNotIn(_ collection: [Date])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection) })
    }

    public func isBefore(_ other: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isBefore: other) })
    }

    public func isAfter(_ other: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isAfter: other) })
    }

}
