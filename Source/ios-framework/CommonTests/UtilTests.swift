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

import XCTest
@testable import ObjectBox

class UtilTests: XCTestCase {

    func testToInt32Array() throws {
        let uint32Array: [UInt32] = [0, 1000, UInt32.max]
        XCTAssertEqual(try Util.toInt32Array(uint32Array), [0, 1000, -1])

        let int32Array: [Int32] = [Int32.min, 0, 1000, Int32.max]
        XCTAssert(try Util.toInt32Array(int32Array) == int32Array)  // === does not work with arrays

        let int64Array: [Int64] = [Int64(Int32.min), -1000, 0, 1000, Int64(UInt32.max)]
        XCTAssertEqual(try Util.toInt32Array(int64Array), [Int32.min, -1000, 0, 1000, -1])

        let int64ArrayBad: [Int64] = [Int64(UInt32.max) + 1]
        XCTAssertThrowsError(try Util.toInt32Array(int64ArrayBad))

        let int64ArrayBadNegative: [Int64] = [Int64(Int32.min) - 1]
        XCTAssertThrowsError(try Util.toInt32Array(int64ArrayBadNegative))
    }

    func testToInt64Array() {
        let uint32Array: [UInt32] = [0, 1000, UInt32.max]
        XCTAssertEqual(Util.toInt64Array(uint32Array), [0, 1000, Int64(UInt32.max)])

        let int32Array: [Int32] = [Int32.min, -1000, 0, 1000, Int32.max]
        XCTAssertEqual(Util.toInt64Array(int32Array), [Int64(Int32.min), -1000, 0, 1000, Int64(Int32.max)])
    }
}
