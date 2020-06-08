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

import XCTest
@testable import ObjectBox

// swiftlint:disable type_body_length force_try
class EntityNullablePropertyTests: XCTestCase {

    var store: Store!
    var box: Box<NullablePropertyEntity>!

    override func setUp() {
        super.setUp()
        let model: OpaquePointer = {
            let modelBuilder = try! ModelBuilder()
            try! NullablePropertyEntity.buildEntity(modelBuilder: modelBuilder)
            return modelBuilder.finish()
        }()
        store = StoreHelper.tempStore(model: model)
        box = store.box(for: NullablePropertyEntity.self)
    }

    override func tearDown() {
        try! store?.closeAndDeleteAllFiles()
        store = nil
        super.tearDown()
    }

    func testNullableInt() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeInt: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeInt)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        originalEntity.maybeInt = Int.max
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeInt, Int.max)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeInt = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeInt)
        } else {
            XCTFail("Get failed"); return
        }
    }

    func testNullableInt64() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeInt64: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeInt64)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        originalEntity.maybeInt64 = Int64.max
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeInt64, Int64.max)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeInt64 = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeInt64)
        } else {
            XCTFail("Get failed"); return
        }
    }

    func testNullableInt32() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeInt32: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeInt32)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        originalEntity.maybeInt32 = Int32.max
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeInt32, Int32.max)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeInt32 = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeInt32)
        } else {
            XCTFail("Get failed"); return
        }
    }

    func testNullableInt16() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeInt16: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeInt16)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        originalEntity.maybeInt16 = Int16.max
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeInt16, Int16.max)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeInt16 = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeInt16)
        } else {
            XCTFail("Get failed"); return
        }
    }

    func testNullableInt8() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeInt8: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeInt8)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        originalEntity.maybeInt8 = Int8.max
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeInt8, Int8.max)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeInt8 = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeInt8)
        } else {
            XCTFail("Get failed"); return
        }
    }

    func testNullableBool() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeBool: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeBool)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        originalEntity.maybeBool = true
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeBool, true)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeBool = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeBool)
        } else {
            XCTFail("Get failed"); return
        }
    }

    func testNullableFloat() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeFloat: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeFloat)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        originalEntity.maybeFloat = Float.greatestFiniteMagnitude
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeFloat, Float.greatestFiniteMagnitude)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeFloat = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeFloat)
        } else {
            XCTFail("Get failed"); return
        }
    }

    func testNullableDouble() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeDouble: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeDouble)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        originalEntity.maybeDouble = Double.greatestFiniteMagnitude
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeDouble, Double.greatestFiniteMagnitude)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeDouble = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeDouble)
        } else {
            XCTFail("Get failed"); return
        }
    }

    func testNullableDate() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeDate: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeDate)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        let date = Date.init(timeIntervalSince1970: 123456)
        originalEntity.maybeDate = date
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeDate, date)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeDate = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeDate)
        } else {
            XCTFail("Get failed"); return
        }
    }

    func testNullableString() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeString: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeString)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        let string = "Lorem ipsum foo bar"
        originalEntity.maybeString = string
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeString, string)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeString = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeString)
        } else {
            XCTFail("Get failed"); return
        }
    }

    func testNullableByteVector() throws {
        XCTAssert(try box.isEmpty())

        // Initial nil value
        let originalEntity = NullablePropertyEntity(maybeByteVector: nil)
        let entityId = try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeByteVector)
        } else {
            XCTFail("Get failed"); return
        }

        // Non-nil change
        let stringData = "Lorem ipsum data".data(using: .utf8)
        originalEntity.maybeByteVector = stringData
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertEqual(obj.maybeByteVector, stringData)
        } else {
            XCTFail("Get failed"); return
        }

        // Reset to nil
        originalEntity.maybeByteVector = nil
        try box.put(originalEntity)

        if let obj = try box.get(entityId) {
            XCTAssertNil(obj.maybeByteVector)
        } else {
            XCTFail("Get failed"); return
        }
    }

}
// swiftlint:enable type_body_length
