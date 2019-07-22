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

/// An object that describes a query. You usually interact with a QueryBuilder solely
/// via Box's `query()` method, but certain properties that can't be modified on a query
/// once it has been built (like sort order) can be configured on the QueryBuilder.
/// Call `build()` on a QueryBuilder to create an actual query object that you can request
/// objects from.

public final class QueryBuilder<E: EntityInspectable & __EntityRelatable>
where E == E.EntityBindingType.EntityType {
    public typealias EntityType = E
    
    internal var store: Store
    internal var queryBuilder: OpaquePointer? /*OBX_query_builder*/

    internal init(store: Store) throws {
        self.store = store
        queryBuilder = obx_qb_create(store.cStore, EntityType.entityInfo.entitySchemaId)
        try checkLastError()
    }
    
    deinit {
        if queryBuilder != nil {
            obx_qb_close(queryBuilder)
            queryBuilder = nil
        }
    }
    
    /// Build a query from the information in this query builder, which can then be
    /// used to get actual query results from the database.
    public func build() -> Query<EntityType> {
        if queryBuilder == nil {
            NSException(name: NSExceptionName.internalInconsistencyException,
                        reason: "This QueryBuilder is invalid.",
                        userInfo: nil).raise()
        }
        
        let cQuery: OpaquePointer! = obx_query_create(queryBuilder)
        do {
            try checkLastError()
        } catch {
            ignoreAndLog(error: error)
        }

        return Query<EntityType>(query: cQuery, store: store)
    }
    
    /// Request that query results for an entity query be returned sorted by the given property.
    /// Can not be called after the query has been used the first time.
    /// Currently has no effect on the result of calling query.property(...).
    /// - Parameter property: The property by which to sort.
    /// - Parameter flags: Additional flags to control sort behaviour, like what to do with NIL values, or to sort
    ///     descending instead of ascending.
    public func ordered<T>(by property: Property<EntityType, T>, flags: OBXOrderFlags = [])
        -> QueryBuilder<EntityType> {
            obx_qb_order(queryBuilder, property.propertyId, flags)
            
            return self
    }
}

// MARK: - Operators

extension QueryBuilder {
    internal func and(_ conditions: [QueryBuilderCondition]) -> QueryBuilderCondition {
        var result: obx_qb_cond = 0
        let numConditions = Int32(conditions.count)
        conditions.map({ $0.cCondition }).withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_all(queryBuilder, ptr.baseAddress, numConditions)
        }
        return QueryBuilderCondition(result, builder: queryBuilder)
        
    }
    
    internal func or(_ conditions: [QueryBuilderCondition]) -> QueryBuilderCondition {
        var result: obx_qb_cond = 0
        let numConditions = Int32(conditions.count)
        conditions.map({ $0.cCondition }).withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_any(queryBuilder, ptr.baseAddress, numConditions)
        }
        return QueryBuilderCondition(result, builder: queryBuilder)
    }
}

// MARK: - Nullability

extension QueryBuilder {
    internal func `where`<T>(isNull queryProperty: Property<EntityType, T>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_null(queryBuilder, property.propertyId), builder: queryBuilder)
    }
    
    internal func `where`<T>(isNotNull queryProperty: Property<EntityType, T>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_not_null(queryBuilder, property.propertyId), builder: queryBuilder)
    }
}

// MARK: - Id<T>

extension QueryBuilder {
    internal func `where`(_ queryProperty: Property<EntityType, EntityId>,
                          isEqualTo entityId: EntityId) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_equal(queryBuilder, property.propertyId, Int64(entityId)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, EntityId>,
                          isNotEqualTo entityId: EntityId) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_not_equal(queryBuilder, property.propertyId, Int64(entityId)),
                                             builder: queryBuilder)
    }
}

// MARK: - Integers
// MARK: Int64

