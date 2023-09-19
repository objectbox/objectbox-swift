//
// Copyright © 2018-2020 ObjectBox Ltd. All rights reserved.
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

/// An object that describes a query. You usually interact with a QueryBuilder solely
/// via Box's `query()` method, but certain properties that can't be modified on a query
/// once it has been built (like sort order) can be configured on the QueryBuilder.
/// Call `build()` on a QueryBuilder to create an actual query object that you can request
/// objects from.

import Foundation

public final class QueryBuilder<E: EntityInspectable & __EntityRelatable>
where E == E.EntityBindingType.EntityType {
    /// The type of entity this query builder operates on.
    public typealias EntityType = E

    // TODO Use this for parameters in this class, once "Ambiguous reference to member..." is resolved
    public typealias QueryProperty<T> = Property<EntityType, T, Void> where T: EntityPropertyTypeConvertible

    internal var store: Store
    internal var queryBuilder: OpaquePointer? /*OBX_query_builder*/
    internal var nestedQueryBuilders = [OpaquePointer]() /* [OBX_query_builder] */
    internal var ownsBuilder = true
    
    internal init(store: Store, builder: OpaquePointer? = nil, ownsBuilder: Bool = true) throws {
        self.store = store
        self.ownsBuilder = ownsBuilder
        if let builder = builder {
            queryBuilder = builder
        } else {
            queryBuilder = obx_query_builder(try store.ensureCStore(), EntityType.entityInfo.entitySchemaId)
        }
        try checkLastError()
    }
    
    deinit {
        nestedQueryBuilders.forEach { obx_qb_close($0) }
        if queryBuilder != nil && ownsBuilder {
            obx_qb_close(queryBuilder)
            queryBuilder = nil
        }
    }
    
    /// Build a query from the information in this query builder, which can then be
    /// used to get actual query results from the database.
    public func build() throws -> Query<EntityType> {
        if queryBuilder == nil {
            NSException(name: NSExceptionName.internalInconsistencyException,
                        reason: "This QueryBuilder is invalid.",
                        userInfo: nil).raise()
        }
        
        let cQuery: OpaquePointer! = obx_query(queryBuilder)
        try checkLastError()
        
        return Query<EntityType>(query: cQuery, store: store)
    }
    
    /// Request that query results for an entity query be returned sorted by the given property.
    /// Can not be called after the query has been used the first time.
    ///
    /// Currently has no effect on the result of calling `query.property(...)`.
    /// - Parameter property: The property by which to sort.
    /// - Parameter flags: Additional flags to control sort behaviour, like what to do with NIL values, or to sort
    ///     descending instead of ascending.
    public func ordered<T>(by property: Property<EntityType, T, Void>, flags: [OrderFlags] = [])
                    -> QueryBuilder<EntityType> {
                        obx_qb_order(queryBuilder, property.propertyId, flags.rawValue)
        return self
    }

    /// Overload of ordered() taking a single flag only.
    public func ordered<T>(by property: Property<EntityType, T, Void>, flags: OrderFlags)
                    -> QueryBuilder<EntityType> {
        return ordered(by: property, flags: [flags])
    }

    /// Note: if a condition creator function (obx_qb_*) fails and returns 0 it is fine to proceed:
    ///       the error is tracked in the query builder and causes to throw on build()
    internal func wrap(_ cCondition: obx_qb_cond) -> PropertyQueryBuilderCondition {
        return PropertyQueryBuilderCondition(cCondition, builder: queryBuilder)
    }
}

// MARK: - Nested query builders

extension QueryBuilder {
    
    /// Used e.g. by relations in queries (aka "links") which create a new query builder.
    internal func add(nestedQueryBuilder: OpaquePointer? /* OBX_query_builder */) {
        if let nestedQueryBuilder = nestedQueryBuilder {
            nestedQueryBuilders.append(nestedQueryBuilder)
        }
    }
    
}

// MARK: - Operators

