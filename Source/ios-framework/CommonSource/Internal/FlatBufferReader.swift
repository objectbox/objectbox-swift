//
// Copyright © 2019 ObjectBox Ltd. All rights reserved.
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

/// Lightweight struct wrapper around FlatBuffer reading.
/// Used by generated Swift code to hydrate an entity from the store.
public struct FlatBufferReader {
    private var fbr: OpaquePointer? /*OBX_fbr*/
    
    /// The pointer passed to setCurrentlyReadTableBytes must stay valid until you've finished calling into the
    /// FlatBufferReader.
    internal mutating func setCurrentlyReadTableBytes(_ newValue: UnsafeRawPointer?) {
        if let newValue = newValue {
            fbr = obx_fbr_get_root(newValue)
        } else {
            fbr = nil
        }
    }
    
    internal func unwrapFBR() -> OpaquePointer {
        guard let fbr = fbr else { fatalError("Must call setCurrentlyReadTableBytes() before calling read(at:).") }
        return fbr
    }
    
    /// - Returns: false if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> Bool {
        var result: Bool = false
        _ = obx_fbr_read_bool(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> Int8 {
        var result: Int8 = 0
        _ = obx_fbr_read_int8(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> Int16 {
        var result: Int16 = 0
        _ = obx_fbr_read_int16(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> Int32 {
        var result: Int32 = 0
        _ = obx_fbr_read_int32(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> Int64 {
        var result: Int64 = 0
        _ = obx_fbr_read_int64(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> UInt8 {
        var result: UInt8 = 0
        _ = obx_fbr_read_uint8(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> UInt16 {
        var result: UInt16 = 0
        _ = obx_fbr_read_uint16(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> UInt32 {
        var result: UInt32 = 0
        _ = obx_fbr_read_uint32(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> UInt64 {
        var result: UInt64 = 0
        _ = obx_fbr_read_uint64(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> Int {
        var result: Int64 = 0
        _ = obx_fbr_read_int64(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return Int(result)
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> UInt {
        var result: UInt64 = 0
        _ = obx_fbr_read_uint64(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return UInt(result)
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> Float {
        var result: Float = 0.0
        _ = obx_fbr_read_float(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> Double {
        var result: Double = 0.0
        _ = obx_fbr_read_double(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return result
    }
    
    /// - Returns: Jan 1st 1970 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> Date {
        // Jan 1st 1970 ... People with that birth date are still alive, but Int64.min might confuse some platforms?
        var result: Int64 = 0
        _ = obx_fbr_read_int64(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return Date(unixTimestamp: result)
    }

    /// - Returns: Jan 1st 1970 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func readNanos(at index: UInt16) -> Date {
        // Jan 1st 1970 ... People with that birth date are still alive, but Int64.min might confuse some platforms?
        var result: Int64 = 0
        _ = obx_fbr_read_int64(unwrapFBR(), index, &result) // If missing, doesn't set "result".
        return Date(unixTimestampNanos: result)
    }
    
    /// - Returns: empty string if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> String {
        guard let result = obx_fbr_read_string(unwrapFBR(), index) else { return "" }
        return String(utf8String: result) ?? "" // Should only occur if DB contains invalid UTF-8
    }
    
    /// - Returns: zero-length Data if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> Data {
        var result = OBX_bytes()
        if !obx_fbr_read_bytes(unwrapFBR(), index, &result) { return Data() }
        return Data(bytes: result.data, count: result.size)
    }
    
    /// - Returns: zero-length array if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    public func read(at index: UInt16) -> [UInt8] {
        var result = OBX_bytes()
        guard obx_fbr_read_bytes(unwrapFBR(), index, &result), let data = result.data else { return [] }
        
        let unsafePointer = data.bindMemory(to: UInt8.self, capacity: result.size)
        let bufferPointer = UnsafeBufferPointer(start: unsafePointer, count: result.size)
        return [UInt8](bufferPointer)
    }
    
    /// - Returns: The ID read, if present, or the invalid ID of 0 if no ID was present.
    public func read<E>(at index: UInt16) -> EntityId<E> where E: EntityInspectable, E: __EntityRelatable,
        E == E.EntityBindingType.EntityType {
        var result: UInt64 = 0
        if !obx_fbr_read_uint64(unwrapFBR(), index, &result) { result = 0 }
        return EntityId<E>(result)
    }
    
    /// - Returns: A to-one relation, ID will == 0 if the relation hasn't been connected yet.
    public func read<T>(at index: UInt16, store: Store) -> ToOne<T> where T: EntityInspectable, T: __EntityRelatable,
        T == T.EntityBindingType.EntityType {
        let entityId: EntityId<T> = read(at: index)
        let entityBox = store.box(for: T.self)
        return ToOne<T>(box: entityBox, id: entityId)
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> Bool? {
        var result: Bool = false
        if !obx_fbr_read_bool(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> Int8? {
        var result: Int8 = 0
        if !obx_fbr_read_int8(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> Int16? {
        var result: Int16 = 0
        if !obx_fbr_read_int16(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> Int32? {
        var result: Int32 = 0
        if !obx_fbr_read_int32(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> Int64? {
        var result: Int64 = 0
        if !obx_fbr_read_int64(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> UInt8? {
        var result: UInt8 = 0
        if !obx_fbr_read_uint8(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> UInt16? {
        var result: UInt16 = 0
        if !obx_fbr_read_uint16(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> UInt32? {
        var result: UInt32 = 0
        if !obx_fbr_read_uint32(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> UInt64? {
        var result: UInt64 = 0
        if !obx_fbr_read_uint64(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> Float? {
        var result: Float = 0.0
        if !obx_fbr_read_float(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> Double? {
        var result: Double = 0.0
        if !obx_fbr_read_double(unwrapFBR(), index, &result) { return nil }
        return result
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> Int? {
        var result: Int64 = 0
        if !obx_fbr_read_int64(unwrapFBR(), index, &result) { return nil }
        return Int(result)
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> UInt? {
        var result: UInt64 = 0
        if !obx_fbr_read_uint64(unwrapFBR(), index, &result) { return nil }
        return UInt(result)
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> Date? {
        var result: Int64 = 0
        if !obx_fbr_read_int64(unwrapFBR(), index, &result) { return nil }
        return Date(unixTimestamp: result)
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func readNanos(at index: UInt16) -> Date? {
        var result: Int64 = 0
        if !obx_fbr_read_int64(unwrapFBR(), index, &result) { return nil }
        return Date(unixTimestampNanos: result)
    }

    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> String? {
        guard let result = obx_fbr_read_string(unwrapFBR(), index) else { return nil }
        return String(utf8String: result) ?? "" // Should only occur if DB contains invalid UTF-8
    }
    
    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> Data? {
        var result = OBX_bytes()
        if !obx_fbr_read_bytes(unwrapFBR(), index, &result) { return nil }
        return Data(bytes: result.data, count: result.size)
    }

    /// - Returns: nil if the value isn't present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written, or it just is an optional)
    public func read(at index: UInt16) -> [UInt8]? {
        var result = OBX_bytes()
        guard obx_fbr_read_bytes(unwrapFBR(), index, &result), let data = result.data else { return nil }
        
        let unsafePointer = data.bindMemory(to: UInt8.self, capacity: result.size)
        let bufferPointer = UnsafeBufferPointer(start: unsafePointer, count: result.size)
        return [UInt8](bufferPointer)
    }
}
