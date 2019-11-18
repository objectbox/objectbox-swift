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
///     try query.setParameter("AgeRestriction", to: 18)
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

// MARK: - Integer

// MARK: Int8

/// :nodoc:
public func == <E>(lhs: Property<E, Int8, Void>, rhs: Int8)
    -> PropertyQueryCondition<E, Int8>
    where E: Entity {
        return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Int8, Void>, rhs: Int8)
    -> PropertyQueryCondition<E, Int8>
    where E: Entity {
        return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Int8, Void>, rhs: Int8)
    -> PropertyQueryCondition<E, Int8>
    where E: Entity {
        return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Int8, Void>, rhs: Int8)
    -> PropertyQueryCondition<E, Int8>
    where E: Entity {
        return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int8, Void>, rhs: Range<Int8>)
    -> PropertyQueryCondition<E, Int8>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int8, Void>, rhs: ClosedRange<Int8>)
    -> PropertyQueryCondition<E, Int8>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int8, Void>, rhs: [Int8])
    -> PropertyQueryCondition<E, Int8>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Int8, Void>, rhs: [Int8])
    -> PropertyQueryCondition<E, Int8>
    where E: Entity {
        return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType == Int8 {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to value: Int8)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }
    
    /// Equivalent to the != operator in query blocks.
    public func isNotEqual(to value: Int8)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }
    
    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ value: Int8)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isLessThan: value) })
    }
    
    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ value: Int8)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isGreaterThan: value) })
    }
    
    /// Equivalent to the <= operator in query blocks.
    public func isLessThanEqual(_ value: Int8)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isBetween: Int8.min, and: value) })
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: `QueryCondition` describing the property match condition.
    public func isBetween(_ lowerBound: Int8, and upperBound: Int8)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: {
                $0.where(self, isBetween: lowerBound, and: upperBound)
            })
    }
    
    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: Range<Int8>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }
    
    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: ClosedRange<Int8>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }
    
    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ collection: [Int8])
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection.map { Int8($0) }) })
    }
    
    /// Equivalent to the ∉ operator in query blocks.
    public func isNotIn(_ collection: [Int8])
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection.map { Int8($0) }) })
    }

    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Int8?

extension Property where Property.ValueType == Int8? {
    /// Test whether an Int8 optional `Int8?` is `nil`, in a query on a property.
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Int16

/// :nodoc:
public func == <E>(lhs: Property<E, Int16, Void>, rhs: Int16)
    -> PropertyQueryCondition<E, Int16>
    where E: Entity {
        return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Int16, Void>, rhs: Int16)
    -> PropertyQueryCondition<E, Int16>
    where E: Entity {
        return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Int16, Void>, rhs: Int16)
    -> PropertyQueryCondition<E, Int16>
    where E: Entity {
        return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Int16, Void>, rhs: Int16)
    -> PropertyQueryCondition<E, Int16>
    where E: Entity {
        return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int16, Void>, rhs: Range<Int16>)
    -> PropertyQueryCondition<E, Int16>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int16, Void>, rhs: ClosedRange<Int16>)
    -> PropertyQueryCondition<E, Int16>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int16, Void>, rhs: [Int16])
    -> PropertyQueryCondition<E, Int16>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Int16, Void>, rhs: [Int16])
    -> PropertyQueryCondition<E, Int16>
    where E: Entity {
        return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType == Int16 {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to value: Int16)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }
    
    /// Equivalent to the != operator in query blocks.
    public func isNotEqual(to value: Int16)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }
    
    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ value: Int16)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isLessThan: value) })
    }
    
    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ value: Int16)
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
    public func isBetween(_ lowerBound: Int16, and upperBound: Int16)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: {
                $0.where(self, isBetween: lowerBound, and: upperBound)
            })
    }
    
    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: Range<Int16>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }
    
    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: ClosedRange<Int16>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }
    
    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ collection: [Int16])
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }
    
    /// Equivalent to the ∉ operator in query blocks.
    public func isNotIn(_ collection: [Int16])
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection) })
    }

    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Int16?