extension QueryBuilder {
    internal func and(_ conditions: [QueryBuilderCondition]) -> QueryBuilderCondition {
        var result: obx_qb_cond = 0
        let numConditions = Int(conditions.count)
        conditions.map({ $0.cCondition }).withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_all(queryBuilder, ptr.baseAddress, numConditions)
        }
        return wrap(result)
    }
    
    internal func or(_ conditions: [QueryBuilderCondition]) -> QueryBuilderCondition {
        var result: obx_qb_cond = 0
        let numConditions = Int(conditions.count)
        conditions.map({ $0.cCondition }).withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_any(queryBuilder, ptr.baseAddress, numConditions)
        }
        return wrap(result)
    }
}

// MARK: - Nullability

extension QueryBuilder {
    internal func `where`<T, R>(isNull queryProperty: Property<EntityType, T, R>) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_null(queryBuilder, queryProperty.propertyId))
    }
    
    internal func `where`<T, R>(isNotNull queryProperty: Property<EntityType, T, R>) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_not_null(queryBuilder, queryProperty.propertyId))
    }
}

// MARK: - EntityId<T>

extension QueryBuilder {
    internal func `where`<R>(_ queryProperty: Property<EntityType, Id, R>,
                             isEqualTo entityId: Id) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_equals_int(queryBuilder, queryProperty.propertyId, Int64(entityId)))
    }
    
    internal func `where`<R>(_ queryProperty: Property<EntityType, Id, R>,
                             isNotEqualTo entityId: Id) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_not_equals_int(queryBuilder, queryProperty.propertyId, Int64(entityId)))
    }
}

// MARK: FixedWidthInteger

extension QueryBuilder {

    internal func `where`<R, VALUE>(_ queryProperty: Property<EntityType, VALUE, R>, isEqualTo integer: VALUE)
                    -> PropertyQueryBuilderCondition where VALUE: FixedWidthInteger {
        return wrap(obx_qb_equals_int(queryBuilder, queryProperty.propertyId, Int64(truncatingIfNeeded: integer)))
    }

    internal func `where`<R, VALUE>(_ queryProperty: Property<EntityType, VALUE, R>, isNotEqualTo integer: VALUE)
                    -> PropertyQueryBuilderCondition where VALUE: FixedWidthInteger {
        return wrap(obx_qb_not_equals_int(queryBuilder, queryProperty.propertyId, Int64(truncatingIfNeeded: integer)))
    }

    internal func `where`<R, VALUE>(_ queryProperty: Property<EntityType, VALUE, R>, isLessThan integer: VALUE)
                    -> PropertyQueryBuilderCondition where VALUE: FixedWidthInteger {
        return wrap(obx_qb_less_than_int(queryBuilder, queryProperty.propertyId, Int64(truncatingIfNeeded: integer)))
    }