extension QueryBuilder {
    
    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isEqualTo integer: Int64) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_equal(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isNotEqualTo integer: Int64) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_not_equal(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isLessThan integer: Int64) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_less(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isGreaterThan integer: Int64) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_greater(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isBetween lowerBound: Int64,
                          and upperBound: Int64) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId, Int64(lowerBound),
                                                                Int64(upperBound)), builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isIn range: Range<Int64>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId, range.lowerBound,
                                                                max(range.upperBound - 1, range.lowerBound)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isIn range: ClosedRange<Int64>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId, range.lowerBound,
                                                                range.upperBound), builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isContainedIn collection: [Int64]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let numNums = Int32(collection.count)
        collection.withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int64_in(queryBuilder, property.propertyId, ptr.baseAddress, numNums)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int64>,
                          isNotContainedIn collection: [Int64]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let numNums = Int32(collection.count)
        collection.withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int64_not_in(queryBuilder, property.propertyId, ptr.baseAddress, numNums)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
    
}

// MARK: Int32

extension QueryBuilder {
    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isEqualTo integer: Int32) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_equal(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isNotEqualTo integer: Int32) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_not_equal(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isLessThan integer: Int32) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_less(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isGreaterThan integer: Int32) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_greater(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isBetween lowerBound: Int32,
                          and upperBound: Int32) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId, Int64(lowerBound),
                                                                Int64(upperBound)), builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isIn range: Range<Int32>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                Int64(range.lowerBound),
                                                                Int64(max(range.upperBound - 1, range.lowerBound))),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isIn range: ClosedRange<Int32>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                Int64(range.lowerBound), Int64(range.upperBound)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isContainedIn collection: [Int32]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let numNums = Int32(collection.count)
        collection.withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int32_in(queryBuilder, property.propertyId, ptr.baseAddress, numNums)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int32>,
                          isNotContainedIn collection: [Int32]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let numNums = Int32(collection.count)
        collection.withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int32_not_in(queryBuilder, property.propertyId, ptr.baseAddress, numNums)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
}

// MARK: Int8

extension QueryBuilder {
    internal func `where`(_ queryProperty: Property<EntityType, Int8>,
                          isEqualTo integer: Int8) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_equal(queryBuilder, property.propertyId,
                                                              Int64(integer)), builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int8>,
                          isNotEqualTo integer: Int8) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_not_equal(queryBuilder, property.propertyId,
                                                                  Int64(integer)), builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int8>,
                          isLessThan integer: Int8) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_less(queryBuilder, property.propertyId,
                                                             Int64(integer)), builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int8>,
                          isGreaterThan integer: Int8) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_greater(queryBuilder, property.propertyId,
                                                                Int64(integer)), builder: queryBuilder)
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`(_ queryProperty: Property<EntityType, Int8>,
                          isBetween lowerBound: Int8,
                          and upperBound: Int8) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                Int64(lowerBound), Int64(upperBound)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int8>,
                          isIn range: Range<Int8>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                Int64(range.lowerBound),
                                                                Int64(max(range.upperBound - 1, range.lowerBound))),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int8>,
                          isIn range: ClosedRange<Int8>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                Int64(range.lowerBound), Int64(range.upperBound)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int8>,
                          isContainedIn collection: [Int8]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let numNums = Int32(collection.count)
        collection.map({ Int32($0) }).withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int32_in(queryBuilder, property.propertyId, ptr.baseAddress, numNums)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int8>,
                          isNotContainedIn collection: [Int8]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let numNums = Int32(collection.count)
        collection.map({ Int32($0) }).withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int32_not_in(queryBuilder, property.propertyId, ptr.baseAddress, numNums)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
}

// MARK: Int16

extension QueryBuilder {
    internal func `where`(_ queryProperty: Property<EntityType, Int16>,
                          isEqualTo integer: Int16) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_equal(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int16>,
                          isNotEqualTo integer: Int16) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_not_equal(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int16>,
                          isLessThan integer: Int16) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_less(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int16>,
                          isGreaterThan integer: Int16) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_greater(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`(_ queryProperty: Property<EntityType, Int16>,
                          isBetween lowerBound: Int16,
                          and upperBound: Int16) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId, Int64(lowerBound),
                                                                Int64(upperBound)), builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int16>,
                          isIn range: Range<Int16>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                Int64(range.lowerBound),
                                                                Int64(max(range.upperBound - 1, range.lowerBound))),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int16>,
                          isIn range: ClosedRange<Int16>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                Int64(range.lowerBound), Int64(range.upperBound)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int16>,
                          isContainedIn collection: [Int16]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let numNums = Int32(collection.count)
        collection.map({ Int32($0) }).withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int32_in(queryBuilder, property.propertyId, ptr.baseAddress, numNums)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int16>,
                          isNotContainedIn collection: [Int16]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let numNums = Int32(collection.count)
        collection.map({ Int32($0) }).withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int32_not_in(queryBuilder, property.propertyId, ptr.baseAddress, numNums)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
}

