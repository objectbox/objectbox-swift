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
///      let query = personBox.query { Person.age > 29 }
///      let ageQuery = query.property(Person.age)
///      let averageAge = ageQuery.average
///
/// - Note: Property values do currently not consider any sorting order defined in the main `Query` object.
public class PropertyQuery<E: EntityInspectable & __EntityRelatable, T: EntityPropertyTypeConvertible>
    where E == E.EntityBindingType.EntityType {

    /// The entity type this query is targeting.
    public typealias EntityType = E

    /// The type of the entity's property this query is targeting.
    public typealias ValueType = T

    internal let box: Box<EntityType>
    internal var nullString: String?
    internal var nullLong: Int64?
    internal var nullDouble: Double?
    /// True if only distinct values should be returned (e.g. 1,2,3 instead of 1,1,2,3,3,3).
    internal var makeDistinct = false
    internal var makeCompareCaseSensitive = true
    internal var store: Store
    internal var cQuery: OpaquePointer /*OBX_query*/
    internal var propertyId: obx_schema_id

    internal init(query: OpaquePointer /*OBX_query*/, propertyId: obx_schema_id, store: Store) {
        self.store = store
        self.cQuery = query
        self.propertyId = propertyId
        self.box = store.box(for: EntityType.self)
    }
}

// MARK: - Central bottlenecks

extension PropertyQuery {
    internal func longSum(box: OpaquePointer /*OBX_box*/) throws -> Int64 {
        var result = Int64(0)
        try checkLastError(obx_query_prop_sum_int(cQuery, box, propertyId, &result))
        return result
    }
    
    internal func longMax(box: OpaquePointer /*OBX_box*/) throws -> Int64 {
        var result = Int64(0)
        try checkLastError(obx_query_prop_max_int(cQuery, box, propertyId, &result))
        return result
    }
    
    internal func longMin(box: OpaquePointer /*OBX_box*/) throws -> Int64 {
        var result = Int64(0)
        try checkLastError(obx_query_prop_min_int(cQuery, box, propertyId, &result))
        return result
    }
    
    internal func findLong(box: OpaquePointer /*OBX_box*/) throws -> Int64? {
        let result = try findLongs(box: box)
        return result.last
    }
    
    internal func findLongs(box: OpaquePointer /*OBX_box*/) throws -> [Int64] {
        let cResult: UnsafeMutablePointer<OBX_int64_array>?
        var nullValue: Int64 = nullLong ?? 0
        cResult = obx_query_prop_int64_find(cQuery, box, propertyId,
                                            (nullLong != nil) ? UnsafePointer<Int64>(&nullValue) : nil, makeDistinct)
        try checkLastError()
        defer { obx_int64_array_free(cResult) }
        
        guard let longs = cResult?.pointee else { return [] }
        
        var result = [Int64]()
        result.reserveCapacity(longs.count)
        
        for longIndex in 0 ..< longs.count {
            result.append(longs.items[longIndex])
        }
        
        return result
    }
    
    internal func doubleSum(box: OpaquePointer /*OBX_box*/) throws -> Double {
        var result = Double(0)
        try checkLastError(obx_query_prop_sum(cQuery, box, propertyId, &result))
        return result
    }
    
    internal func doubleMax(box: OpaquePointer /*OBX_box*/) throws -> Double {
        var result = Double(0)
        try checkLastError(obx_query_prop_max(cQuery, box, propertyId, &result))
        return result
    }
    
    internal func doubleMin(box: OpaquePointer /*OBX_box*/) throws -> Double {
        var result = Double(0)
        try checkLastError(obx_query_prop_min(cQuery, box, propertyId, &result))
        return result
    }
    
    internal func findDouble(box: OpaquePointer /*OBX_box*/) throws -> Double? {
        let result = try findDoubles(box: box)
        return result.last
    }
    