    internal func `where`<R, VALUE>(_ queryProperty: Property<EntityType, VALUE, R>, isGreaterThan integer: VALUE)
                    -> PropertyQueryBuilderCondition where VALUE: FixedWidthInteger {
        return wrap(obx_qb_greater_than_int(queryBuilder, queryProperty.propertyId, Int64(truncatingIfNeeded: integer)))
    }

    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`<R, VALUE>(_ queryProperty: Property<EntityType, VALUE, R>, isBetween lowerBound: VALUE,
                                    and upperBound: VALUE) -> PropertyQueryBuilderCondition
        where VALUE: FixedWidthInteger {
        return wrap(obx_qb_between_2ints(queryBuilder, queryProperty.propertyId,
                Int64(truncatingIfNeeded: lowerBound), Int64(truncatingIfNeeded: upperBound)))
    }

    internal func `where`<R, VALUE>(_ queryProperty: Property<EntityType, VALUE, R>, isIn range: Range<VALUE>)
                    -> PropertyQueryBuilderCondition where VALUE: FixedWidthInteger {
        let lower = Int64(truncatingIfNeeded: range.lowerBound)
        let upperValue: VALUE = VALUE.isSigned ? range.upperBound - 1 :
                /* unsigned: avoid underflow */ range.upperBound == 0 ? 0 : range.upperBound - 1
        let upper = max(Int64(upperValue), lower)
        return wrap(obx_qb_between_2ints(queryBuilder, queryProperty.propertyId, lower, upper))
    }

    internal func `where`<R, VALUE>(_ queryProperty: Property<EntityType, VALUE, R>, isIn range: ClosedRange<VALUE>)
                    -> PropertyQueryBuilderCondition where VALUE: FixedWidthInteger {
        let lower = Int64(truncatingIfNeeded: range.lowerBound)
        let upper = Int64(truncatingIfNeeded: range.upperBound)
        return wrap(obx_qb_between_2ints(queryBuilder, queryProperty.propertyId, lower, upper))
    }

    /// "IN" or "NOT IN" depending on parameter notIn
    internal func `where`<R, VALUE>(_ queryProperty: Property<EntityType, VALUE, R>, isContainedIn collection: [VALUE],
                                    notIn: Bool = false)
                    -> PropertyQueryBuilderCondition where VALUE: FixedWidthInteger {
        var result: obx_qb_cond = 0
        let numNums = Int(collection.count)
        let propertyId = queryProperty.propertyId
        let bits = VALUE.zero.bitWidth

        if bits == 64 {
            collection.withContiguousStorageIfAvailable { (ptr: UnsafeBufferPointer<VALUE>) -> Void in
                let dataPtr = UnsafePointer<Int64>(OpaquePointer(ptr.baseAddress))
                result = notIn ? obx_qb_not_in_int64s(queryBuilder, propertyId, dataPtr, numNums) :
                        obx_qb_in_int64s(queryBuilder, propertyId, dataPtr, numNums)
            }
        } else if bits == 32 {
            collection.withContiguousStorageIfAvailable { (ptr: UnsafeBufferPointer<VALUE>) -> Void in
                let dataPtr = UnsafePointer<Int32>(OpaquePointer(ptr.baseAddress))
                result = notIn ? obx_qb_not_in_int32s(queryBuilder, propertyId, dataPtr, numNums) :
                        obx_qb_in_int32s(queryBuilder, propertyId, dataPtr, numNums)
            }
        } else if false && bits < 32 { // C API does currently not support smaller types
            collection.map({ Int32(truncatingIfNeeded: $0) }).withContiguousStorageIfAvailable { (ptr) -> Void in
                result = notIn ? obx_qb_not_in_int32s(queryBuilder, propertyId, ptr.baseAddress, numNums) :
                        obx_qb_in_int32s(queryBuilder, propertyId, ptr.baseAddress, numNums)
            }
        } else {
            fatalError("Unsupported type with \(bits) bits: in/notIn currently only support 32 and 64 bit value types")
        }
        failFatallyIfError()

        return wrap(result)
    }

}

// MARK: Bool

extension QueryBuilder {
    internal func `where`<R>(_ queryProperty: Property<EntityType, Bool, R>,
                             isEqualTo value: Bool) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_equals_int(queryBuilder, queryProperty.propertyId, value ? 1 : 0))
    }
    
    internal func `where`<R>(_ queryProperty: Property<EntityType, Bool, R>,
                             isNotEqualTo value: Bool) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_not_equals_int(queryBuilder, queryProperty.propertyId, value ? 1 : 0))
    }

    internal func `where`<R>(_ queryProperty: Property<EntityType, Bool?, R>,
                             isEqualTo value: Bool) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_equals_int(queryBuilder, queryProperty.propertyId, value ? 1 : 0))
    }

    internal func `where`<R>(_ queryProperty: Property<EntityType, Bool?, R>,
                             isNotEqualTo value: Bool) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_not_equals_int(queryBuilder, queryProperty.propertyId, value ? 1 : 0))
    }
}

// MARK: - Floating points

extension QueryBuilder {
    internal func `where`<FP, R>(_ queryProperty: Property<EntityType, FP, R>, isEqualTo value: FP, tolerance: FP)
                    -> PropertyQueryBuilderCondition where FP: BinaryFloatingPoint {
        return wrap(obx_qb_between_2doubles(queryBuilder, queryProperty.propertyId, Double(value - tolerance),
                Double(value + tolerance)))
    }
    
    internal func `where`<FP, R>(_ queryProperty: Property<EntityType, FP?, R>, isEqualTo value: FP, tolerance: FP)
                    -> PropertyQueryBuilderCondition where FP: BinaryFloatingPoint {
        return wrap(obx_qb_between_2doubles(queryBuilder, queryProperty.propertyId, Double(value - tolerance),
                Double(value + tolerance)))
    }

    internal func `where`<FP, R>(_ queryProperty: Property<EntityType, FP, R>, isLessThan value: FP)
                    -> PropertyQueryBuilderCondition where FP: BinaryFloatingPoint {
        return wrap(obx_qb_less_than_double(queryBuilder, queryProperty.propertyId, Double(value)))
    }
    
    internal func `where`<FP, R>(_ queryProperty: Property<EntityType, FP?, R>, isLessThan value: FP)
                    -> PropertyQueryBuilderCondition where FP: BinaryFloatingPoint {
        return wrap(obx_qb_less_than_double(queryBuilder, queryProperty.propertyId, Double(value)))
    }

    internal func `where`<FP, R>(_ queryProperty: Property<EntityType, FP, R>, isGreaterThan value: FP)
                    -> PropertyQueryBuilderCondition where FP: BinaryFloatingPoint {
        return wrap(obx_qb_greater_than_double(queryBuilder, queryProperty.propertyId, Double(value)))
    }

    internal func `where`<FP, R>(_ queryProperty: Property<EntityType, FP?, R>, isGreaterThan value: FP)
                    -> PropertyQueryBuilderCondition where FP: BinaryFloatingPoint {
        return wrap(obx_qb_greater_than_double(queryBuilder, queryProperty.propertyId, Double(value)))
    }

    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`<FP, R>(_ property: Property<EntityType, FP, R>, isBetween lowerBound: FP, and upperBound: FP)
                    -> PropertyQueryBuilderCondition where FP: BinaryFloatingPoint {
        return wrap(obx_qb_between_2doubles(queryBuilder, property.propertyId, Double(lowerBound), Double(upperBound)))
    }