// MARK: Int

extension QueryBuilder {
    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isEqualTo integer: Int) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_equal(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isNotEqualTo integer: Int) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_not_equal(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isLessThan integer: Int) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_less(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isGreaterThan integer: Int) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_greater(queryBuilder, property.propertyId, Int64(integer)),
                                             builder: queryBuilder)
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isBetween lowerBound: Int,
                          and upperBound: Int) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId, Int64(lowerBound),
                                                                Int64(upperBound)), builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isIn range: Range<Int>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                Int64(range.lowerBound),
                                                                Int64(max(range.upperBound - 1, range.lowerBound))),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isIn range: ClosedRange<Int>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                Int64(range.lowerBound), Int64(range.upperBound)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isContainedIn collection: [Int]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let numNums = Int32(collection.count)
        collection.map({ Int64($0) }).withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int64_in(queryBuilder, property.propertyId, ptr.baseAddress, numNums)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Int>,
                          isNotContainedIn collection: [Int]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let numNums = Int32(collection.count)
        collection.map({ Int64($0) }).withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int64_not_in(queryBuilder, property.propertyId, ptr.baseAddress, numNums)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
}

// MARK: - Floating points
// MARK: Double

extension QueryBuilder {
    internal func `where`(_ queryProperty: Property<EntityType, Double>,
                          isEqualTo value: Double, tolerance: Double) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_double_between(queryBuilder, property.propertyId,
                                                                   value - tolerance, value + tolerance),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Double>,
                          isLessThan value: Double) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_double_less(queryBuilder, property.propertyId, value),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Double>,
                          isGreaterThan value: Double) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_double_greater(queryBuilder, property.propertyId, value),
                                             builder: queryBuilder)
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`(_ queryProperty: Property<EntityType, Double>,
                          isBetween lowerBound: Double,
                          and upperBound: Double) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_double_between(queryBuilder, property.propertyId,
                                                                   lowerBound, upperBound), builder: queryBuilder)
    }
}

// MARK: Float

extension QueryBuilder {
    internal func `where`(_ queryProperty: Property<EntityType, Float>,
                          isEqualTo value: Float, tolerance: Float) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_double_between(queryBuilder, property.propertyId,
                                                                   Double(value - tolerance),
                                                                   Double(value + tolerance)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Float>,
                          isLessThan value: Float) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_double_less(queryBuilder, property.propertyId, Double(value)),
                                             builder: queryBuilder)
    }
    
    internal func `where`(_ queryProperty: Property<EntityType, Float>,
                          isGreaterThan value: Float) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_double_greater(queryBuilder, property.propertyId, Double(value)),
                                             builder: queryBuilder)
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Lower limiting value, inclusive.
    /// - parameter upperBound: Upper limiting value, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`(_ queryProperty: Property<EntityType, Float>,
                          isBetween lowerBound: Float,
                          and upperBound: Float) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_double_between(queryBuilder, property.propertyId,
                                                                   Double(lowerBound), Double(upperBound)),
                                             builder: queryBuilder)
    }
}

// MARK: - String and Optional<String>

