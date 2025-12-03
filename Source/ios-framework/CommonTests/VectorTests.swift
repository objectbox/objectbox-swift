//
// Copyright © 2024-2025 ObjectBox Ltd. <https://objectbox.io>
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

import ObjectBox
import XCTest

/// Tests float and string vector properties.
class VectorTests: XCTestCase {
    
    var store: Store!
    
    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        store = try! Store.testEntities()
    }

    override func tearDown() {
        // swiftlint:disable:next force_try
        try! store?.closeAndDeleteAllFiles()
        store = nil
        super.tearDown()
    }

    private func checkQueryCount(_ box: Box<VectorTestEntity>, condition: QueryCondition<VectorTestEntity>,
                                 expectedCount: Int) throws {
        let query = try box.query { condition }.build()
        let count = try query.count()
        XCTAssertEqual(count, expectedCount)
    }
    
    func testPutAndGet() throws {
        let box: Box<VectorTestEntity> = store.box()
        let testEntity = VectorTestEntity()
        testEntity.floatArray = [-200.01, 200.01]
        testEntity.floatArrayNull = testEntity.floatArray
        testEntity.stringArray = ["Hello", "World"]
        testEntity.stringArrayNull = testEntity.stringArray
        testEntity.int32Array = [0, Int32.min, Int32.max]
        testEntity.int32ArrayNull = testEntity.int32Array
        testEntity.int64Array = [0, Int64.min, Int64.max]
        testEntity.int64ArrayNull = testEntity.int64Array
        let id = try box.put(testEntity)
        let read = try box.get(id)!
        XCTAssertEqual(read.floatArray, [-200.01, 200.01])
        XCTAssertEqual(read.floatArrayNull, [-200.01, 200.01])
        XCTAssertEqual(read.stringArray, ["Hello", "World"])
        XCTAssertEqual(read.stringArrayNull, ["Hello", "World"])
        XCTAssertEqual(read.int32Array, [0, Int32.min, Int32.max])
        XCTAssertEqual(read.int32ArrayNull, [0, Int32.min, Int32.max])
        XCTAssertEqual(read.int64Array, [0, Int64.min, Int64.max])
        XCTAssertEqual(read.int64ArrayNull, [0, Int64.min, Int64.max])
    }
    
    func testPutAndGetDefaultValues() throws {
        let box: Box<VectorTestEntity> = store.box()
        let id = try box.put(VectorTestEntity())
        let read = try box.get(id)!
        XCTAssertEqual(read.floatArray, [])
        XCTAssertEqual(read.floatArrayNull, nil)
        XCTAssertEqual(read.stringArray, [])
        XCTAssertEqual(read.stringArrayNull, nil)
    }
    
    func testComparison_Int32Array() throws {
        let box: Box<VectorTestEntity> = store.box(for: VectorTestEntity.self)

        XCTAssertNoThrow(try box.put([
            VectorTestEntity(int32Array: [4, 5, Int32.max]),
            VectorTestEntity(int32Array: [1, 2, 3]),
            VectorTestEntity(int32Array: [-1, -2, Int32.min])
        ]))
        
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isEqual(to: 1), expectedCount: 1)

        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isGreaterThan(-3), expectedCount: 3)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isGreaterThan(1), expectedCount: 2)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isGreaterThan(4), expectedCount: 1)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isGreaterThan(Int32.max), expectedCount: 0)

        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isGreaterOrEqual(3), expectedCount: 2)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isGreaterOrEqual(4), expectedCount: 1)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isGreaterOrEqual(Int32.max), expectedCount: 1)

        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isLessOrEqual(4), expectedCount: 3)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isLessOrEqual(3), expectedCount: 2)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isLessOrEqual(1), expectedCount: 2)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isLessOrEqual(0), expectedCount: 1)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isLessOrEqual(Int32.min), expectedCount: 1)

        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isLessThan(5), expectedCount: 3)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isLessThan(3), expectedCount: 2)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isLessThan(1), expectedCount: 1)
        try checkQueryCount(box, condition: VectorTestEntity.int32Array.isLessThan(Int32.min), expectedCount: 0)
    }
    
    func testComparison_Int64Array() throws {
        let box: Box<VectorTestEntity> = store.box(for: VectorTestEntity.self)

        XCTAssertNoThrow(try box.put([
            VectorTestEntity(int64Array: [4, 5, Int64.max]),
            VectorTestEntity(int64Array: [1, 2, 3]),
            VectorTestEntity(int64Array: [-1, -2, Int64.min])
        ]))
        
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isEqual(to: 1), expectedCount: 1)

        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isGreaterThan(-3), expectedCount: 3)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isGreaterThan(1), expectedCount: 2)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isGreaterThan(4), expectedCount: 1)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isGreaterThan(Int64.max), expectedCount: 0)
        
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isGreaterOrEqual(3), expectedCount: 2)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isGreaterOrEqual(4), expectedCount: 1)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isGreaterOrEqual(Int64.max), expectedCount: 1)

        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isLessOrEqual(4), expectedCount: 3)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isLessOrEqual(3), expectedCount: 2)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isLessOrEqual(1), expectedCount: 2)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isLessOrEqual(0), expectedCount: 1)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isLessOrEqual(Int64.min), expectedCount: 1)

        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isLessThan(5), expectedCount: 3)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isLessThan(3), expectedCount: 2)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isLessThan(1), expectedCount: 1)
        try checkQueryCount(box, condition: VectorTestEntity.int64Array.isLessThan(Int64.min), expectedCount: 0)
    }


    func testFind_StringArray() throws {
        let box: Box<VectorTestEntity> = store.box(for: VectorTestEntity.self)

        XCTAssertNoThrow(try box.put([
            VectorTestEntity(stringArray: ["apple", "banana", "cherry"]),
            VectorTestEntity(stringArray: ["apple", "BANANA", "cherry"])
        ]))

        let conditionIsNil = VectorTestEntity.stringArrayNull.isNil()
        XCTAssertEqual(try box.query { conditionIsNil }.build().count(), 2)

        let conditionIsNotNil = VectorTestEntity.stringArrayNull.isNotNil()
        XCTAssertEqual(try box.query { conditionIsNotNil }.build().count(), 0)

        let resultIgnoreCase = try box.query({
            VectorTestEntity.stringArray.containsElement(element: "banana", caseSensitive: false)
        }).build().find()
        XCTAssertEqual(resultIgnoreCase.count, 2)
        XCTAssertEqual(resultIgnoreCase[0].stringArray, ["apple", "banana", "cherry"])
        XCTAssertEqual(resultIgnoreCase[1].stringArray, ["apple", "BANANA", "cherry"])

        let resultCaseSensitive = try box.query({
            VectorTestEntity.stringArray.containsElement(element: "banana", caseSensitive: true)
        }).build().find()
        XCTAssertEqual(resultCaseSensitive.count, 1)
        XCTAssertEqual(resultCaseSensitive[0].stringArray, ["apple", "banana", "cherry"])
    }
}
