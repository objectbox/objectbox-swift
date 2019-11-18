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

/// A reusable query returning entities.
///
/// You can hold on to a `Query` once it is set up and re-evaluate it e.g. using `find()` or `all()`.
///
/// Use the block-based query method to state conditions using operator overloads, like:
///
///    let query = box.query { Person.age > 21 && Person.name.startsWith("M") }.build()
///
/// If you want to return aggregate results or just property values and not whole entities, use `property(_:)` to obtain
/// a `PropertyQuery`.
///

public class Query<E: EntityInspectable & __EntityRelatable>: CustomDebugStringConvertible
where E == E.EntityBindingType.EntityType {
    /// The entity type this query is going to target.
    public typealias EntityType = E
    
    internal var cQuery: OpaquePointer /*OBX_query*/
    internal var store: Store
    
    internal init(query: OpaquePointer /*OBX_query*/, store: Store) {
        self.cQuery = query
        self.store = store
    }
    
    deinit {
        obx_query_close(cQuery)
    }

    /// Find all objects matching the query between the given offset and limit.
    ///
    /// - Parameters:
    ///   - offset: How many results to skip. (Useful when paginating results.)
    ///   - limit: Maximum number of objects that may be returned (may give fewer).
    /// - Returns: Collection of objects matching the query conditions.
    public func find(offset: UInt64 = 0, limit: UInt64 = 0) throws -> [EntityType] {
        var result = [EntityType]()
        
        try store.obx_runInReadOnlyTransaction { _ in
            let box = self.store.box(for: EntityType.self)
            if let bytesArray = obx_query_find(cQuery, offset, limit) {
                try check(error: obx_last_error_code())
                defer { obx_bytes_array_free(bytesArray) }
                result = try box.readAll(bytesArray.pointee)
            }
            try check(error: obx_last_error_code())
        }
        
        return result
    }
    
    // Variant of find() that is faster due to using ContiguousArray.
    public func findContiguous(offset: UInt64 = 0, limit: UInt64 = 0) throws -> ContiguousArray<EntityType> {
        var result = ContiguousArray<EntityType>()
        
        try store.obx_runInReadOnlyTransaction { _ in
            let box = self.store.box(for: EntityType.self)
            if let bytesArray = obx_query_find(cQuery, offset, limit) {
                try check(error: obx_last_error_code())
                defer { obx_bytes_array_free(bytesArray) }
                result = try box.readAllContiguous(bytesArray.pointee)
            }
            try check(error: obx_last_error_code())
        }
        
        return result
    }

    /// Find all object IDs matching the query between the given offset and limit.
    ///
    /// - Parameters:
    ///   - offset: How many results to skip. (Useful when paginating results.)
    ///   - limit: Maximum number of results that may be returned (may give fewer).
    /// - Returns: Collection of object IDs matching the query conditions.
    public func findIds(offset: UInt64 = 0, limit: UInt64 = 0) throws -> [EntityId<EntityType>] {
        var result = [EntityId<EntityType>]()
        
        if let idArray = obx_query_find_ids(cQuery, offset, limit) {
            try check(error: obx_last_error_code())
            defer { obx_id_array_free(idArray) }
            
            // swiftlint:disable opening_brace
            result = [EntityId<EntityType>](unsafeUninitializedCapacity: idArray.pointee.count)
            { ptr, initializedCount in
                for idIndex in 0 ..< idArray.pointee.count {
                    ptr[idIndex] = EntityId<EntityType>(idArray.pointee.ids[idIndex])
                }
                initializedCount = idArray.pointee.count
            }
            // swiftlint:enable opening_brace
        }
        try check(error: obx_last_error_code())
        
        return result
    }

    /// Delete all objects matching the query.
    ///
    /// - Parameters:
    /// - Returns: Number of objects deleted.
    @discardableResult
    public func remove() throws -> UInt64 {
        var result: UInt64 = 0
        
        obx_query_remove(cQuery, &result)
        try check(error: obx_last_error_code())
        
        return result
    }


    /// Find the first Object matching the query.
    public func findFirst() throws -> EntityType? {
        return try find(offset: 0, limit: 1).first
    }

    /// Find the single object matching the query.
    ///
    /// When `count > 1`, this will throw.
    ///
    /// - Returns: The one and only object matching the query conditions.
    /// - Throws: ObjectBoxError.nonUniqueResult when there is more than one match, ObjectBoxError.notFound when there
    ///             are no matches at all.
    public func findUnique() throws -> EntityType {
        let found = try find(offset: 0, limit: 2)
        guard found.count < 2 else { throw ObjectBoxError.nonUniqueResult(message: "More than 1 result in database.") }
        guard found.count > 0 else { throw ObjectBoxError.notFound(message: "No results in database.") }
        return found[0]
    }

    /// The number of objects matching the query.
    public func count() throws -> Int {
        var result: UInt64 = 0
        
        try check(error: obx_query_count(cQuery, &result))

        return Int(result) // Return as Int because that's what Swift Standard lib uses for arrays.
    }

    /// Find all Objects matching the query.
    /// Alternative name for find() without arguments.
    public func all() throws -> [EntityType] {
        return try find()
    }
    
    /// Variant of all() that is faster due to using ContiguousArray.
    public func allContiguous() throws -> ContiguousArray<EntityType> {
        return try findContiguous()
    }

    /// Accessor to get a `PropertyQuery` object based on the query conditions.
    ///
    /// You use `Query` to get objects, `PropertyQuery` to get aggregate results for entity properties.
    /// For example, for an `Int` property, you can get the `average`, `sum`, `min`, and `max`, among other things.
    /// 
    /// - Parameter property: Object property to modify the query for.
    /// - Returns: New `PropertyQuery` to configure.
    public func property<T>(_ property: Property<EntityType, T, Void>) -> PropertyQuery<EntityType, T>
        where T: EntityPropertyTypeConvertible {
        return PropertyQuery(query: cQuery, propertyId: property.base.propertyId, store: store)
    }

    // MARK: - Parameter changes
    
    internal func setParameters(property: PropertyDescriptor, to collection: [Int64]) throws {
        if property.type == .long {
            let numParams = Int32(collection.count)
            collection.withContiguousStorageIfAvailable { ptr -> Void in
                obx_query_int64_params_in(cQuery, EntityType.entityInfo.entitySchemaId,
                                          property.propertyId, ptr.baseAddress, numParams)
            }
        } else {
            let i32collection = collection.map { Int32($0) }
            let numParams = Int32(i32collection.count)
            i32collection.withContiguousStorageIfAvailable { ptr -> Void in
                obx_query_int32_params_in(cQuery, EntityType.entityInfo.entitySchemaId,
                                          property.propertyId, ptr.baseAddress, numParams)
            }
        }
        try checkLastError()
    }
    
    internal func setParametersForPropertyWithAlias(_ alias: String, to collection: [Int64]) throws {
        let numParams = Int32(collection.count)
        collection.withContiguousStorageIfAvailable { ptr -> Void in
            obx_query_int64_params_in_alias(cQuery, alias, ptr.baseAddress, numParams)
        }
        try checkLastError()
    }
    
    internal func setParametersForPropertyWithAlias(_ alias: String, to collection: [Int32]) throws {
        let numParams = Int32(collection.count)
        collection.withContiguousStorageIfAvailable { ptr -> Void in
            obx_query_int32_params_in_alias(cQuery, alias, ptr.baseAddress, numParams)
        }
        try checkLastError()
    }
    
    internal func setParameter(property: PropertyDescriptor, to value: Int64) throws {
        obx_query_int_param(cQuery, EntityType.entityInfo.entitySchemaId, property.propertyId, value)
        try checkLastError()
    }
    
    /// Specify a value for a parameter of a sub-expression of a query.
    public func setParameter(_ alias: String, to value: Int64) throws {
        obx_query_int_param_alias(cQuery, alias, value)
        try checkLastError()
    }
    
    internal func setParameters(property: PropertyDescriptor, to value1: Int64, _ value2: Int64) throws {
        obx_query_int_params(cQuery, EntityType.entityInfo.entitySchemaId, property.propertyId,
                             value1, value2)
        try checkLastError()
    }
    
    /// Specify two values for a parameter of a sub-expression of a query.
    public func setParameters(_ alias: String, to value1: Int64, _ value2: Int64) throws {
        obx_query_int_params_alias(cQuery, alias, value1, value2)
        try checkLastError()
    }
    
    internal func setParameter(property: PropertyDescriptor, to value: Double) throws {
        obx_query_double_param(cQuery, EntityType.entityInfo.entitySchemaId, property.propertyId, value)
        try checkLastError()
    }
    
    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(alias:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    public func setParameter(_ alias: String, to value: Double) throws {
        obx_query_double_param_alias(cQuery, alias, value)
        try checkLastError()
    }
    
    internal func setParameters(property: PropertyDescriptor, to value1: Double, _ value2: Double) throws {
        obx_query_double_params(cQuery, EntityType.entityInfo.entitySchemaId, property.propertyId,
                                value1, value2)
        try checkLastError()
    }
    
    /// Sets a parameter previously specified using a `ParameterAlias` to new values.
    ///
    /// This is the variant with 2 values, e.g. for `isBetween(_:and:)` comparison.
    /// See `setParameter(alias:to:)` for operators with 1 value.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value1: New first value for the condition.
    ///   - value2: New second value for the condition.
    public func setParameters(_ alias: String, to value1: Double, _ value2: Double) throws {
        obx_query_double_params_alias(cQuery, alias, value1, value2)
        try checkLastError()
    }
    
    internal func setParameter(property: PropertyDescriptor, to value: String) throws {
        obx_query_string_param(cQuery, EntityType.entityInfo.entitySchemaId, property.propertyId, value)
        try checkLastError()
    }
    
    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(alias:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - string: New value.
    public func setParameter(_ alias: String, to string: String) throws {
        obx_query_string_param_alias(cQuery, alias, string)
        try checkLastError()
    }
    
    internal func setParameters(property: PropertyDescriptor, to collection: [String]) throws {
        let numStrings = Int32(collection.count)
        var strings: [UnsafePointer?] = collection.map { ($0 as NSString).utf8String }
        strings.withContiguousMutableStorageIfAvailable { ptr -> Void in
            obx_query_string_params_in(cQuery, EntityType.entityInfo.entitySchemaId, property.propertyId,
                                       ptr.baseAddress, numStrings)
        }
        try checkLastError()
    }
    
    /// Sets a parameter previously specified during query construction to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - collection: New collection of values for the condition.
    public func setParameters(_ alias: String, to collection: [String]) throws {
        let numStrings = Int32(collection.count)
        var strings: [UnsafePointer?] = collection.map { ($0 as NSString).utf8String }
        strings.withContiguousMutableStorageIfAvailable { ptr -> Void in
            obx_query_string_params_in_alias(cQuery, alias, ptr.baseAddress, numStrings)
        }
        try checkLastError()
    }
    
    /// :nodoc:
    public var debugDescription: String {
        var parts = [String]()
        
        let descBuf = obx_query_describe(cQuery)
        
        if let descBuf = descBuf, let descStr = String(utf8String: descBuf) {
            parts.append(descStr)
            if let paramsBuf = obx_query_describe_params(cQuery), let paramsStr = String(utf8String: paramsBuf) {
                parts.append(paramsStr)
            }
        }
        
        return "<ObjectBox.Query \"\(parts.joined(separator: ", "))\">"
    }
}
