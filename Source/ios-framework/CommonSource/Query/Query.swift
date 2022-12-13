//
// Copyright © 2018-2022 ObjectBox Ltd. All rights reserved.
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

/// Some wrapper used with/for CDataVisitor - not sure if we actually need it...
internal class CDataVisitorContext {
    var fun: (UnsafeRawPointer?, Int) -> Bool

    init(_ fun: @escaping (UnsafeRawPointer?, Int) -> Bool) {
        self.fun = fun
    }
}

internal func CDataVisitor(data: UnsafeRawPointer?, size: Int, userData: UnsafeMutableRawPointer?) -> CBool {
    let context: CDataVisitorContext = Unmanaged.fromOpaque(userData!).takeUnretainedValue()
    return context.fun(data, size)
}

/// A reusable query returning entities or their IDs.
///
/// You can hold on to a `Query` once it is set up and re-query it e.g. using `find()`.
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
    internal var useBytesArray: Bool

    internal init(query: OpaquePointer /*OBX_query*/, store: Store) {
        cQuery = query
        self.store = store
        useBytesArray = store.supportsLargeArrays
    }

    deinit {
        obx_query_close(cQuery)
    }

    /// Semi-internal; tells the query to use a visitor approach which may be not as fast but uses a bit less memory
    /// with larger result sets.
    @discardableResult func useVisitor() -> Query<E> {
        useBytesArray = false
        return self // allow chaining
    }

    private func setOffsetLimit(_ offset: Int, _ limit: Int) throws {
        try checkCResult(obx_query_offset_limit(cQuery, offset, limit))
    }

    private func resetOffsetLimit() {
        obx_query_offset_limit(cQuery, 0, 0)  // Ignore result; do not throw
    }

    /// Find all objects matching the query between the given offset and limit.
    ///
    /// - Parameters:
    ///   - offset: How many results to skip. (Useful when paginating results.)
    ///   - limit: Maximum number of objects that may be returned (may give fewer).
    /// - Returns: Collection of objects matching the query conditions.
    public func find(offset: Int = 0, limit: Int = 0) throws -> [EntityType] {
        return try store.runInReadOnlyTransaction {
            if useBytesArray {
                let box = store.box(for: EntityType.self)
                try setOffsetLimit(offset, limit)
                guard let bytesArray = obx_query_find(cQuery) else {
                    try throwObxErr(obx_last_error_code())
                }
                defer {
                    obx_bytes_array_free(bytesArray)
                }
                return try box.readAll(bytesArray.pointee)
            } else {
                var flatBuffer = FlatBufferReader()
                let binding = EntityType.entityBinding
                var result = [EntityType]()

                let context = CDataVisitorContext({ (data: UnsafeRawPointer?, _) -> Bool in
                    guard let safePtr = data else {
                        return false
                    }
                    flatBuffer.setCurrentlyReadTableBytes(UnsafeRawPointer(safePtr))
                    result.append(binding.createEntity(entityReader: flatBuffer, store: self.store))
                    return true
                })

                try checkCResult(obx_query_offset_limit(cQuery, offset, limit))
                let error = obx_query_visit(cQuery, CDataVisitor, Unmanaged.passUnretained(context).toOpaque())
                try check(error: error)
                return result
            }
        }
    }

    // Variant of find() that is faster due to using ContiguousArray.
    public func findContiguous(offset: Int = 0, limit: Int = 0) throws -> ContiguousArray<EntityType> {
        var result = ContiguousArray<EntityType>()

        try store.runInReadOnlyTransaction {
            if useBytesArray {
                let box = store.box(for: EntityType.self)
                try setOffsetLimit(offset, limit)
                guard let bytesArray = obx_query_find(cQuery) else {
                    try throwObxErr(obx_last_error_code())
                }
                defer {
                    obx_bytes_array_free(bytesArray)
                }
                result = try box.readAllContiguous(bytesArray.pointee)
            } else {
                var flatBuffer = FlatBufferReader()
                let binding = EntityType.entityBinding

                let context = CDataVisitorContext({ (data: UnsafeRawPointer?, _) -> Bool in
                    guard let safePtr = data else {
                        return false
                    }
                    flatBuffer.setCurrentlyReadTableBytes(UnsafeRawPointer(safePtr))
                    result.append(binding.createEntity(entityReader: flatBuffer, store: self.store))
                    return true
                })

                try checkCResult(obx_query_offset_limit(cQuery, offset, limit))
                let error = obx_query_visit(cQuery, CDataVisitor, Unmanaged.passUnretained(context).toOpaque())
                try check(error: error)
            }
        }

        return result
    }

    /// Find all object IDs matching the query between the given offset and limit.
    ///
    /// - Parameters:
    ///   - offset: How many results to skip. (Useful when paginating results.)
    ///   - limit: Maximum number of results that may be returned (may give fewer).
    /// - Returns: Collection of object IDs matching the query conditions.
    public func findIds(offset: Int = 0, limit: Int = 0) throws -> [EntityId<EntityType>] {
        var result = [EntityId<EntityType>]()

        try setOffsetLimit(offset, limit)
        guard let idArray = obx_query_find_ids(cQuery) else {
            try throwObxErr(obx_last_error_code())
        }
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

        return result
    }

    /// Delete all objects matching the query.
    ///
    /// - Parameters:
    /// - Returns: Number of objects deleted.
    @discardableResult
    public func remove() throws -> UInt64 {
        var result: UInt64 = 0

        let err = obx_query_remove(cQuery, &result)
        try check(error: err)

        return result
    }

    /// Find the first Object matching the query.
    public func findFirst() throws -> EntityType? {
        defer { resetOffsetLimit() }  // reset the internal state set by find()
        return try find(offset: 0, limit: 1).first
    }

    /// Find the single object matching the query (the result must be unique).
    ///
    /// - Returns: The one and only object matching the query conditions, or nil if the query did not match anything.
    /// - Throws: ObjectBoxError.nonUniqueResult when there is more than one match
    public func findUnique() throws -> EntityType? {
        defer { resetOffsetLimit() }  // reset the internal state set by find()
        let found = try find(offset: 0, limit: 2)
        guard found.count < 2 else { throw ObjectBoxError.nonUniqueResult(message: "More than 1 result in database.") }
        return found.count == 1 ? found[0] : nil
    }

    /// The number of objects matching the query.
    public func count() throws -> Int {
        var result: UInt64 = 0

        try check(error: obx_query_count(cQuery, &result))

        return Int(result) // Return as Int because that's what Swift Standard lib uses for arrays.
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
        return PropertyQuery(query: self, propertyId: property.base.propertyId)
    }

    // Work-around to get rid of the optional value type in Property to enable standard PropertyQuery functionality.
    public func property<T>(_ property: Property<EntityType, T?, Void>) -> PropertyQuery<EntityType, T>
            where T: EntityPropertyTypeConvertible {
        return PropertyQuery(query: self, propertyId: property.base.propertyId)
    }

    /// Allows having a `PropertyQuery` for Date properties via their Int64 unix timestamps
    public func propertyInt64(_ property: Property<EntityType, Date, Void>) -> PropertyQuery<EntityType, Int64> {
        return PropertyQuery(query: self, propertyId: property.base.propertyId)
    }

    /// Allows having a `PropertyQuery` for Date properties via their Int64 unix timestamps
    public func propertyInt64(_ property: Property<EntityType, Date?, Void>) -> PropertyQuery<EntityType, Int64> {
        return PropertyQuery(query: self, propertyId: property.base.propertyId)
    }

    // MARK: - Parameter changes

    // Note: using same name fragment ("checkFatalError") to exclude from symbol stack
    internal func checkFatalErrorParam(_ err: obx_err) {
        if err != OBX_SUCCESS {
            print("Could not set query parameter; this is typically an user error.")
            print("Please check if the provided parameter types/numbers match the ones in the query definition.")
            print("E.g. a 'between' query condition takes two parameters, so you must not set a single parameter.")
            checkFatalError(err)
        }
    }

    internal func setParametersInternal64(property: PropertyDescriptor, to collection: [Int64]) {
        let numParams = Int(collection.count)
        collection.withContiguousStorageIfAvailable { ptr -> Void in
            let err = obx_query_param_int64s(cQuery, EntityType.entityInfo.entitySchemaId,
                    property.propertyId, ptr.baseAddress, numParams)
            checkFatalErrorParam(err)
        }
    }

    internal func setParametersInternal32(property: PropertyDescriptor, to collection: [Int32]) {
        let numParams = Int(collection.count)
        collection.withContiguousStorageIfAvailable { ptr -> Void in
            let typeId = EntityType.entityInfo.entitySchemaId
            let err = obx_query_param_int32s(cQuery, typeId, property.propertyId, ptr.baseAddress, numParams)
            checkFatalErrorParam(err)
        }
    }

    internal func setParametersInternal<T>(property: PropertyDescriptor, to collection: [T])
            where T: FixedWidthInteger {
        let typeId = EntityType.entityInfo.entitySchemaId
        let typeSize = obx_query_param_get_type_size(cQuery, typeId, property.propertyId)
        if typeSize == 8 {
            setParametersInternal64(property: property, to: Util.toInt64Array(collection))
        } else {
            precondition(typeSize > 0 && typeSize <= 4)
            let collection32: [Int32]
            do {
                collection32 = try Util.toInt32Array(collection)
            } catch {
                fatalErrorWithStack("""
                                    Usage error; ensure to use the proper parameter type 
                                    (type: \(typeId), property:\(property.propertyId)): \(error)
                                    """)
            }
            setParametersInternal32(property: property, to: collection32)
        }
    }

    internal func setParametersInternal(_ alias: String, to collection: [Int64]) {
        let numParams = Int(collection.count)
        collection.withContiguousStorageIfAvailable { ptr -> Void in
            let err = obx_query_param_alias_int64s(cQuery, alias, ptr.baseAddress, numParams)
            checkFatalErrorParam(err)
        }
    }

    internal func setParametersInternal(_ alias: String, to collection: [Int32]) {
        let numParams = Int(collection.count)
        collection.withContiguousStorageIfAvailable { ptr -> Void in
            let err = obx_query_param_alias_int32s(cQuery, alias, ptr.baseAddress, numParams)
            checkFatalErrorParam(err)
        }
    }

    internal func setParameterInternal(property: PropertyDescriptor, to value: Int64) {
        let err = obx_query_param_int(cQuery, EntityType.entityInfo.entitySchemaId, property.propertyId, value)
        checkFatalErrorParam(err)
    }

    /// Specify a value for a parameter of a sub-expression of a query.
    internal func setParameterInternal(_ alias: String, to value: Int64) {
        let err = obx_query_param_alias_int(cQuery, alias, value)
        checkFatalErrorParam(err)
    }

    internal func setParametersInternal(property: PropertyDescriptor, to value1: Int64, _ value2: Int64) {
        let typeId = EntityType.entityInfo.entitySchemaId
        let err = obx_query_param_2ints(cQuery, typeId, property.propertyId, value1, value2)
        checkFatalErrorParam(err)
    }

    /// Specify two values for a parameter of a sub-expression of a query.
    internal func setParametersInternal(_ alias: String, to value1: Int64, _ value2: Int64) {
        let err = obx_query_param_alias_2ints(cQuery, alias, value1, value2)
        checkFatalErrorParam(err)
    }

    internal func setParameterInternal(property: PropertyDescriptor, to value: Double) {
        let err = obx_query_param_double(cQuery, EntityType.entityInfo.entitySchemaId, property.propertyId, value)
        checkFatalErrorParam(err)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(alias:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    internal func setParameterInternal(_ alias: String, to value: Double) {
        let err = obx_query_param_alias_double(cQuery, alias, value)
        checkFatalErrorParam(err)
    }

    internal func setParametersInternal(property: PropertyDescriptor, to value1: Double, _ value2: Double) {
        let typeId = EntityType.entityInfo.entitySchemaId
        let err = obx_query_param_2doubles(cQuery, typeId, property.propertyId, value1, value2)
        checkFatalErrorParam(err)
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
    internal func setParametersInternal(_ alias: String, to value1: Double, _ value2: Double) {
        let err = obx_query_param_alias_2doubles(cQuery, alias, value1, value2)
        checkFatalErrorParam(err)
    }

    internal func setParameterInternal(property: PropertyDescriptor, to value: String) {
        let err = obx_query_param_string(cQuery, EntityType.entityInfo.entitySchemaId, property.propertyId, value)
        checkFatalErrorParam(err)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(alias:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - string: New value.
    public func setParameter(_ alias: String, to string: String) {
        let err = obx_query_param_alias_string(cQuery, alias, string)
        checkFatalErrorParam(err)
    }

    internal func setParametersInternal(property: PropertyDescriptor, to collection: [String]) {
        let numStrings = Int(collection.count)
        var strings: [UnsafePointer?] = collection.map { ($0 as NSString).utf8String }
        strings.withContiguousMutableStorageIfAvailable { ptr -> Void in
            let typeId = EntityType.entityInfo.entitySchemaId
            let err = obx_query_param_strings(cQuery, typeId, property.propertyId, ptr.baseAddress, numStrings)
            checkFatalErrorParam(err)
        }
    }

    /// Sets a parameter previously specified during query construction to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - collection: New collection of values for the condition.
    public func setParameters(_ alias: String, to collection: [String]) {
        let numStrings = Int(collection.count)
        var strings: [UnsafePointer?] = collection.map { ($0 as NSString).utf8String }
        strings.withContiguousMutableStorageIfAvailable { ptr -> Void in
            let err = obx_query_param_alias_strings(cQuery, alias, ptr.baseAddress, numStrings)
            checkFatalErrorParam(err)
        }
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
