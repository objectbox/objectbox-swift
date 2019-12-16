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

        let query = try box.query {
            NullablePropertyEntity.double > 1.0
                && NullablePropertyEntity.int32 > 2
                && NullablePropertyEntity.string.hasSuffix("b")
        }.build()

        // Combined results
        XCTAssertEqual(try query.count(), 1)

        // Per-property results count non-nil values
        XCTAssertEqual(try query.property(NullablePropertyEntity.double).count(), 1)
        XCTAssertEqual(try query.property(NullablePropertyEntity.string).count(), 1)
        XCTAssertEqual(try query.property(NullablePropertyEntity.int32).count(), 1)
        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeBool).count(), 0)
        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeString).count(), 0)
    }

    func testPropertyQuery_CountDistinct() throws {
        try box.put([
            NullablePropertyEntity(int32: 1),
            NullablePropertyEntity(int32: 2),
            NullablePropertyEntity(int32: 2),
            NullablePropertyEntity(int32: 3)
            ])

        let query = try box.query { NullablePropertyEntity.int32 > 1 }.build()

        XCTAssertEqual(try query.property(NullablePropertyEntity.int32).count(), 3)
        XCTAssertEqual(try query.property(NullablePropertyEntity.int32).distinct().count(), 2)
    }

    // MARK: - Integers

    func intTest<T>(_ property: Property<NullablePropertyEntity, T, Void>) throws where T: FixedWidthInteger {
        XCTAssertEqual(try box.count(), 6) // Precondition, e.g. no dirty DB before data was put

        // 2. and 3. conditions do not limit the result; just to increase condition coverage
        let query = try box.query { property > 25 && property.isLessThan(99) && property.isNotNil() }.build()
        try intTest(property, query, query.property(property))
    }

    func intTest<E, T>(_ property: Property<E, T, Void>, _ query: Query<E>, _ propertyQuery: PropertyQuery<E, T>)
    throws where T: FixedWidthInteger {

        // Aggregates

        XCTAssertEqual(try propertyQuery.count(), 2)
        XCTAssertEqual(try propertyQuery.sum(), 70)
        XCTAssertEqual(try propertyQuery.max(), 40)
        XCTAssertEqual(try propertyQuery.min(), 30)
        XCTAssertEqual(try propertyQuery.average(), 35)

        // find()

        var results = try propertyQuery.find().sorted()
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0], 30)
        XCTAssertEqual(results[1], 40)

        // Distinct

        query.setParameter(property, to: 0)
        XCTAssertEqual(try propertyQuery.count(), 6)
        try propertyQuery.distinct()
        XCTAssertEqual(try propertyQuery.count(), 4)

        results = try propertyQuery.find().sorted()
        XCTAssertEqual(results.count, 4)
        XCTAssertEqual(results[0], 10)
        XCTAssertEqual(results[1], 20)
        XCTAssertEqual(results[2], 30)
        XCTAssertEqual(results[3], 40)

        // Unique
        XCTAssertThrowsError(try propertyQuery.findUnique())
        query.setParameter(property, to: 39)
        XCTAssertEqual(try propertyQuery.findUnique(), 40)
    }

    func testPropertyQuery_Int64() throws {
        try box.put([
            NullablePropertyEntity(int64: 10),
            NullablePropertyEntity(int64: 10),
            NullablePropertyEntity(int64: 20),
            NullablePropertyEntity(int64: 20),
            NullablePropertyEntity(int64: 30),
            NullablePropertyEntity(int64: 40)
        ])

        try intTest(NullablePropertyEntity.int64)
    }

    func testPropertyQuery_Int32() throws {
        try box.put([
            NullablePropertyEntity(int32: 10),
            NullablePropertyEntity(int32: 10),
            NullablePropertyEntity(int32: 20),
            NullablePropertyEntity(int32: 20),
            NullablePropertyEntity(int32: 30),
            NullablePropertyEntity(int32: 40)
        ])

        try intTest(NullablePropertyEntity.int32)
    }

    func testPropertyQuery_Int16() throws {
        try box.put([
            NullablePropertyEntity(int16: 10),
            NullablePropertyEntity(int16: 10),
            NullablePropertyEntity(int16: 20),
            NullablePropertyEntity(int16: 20),
            NullablePropertyEntity(int16: 30),
            NullablePropertyEntity(int16: 40)
        ])

        try intTest(NullablePropertyEntity.int16)
    }

    func testPropertyQuery_Int8() throws {
        try box.put([
            NullablePropertyEntity(int8: 10),
            NullablePropertyEntity(int8: 10),
            NullablePropertyEntity(int8: 20),
            NullablePropertyEntity(int8: 20),
            NullablePropertyEntity(int8: 30),
            NullablePropertyEntity(int8: 40)
        ])

        try intTest(NullablePropertyEntity.int8)
    }

    func testPropertyQuery_OptionalDate() throws {
        try box.put([
            NullablePropertyEntity(maybeDate: Date(unixTimestamp: 10)),
            NullablePropertyEntity(maybeDate: Date(unixTimestamp: 10)),
            NullablePropertyEntity(maybeDate: Date(unixTimestamp: 20)),
            NullablePropertyEntity(maybeDate: Date(unixTimestamp: 20)),
            NullablePropertyEntity(maybeDate: Date(unixTimestamp: 30)),
            NullablePropertyEntity(maybeDate: Date(unixTimestamp: 40))
        ])

        let property: Property<NullablePropertyEntity, Date?, Void> = NullablePropertyEntity.maybeDate
        // 2. and 3. conditions do not limit the result; just to increase condition coverage
        let query = try box.query {
            property > Date(unixTimestamp: 25) && property.isBefore(Date(unixTimestamp: 99)) && property.isNotNil()
        }.build()

        let intProperty = Property<NullablePropertyEntity, Int64, Void>(propertyId: property.propertyId,
                isPrimaryKey: property.isPrimaryKey)
        try intTest(intProperty, query, query.propertyInt64(property))
    }

    // MARK: - Integers?

    func intOptionalTest<T>(_ property: Property<NullablePropertyEntity, T?, Void>) throws where T: FixedWidthInteger {
        XCTAssertEqual(try box.count(), 6) // Precondition, e.g. no dirty DB before data was put

        // 2. and 3. conditions do not limit the result; just to increase condition coverage
        let query = try box.query { property > 25 && property < 99 && property.isNotNil() }.build()
        try intTest(nonOptional(property), query, query.property(property))
    }

    func testPropertyQuery_Int64Optional() throws {
        try box.put([
            NullablePropertyEntity(maybeInt64: 10),
            NullablePropertyEntity(maybeInt64: 10),
            NullablePropertyEntity(maybeInt64: 20),
            NullablePropertyEntity(maybeInt64: 20),
            NullablePropertyEntity(maybeInt64: 30),
            NullablePropertyEntity(maybeInt64: 40)
        ])

        try intOptionalTest(NullablePropertyEntity.maybeInt64)
    }

    func testPropertyQuery_Int32Optional() throws {
        try box.put([
            NullablePropertyEntity(maybeInt32: 10),
            NullablePropertyEntity(maybeInt32: 10),
            NullablePropertyEntity(maybeInt32: 20),
            NullablePropertyEntity(maybeInt32: 20),
            NullablePropertyEntity(maybeInt32: 30),
            NullablePropertyEntity(maybeInt32: 40)
        ])

        try intOptionalTest(NullablePropertyEntity.maybeInt32)
    }

    func testPropertyQuery_IntOptional16() throws {
        try box.put([
            NullablePropertyEntity(maybeInt16: 10),
            NullablePropertyEntity(maybeInt16: 10),
            NullablePropertyEntity(maybeInt16: 20),
            NullablePropertyEntity(maybeInt16: 20),
            NullablePropertyEntity(maybeInt16: 30),
            NullablePropertyEntity(maybeInt16: 40)
        ])

        try intOptionalTest(NullablePropertyEntity.maybeInt16)
    }

    func testPropertyQuery_IntOptional8() throws {
        try box.put([
            NullablePropertyEntity(maybeInt8: 10),
            NullablePropertyEntity(maybeInt8: 10),
            NullablePropertyEntity(maybeInt8: 20),
            NullablePropertyEntity(maybeInt8: 20),
            NullablePropertyEntity(maybeInt8: 30),
            NullablePropertyEntity(maybeInt8: 40)
        ])

        try intOptionalTest(NullablePropertyEntity.maybeInt8)
    }

    // TODO: this should be in QueryOperatorTests.swift, which does not support NullablePropertyEntity yet however
    // Types less than 32 bits currently not supported by C API
