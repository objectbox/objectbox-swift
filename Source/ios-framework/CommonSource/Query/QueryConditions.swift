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

// QueryCondition does not wrap a core type directly. Instead, it expects a QueryBuilder during evaluation.
// The call to the QueryBuilder is specified in concrete conditions below, each calling to the adapter
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
///     let alcoholAllowedQuery = try personBox.query {
///         return alcoholRestriction
///             || (Person.firstName == "Johnny" && Person.lastName == "Walker")
///     }.build()
///
public class QueryCondition<E: EntityInspectable & __EntityRelatable>
where E == E.EntityBindingType.EntityType {
    /// The type of entity this query will return.
    public typealias EntityType = E

    internal let expression: (QueryBuilder<E>) -> QueryBuilderCondition

    internal init(expression: @escaping (QueryBuilder<E>) -> QueryBuilderCondition) {
        self.expression = expression
    }

    internal func evaluate(queryBuilder: QueryBuilder<E>) -> QueryBuilderCondition {
        return expression(queryBuilder)
    }
}

/// Representation of comparison expression conditions of a `Query`.
///
/// All operators that target entity properties will produce this:
///
///     personBox.query { Person.age > 21 }
///
/// You can apply a short name (called _alias_, see `PropertyAlias`) to later identify specific expressions
/// using the `.=` operator. This is useful to change the values. The example above with an alias would read:
///
///     let query = try personBox.query { "AgeRestriction" .= Person.age > 21 }.build()
///     // Change the condition to `Person.age > 18`
///     query.setParameter("AgeRestriction", to: 18)
///
/// You can form conditions and use them later, like:
///
///      let alcoholRestriction: QueryCondition<Person> =
///              "MinAge" .= Person.age > 21
///              && "MaxAge" .= Person.age < 80
///      // ...
///      let alcoholAllowedQuery = try personBox.query {
///          return alcoholRestriction
///              || (Person.firstName == "Johnny" && Person.lastName == "Walker")
///      }.build()
///      try alcoholAllowedQuery.setParameter("MinAge", to: 18)
///
public class PropertyQueryCondition<E: EntityInspectable & __EntityRelatable, T: EntityPropertyTypeConvertible>:
    QueryCondition<E>
where E == E.EntityBindingType.EntityType {
    /// Entity type that contains the property this query condition is describing.
    public typealias EntityType = E

    /// Supported property value query condition this is describing.
    public typealias ValueType = T

    /// Condition alias; `nil` by default, not configuring an alias.
    internal var alias: String?

    override func evaluate(queryBuilder: QueryBuilder<E>) -> QueryBuilderCondition {
        let result = expression(queryBuilder)
        setQueryBuilderAliasIfNeeded(from: result)
        return result
    }

    internal func setQueryBuilderAliasIfNeeded(from condition: QueryBuilderCondition) {
        guard let alias = alias else { return }
        if condition as? PropertyQueryBuilderCondition == nil {
            assertionFailure("Expected PropertyQueryBuilderCondition")
        }
        
        obx_qb_param_alias(condition.queryBuilder, alias)
    }
}

// Not sure if that is the best approach; maybe we should not carry optional values in Property in the first place?
/// Work-around that makes the given property with an optional VALUE "non-optional" by creating a new Property.
internal func nonOptional<E, VALUE>(_ property: Property<E, VALUE?, Void>) -> Property<E, VALUE, Void> {
    return Property<E, VALUE, Void>(propertyId: property.propertyId, isPrimaryKey: property.isPrimaryKey)
}

// MARK: Operators

/// :nodoc:
public func && <E>(lhs: QueryCondition<E>, rhs: QueryCondition<E>) -> QueryCondition<E> {
    return QueryCondition<E>(expression: { adapter in
        return adapter.and([lhs.evaluate(queryBuilder: adapter),
                           rhs.evaluate(queryBuilder: adapter)])
    })
}