    internal func findDoubles(box: OpaquePointer /*OBX_box*/)
        throws -> [Double] {
        let cResult: UnsafeMutablePointer<OBX_double_array>?
        var nullValue: Double = nullDouble ?? 0.0
        cResult = obx_query_prop_double_find(cQuery, box, propertyId,
                                             (nullDouble != nil) ? UnsafePointer<Double>(&nullValue) : nil,
                                             makeDistinct)
        try checkLastError()
        
        defer { if let cResult = cResult { obx_double_array_free(cResult) } }
        
        guard let doubles = cResult?.pointee else { return [] }
        
        var result = [Double]()
        result.reserveCapacity(doubles.count)
        
        for doubleIndex in 0 ..< doubles.count {
            result.append(doubles.items[doubleIndex])
        }
        
        return result
    }
    
    internal func average(box: OpaquePointer /*OBX_box*/) throws -> Double {
        var result = Double(0)
        try checkLastError(obx_query_prop_avg(cQuery, box, propertyId, &result))
        return result
    }
    
    internal func findStrings(box: OpaquePointer /*OBX_box*/)
        throws -> [String] {
        let fetch = { (ptr: UnsafePointer<Int8>?) -> UnsafeMutablePointer<OBX_string_array>? in
            let result: UnsafeMutablePointer<OBX_string_array>?
            var flags: OBXQueryFlags = []
            if self.makeDistinct {
                flags.insert(self.makeCompareCaseSensitive ? .DISTINCT_CASE_SENSITIVE : .DISTINCT_CASE_INSENSITIVE)
            }
            result = obx_query_prop_string_find(self.cQuery, box, self.propertyId, ptr, flags)
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
        
        var result = [String]()
        result.reserveCapacity(strings.count)
        
        for stringIndex in 0 ..< strings.count {
            if let string = strings.items[stringIndex] {
                result.append(String(utf8String: string)!)
            }
        }
        
        return result
    }
}

extension PropertyQuery {
    /// The count of objects matching this query.
    public var count: Int {
        var result: UInt64 = 0
        
        do {
            try checkLastError(obx_query_prop_count(cQuery, box.cBox, propertyId, makeDistinct, &result))
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int(result)
    }
}

// MARK: - Distinct

extension PropertyQuery where T: EntityScalarPropertyType {
    /// Enable that only distinct values should be returned (e.g. 1,2,3 instead of 1,1,2,3,3,3).
    ///
    /// - Note: Cannot be unset.
    /// - Returns: `self` for chaining
    @discardableResult
    public func distinct() -> PropertyQuery<EntityType, ValueType> {
        makeDistinct = true
        return self
    }
}

// MARK: - Integer Aggregates

// `longSum` guarantees Int64, but Int may be Int32 on some platforms;
// so we wrap it in the easy-to-consume Int, except for Int64

extension PropertyQuery where T == Int {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Int {
        var result: Int64 = 0
        