extension Property where Property.ValueType == Int16? {
    /// Test whether an Int16 optional `Int16?` is `nil`, in a query on a property.
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int16 optional `Int16?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Int32

/// :nodoc:
public func == <E>(lhs: Property<E, Int32, Void>, rhs: Int32)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Int32, Void>, rhs: Int32)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Int32, Void>, rhs: Int32)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Int32, Void>, rhs: Int32)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int32, Void>, rhs: Range<Int32>)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int32, Void>, rhs: ClosedRange<Int32>)
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int32, Void>, rhs: [Int32])
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Int32, Void>, rhs: [Int32])
    -> PropertyQueryCondition<E, Int32>
    where E: Entity {
    return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType == Int32 {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to value: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }

    /// Equivalent to the != operator in query blocks.
    public func isNotEqual(to value: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }

    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ value: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isLessThan: value) })
    }

    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ value: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isGreaterThan: value) })
    }
    
    /// Equivalent to the <= operator in query blocks.
    public func isLessThanEqual(_ value: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isBetween: Int32.min, and: value) })
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: `QueryCondition` describing the property match condition.
    public func isBetween(_ lowerBound: Int32, and upperBound: Int32)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: {
            $0.where(self, isBetween: lowerBound, and: upperBound)
        })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: Range<Int32>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: ClosedRange<Int32>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ collection: [Int32])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }

    /// Equivalent to the ∉ operator in query blocks.
    public func isNotIn(_ collection: [Int32])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection) })
    }

    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Int32?

extension Property where Property.ValueType == Int32? {
    /// Test whether an Int32 optional `Int32?` is `nil`, in a query on a property.
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int32 optional `Int32?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Int64

/// :nodoc:
public func == <E, R>(lhs: Property<E, Int64, R>, rhs: Int64)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E, R>(lhs: Property<E, Int64, R>, rhs: Int64)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E, R>(lhs: Property<E, Int64, R>, rhs: Int64)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E, R>(lhs: Property<E, Int64, R>, rhs: Int64)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E, R>(lhs: Property<E, Int64, R>, rhs: Range<Int64>)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E, R>(lhs: Property<E, Int64, R>, rhs: ClosedRange<Int64>)
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E, R>(lhs: Property<E, Int64, R>, rhs: [Int64])
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E, R>(lhs: Property<E, Int64, R>, rhs: [Int64])
    -> PropertyQueryCondition<E, Int64>
    where E: Entity {
        return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType == Int64 {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to value: Int64)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }

    /// Equivalent to the != operator in query blocks.
    public func isNotEqual(to value: Int64)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }

    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ value: Int64)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isLessThan: value) })
    }

    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ value: Int64)
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
    public func isBetween(_ lowerBound: Int64, and upperBound: Int64)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: {
                $0.where(self, isBetween: lowerBound, and: upperBound)
            })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: Range<Int64>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: ClosedRange<Int64>)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ collection: [Int64])
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }

    /// Equivalent to the ∉ operator in query blocks.
    public func isNotIn(_ collection: [Int64])
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection) })
    }

    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Int64?

extension Property where Property.ValueType == Int64? {
    /// Test whether an Int64 optional `Int64?` is `nil`, in a query on a property.
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int64 optional `Int64?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Int

/// :nodoc:
public func == <E>(lhs: Property<E, Int, Void>, rhs: Int)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Int, Void>, rhs: Int)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Int, Void>, rhs: Int)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Int, Void>, rhs: Int)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int, Void>, rhs: Range<Int>)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int, Void>, rhs: ClosedRange<Int>)
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Int, Void>, rhs: [Int])
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Int, Void>, rhs: [Int])
    -> PropertyQueryCondition<E, Int>
    where E: Entity {
    return lhs.isNotIn(rhs)
}
// swiftlint:enable identifier_name

extension Property where Property.ValueType == Int {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to value: Int)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: value) })
    }

    /// Equivalent to the != operator in query blocks.
    public func isNotEqual(to value: Int)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotEqualTo: value) })
    }

    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ value: Int)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isLessThan: value) })
    }

    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ value: Int)
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
    public func isBetween(_ lowerBound: Int, and upperBound: Int)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: {
            $0.where(self, isBetween: lowerBound, and: upperBound)
        })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: Range<Int>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ range: ClosedRange<Int>)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isIn: range) })
    }

    /// Equivalent to the ∈ operator in query blocks.
    public func isIn(_ collection: [Int])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isContainedIn: collection) })
    }

    /// Equivalent to the ∉ operator in query blocks.
    public func isNotIn(_ collection: [Int])
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isNotContainedIn: collection) })
    }

    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Int?

extension Property where Property.ValueType == Int? {
    /// Test whether an Int optional `Int?` is `nil`, in a query on a property.
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int optional `Int?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: - Double

/// :nodoc:
public func < <E>(lhs: Property<E, Double, Void>, rhs: Double)
    -> PropertyQueryCondition<E, Double>
    where E: Entity {
    return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Double, Void>, rhs: Double)
    -> PropertyQueryCondition<E, Double>
    where E: Entity {
    return lhs.isGreaterThan(rhs)
}

extension Property where Property.ValueType == Double {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to other: Double, tolerance: Double)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: other, tolerance: tolerance) })
    }

    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ double: Double)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isLessThan: double) })
    }

    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ double: Double)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(self, isGreaterThan: double) })
    }

    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: `QueryCondition` describing the property match condition.
    public func isBetween(_ lowerBound: Double, and upperBound: Double)
        -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: {
            $0.where(self, isBetween: lowerBound, and: upperBound)
        })
    }

    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Double?