/// :nodoc:
public func || <E>(lhs: QueryCondition<E>, rhs: QueryCondition<E>) -> QueryCondition<E> {
    return QueryCondition<E>(expression: { adapter in
        return adapter.or([lhs.evaluate(queryBuilder: adapter),
                          rhs.evaluate(queryBuilder: adapter)])
    })
}

infix operator ∈ : ComparisonPrecedence
infix operator ∉ : ComparisonPrecedence

// MARK: - EntityId<T>

/// :nodoc:
public func == <E, T>(lhs: Property<E, EntityId<T>, T>, rhs: EntityId<T>)
    -> PropertyQueryCondition<E, UInt64>
    where E: Entity, T: Entity {
    return lhs.isEqual(to: rhs.value)
}

// TODO: Figure out why entityIdProperty is needed here, can't we just use self?
extension Property where Property.ValueType: IdBase {
    internal var entityIdProperty: Property<EntityType, Id, ReferencedType> {
        return Property<EntityType, Id, ReferencedType>(base: self.base)
    }

    /// Equivalent to the == operator in query blocks.
    public func isEqual(to value: Id)
        -> PropertyQueryCondition<EntityType, Id> {
            return PropertyQueryCondition(expression: {
                $0.where(self.entityIdProperty, isEqualTo: value)
            })
    }
}


extension Property {
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Bool

/// :nodoc:
public func == <E>(lhs: Property<E, Bool, Void>, rhs: Bool) -> PropertyQueryCondition<E, Bool> where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Bool, Void>, rhs: Bool) -> PropertyQueryCondition<E, Bool> where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func == <E>(lhs: Property<E, Bool?, Void>, rhs: Bool) -> PropertyQueryCondition<E, Bool?> where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Bool?, Void>, rhs: Bool) -> PropertyQueryCondition<E, Bool?> where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

extension Property where Property.ValueType == Bool {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to value: Bool) -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }

    /// Equivalent to the != operator in query blocks.
    public func isNotEqual(to value: Bool) -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }
}

extension Property where Property.ValueType == Bool? {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to value: Bool) -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }

    /// Equivalent to the != operator in query blocks.
    public func isNotEqual(to value: Bool) -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }
}

// MARK: FixedWidthInteger

/// :nodoc:
public func == <E, VALUE>(lhs: Property<E, VALUE, Void>, rhs: VALUE)
    -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
        return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E, VALUE>(lhs: Property<E, VALUE, Void>, rhs: VALUE)
    -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
        return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E, VALUE>(lhs: Property<E, VALUE, Void>, rhs: VALUE)
    -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
        return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E, VALUE>(lhs: Property<E, VALUE, Void>, rhs: VALUE)
    -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
        return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E, VALUE>(lhs: Property<E, VALUE, Void>, rhs: Range<VALUE>)
    -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E, VALUE>(lhs: Property<E, VALUE, Void>, rhs: ClosedRange<VALUE>)
    -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
        return lhs.isIn(rhs)
}

// :nodoc:
public func ∈ <E, VALUE>(lhs: Property<E, VALUE, Void>, rhs: [VALUE])
                -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E, VALUE>(lhs: Property<E, VALUE, Void>, rhs: [VALUE])
                -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
    return lhs.isNotIn(rhs)
}

// swiftlint:enable identifier_name

extension Property where Property.ValueType: FixedWidthInteger {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to value: ValueType)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }
    
    /// Equivalent to the != operator in query blocks.
    public func isNotEqual(to value: ValueType)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }
    
    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ value: ValueType)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isLessThan: value) })
    }
    
    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ value: ValueType) -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isGreaterThan: value) })
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: `QueryCondition` describing the property match condition.
    public func isBetween(_ lowerBound: ValueType, and upperBound: ValueType)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: {
                $0.where(self, isBetween: lowerBound, and: upperBound)
            })
    }
    
    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: ClosedRange<ValueType>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: Range<ValueType>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ collection: [ValueType])
                    -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }

    /// Equivalent to the ∉ operator in query blocks.
    public func isNotIn(_ collection: [ValueType])
                    -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection, notIn: true) })
    }
}