extension QueryBuilder {
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isEqualTo string: String,
                             caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            let property = queryProperty.base
            return PropertyQueryBuilderCondition(obx_qb_string_equal(queryBuilder, property.propertyId, string,
                                                                     caseSensitive), builder: queryBuilder)
    }
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isNotEqualTo string: String,
                             caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            let property = queryProperty.base
            return PropertyQueryBuilderCondition(obx_qb_string_not_equal(queryBuilder, property.propertyId, string,
                                                                         caseSensitive), builder: queryBuilder)
    }
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isLessThan string: String,
                             caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            let property = queryProperty.base
            return PropertyQueryBuilderCondition(obx_qb_string_less(queryBuilder, property.propertyId, string,
                                                                    caseSensitive, false), builder: queryBuilder)
    }
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isGreaterThan string: String,
                             caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            let property = queryProperty.base
            return PropertyQueryBuilderCondition(obx_qb_string_greater(queryBuilder, property.propertyId, string,
                                                                       caseSensitive, false), builder: queryBuilder)
    }
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isContainedIn collection: [String],
                             caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            let property = queryProperty.base
            var strings: [UnsafePointer?] = collection.map { str -> UnsafePointer<Int8> in
                return (str as NSString).utf8String!
            }
            var result: obx_qb_cond = 0
            let numStrings = Int32(strings.count)
            strings.withContiguousMutableStorageIfAvailable { ptr -> Void in
                result = obx_qb_string_in(queryBuilder, property.propertyId, ptr.baseAddress, numStrings, caseSensitive)
            }
            return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             startsWith prefix: String,
                             caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            let property = queryProperty.base
            return PropertyQueryBuilderCondition(obx_qb_string_starts_with(queryBuilder, property.propertyId, prefix,
                                                                           caseSensitive), builder: queryBuilder)
    }
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             endsWith suffix: String,
                             caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            let property = queryProperty.base
            return PropertyQueryBuilderCondition(obx_qb_string_ends_with(queryBuilder, property.propertyId, suffix,
                                                                         caseSensitive), builder: queryBuilder)
    }
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             contains substring: String,
                             caseSensitive: Bool = true) -> PropertyQueryBuilderCondition
        where S: StringPropertyType {
            let property = queryProperty.base
            return PropertyQueryBuilderCondition(obx_qb_string_contains(queryBuilder, property.propertyId, substring,
                                                                        caseSensitive), builder: queryBuilder)
    }
    
}

// MARK: - Data and Optional<Data>

extension QueryBuilder {
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isEqualTo data: Data) -> PropertyQueryBuilderCondition
        where S: DataPropertyType {
            let property = queryProperty.base
            let bufferLength = data.count
            return data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> PropertyQueryBuilderCondition in
                return PropertyQueryBuilderCondition(obx_qb_bytes_equal(queryBuilder, property.propertyId,
                                                                        buffer.baseAddress, bufferLength),
                                                     builder: queryBuilder)
            })
    }
        
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isLessThan data: Data) -> PropertyQueryBuilderCondition
        where S: DataPropertyType {
            let property = queryProperty.base
            let bufferLength = data.count
            return data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> PropertyQueryBuilderCondition in
                return PropertyQueryBuilderCondition(obx_qb_bytes_less(queryBuilder, property.propertyId,
                                                                       buffer.baseAddress, bufferLength, false),
                                                     builder: queryBuilder)
            })
    }
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isLessThanEqual data: Data) -> PropertyQueryBuilderCondition
        where S: DataPropertyType {
            let property = queryProperty.base
            let bufferLength = data.count
            return data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> PropertyQueryBuilderCondition in
                return PropertyQueryBuilderCondition(obx_qb_bytes_less(queryBuilder, property.propertyId,
                                                                       buffer.baseAddress, bufferLength, true),
                                                     builder: queryBuilder)
            })
    }
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isGreaterThan data: Data) -> PropertyQueryBuilderCondition
        where S: DataPropertyType {
            let property = queryProperty.base
            let bufferLength = data.count
            return data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> PropertyQueryBuilderCondition in
                return PropertyQueryBuilderCondition(obx_qb_bytes_greater(queryBuilder, property.propertyId,
                                                                          buffer.baseAddress, bufferLength, false),
                                                     builder: queryBuilder)
            })
    }
    
    internal func `where`<S>(_ queryProperty: Property<EntityType, S>,
                             isGreaterThanEqual data: Data) -> PropertyQueryBuilderCondition
        where S: DataPropertyType {
            let property = queryProperty.base
            let bufferLength = data.count
            return data.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> PropertyQueryBuilderCondition in
                return PropertyQueryBuilderCondition(obx_qb_bytes_greater(queryBuilder, property.propertyId,
                                                                           buffer.baseAddress, bufferLength, true),
                                                     builder: queryBuilder)
            })
    }
    
}