extension Property where Property.ValueType == Double? {
    /// Test whether an Double optional `Double?` is `nil`, in a query on a property.
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Double optional `Double?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: - Float

/// :nodoc:
public func < <E>(lhs: Property<E, Float, Void>, rhs: Float)
    -> PropertyQueryCondition<E, Float>
    where E: Entity {
        return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Float, Void>, rhs: Float)
    -> PropertyQueryCondition<E, Float>
    where E: Entity {
        return lhs.isGreaterThan(rhs)
}

extension Property where Property.ValueType == Float {
    /// Equivalent to the == operator in query blocks.
    public func isEqual(to other: Float, tolerance: Float)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isEqualTo: other, tolerance: tolerance) })
    }
    
    /// Equivalent to the < operator in query blocks.
    public func isLessThan(_ double: Float)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isLessThan: double) })
    }
    
    /// Equivalent to the > operator in query blocks.
    public func isGreaterThan(_ double: Float)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: { $0.where(self, isGreaterThan: double) })
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: `QueryCondition` describing the property match condition.
    public func isBetween(_ lowerBound: Float, and upperBound: Float)
        -> PropertyQueryCondition<EntityType, ValueType> {
            return PropertyQueryCondition(expression: {
                $0.where(self, isBetween: lowerBound, and: upperBound)
            })
    }

    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Float?

extension Property where Property.ValueType == Float? {
    /// Test whether an Float optional `Float?` is `nil`, in a query on a property.
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Float optional `Float?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}


// MARK: - String

/// :nodoc:
public func == <E>(lhs: Property<E, String, Void>, rhs: String)
    -> PropertyQueryCondition<E, String>
    where E: Entity {
        return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, String, Void>, rhs: String)
    -> PropertyQueryCondition<E, String>
    where E: Entity {
        return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, String, Void>, rhs: String)
    -> PropertyQueryCondition<E, String>
    where E: Entity {
        return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, String, Void>, rhs: String)
    -> PropertyQueryCondition<E, String>
    where E: Entity {
        return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, String, Void>, rhs: [String])
    -> PropertyQueryCondition<E, String>
    where E: Entity {
        return lhs.isIn(rhs)
}
// swiftlint:enable identifier_name

/// :nodoc:
public func == <E>(lhs: Property<E, String?, Void>, rhs: String)
    -> PropertyQueryCondition<E, String?>
    where E: Entity {
        return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, String?, Void>, rhs: String)
    -> PropertyQueryCondition<E, String?>
    where E: Entity {
        return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, String?, Void>, rhs: String)
    -> PropertyQueryCondition<E, String?>
    where E: Entity {
        return lhs.isLessThan(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, String?, Void>, rhs: String)
    -> PropertyQueryCondition<E, String?>
    where E: Entity {
        return lhs.isGreaterThan(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, String?, Void>, rhs: [String])
    -> PropertyQueryCondition<E, String?>
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

    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: String?

extension Property where Property.ValueType == String? {
    /// Test whether a String optional `String?` is `nil`, in a query on a property.
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a String optional `String?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
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
    
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Data?

extension Property where Property.ValueType == Data? {
    /// Test whether a Data optional `Data?` is `nil`, in a query on a property.
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Data optional `Data?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
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

    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: - Date?

/// :nodoc:
public func == <E>(lhs: Property<E, Date?, Void>, rhs: Date)
    -> PropertyQueryCondition<E, Date?>
    where E: Entity {
        return lhs.isEqual(to: rhs)
}

/// :nodoc:
public func != <E>(lhs: Property<E, Date?, Void>, rhs: Date)
    -> PropertyQueryCondition<E, Date?>
    where E: Entity {
        return lhs.isNotEqual(to: rhs)
}

/// :nodoc:
public func < <E>(lhs: Property<E, Date?, Void>, rhs: Date)
    -> PropertyQueryCondition<E, Date?>
    where E: Entity {
        return lhs.isBefore(rhs)
}

/// :nodoc:
public func > <E>(lhs: Property<E, Date?, Void>, rhs: Date)
    -> PropertyQueryCondition<E, Date?>
    where E: Entity {
        return lhs.isAfter(rhs)
}

// swiftlint:disable identifier_name
/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date?, Void>, rhs: Range<Date>)
    -> PropertyQueryCondition<E, Date?>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date?, Void>, rhs: ClosedRange<Date>)
    -> PropertyQueryCondition<E, Date?>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∈ <E>(lhs: Property<E, Date?, Void>, rhs: [Date])
    -> PropertyQueryCondition<E, Date?>
    where E: Entity {
        return lhs.isIn(rhs)
}

/// :nodoc:
public func ∉ <E>(lhs: Property<E, Date?, Void>, rhs: [Date])
    -> PropertyQueryCondition<E, Date?>
    where E: Entity {
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
    
    public func isNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNull: self) })
    }
    
    /// Test whether a Int8 optional `Int8?` contains a value, not `nil`, in a query on a property.
    public func isNotNil() -> PropertyQueryCondition<EntityType, ValueType> {
        return PropertyQueryCondition(expression: { $0.where(isNotNull: self) })
    }
}

// MARK: Date?