    internal func `where`<FP, R>(_ property: Property<EntityType, FP?, R>, isBetween lowerBound: FP, and upperBound: FP)
                    -> PropertyQueryBuilderCondition where FP: BinaryFloatingPoint {
        return wrap(obx_qb_between_2doubles(queryBuilder, property.propertyId, Double(lowerBound), Double(upperBound)))
    }
}

// MARK: - String and Optional<String>

extension QueryBuilder {
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                isEqualTo string: String,
                                caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            return wrap(obx_qb_equals_string(queryBuilder, queryProperty.propertyId, string, caseSensitive))
    }
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                isNotEqualTo string: String,
                                caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            return wrap(obx_qb_not_equals_string(queryBuilder, queryProperty.propertyId, string, caseSensitive))
    }
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                isLessThan string: String,
                                caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            return wrap(obx_qb_less_than_string(queryBuilder, queryProperty.propertyId, string, caseSensitive))
    }
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                isGreaterThan string: String,
                                caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            return wrap(obx_qb_greater_than_string(queryBuilder, queryProperty.propertyId, string, caseSensitive))
    }
    
    internal func `where`<S, R>(_ property: Property<EntityType, S, R>, isContainedIn collection: [String],
                                caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            var strings: [UnsafePointer?] = collection.map { str -> UnsafePointer<Int8> in
                return (str as NSString).utf8String!
            }
            var result: obx_qb_cond = 0
            let numStrings = Int(strings.count)
            strings.withContiguousMutableStorageIfAvailable { ptr -> Void in
                result = obx_qb_in_strings(queryBuilder, property.propertyId, ptr.baseAddress, numStrings,
                                           caseSensitive)
            }
            return wrap(result)
    }
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                startsWith prefix: String,
                                caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            return wrap(obx_qb_starts_with_string(queryBuilder, queryProperty.propertyId, prefix, caseSensitive))
    }
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                endsWith suffix: String,
                                caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            return wrap(obx_qb_ends_with_string(queryBuilder, queryProperty.propertyId, suffix, caseSensitive))
    }
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                contains substring: String,
                                caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            return wrap(obx_qb_contains_string(queryBuilder, queryProperty.propertyId, substring, caseSensitive))
    }
    
}

// MARK: - Data and Optional<Data>