//    func testOptionalInt16_InCollection() throws {
//        let box = store.box(for: NullablePropertyEntity.self)
//
//        failFatallyIfError()
//
//        let entity1 = NullablePropertyEntity(maybeInt16: 100)
//        let entity2 = NullablePropertyEntity(maybeInt16: 200)
//        let entity3 = NullablePropertyEntity(maybeInt16: 300)
//        try box.put([entity1, entity2, entity3])
//
//        let values: [Int16] = [100, 0, 50]
//
//        let resultsIn = try box.query({ NullablePropertyEntity.maybeInt16 ∈ values }).build().find()
//        XCTAssertEqual(resultsIn.count, 1)
//        XCTAssertEqual(resultsIn[0].maybeInt16, 100)
//
//        let resultsNotIn = try box.query({ NullablePropertyEntity.maybeInt16 ∉ values }).build().find()
//        XCTAssertEqual(resultsNotIn.count, 2)
//        XCTAssertNotEqual(resultsNotIn[0].maybeInt16!, 100)
//        XCTAssertNotEqual(resultsNotIn[1].maybeInt16!, 100)
//    }

    // TODO: this should be in QueryOperatorTests.swift, which does not support NullablePropertyEntity yet however
    func testOptionalInt32_InCollection() throws {
        let box = store.box(for: NullablePropertyEntity.self)

        failFatallyIfError()

        let entity1 = NullablePropertyEntity(maybeInt32: 100)
        let entity2 = NullablePropertyEntity(maybeInt32: 200)
        let entity3 = NullablePropertyEntity(maybeInt32: 300)
        try box.put([entity1, entity2, entity3])

        let values: [Int32] = [100, 0, 50]

        let resultsIn = try box.query({ NullablePropertyEntity.maybeInt32 ∈ values }).build().find()
        XCTAssertEqual(resultsIn.count, 1)
        XCTAssertEqual(resultsIn[0].maybeInt32, 100)

        let resultsNotIn = try box.query({ NullablePropertyEntity.maybeInt32 ∉ values }).build().find()
        XCTAssertEqual(resultsNotIn.count, 2)
        XCTAssertNotEqual(resultsNotIn[0].maybeInt32!, 100)
        XCTAssertNotEqual(resultsNotIn[1].maybeInt32!, 100)
    }

    // MARK: - Double

    func testPropertyQuery_DoubleSum() throws {
        try box.put([
            NullablePropertyEntity(double: 1.1),
            NullablePropertyEntity(double: 2.2),
            NullablePropertyEntity(double: 3.3),
            NullablePropertyEntity(double: 4.4)
            ])

        let query = try box.query { NullablePropertyEntity.double > 2.5 }.build()
        XCTAssertEqual(try query.property(NullablePropertyEntity.double).sum(), 7.7)
    }

    func testPropertyQuery_FloatOptional() throws {
        try box.put([
            NullablePropertyEntity(maybeFloat: 1.1),
            NullablePropertyEntity(maybeFloat: 2.2),
            NullablePropertyEntity(maybeFloat: 3.3),
            NullablePropertyEntity(maybeFloat: 4.4)
            ])

        let query = try box.query { NullablePropertyEntity.maybeFloat > 2.5 }.build()
        let propertyQuery = query.property(NullablePropertyEntity.maybeFloat)
        XCTAssertEqual(try propertyQuery.sum(), 7.7, accuracy: 0.00001)

        query.setParameter(NullablePropertyEntity.maybeFloat, to: Float(4))
        XCTAssertEqual(try propertyQuery.average(), 4.4, accuracy: 0.00001)
    }

    func testPropertyQuery_DoubleMax() throws {
        try box.put([
            NullablePropertyEntity(double: 1.1),
            NullablePropertyEntity(double: 2.2),
            NullablePropertyEntity(double: 3.3),
            NullablePropertyEntity(double: 4.4)
            ])

        var query = try box.query { NullablePropertyEntity.double > 2 && NullablePropertyEntity.double < 4 }.build()
        XCTAssertEqual(try query.property(NullablePropertyEntity.double).max(), 3.3)

        query = try box.query { NullablePropertyEntity.double > 2 && NullablePropertyEntity.double < 4 }.build()
        XCTAssertEqual(try query.property(NullablePropertyEntity.double).min(), 2.2)

        query = try box.query { NullablePropertyEntity.double > 1.0 }.build()
        XCTAssertEqual(try query.property(NullablePropertyEntity.double).average(), 2.75)
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

        let query = try box.query().build()

        XCTAssertEqual(try query.count(), 5)
        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeString).findStrings().count, 4)
        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeString).distinct(caseSensitiveCompare: true)
                .findStrings().count, 4)
        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: true).findStrings().count, 4)
        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: false).findStrings().count, 2)

        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeString)
            .with(nullString: "REPLACEMENT").findStrings().count, 5)
        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeString)
            .with(nullString: "REPLACEMENT")
            .distinct(caseSensitiveCompare: false).findStrings().count, 3)

        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeString)
            .with(nullString: "x").findStrings().count, 5)
        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: true)
            .with(nullString: "x").findStrings().count, 5)
        XCTAssertEqual(try query.property(NullablePropertyEntity.maybeString)
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

        let query = try box.query().build()

        XCTAssertEqual(try query.count(), 5)
        XCTAssertNotNil(try query.property(NullablePropertyEntity.maybeString).findString())
        XCTAssertNotNil(try query.property(NullablePropertyEntity.maybeString).distinct(caseSensitiveCompare: true)
                .findString())
        XCTAssertNotNil(try query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: true).findString())
        XCTAssertNotNil(try query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: false).findString())
        XCTAssertThrowsError(try query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: false).findUniqueString())

        _ = try box.put(NullablePropertyEntity(maybeString: "qwertz"))
        XCTAssertEqual(try query.count(), 6)

        // "unique" does not produce a unique result, but asserts there's only 1 result
        XCTAssertThrowsError(try query.property(NullablePropertyEntity.maybeString)
            .distinct(caseSensitiveCompare: false).findUniqueString())
        let uniqueQuery = try box.query { NullablePropertyEntity.maybeString.startsWith("qwe") }.build()
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
        
        XCTAssertEqual(try box.query({
            NullablePropertyEntity.maybeByteVector.isNil()
        }).build().find().count, 1)
        
        XCTAssertEqual(try box.query({
            NullablePropertyEntity.maybeByteVector.isNotNil()
        }).build().find().count, 2)

        let queryEqual = try box.query({ NullablePropertyEntity.maybeByteVector == secondBytes }).build()
        XCTAssertEqual(try queryEqual.findUnique()!.id, entity3.id)
        queryEqual.setParameter(NullablePropertyEntity.maybeByteVector, to: firstBytes)
        XCTAssertEqual(try queryEqual.findUnique()!.id, entity2.id)

        XCTAssertEqual(try box.query({
            NullablePropertyEntity.maybeByteVector < secondBytes
        }).build().find().count, 1)
        
        XCTAssertEqual(try box.query({
            NullablePropertyEntity.maybeByteVector > firstBytes
        }).build().find().count, 1)
        
        XCTAssertEqual(try box.query({
            NullablePropertyEntity.byteVector == secondBytes
        }).build().find().count, 1)
        
        XCTAssertEqual(try box.query({
            NullablePropertyEntity.byteVector < firstBytes
        }).build().find().count, 0)
        
        XCTAssertEqual(try box.query({
            NullablePropertyEntity.byteVector > firstBytes
        }).build().find().count, 2)
    }
    
}
// swiftlint:enable type_body_length
