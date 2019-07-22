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
class PropertyQueryTests: XCTestCase {

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

    // MARK: -

    func testPropertyQuery_Count() throws {
        try box.put([
            NullablePropertyEntity(int32: 1, double: 1.11, string: "Matt"),
            NullablePropertyEntity(int32: 0, double: 2.22, string: "Mark"),
            NullablePropertyEntity(int32: 3, double: 3.33, string: "Bob"),
            NullablePropertyEntity(int32: 4, double: 0, string: "")
            ])

        let query = box.query {
            NullablePropertyEntity.double > 1.0
                && NullablePropertyEntity.int32 > 2
                && NullablePropertyEntity.string.hasSuffix("b")
        }.build()

        // Combined results
        XCTAssertEqual(query.count, 1)

        // Per-property results count non-nil values
        XCTAssertEqual(query.property(NullablePropertyEntity.double).count, 1)
        XCTAssertEqual(query.property(NullablePropertyEntity.int32).count, 1)
        XCTAssertEqual(query.property(NullablePropertyEntity.string).count, 1)
    }

    func testPropertyQuery_CountDistinct() throws {
        try box.put([
            NullablePropertyEntity(int32: 1),
            NullablePropertyEntity(int32: 2),
            NullablePropertyEntity(int32: 2),
            NullablePropertyEntity(int32: 3)
            ])

        let query = box.query { NullablePropertyEntity.int32 > 1 }.build()

        XCTAssertEqual(query.count, 3)
        XCTAssertEqual(query.property(NullablePropertyEntity.int32).count, 3)
        XCTAssertEqual(query.property(NullablePropertyEntity.int32).distinct().count, 2)
    }

    // MARK: - Long