extension QueryBuilder {
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                isEqualTo data: Data) -> PropertyQueryBuilderCondition
        where S: DataPropertyType {
            let bufferLength = data.count
            return data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> PropertyQueryBuilderCondition in
                return wrap(obx_qb_equals_bytes(queryBuilder, queryProperty.propertyId, buffer.baseAddress,
                        bufferLength))
            })
    }
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                isLessThan data: Data) -> PropertyQueryBuilderCondition
        where S: DataPropertyType {
            let bufferLength = data.count
            return data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> PropertyQueryBuilderCondition in
                return wrap(obx_qb_less_than_bytes(queryBuilder, queryProperty.propertyId, buffer.baseAddress,
                                                   bufferLength))
            })
    }

    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                isLessThanEqual data: Data) -> PropertyQueryBuilderCondition
        where S: DataPropertyType {
            let bufferLength = data.count
            return data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> PropertyQueryBuilderCondition in
                return wrap(obx_qb_less_or_equal_bytes(queryBuilder, queryProperty.propertyId, buffer.baseAddress,
                        bufferLength))
            })
    }
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                isGreaterThan data: Data) -> PropertyQueryBuilderCondition
        where S: DataPropertyType {
            let bufferLength = data.count
            return data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> PropertyQueryBuilderCondition in
                return wrap(obx_qb_greater_than_bytes(queryBuilder, queryProperty.propertyId, buffer.baseAddress,
                        bufferLength))
            })
    }
    
    internal func `where`<S, R>(_ queryProperty: Property<EntityType, S, R>,
                                isGreaterThanEqual data: Data) -> PropertyQueryBuilderCondition
        where S: DataPropertyType {
            let bufferLength = data.count
            return data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> PropertyQueryBuilderCondition in
                return wrap(obx_qb_greater_or_equal_bytes(queryBuilder, queryProperty.propertyId, buffer.baseAddress,
                        bufferLength))
            })
    }
    
}

// MARK: - Date and Optional<Date>

extension QueryBuilder {
    
    internal func `where`<D, R>(_ queryProperty: Property<EntityType, D, R>,
                                isEqualTo date: Date) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_equals_int(queryBuilder, queryProperty.propertyId, date.unixTimestamp))
    }
    
    internal func `where`<D, R>(_ queryProperty: Property<EntityType, D, R>,
                                isNotEqualTo date: Date) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_not_equals_int(queryBuilder, queryProperty.propertyId, date.unixTimestamp))
    }
    
    internal func `where`<D, R>(_ queryProperty: Property<EntityType, D, R>,
                                isBefore date: Date) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_less_than_int(queryBuilder, queryProperty.propertyId, date.unixTimestamp))
    }
    
    internal func `where`<D, R>(_ queryProperty: Property<EntityType, D, R>,
                                isAfter date: Date) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_greater_than_int(queryBuilder, queryProperty.propertyId, date.unixTimestamp))
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Earliest date, inclusive.
    /// - parameter upperBound: Latest date, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`<D, R>(_ queryProperty: Property<EntityType, D, R>,
                                isBetween lowerBound: Date,
                                and upperBound: Date) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_between_2ints(queryBuilder, queryProperty.propertyId, lowerBound.unixTimestamp,
                upperBound.unixTimestamp))
    }
    
    internal func `where`<D, R>(_ queryProperty: Property<EntityType, D, R>,
                                isIn range: Range<Date>) -> PropertyQueryBuilderCondition {
        let lower = range.lowerBound.unixTimestamp
        let upper = max(range.upperBound.unixTimestamp - 1, lower)
        return wrap(obx_qb_between_2ints(queryBuilder, queryProperty.propertyId, lower, upper))
    }
    
    internal func `where`<D, R>(_ queryProperty: Property<EntityType, D, R>,
                                isIn range: ClosedRange<Date>) -> PropertyQueryBuilderCondition {
        return wrap(obx_qb_between_2ints(queryBuilder, queryProperty.propertyId, range.lowerBound.unixTimestamp,
                range.upperBound.unixTimestamp))
    }
    
    internal func `where`<D, R>(_ queryProperty: Property<EntityType, D, R>,
                                isContainedIn collection: [Date]) -> PropertyQueryBuilderCondition {
        var result: obx_qb_cond = 0
        let dates: [Int64] = collection.map { date -> Int64 in
            return date.unixTimestamp
        }
        let numDates = Int(dates.count)
        dates.withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_in_int64s(queryBuilder, queryProperty.propertyId, ptr.baseAddress, numDates)
            failFatallyIfError()
        }
        return wrap(result)
    }
    
    internal func `where`<D, R>(_ queryProperty: Property<EntityType, D, R>,
                                isNotContainedIn collection: [Date]) -> PropertyQueryBuilderCondition {
        var result: obx_qb_cond = 0
        let dates: [Int64] = collection.map { date -> Int64 in
            return date.unixTimestamp
        }
        let numDates = Int(dates.count)
        dates.withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_not_in_int64s(queryBuilder, queryProperty.propertyId, ptr.baseAddress, numDates)
            failFatallyIfError()
        }
        return wrap(result)
    }
}