// MARK: Optional<FixedWidthInteger>

/// :nodoc:
public func == <E, VALUE>(lhs: Property<E, VALUE?, Void>, rhs: VALUE)
                -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
    return nonOptional(lhs).isEqual(to: rhs)
}

/// :nodoc:
public func != <E, VALUE>(lhs: Property<E, VALUE?, Void>, rhs: VALUE)
                -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
    return nonOptional(lhs).isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E, VALUE>(lhs: Property<E, VALUE?, Void>, rhs: VALUE)
                -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
    return nonOptional(lhs).isLessThan(rhs)
}

/// :nodoc:
public func > <E, VALUE>(lhs: Property<E, VALUE?, Void>, rhs: VALUE)
                -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
    return nonOptional(lhs).isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E, VALUE>(lhs: Property<E, VALUE?, Void>, rhs: Range<VALUE>)
                -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
    return nonOptional(lhs).isIn(rhs)
}

/// :nodoc:
public func ∈ <E, VALUE>(lhs: Property<E, VALUE?, Void>, rhs: ClosedRange<VALUE>)
                -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
    return nonOptional(lhs).isIn(rhs)
}

// :nodoc:
public func ∈ <E, VALUE>(lhs: Property<E, VALUE?, Void>, rhs: [VALUE])
                -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
    return nonOptional(lhs).isIn(rhs)
}

/// :nodoc:
public func ∉ <E, VALUE>(lhs: Property<E, VALUE?, Void>, rhs: [VALUE])
                -> PropertyQueryCondition<E, VALUE> where E: Entity, VALUE: FixedWidthInteger {
    return nonOptional(lhs).isNotIn(rhs)
}

// swiftlint:enable identifier_name

// MARK: - Floating point

/// :nodoc:
public func < <FP, E>(lhs: Property<E, FP, Void>, rhs: FP) -> PropertyQueryCondition<E, FP>
        where E: Entity, FP: BinaryFloatingPoint {
    return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <FP, E>(lhs: Property<E, FP, Void>, rhs: FP) -> PropertyQueryCondition<E, FP>
        where E: Entity, FP: BinaryFloatingPoint {
    return lhs.isGreaterThan(rhs)
}

/// :nodoc:
public func < <FP, E>(lhs: Property<E, FP?, Void>, rhs: FP) -> PropertyQueryCondition<E, FP>
        where E: Entity, FP: BinaryFloatingPoint {
    return nonOptional(lhs).isLessThan(rhs)
}

/// :nodoc:
public func > <FP, E>(lhs: Property<E, FP?, Void>, rhs: FP) -> PropertyQueryCondition<E, FP>
        where E: Entity, FP: BinaryFloatingPoint {
    return nonOptional(lhs).isGreaterThan(rhs)
}

extension Property where Property.ValueType: BinaryFloatingPoint {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to other: ValueType, tolerance: ValueType)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: other, tolerance: tolerance) })
    }

    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ value: ValueType)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isLessThan: value) })
    }

    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ value: ValueType)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isGreaterThan: value) })
    }

    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: `QueryCondition` describing the property match condition.
    public func isBetween(_ lowerBound: ValueType, and upperBound: ValueType)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: {
            $0.where(self, isBetween: lowerBound, and: upperBound)
        })
    }

}

// MARK: - String

/// :nodoc:
public func == <E>(lhs: Property<E, String, Void>, rhs: String) -> PropertyQueryCondition<E, String> where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, String, Void>, rhs: String) -> PropertyQueryCondition<E, String> where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, String, Void>, rhs: String) -> PropertyQueryCondition<E, String> where E: Entity {
    return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, String, Void>, rhs: String) -> PropertyQueryCondition<E, String> where E: Entity {
    return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, String, Void>, rhs: [String]) -> PropertyQueryCondition<E, String> where E: Entity {
    return lhs.isIn(rhs)
}