// MARK: - Date and Optional<Date>

extension QueryBuilder {
    
    internal func `where`<D>(_ queryProperty: Property<EntityType, D>,
                             isEqualTo date: Date) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_equal(queryBuilder, property.propertyId, date.unixTimestamp),
                                             builder: queryBuilder)
    }
    
    internal func `where`<D>(_ queryProperty: Property<EntityType, D>,
                             isNotEqualTo date: Date) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_not_equal(queryBuilder, property.propertyId,
                                                                  date.unixTimestamp), builder: queryBuilder)
    }
    
    internal func `where`<D>(_ queryProperty: Property<EntityType, D>,
                             isBefore date: Date) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_less(queryBuilder, property.propertyId, date.unixTimestamp),
                                             builder: queryBuilder)
    }
    
    internal func `where`<D>(_ queryProperty: Property<EntityType, D>,
                             isAfter date: Date) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_greater(queryBuilder, property.propertyId, date.unixTimestamp),
                                             builder: queryBuilder)
    }
    
    /// Matches all property values between `lowerBound` and `upperBound`,
    /// including the bounds themselves. The order of the bounds does not matter.
    ///
    /// - parameter queryProperty: Entity property to compare values of.
    /// - parameter lowerBound: Earliest date, inclusive.
    /// - parameter upperBound: Latest date, inclusive.
    /// - returns: Same `QueryBuilder` instance after applying the condition.
    internal func `where`<D>(_ queryProperty: Property<EntityType, D>,
                             isBetween lowerBound: Date,
                             and upperBound: Date) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                lowerBound.unixTimestamp, upperBound.unixTimestamp),
                                             builder: queryBuilder)
    }
    
    internal func `where`<D>(_ queryProperty: Property<EntityType, D>,
                             isIn range: Range<Date>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                range.lowerBound.unixTimestamp,
                                                                max(range.upperBound.unixTimestamp - 1,
                                                                    range.lowerBound.unixTimestamp)),
                                             builder: queryBuilder)
    }
    
    internal func `where`<D>(_ queryProperty: Property<EntityType, D>,
                             isIn range: ClosedRange<Date>) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        return PropertyQueryBuilderCondition(obx_qb_int_between(queryBuilder, property.propertyId,
                                                                range.lowerBound.unixTimestamp,
                                                                range.upperBound.unixTimestamp), builder: queryBuilder)
    }
    
    internal func `where`<D>(_ queryProperty: Property<EntityType, D>,
                             isContainedIn collection: [Date]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let dates: [Int64] = collection.map { date -> Int64 in
            return date.unixTimestamp
        }
        let numDates = Int32(dates.count)
        dates.withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int64_in(queryBuilder, property.propertyId, ptr.baseAddress, numDates)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
    
    internal func `where`<D>(_ queryProperty: Property<EntityType, D>,
                             isNotContainedIn collection: [Date]) -> PropertyQueryBuilderCondition {
        let property = queryProperty.base
        var result: obx_qb_cond = 0
        let dates: [Int64] = collection.map { date -> Int64 in
            return date.unixTimestamp
        }
        let numDates = Int32(dates.count)
        dates.withContiguousStorageIfAvailable { (ptr) -> Void in
            result = obx_qb_int64_not_in(queryBuilder, property.propertyId, ptr.baseAddress, numDates)
            failFatallyIfError()
        }
        return PropertyQueryBuilderCondition(result, builder: queryBuilder)
    }
}
