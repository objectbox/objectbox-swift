//
// Copyright © 2021-2025 ObjectBox Ltd. All rights reserved.
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

internal class Util {

    /// Note: binary representation matters for ObjectBox, not signed/unsigned state (e.g. a casted UInt32.max works).
    /// - Returns: a new Int32 array or the given array if it already was an Int32 array.
    /// - Throws: ObjectBoxError.illegalArgument if a value is outside the 32 bit integer range
    internal static func toInt32Array<T>(_ collection: [T]) throws -> [Int32] where T: FixedWidthInteger {
        if MemoryLayout<T>.size > 4 {  // casting down: check if values fit into 32 bit
            return try collection.map {
                if $0 < Int32.min || $0 > UInt32.max { // That should work with signed and unsigned Ts
                    throw ObjectBoxError.illegalArgument(message: "Value outside the 32 bit integer range: \($0)")
                }
                return Int32(truncatingIfNeeded: $0)
            }
        } else {
            return collection as? [Int32] ?? collection.map { Int32(truncatingIfNeeded: $0) }
        }
    }

    /// Note: binary representation matters for ObjectBox, not signed/unsigned state (e.g. a casted UInt64.max works).
    /// - Returns: a new Int64 array or the given array if it already was an Int64 array.
    internal static func toInt64Array<T>(_ collection: [T]) -> [Int64] where T: FixedWidthInteger {
        return collection as? [Int64] ?? collection.map { Int64(truncatingIfNeeded: $0) }
    }

    /// Like withCString but for String arrays.
    /// Always provides a valid (non-nil) pointer, even for empty arrays.
    internal static func withArrayOfCStrings<R>(
            _ strings: [String],
            _ body: (UnsafePointer<UnsafePointer<CChar>?>, Int) -> R
    ) -> R {
        // Result placeholder
        var result: R?
        let count = strings.count

        // Array of C-string pointers (the “char*[]”)
        var cPointers = [UnsafePointer<CChar>?](repeating: nil, count: count)

        // For empty arrays, provide a valid pointer (required by some C APIs marked _Nonnull)
        if count == 0 {
            var empty: UnsafePointer<CChar>?
            return withUnsafePointer(to: &empty) { ptr in
                return body(ptr, 0)
            }
        }

        func recurse(_ index: Int) {
            if index == count {
                // All strings converted, call body with buffer pointer
                cPointers.withUnsafeBufferPointer { buffer in
                    result = body(buffer.baseAddress!, count)
                }
                return
            }

            strings[index].withCString { cStr in
                cPointers[index] = cStr
                recurse(index + 1) // nested closure keeps all previous cStr alive
            }
        }

        recurse(0)
        return result!
    }

    /// Like withCString but for String arrays – mutable pointer variant.
    /// Always provides a valid (non-nil) pointer, even for empty arrays.
    internal static func withArrayOfCStringsMutable<R>(
        _ strings: [String],
        _ body: (UnsafeMutablePointer<UnsafePointer<CChar>?>, Int) -> R
    ) -> R {
        // Reuse the immutable version and cast the pointer
        return withArrayOfCStrings(strings) { ptr, count in
            return body(UnsafeMutablePointer(mutating: ptr), count)
        }
    }

}