// MARK: - Queries Across Relations

public extension QueryBuilder {
    /// Adds an and-relation to another entity referenced by a ToOne property of this entity to this query.
    ///
    /// - Note: in relational databases you would use a "join" for this.
    ///
    /// - parameter property: The ToOne relation property you wish to traverse for your query.
    /// - parameter conditions: The query you want to execute on the referenced property.
    /// - returns: This object, so you can chain calls
    ///         like `orderBox.query().link(property: Order.customer) { Customer.name == "Sally Sparrow" }.build()`
    func link<V: IdBase, R>(_ property: Property<E, V, R>,
                            conditions: @escaping () -> QueryCondition<R>)
        -> QueryBuilder<E>
        where R == R.EntityBindingType.EntityType {
            let nestedQueryBuilder: OpaquePointer! = obx_qb_link_property(queryBuilder, property.propertyId)
            guard let nestedSwiftBuilder = try? QueryBuilder<R>(
                store: store,
                builder: nestedQueryBuilder,
                ownsBuilder: false) else {
                    fatalError("Failed to build query.")
            }
            let expression = conditions()
            _ = expression.evaluate(queryBuilder: nestedSwiftBuilder)
            add(nestedQueryBuilder: nestedQueryBuilder) // C-API takes care of calling build() when parent is built.
            return self
    }
    
    /// Apply the given conditions to the given C query builder and add it as a nested query builder
    /// to this query builder. Takes over ownership of the given query builder.
    private func add<V: EntityInspectable>(nestedQueryBuilder: OpaquePointer!,
                                           conditions: @escaping () -> QueryCondition<V>) {
        let nestedSwiftBuilder: QueryBuilder<V>
        do {
            nestedSwiftBuilder = try QueryBuilder<V>(
                store: store,
                builder: nestedQueryBuilder,
                ownsBuilder: false)
        } catch {
            obx_qb_close(nestedQueryBuilder)
            fatalError("Failed to build query: \(error).")
        }
        let expression = conditions()
        _ = expression.evaluate(queryBuilder: nestedSwiftBuilder)
        add(nestedQueryBuilder: nestedQueryBuilder) // C-API takes care of calling build() when parent is built.
    }
    
    /// Adds an and-relation to another entity referenced by a ToMany property of this entity to this query.
    ///
    /// Note: in relational databases you would use a "join" for this.
    ///
    /// - parameter property: The ToMany relation property you wish to traverse for your query.
    /// - parameter conditions: The query you want to execute on the referenced property.
    /// - returns: This object, so you can chain calls
    ///         like `customerBox.query().and(property: Customer.orders) { Order.name == "Paint Supplies" }.build()`
    func link<V: EntityInspectable>(_ property: ToManyProperty<V>,
                                    conditions: @escaping () -> QueryCondition<V>)
        -> QueryBuilder<E>
        where V == V.EntityBindingType.EntityType {
            let nestedQueryBuilder: OpaquePointer!
            switch property.toManyId {
            case .valuePropertyId(let propertyId):
                nestedQueryBuilder = obx_qb_backlink_property(queryBuilder,
                                                              V.entityInfo.entitySchemaId,
                                                              propertyId)
            case .relationId(let relationId):
                nestedQueryBuilder = obx_qb_link_standalone(queryBuilder, relationId)
            case .backlinkRelationId(let relationId):
                nestedQueryBuilder = obx_qb_backlink_standalone(queryBuilder, relationId)
            }
            add(nestedQueryBuilder: nestedQueryBuilder, conditions: conditions)
            return self
    }
}
