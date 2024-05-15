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

// Note: Arrays etc. in Swift are counted using Ints (int32 on 32-bit, int64 on 64-bit), so we do the same and return
//  all counts as Ints. Similarly, given the sum() can quickly overflow, we return the sum as Int for smaller types, so
//  callers have to cast and think about overflows, and averages are near-useless as integers, so we promote them to
//  Double for integer types (So Float is the only one that has avg() return a Float, because that's already
//  fractional).
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
///      let query = try personBox.query { Person.age > 29 }.build()
///      let ageQuery = query.property(Person.age)
///      let averageAge = try ageQuery.average()
///
/// - Note: Property values do currently not consider any sorting order defined in the main `Query` object.
public class PropertyQuery<E: EntityInspectable & __EntityRelatable, T: EntityPropertyTypeConvertible>
    where E == E.EntityBindingType.EntityType {

    /// The entity type this query is targeting.
    public typealias EntityType = E

    /// The type of the entity's property this query is targeting.
    public typealias ValueType = T

    internal let query: Query<EntityType>  // Hold on to main query to keep it alive
    internal let box: Box<EntityType>

    internal var cQueryProp: OpaquePointer /*OBX_query_prop*/

    internal var nullString: String?
    internal var nullLong: Int64?
    internal var nullDouble: Double?

    internal init(query: Query<EntityType>, propertyId: obx_schema_id) {
        self.query = query
        self.box = query.store.box(for: EntityType.self)

        let cPropertyQuery: OpaquePointer? = obx_query_prop(query.cQuery, propertyId)
        if cPropertyQuery == nil {
            // swiftlint:disable force_try
            try! checkLastError() // Should always throw; runtime error is OK because is an dev error (wrong schema ID)
            try! throwObxErr(0, message: "Should have thrown before")
            // swiftlint:enable force_try
        }
        self.cQueryProp = cPropertyQuery!
    }

    internal func longSum(box: OpaquePointer /*OBX_box*/) throws -> Int64 {
        var result = Int64(0)
        try checkLastError(obx_query_prop_sum_int(cQueryProp, &result, nil))
        return result
    }
    
    internal func longMax(box: OpaquePointer /*OBX_box*/) throws -> Int64 {
        var result = Int64(0)
        try checkLastError(obx_query_prop_max_int(cQueryProp, &result, nil))
        return result
    }
    
    internal func longMin(box: OpaquePointer /*OBX_box*/) throws -> Int64 {
        var result = Int64(0)
        try checkLastError(obx_query_prop_min_int(cQueryProp, &result, nil))
        return result
    }

    internal func doubleSum(box: OpaquePointer /*OBX_box*/) throws -> Double {
        var result = Double(0)
        try checkLastError(obx_query_prop_sum(cQueryProp, &result, nil))
        return result
    }
    
    internal func doubleMax(box: OpaquePointer /*OBX_box*/) throws -> Double {
        var result = Double(0)
        try checkLastError(obx_query_prop_max(cQueryProp, &result, nil))
        return result
    }
    
    internal func doubleMin(box: OpaquePointer /*OBX_box*/) throws -> Double {
        var result = Double(0)
        try checkLastError(obx_query_prop_min(cQueryProp, &result, nil))
        return result
    }
    
    internal func findDouble(box: OpaquePointer /*OBX_box*/) throws -> Double? {
        let result = try findDoubles(box: box)
        return result.last
    }
    
    internal func findDoubles(box: OpaquePointer /*OBX_box*/) throws -> [Double] {
        let cResult: UnsafeMutablePointer<OBX_double_array>?
        if nullDouble != nil {
            var nullValue: Double = nullDouble!
            cResult = obx_query_prop_find_doubles(cQueryProp, &nullValue)
        } else {
            cResult = obx_query_prop_find_doubles(cQueryProp, nil)
        }
        defer { obx_double_array_free(cResult) }
        try checkLastError()

        guard let doubles = cResult?.pointee else { return [] }
        
        return [Double](unsafeUninitializedCapacity: doubles.count) { (ptr, initializedCount) in
            for doubleIndex in 0 ..< doubles.count {
                ptr[doubleIndex] = doubles.items[doubleIndex]
            }
            initializedCount = doubles.count
        }
    }
    
    internal func average(box: OpaquePointer /*OBX_box*/) throws -> Double {
        var result = Double(0)
        try checkLastError(obx_query_prop_avg(cQueryProp, &result, nil))
        return result
    }
    
    internal func averageIntInternal(box: OpaquePointer /*OBX_box*/) throws -> Int64 {
        var result = Int64(0)
        try checkLastError(obx_query_prop_avg_int(cQueryProp, &result, nil))
        return result
    }

    internal func findStrings(box: OpaquePointer /*OBX_box*/)
        throws -> [String] {
        let fetch = { (ptr: UnsafePointer<Int8>?) -> UnsafeMutablePointer<OBX_string_array>? in
            let result: UnsafeMutablePointer<OBX_string_array>?
            result = obx_query_prop_find_strings(self.cQueryProp, ptr)
            try checkLastError()
            return result
        }
        
        let cResult: UnsafeMutablePointer<OBX_string_array>?
        if let nullString = nullString {
            cResult = try nullString.withCString(fetch)
        } else {
            cResult = try fetch(nil)
        }
        defer { obx_string_array_free(cResult) }
        
        guard let strings = cResult?.pointee else { return [] }
        
        // Crashes when I use the unsafeUninitializedCapacity initializer below.
        // Seems it tries to deinit the uninitialized memory on assignment.
        var result = [String](repeating: "", count: strings.count)
        for stringIndex in 0 ..< strings.count {
            if let string = strings.items[stringIndex] {
                result[stringIndex] = String(utf8String: string)!
            }
        }
        return result
    }

    /// The count of objects matching this query.
    public func count() throws -> Int {
        var result: UInt64 = 0
        try checkLastError(obx_query_prop_count(cQueryProp, &result))
        return Int(result)
    }

    /// Enable that only distinct values should be returned (e.g. 1,2,3 instead of 1,1,2,3,3,3).
    ///
    /// - Note: Cannot be unset.
    /// - Returns: `self` for chaining
    @discardableResult
    public func distinct() throws -> PropertyQuery<EntityType, ValueType> {
        obx_query_prop_distinct(cQueryProp, true)
        try checkLastError()
        return self
    }
}

