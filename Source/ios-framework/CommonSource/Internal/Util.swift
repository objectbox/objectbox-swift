//
// Copyright © 2021 ObjectBox Ltd. All rights reserved.
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
}