// swiftlint:enable identifier_name

/// :nodoc:
public func == <E>(lhs: Property<E, String?, Void>, rhs: String) -> PropertyQueryCondition<E, String?> where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, String?, Void>, rhs: String) -> PropertyQueryCondition<E, String?> where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, String?, Void>, rhs: String) -> PropertyQueryCondition<E, String?> where E: Entity {
    return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, String?, Void>, rhs: String) -> PropertyQueryCondition<E, String?> where E: Entity {
    return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, String?, Void>, rhs: [String]) -> PropertyQueryCondition<E, String?>
        where E: Entity {
    return lhs.isIn(rhs)
}

// swiftlint:enable identifier_name

extension Property where Property.ValueType: StringPropertyType {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to string: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, isEqualTo: string, caseSensitive: caseSensitive) })
    }

    /// Equivalent to the != operator in query blocks.
    public func isNotEqual(to string: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, isNotEqualTo: string, caseSensitive: caseSensitive) })
    }

    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ string: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, isLessThan: string, caseSensitive: caseSensitive) })
    }

    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ string: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, isGreaterThan: string, caseSensitive: caseSensitive) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ collection: [String], caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, isContainedIn: collection, caseSensitive: caseSensitive) })
    }

    /// Alternate name for startsWith(_,caseSensitive:).
    public func hasPrefix(_ prefix: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return startsWith(prefix, caseSensitive: caseSensitive)
    }

    /// In query blocks, use this to find prefix string matches of a property.
    public func startsWith(_ prefix: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, startsWith: prefix, caseSensitive: caseSensitive) })
    }

    /// Alternate name for endsWith(_,caseSensitive:).
    public func hasSuffix(_ suffix: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return endsWith(suffix, caseSensitive: caseSensitive)
    }

    /// In query blocks, use this to find suffix string matches of a property.
    public func endsWith(_ suffix: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, endsWith: suffix, caseSensitive: caseSensitive) })
    }

    /// In query blocks, use this to find substring matches of a property.
    public func contains(_ substring: String, caseSensitive: Bool = true)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { queryBuilder in
            queryBuilder.where(self, contains: substring, caseSensitive: caseSensitive)})
    }

}


// MARK: - Data

/// :nodoc:
public func == <E>(lhs: Property<E, Data, Void>, rhs: Data)
    -> PropertyQueryCondition<E, Data>
    where E: Entity {
        return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Data, Void>, rhs: Data)
    -> PropertyQueryCondition<E, Data>
    where E: Entity {
        return lhs.isLessThan(rhs)
}

/// :nodoc:
public func <= <E>(lhs: Property<E, Data, Void>, rhs: Data)
    -> PropertyQueryCondition<E, Data>
    where E: Entity {
        return lhs.isLessThanEqual(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Data, Void>, rhs: Data)
    -> PropertyQueryCondition<E, Data>
    where E: Entity {
        return lhs.isGreaterThan(rhs)
}

/// :nodoc:
public func >= <E>(lhs: Property<E, Data, Void>, rhs: Data)
    -> PropertyQueryCondition<E, Data>
    where E: Entity {
        return lhs.isGreaterThanEqual(rhs)
}
// swiftlint:enable identifier_name

/// :nodoc:
public func == <E>(lhs: Property<E, Data?, Void>, rhs: Data)
    -> PropertyQueryCondition<E, Data?>
    where E: Entity {
        return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Data?, Void>, rhs: Data)
    -> PropertyQueryCondition<E, Data?>
    where E: Entity {
        return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Data?, Void>, rhs: Data)
    -> PropertyQueryCondition<E, Data?>
    where E: Entity {
        return lhs.isGreaterThan(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType: DataPropertyType {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to data: Data)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { queryBuilder in
                queryBuilder.where(self, isEqualTo: data) })
    }
    
    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ data: Data)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { queryBuilder in
                queryBuilder.where(self, isLessThan: data) })
    }
    
    /// Equivalent to the <= operator in query blocks.
    public func isLessThanEqual(_ data: Data)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { queryBuilder in
                queryBuilder.where(self, isLessThanEqual: data) })
    }
    
    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ data: Data)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { queryBuilder in
                queryBuilder.where(self, isGreaterThan: data) })
    }
    
    /// Equivalent to the >= operator in query blocks.
    public func isGreaterThanEqual(_ data: Data)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { queryBuilder in
                queryBuilder.where(self, isGreaterThanEqual: data) })
    }

}