// MARK: - Integer

extension PropertyQuery where T: FixedWidthInteger {
    /// Sums up all values for the given property over all Objects matching the query.
    public func sum() throws -> Int64 {
        return try longSum(box: box.cBox)
    }

    /// Sums up all values for the given property over all Objects matching the query.
    public func sumInt() throws -> Int {
        return try Int(longSum(box: box.cBox))
    }

    /// Sums up all values for the given property over all Objects matching the query.
    public func sumUnsigned() throws -> UInt64 {
        return try UInt64(truncatingIfNeeded: longSum(box: box.cBox))
    }

    /// Finds the maximum value for the given property over all Objects matching the query.
    public func max() throws -> T {
        return try T(longMax(box: box.cBox))
    }

    /// Finds the minimum value for the given property over all Objects matching the query.
    public func min() throws -> T {
        return try T(longMin(box: box.cBox))
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public func average() throws -> Double {
        return try average(box: box.cBox)
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public func averageInt() throws -> T {
        return try T(averageIntInternal(box: box.cBox))
    }

    /// T: Int64 or UInt64 (only)
    internal func findInts64Internal() throws -> [T] {
        let cResult: UnsafeMutablePointer<OBX_int64_array>?
        if nullLong != nil {
            var nullValue: Int64 = Int64(truncatingIfNeeded: nullLong ?? 0)
            cResult = obx_query_prop_find_int64s(cQueryProp, &nullValue)
        } else {
            cResult = obx_query_prop_find_int64s(cQueryProp, nil)
        }
        defer { obx_int64_array_free(cResult) }
        try checkLastError()

        guard let cArray = cResult?.pointee else { return [] }
        return [T](unsafeUninitializedCapacity: cArray.count) { (ptr, initializedCount) in
            for longIndex in 0..<cArray.count {
                ptr[longIndex] = T(truncatingIfNeeded: cArray.items[longIndex])
            }
            initializedCount = cArray.count
        }
    }

    /// T: Int32 or UInt32 (only)
    internal func findInts32Internal() throws -> [T] {
        let cResult: UnsafeMutablePointer<OBX_int32_array>?
        if nullLong != nil {
            var nullValue: Int32 = Int32(truncatingIfNeeded: nullLong ?? 0)
            cResult = obx_query_prop_find_int32s(cQueryProp, &nullValue)
        } else {
            cResult  = obx_query_prop_find_int32s(cQueryProp, nil)
        }
        defer { obx_int32_array_free(cResult) }
        try checkLastError()

        guard let cArray = cResult?.pointee else { return [] }
        return [T](unsafeUninitializedCapacity: cArray.count) { (ptr, initializedCount) in
            for longIndex in 0..<cArray.count {
                ptr[longIndex] = T(truncatingIfNeeded: cArray.items[longIndex])
            }
            initializedCount = cArray.count
        }
    }

    /// T: Int16 or UInt16 (only)
    internal func findInts16Internal() throws -> [T] {
        let cResult: UnsafeMutablePointer<OBX_int16_array>?
        if nullLong != nil {
            var nullValue: Int16 = Int16(truncatingIfNeeded: nullLong ?? 0)
            cResult = obx_query_prop_find_int16s(cQueryProp, &nullValue)
        } else {
            cResult = obx_query_prop_find_int16s(cQueryProp, nil)
        }
        defer { obx_int16_array_free(cResult) }
        try checkLastError()

        guard let cArray = cResult?.pointee else { return [] }
        return [T](unsafeUninitializedCapacity: cArray.count) { (ptr, initializedCount) in
            for longIndex in 0..<cArray.count {
                ptr[longIndex] = T(truncatingIfNeeded: cArray.items[longIndex])
            }
            initializedCount = cArray.count
        }
    }

    /// T: Int8 or UInt8 (only)
    internal func findInts8Internal() throws -> [T] {
        let cResult: UnsafeMutablePointer<OBX_int8_array>?
        if nullLong != nil {
            var nullValue: Int8 = Int8(truncatingIfNeeded: nullLong ?? 0)
            cResult = obx_query_prop_find_int8s(cQueryProp, &nullValue)
        } else {
            cResult = obx_query_prop_find_int8s(cQueryProp, nil)
        }
        defer { obx_int8_array_free(cResult) }
        try checkLastError()

        guard let cArray = cResult?.pointee else { return [] }
        return [T](unsafeUninitializedCapacity: cArray.count) { (ptr, initializedCount) in
            for longIndex in 0..<cArray.count {
                ptr[longIndex] = T(truncatingIfNeeded: cArray.items[longIndex])
            }
            initializedCount = cArray.count
        }
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: Values for the given property.
    public func find() throws -> [T] {
        let bits = T.self.zero.bitWidth
        if bits == 64 { return try findInts64Internal() }
        if bits == 32 { return try findInts32Internal() }
        if bits == 16 { return try findInts16Internal() }
        if bits == 8 { return try findInts8Internal() }
        throw ObjectBoxError.illegalArgument(message: "Unsupported int type with \(bits) bits")
    }

    /// Find a unique value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    /// - Throws: ObjectBoxError.uniqueViolation if more than 1 result was found.
    public func findUnique() throws -> T? {
        // Note: C API could expose this functionality in the future (core does that efficiently)
        let results = try find()
        guard results.count < 2 else {
            throw ObjectBoxError.uniqueViolation(message: "Expected a unique integer, but found \(results.count)")
        }
        return results.first
    }

}

extension PropertyQuery where T == Int64 {
    /// Provide a value to return in place of `nil` from this property query.
    /// - returns: `self` for chaining
    @discardableResult
    public func with(nullValue: Int64) -> PropertyQuery<EntityType, ValueType> {
        nullLong = nullValue
        return self
    }
}

extension PropertyQuery where T == Int64? {
    /// Provide a value to return in place of `nil` from this property query.
    /// - returns: `self` for chaining
    @discardableResult
    public func with(nullValue: Int64) -> PropertyQuery<EntityType, ValueType> {
        nullLong = nullValue
        return self
    }
}

// MARK: - Floating Point Aggregates

extension PropertyQuery where T == Double {
    /// Sums up all values for the given property over all Objects matching the query.
    public func sum() throws -> Double {
        return try doubleSum(box: box.cBox)
    }
    
    /// Finds the maximum value for the given property over all Objects matching the query.
    public func max() throws -> Double {
        return try doubleMax(box: box.cBox)
    }
    
    /// Finds the minimum value for the given property over all Objects matching the query.
    public func min() throws -> Double {
        return try doubleMin(box: box.cBox)
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public func average() throws -> Double {
        return try average(box: box.cBox)
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: Values for the given property.
    public func findDoubles() throws -> [Double] {
        return try findDoubles(box: box.cBox)
    }

    /// Find a unique value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    /// - Throws: ObjectBoxError.uniqueViolation if more than 1 result was found.
    public func findUniqueDouble() throws -> Double? {
        let results = try findDoubles(box: box.cBox)
        guard results.count < 2 else {
            throw ObjectBoxError.uniqueViolation(message: "Expected unique floating point number here, found several.")
        }
        
        return results.last
    }
}

extension PropertyQuery where T == Double? {
    /// Provide a value to return in place of `nil` from this property query.
    /// - returns: `self` for chaining
    @discardableResult
    public func with(nullValue: Double) -> PropertyQuery<EntityType, ValueType> {
        nullDouble = nullValue
        return self
    }
}

extension PropertyQuery where T == Float {
    /// Sums up all values for the given property over all Objects matching the query.
    public func sum() throws -> Double {
        return try doubleSum(box: box.cBox)
    }
    
    /// Finds the maximum value for the given property over all Objects matching the query.
    public func max() throws -> Float {
        return try Float(doubleMax(box: box.cBox))
    }
    
    /// Finds the minimum value for the given property over all Objects matching the query.
    public func min() throws -> Float {
        return try Float(doubleMin(box: box.cBox))
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public func average() throws -> Double {
        return try average(box: box.cBox)
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: Values for the given property.
    public func findFloats() throws -> [Float] {
        return try findDoubles(box: box.cBox).map { Float($0) }
    }

    /// Find a unique value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    /// - Throws: ObjectBoxError.uniqueViolation if more than 1 result was found.
    public func findUniqueFloat() throws -> Float? {
        let results = try findDoubles(box: box.cBox)
        guard results.count < 2 else {
            throw ObjectBoxError.uniqueViolation(message: "Expected unique floating point number here, found several.")
        }
        
        return results.last.map { Float($0) }
    }
}

extension PropertyQuery where T == Float? {
    /// Provide a value to return in place of `nil` from this property query.
    /// - returns: `self` for chaining
    @discardableResult
    public func with(nullValue: Float) -> PropertyQuery<EntityType, ValueType> {
        nullDouble = Double(nullValue)
        return self
    }
}

// MARK: - String

extension PropertyQuery where T: StringPropertyType {
    /// - parameter caseSensitiveCompare: Specifies if ["foo", "FOO", "Foo"] counts as 1.
    /// - returns: `self` for chaining
    @discardableResult
    public func distinct(caseSensitiveCompare: Bool = true) throws -> PropertyQuery<EntityType, ValueType> {
        obx_query_prop_distinct_case(cQueryProp, true, caseSensitiveCompare)
        try checkLastError()
        return self
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: String values for the given property.
    public func findStrings() throws -> [String] {
        return try findStrings(box: box.cBox)
    }

    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    public func findString() throws -> String? {
        return try findStrings(box: box.cBox).last
    }

    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    public func findUniqueString() throws -> String? {
        var result: String?
        
        let results = try findStrings(box: box.cBox)
        guard results.count < 2 else {
            throw ObjectBoxError.uniqueViolation(message: "Expected a unique String here, found several.")
        }
        result = (results.count == 1) ? results.last : nil
        
        return result
    }
}

extension PropertyQuery where T == String? {
    /// Set a replacement string for `nil` results.
    ///
    /// - returns: `self` for chaining
    @discardableResult
    public func with(nullString: String) -> PropertyQuery<EntityType, ValueType> {
        self.nullString = nullString
        return self
    }
}