        do {
            result = try longSum(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int(result)
    }

    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Int {
        var result: Int64 = 0
        
        do {
            result = try longMax(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int(result)
    }

    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Int {
        var result: Int64 = 0
        
        do {
            result = try longMin(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int(result)
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        var result: Double = 0
        
        do {
            result = try average(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
            
        return result
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: Values for the given property.
    public func findIntegers() -> [Int] {
        var result: [Int64] = []
        
        do {
            result = try findLongs(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result.map { Int($0) }
    }

    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    public func findInteger() -> Int? {
        var result: Int64?
        
        do {
            result = try findLong(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        if let result = result {
            return Int(result)
        } else {
            return nil
        }
    }
}

extension PropertyQuery where T: LongPropertyType {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Int64 {
        var result: Int64 = 0
        
        do {
            result = try longSum(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }

    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Int64 {
        var result: Int64 = 0
        
        do {
            result = try longMax(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }

    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Int64 {
        var result: Int64 = 0
        
        do {
            result = try longMin(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        var result: Double = 0
        
        do {
            result = try average(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
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
        var result: [Int64] = []
        
        do {
            result = try findLongs(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }

    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found, or unique was requested and
    ///             not exactly 1 result was returned.
    public func findLong() -> Int64? {
        return findInt64()
    }

    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    public func findInt64() -> Int64? {
        var result: Int64?
        
        do {
            result = try findLong(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }

    /// Find a unique value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    /// - Throws: ObjectBoxError.uniqueViolation if more than 1 result was found.
    public func findUniqueInt64() throws -> Int64? {
        var result: Int64?
        
        let results = try findLongs(box: box.cBox)
        guard results.count < 2 else {
            throw ObjectBoxError.uniqueViolation(message: "Expected a unique integer here, found several.")
        }
        result = results.last
        
        return result
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

extension PropertyQuery where T == Int32 {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Int {
        var result: Int64 = 0
        
        do {
            result = try longSum(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int(result)
    }
    
    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Int32 {
        var result: Int64 = 0
        
        do {
            result = try longMax(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int32(result)
    }
    
    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Int32 {
        var result: Int64 = 0
        
        do {
            result = try longMin(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int32(result)
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        var result: Double = 0
        
        do {
            result = try average(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }
}

extension PropertyQuery where T == Int16 {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Int {
        var result: Int = 0
        
        do {
            result = Int(try longSum(box: box.cBox))
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }
    
    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Int16 {
        var result: Int64 = 0
        
        do {
            result = try longMax(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int16(result)
    }
    
    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Int16 {
        var result: Int64 = 0
        
        do {
            result = try longMin(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int16(result)
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        var result: Double = 0
        
        do {
            result = try average(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }
}

extension PropertyQuery where T == Int8 {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Int {
        var result: Int64 = 0
        
        do {
            result = try longSum(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int(result)
    }
    
    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Int8 {
        var result: Int = 0
        
        do {
            result = Int(try longMax(box: box.cBox))
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int8(result)
    }
    
    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Int8 {
        var result: Int = 0
        
        do {
            result = Int(try longMin(box: box.cBox))
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Int8(result)
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        var result: Double = 0
        
        do {
            result = try average(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }
}

// MARK: - Floating Point Aggregates

extension PropertyQuery where T == Double {
    /// Sums up all values for the given property over all Objects matching the query.
    public var sum: Double {
        var result: Double = 0
        
        do {
            result = try doubleSum(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }
    
    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Double {
        var result: Double = 0
        
        do {
            result = try doubleMax(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }
    
    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Double {
        var result: Double = 0
        
        do {
            result = try doubleMin(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Double {
        var result: Double = 0
        
        do {
            result = try average(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: Values for the given property.
    public func findDoubles() -> [Double] {
        var result: [Double] = []
        
        do {
            result = try findDoubles(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
    }
    
    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found, or unique was requested and
    ///             not exactly 1 result was returned.
    public func findDouble() -> Double? {
        var result: Double?
        
        do {
            result = try findDouble(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
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
    public var sum: Float {
        var result: Double = 0
        
        do {
            result = try doubleSum(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Float(result)
    }
    
    /// Finds the maximum value for the given property over all Objects matching the query.
    public var max: Float {
        var result: Double = 0
        
        do {
            result = try doubleMax(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Float(result)
    }
    
    /// Finds the minimum value for the given property over all Objects matching the query.
    public var min: Float {
        var result: Double = 0
        
        do {
            result = try doubleMin(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Float(result)
    }

    /// Calculates the average of all values for the given property over all Objects matching the query.
    public var average: Float {
        var result: Double = 0
        
        do {
            result = try average(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return Float(result)
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: Values for the given property.
    public func findFloats() -> [Float] {
        var result: [Double] = []
        
        do {
            result = try findDoubles(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result.map { Float($0) }
    }
    
    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    public func findFloat() -> Float? {
        var result: Double?
        
        do {
            result = try findDouble(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result.map { Float($0) }
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
    public func distinct(caseSensitiveCompare: Bool = true) -> PropertyQuery<EntityType, ValueType> {
        self.makeDistinct = true
        self.makeCompareCaseSensitive = caseSensitiveCompare
        return self
    }

    /// Find the values for the given property for objects matching the query.
    ///
    /// - Note: Results are not guaranteed to be in any particular order.
    /// - Returns: String values for the given property.
    public func findStrings() -> [String] {
        var result = [String]()
        
        do {
            result = try findStrings(box: box.cBox)
        } catch {
            ignoreAndLog(error: error)
        }

        return result
    }

    /// Find a value for the given property.
    ///
    /// - Returns: A value of the objects matching the query, `nil` if no value was found.
    public func findString() -> String? {
        var result: String?
        
        do {
            result = try findStrings(box: box.cBox).last
        } catch {
            ignoreAndLog(error: error)
        }
        
        return result
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