    func testPropertyQuery_LongSum() throws {
        try box.put([
            NullablePropertyEntity(int64: 100),
            NullablePropertyEntity(int64: 200),
            NullablePropertyEntity(int64: 300),
            NullablePropertyEntity(int64: 400)
            ])

        let query = box.query { NullablePropertyEntity.int64.isIn([300, 400]) }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.int64).sum, 700)
    }

    func testPropertyQuery_LongMax() throws {
        try box.put([
            NullablePropertyEntity(int64: 100),
            NullablePropertyEntity(int64: 200),
            NullablePropertyEntity(int64: 300),
            NullablePropertyEntity(int64: 400)
            ])

        let query = box.query { NullablePropertyEntity.int64 < 300 }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.int64).max, 200)
    }

    func testPropertyQuery_LongMin() throws {
        try box.put([
            NullablePropertyEntity(int64: 100),
            NullablePropertyEntity(int64: 200),
            NullablePropertyEntity(int64: 300),
            NullablePropertyEntity(int64: 400)
            ])

        let query = box.query { NullablePropertyEntity.int64 > 200 }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.int64).min, 300)
    }

    func testPropertyQuery_LongAverage() throws {
        try box.put([
            NullablePropertyEntity(int64: 100),
            NullablePropertyEntity(int64: 200),
            NullablePropertyEntity(int64: 300),
            NullablePropertyEntity(int64: 400)
            ])

        let query = box.query { NullablePropertyEntity.int64 < 400 && NullablePropertyEntity.int64 > 100 }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.int64).average, 250)
    }

    func testPropertyQuery_FindLongs() throws {
        try box.put([
            NullablePropertyEntity(int64: 1),
            NullablePropertyEntity(int64: 1),
            NullablePropertyEntity(int64: 2),
            NullablePropertyEntity(int64: 2)
            ])

        let query = box.query().build()

        XCTAssertEqual(query.count, 4)
        XCTAssertEqual(query.property(NullablePropertyEntity.int64).findInt64s().count, 4)
        XCTAssertEqual(query.property(NullablePropertyEntity.int64).distinct().findInt64s().count, 2)
//        let int64s = query.property(NullablePropertyEntity.int64).findInt64s(offset: 1, limit: 2)
//        XCTAssertEqual(int64s.count, 2)
//        // We don't really have an ordering guarantee, but currently we return in insertion order, which is why this
//        // test works in practice.
//        // TODO: This test should really use .ordered(), but that's not yet implemented for property queries.
//        XCTAssertEqual(int64s[0], 1)
//        XCTAssertEqual(int64s[1], 2)

        // TODO: allow null?
//        XCTAssertEqual(query.property(AllTypesEntity.string)
//            .with(nullString: "x").findLongs().count, 5)
//        XCTAssertEqual(query.property(AllTypesEntity.string)
//            .distinct(caseSensitiveCompare: true)
//            .with(nullString: "x").findLongs().count, 5)
//        XCTAssertEqual(query.property(AllTypesEntity.string)
//            .distinct(caseSensitiveCompare: false)
//            .with(nullString: "x").findLongs().count, 3)
    }

    func testPropertyQuery_FindLong() throws {
        try box.put([
            NullablePropertyEntity(int64: 1),
            NullablePropertyEntity(int64: 1),
            NullablePropertyEntity(int64: 2),
            NullablePropertyEntity(int64: 2)
            ])

        let query = box.query().build()

        XCTAssertEqual(query.count, 4)
        XCTAssertNotNil(query.property(NullablePropertyEntity.int64).findInt64())
        XCTAssertNotNil(query.property(NullablePropertyEntity.int64).distinct().findInt64())
        // TODO: The following was a fatal exception. Changed it to return NIL, which callers need to check for anyway.
        XCTAssertThrowsError(try query.property(NullablePropertyEntity.int64).findUniqueInt64())

        XCTAssertNoThrow(_ = try box.put(NullablePropertyEntity(int64: 100)))
        XCTAssertEqual(query.count, 5)

        // "unique" does not produce a unique result, but asserts there's only 1 result
        XCTAssertThrowsError(try query.property(NullablePropertyEntity.int64).findUniqueInt64())
        let uniqueQuery = box.query { NullablePropertyEntity.int64 > 2 }.build()
        XCTAssertEqual(try uniqueQuery.property(NullablePropertyEntity.int64).findUniqueInt64(), 100)
    }

    // MARK: - Integer

    func testPropertyQuery_IntegerSum() throws {
        try box.put([
            NullablePropertyEntity(int32: 100),
            NullablePropertyEntity(int32: 200),
            NullablePropertyEntity(int32: 300),
            NullablePropertyEntity(int32: 400)
            ])

        let query = box.query { NullablePropertyEntity.int32.isIn([300, 400]) }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.int32).sum, 700)
    }

    func testPropertyQuery_IntegerMax() throws {
        try box.put([
            NullablePropertyEntity(int32: 100),
            NullablePropertyEntity(int32: 200),
            NullablePropertyEntity(int32: 300),
            NullablePropertyEntity(int32: 400)
            ])

        let query = box.query { NullablePropertyEntity.int32 < 400 }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.int32).max, 300)
    }

    func testPropertyQuery_IntegerMin() throws {
        try box.put([
            NullablePropertyEntity(int32: 100),
            NullablePropertyEntity(int32: 200),
            NullablePropertyEntity(int32: 300),
            NullablePropertyEntity(int32: 400)
            ])

        let query = box.query { NullablePropertyEntity.int32 > 100 }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.int32).min, 200)
    }

    func testPropertyQuery_IntegerAverage() throws {
        try box.put([
            NullablePropertyEntity(int32: 100),
            NullablePropertyEntity(int32: 200),
            NullablePropertyEntity(int32: 300),
            NullablePropertyEntity(int32: 400)
            ])

        let query = box.query { NullablePropertyEntity.int32 > 200 }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.int32).average, 350)
    }

    // MARK: - Double

    func testPropertyQuery_DoubleSum() throws {
        try box.put([
            NullablePropertyEntity(double: 1.1),
            NullablePropertyEntity(double: 2.2),
            NullablePropertyEntity(double: 3.3),
            NullablePropertyEntity(double: 4.4)
            ])

        let query = box.query { NullablePropertyEntity.double > 2.5 }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.double).sum, 7.7)
    }

    func testPropertyQuery_DoubleMax() throws {
        try box.put([
            NullablePropertyEntity(double: 1.1),
            NullablePropertyEntity(double: 2.2),
            NullablePropertyEntity(double: 3.3),
            NullablePropertyEntity(double: 4.4)
            ])

        let query = box.query { NullablePropertyEntity.double > 2 && NullablePropertyEntity.double < 4 }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.double).max, 3.3)
    }

    func testPropertyQuery_DoubleMin() throws {
        try box.put([
            NullablePropertyEntity(double: 1.1),
            NullablePropertyEntity(double: 2.2),
            NullablePropertyEntity(double: 3.3),
            NullablePropertyEntity(double: 4.4)
            ])

        let query = box.query { NullablePropertyEntity.double > 2 && NullablePropertyEntity.double < 4 }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.double).min, 2.2)
    }

    func testPropertyQuery_DoubleAverage() throws {
        try box.put([
            NullablePropertyEntity(double: 1.1),
            NullablePropertyEntity(double: 2.2),
            NullablePropertyEntity(double: 3.3),
            NullablePropertyEntity(double: 4.4)
            ])

        let query = box.query { NullablePropertyEntity.double > 1.0 }.build()
        XCTAssertEqual(query.property(NullablePropertyEntity.double).average, 2.75)
    }

    // MARK: - String

    func testPropertyQuery_FindMaybeStrings() throws {
        try box.put([
            NullablePropertyEntity(maybeString: "abc"),
            NullablePropertyEntity(maybeString: "aBc"),
            NullablePropertyEntity(maybeString: "DEF"),
            NullablePropertyEntity(maybeString: "def"),
            NullablePropertyEntity(maybeString: nil)
            ])

        let query = box.query().build()

        XCTAssertEqual(query.count, 5)
        XCTAssertEqual(query.property(NullablePropertyEntity.maybeString).findStrings().count, 4)
        XCTAssertEqual(query.property(NullablePropertyEntity.maybeString).distinct().findStrings().count, 4)
        XCTAssertEqual(query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: true).findStrings().count, 4)
        XCTAssertEqual(query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: false).findStrings().count, 2)

        XCTAssertEqual(query.property(NullablePropertyEntity.maybeString)
            .with(nullString: "REPLACEMENT").findStrings().count, 5)
        XCTAssertEqual(query.property(NullablePropertyEntity.maybeString)
            .with(nullString: "REPLACEMENT")
            .distinct(caseSensitiveCompare: false).findStrings().count, 3)

        XCTAssertEqual(query.property(NullablePropertyEntity.maybeString)
            .with(nullString: "x").findStrings().count, 5)
        XCTAssertEqual(query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: true)
            .with(nullString: "x").findStrings().count, 5)
        XCTAssertEqual(query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: false)
            .with(nullString: "x").findStrings().count, 3)
    }

    func testPropertyQuery_FindString() throws {
        try box.put([
            NullablePropertyEntity(maybeString: "abc"),
            NullablePropertyEntity(maybeString: "aBc"),
            NullablePropertyEntity(maybeString: "DEF"),
            NullablePropertyEntity(maybeString: "def"),
            NullablePropertyEntity(maybeString: nil)
            ])

        let query = box.query().build()

        XCTAssertEqual(query.count, 5)
        XCTAssertNotNil(query.property(NullablePropertyEntity.maybeString).findString())
        XCTAssertNotNil(query.property(NullablePropertyEntity.maybeString).distinct().findString())
        XCTAssertNotNil(query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: true).findString())
        XCTAssertNotNil(query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: false).findString())
        XCTAssertThrowsError(try query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: false).findUniqueString())

        _ = try box.put(NullablePropertyEntity(maybeString: "qwertz"))
        XCTAssertEqual(query.count, 6)

        // "unique" does not produce a unique result, but asserts there's only 1 result
        XCTAssertThrowsError(try query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: false).findUniqueString())
        let uniqueQuery = box.query { NullablePropertyEntity.maybeString.startsWith("qwe") }.build()
        XCTAssertEqual(try uniqueQuery.property(NullablePropertyEntity.maybeString).findUniqueString(), "qwertz")
    }

    func testByteVectorQueries() throws {
        let box = store.box(for: NullablePropertyEntity.self)
        
        let firstBytes = "CAROLSHAW".data(using: .utf8)!
        let secondBytes = "EVELYNBOYDGRANVILLE".data(using: .utf8)!
        let thirdBytes = "MARYKENNETHKELLER".data(using: .utf8)!
        let entity1 = NullablePropertyEntity(byteVector: firstBytes)
        let entity2 = NullablePropertyEntity(maybeByteVector: firstBytes, byteVector: secondBytes)
        let entity3 = NullablePropertyEntity(maybeByteVector: secondBytes, byteVector: thirdBytes)
        try box.put([entity1, entity2, entity3])
        
        XCTAssertEqual(box.query({
            NullablePropertyEntity.maybeByteVector.isNil()
        }).build().find().count, 1)
        
        XCTAssertEqual(box.query({
            NullablePropertyEntity.maybeByteVector.isNotNil()
        }).build().find().count, 2)
        
        XCTAssertEqual(box.query({
            NullablePropertyEntity.maybeByteVector == secondBytes
        }).build().find().count, 1)
        
        XCTAssertEqual(box.query({
            NullablePropertyEntity.maybeByteVector < secondBytes
        }).build().find().count, 1)
        
        XCTAssertEqual(box.query({
            NullablePropertyEntity.maybeByteVector > firstBytes
        }).build().find().count, 1)
        
        XCTAssertEqual(box.query({
            NullablePropertyEntity.byteVector == secondBytes
        }).build().find().count, 1)
        
        XCTAssertEqual(box.query({
            NullablePropertyEntity.byteVector < firstBytes
        }).build().find().count, 0)
        
        XCTAssertEqual(box.query({
            NullablePropertyEntity.byteVector > firstBytes
        }).build().find().count, 2)
    }
    
}
// swiftlint:enable type_body_length