// MARK: - Date

/// :nodoc:
public func == <E>(lhs: Property<E, Date, Void>, rhs: Date)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Date, Void>, rhs: Date)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Date, Void>, rhs: Date)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isBefore(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Date, Void>, rhs: Date)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isAfter(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date, Void>, rhs: Range<Date>)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date, Void>, rhs: ClosedRange<Date>)
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date, Void>, rhs: [Date])
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Date, Void>, rhs: [Date])
    -> PropertyQueryCondition<E, Date>
    where E: Entity {
    return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType: DatePropertyType {
    public func isEqual(to date: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: date) })
    }

    public func isNotEqual(to date: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: date) })
    }

    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter lowerBound: Earliest date, inclusive.
    /// - parameter upperBound: Latest date, inclusive.
    /// - returns: `QueryCondition` describing the property match condition.
    public func isBetween(_ lowerBound: Date, and upperBound: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: {
            $0.where(self, isBetween: lowerBound, and: upperBound)
        })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: Range<Date>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: ClosedRange<Date>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ collection: [Date])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }

    /// Equivalent to the ∉ operator in query blocks.
    public func isNotIn(_ collection: [Date])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection) })
    }

    /// Equivalent to the < operator in query blocks.
    public func isBefore(_ other: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isBefore: other) })
    }

    /// Equivalent to the > operator in query blocks.
    public func isAfter(_ other: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isAfter: other) })
    }

}

// MARK: - Date?

/// :nodoc:
public func == <E>(lhs: Property<E, Date?, Void>, rhs: Date) -> PropertyQueryCondition<E, Date?> where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Date?, Void>, rhs: Date) -> PropertyQueryCondition<E, Date?> where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Date?, Void>, rhs: Date) -> PropertyQueryCondition<E, Date?> where E: Entity {
    return lhs.isBefore(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Date?, Void>, rhs: Date) -> PropertyQueryCondition<E, Date?> where E: Entity {
    return lhs.isAfter(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date?, Void>, rhs: Range<Date>) -> PropertyQueryCondition<E, Date?>
        where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date?, Void>, rhs: ClosedRange<Date>) -> PropertyQueryCondition<E, Date?>
        where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date?, Void>, rhs: [Date]) -> PropertyQueryCondition<E, Date?> where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Date?, Void>, rhs: [Date]) -> PropertyQueryCondition<E, Date?> where E: Entity {
    return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType == Date? {
    public func isEqual(to date: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: date) })
    }
    
    public func isNotEqual(to date: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: date) })
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter lowerBound: Earliest date, inclusive.
    /// - parameter upperBound: Latest date, inclusive.
    /// - returns: `QueryCondition` describing the property match condition.
    public func isBetween(_ lowerBound: Date, and upperBound: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: {
                $0.where(self, isBetween: lowerBound, and: upperBound)
            })
    }
    
    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: Range<Date>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }
    
    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: ClosedRange<Date>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }
    
    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ collection: [Date])
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }
    
    /// Equivalent to the ∉ operator in query blocks.
    public func isNotIn(_ collection: [Date])
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection) })
    }
    
    /// Equivalent to the < operator in query blocks.
    public func isBefore(_ other: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isBefore: other) })
    }
    
    /// Equivalent to the > operator in query blocks.
    public func isAfter(_ other: Date)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isAfter: other) })
    }

}
