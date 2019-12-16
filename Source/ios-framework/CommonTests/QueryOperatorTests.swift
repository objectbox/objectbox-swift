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

class QueryOperatorTests: XCTestCase {

    var store: Store!

    override func setUp() {
        super.setUp()
        store = StoreHelper.tempStore(model: createTestModel())
    }

    override func tearDown() {
        try! store?.closeAndDeleteAllFiles()
        store = nil
        super.tearDown()
    }

    func testInteger_Equals() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: 100)
        let entity2 = AllTypesEntity.create(integer: 200)
        let entity3 = AllTypesEntity.create(integer: 300)
        try box.put([entity1, entity2, entity3])

        let results1 = try box.query({ AllTypesEntity.integer.isEqual(to: 100) }).build().find()
        XCTAssertEqual(results1.count, 1)
        XCTAssert(results1.contains(where: { $0.integer == 100 }))

        let results2 = try box.query({ AllTypesEntity.integer == 200 }).build().find()
        XCTAssertEqual(results2.count, 1)
        XCTAssert(results2.contains(where: { $0.integer == 200 }))
    }

    func testInteger_NotEquals() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: 100)
        let entity2 = AllTypesEntity.create(integer: 200)
        let entity3 = AllTypesEntity.create(integer: 300)
        try box.put([entity1, entity2, entity3])

        let results1 = try box.query({ AllTypesEntity.integer.isNotEqual(to: 200) }).build().find()
        XCTAssertEqual(results1.count, 2)
        XCTAssert(results1.contains(where: { $0.integer == 100 }))
        XCTAssert(results1.contains(where: { $0.integer == 300 }))

        let results2 = try box.query({ AllTypesEntity.integer != 100 }).build().find()
        XCTAssertEqual(results2.count, 2)
        XCTAssert(results2.contains(where: { $0.integer == 200 }))
        XCTAssert(results2.contains(where: { $0.integer == 300 }))
    }

    func testInteger_GreaterThan() throws {
        let box = store.box(for: AllTypesEntity.self)
        
        let entity1 = AllTypesEntity.create(integer: 100)
        let entity2 = AllTypesEntity.create(integer: 200)
        let entity3 = AllTypesEntity.create(integer: 300)
        try box.put([entity1, entity2, entity3])
        
        let results1 = try box.query({ AllTypesEntity.integer.isGreaterThan(100) }).build().find()
        XCTAssertEqual(results1.count, 2)
        XCTAssert(results1.contains(where: { $0.integer == 200 }))
        XCTAssert(results1.contains(where: { $0.integer == 300 }))
        
        let results2 = try box.query({ AllTypesEntity.integer > 100 }).build().find()
        XCTAssertEqual(results2.count, 2)
        XCTAssert(results2.contains(where: { $0.integer == 200 }))
        XCTAssert(results2.contains(where: { $0.integer == 300 }))
    }
    
    func testInteger_LessThan() throws {
        let box = store.box(for: AllTypesEntity.self)
        
        let entity1 = AllTypesEntity.create(integer: 100)
        let entity2 = AllTypesEntity.create(integer: 200)
        let entity3 = AllTypesEntity.create(integer: 300)
        try box.put([entity1, entity2, entity3])
        
        let results1 = try box.query({ AllTypesEntity.integer.isLessThan(300) }).build().find()
        XCTAssertEqual(results1.count, 2)
        XCTAssert(results1.contains(where: { $0.integer == 200 }))
        XCTAssert(results1.contains(where: { $0.integer == 100 }))
        
        let results2 = try box.query({ AllTypesEntity.integer < 300 }).build().find()
        XCTAssertEqual(results2.count, 2)
        XCTAssert(results2.contains(where: { $0.integer == 200 }))
        XCTAssert(results2.contains(where: { $0.integer == 100 }))
    }
    
    func testInteger_InCollection() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: 100)
        let entity2 = AllTypesEntity.create(integer: 200)
        let entity3 = AllTypesEntity.create(integer: 300)
        try box.put([entity1, entity2, entity3])

        let values: [Int32] = [100, 0, 50]

        let results1 = try box.query({ AllTypesEntity.integer.isIn(values) }).build().find()
        XCTAssertEqual(results1.count, 1)
        XCTAssert(results1.contains(where: { $0.integer == 100 }))

        let results2 = try box.query({ AllTypesEntity.integer ∈ values }).build().find()
        XCTAssertEqual(results2.count, 1)
        XCTAssert(results2.contains(where: { $0.integer == 100 }))
    }

    func testInteger_NotInCollection() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: 100)
        let entity2 = AllTypesEntity.create(integer: 200)
        let entity3 = AllTypesEntity.create(integer: 300)
        try box.put([entity1, entity2, entity3])

        let results1 = try box.query({ AllTypesEntity.integer.isNotIn([100, 0, 50]) }).build().find()
        XCTAssertEqual(results1.count, 2)
        XCTAssert(results1.contains(where: { $0.integer == 200 }))
        XCTAssert(results1.contains(where: { $0.integer == 300 }))

        let results2 = try box.query({ AllTypesEntity.integer ∉ [100, 0, 50] }).build().find()
        XCTAssertEqual(results2.count, 2)
        XCTAssert(results2.contains(where: { $0.integer == 200 }))
        XCTAssert(results2.contains(where: { $0.integer == 300 }))
    }

    func testInteger_Between() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: -100)
        let entity2 = AllTypesEntity.create(integer: 200)
        let entity3 = AllTypesEntity.create(integer: 300)
        try box.put([entity1, entity2, entity3])

        let resultsIsBetween = try box.query({ AllTypesEntity.integer.isBetween(-150, and: 250) }).build().find()
        XCTAssertEqual(resultsIsBetween.count, 2)
        XCTAssert(resultsIsBetween.contains(where: { $0.integer == -100 }))
        XCTAssert(resultsIsBetween.contains(where: { $0.integer == 200 }))

        let resultsInRange = try box.query({ AllTypesEntity.integer.isIn(-100 ..< 200) }).build().find()
        XCTAssertEqual(resultsInRange.count, 1)
        XCTAssert(resultsInRange.contains(where: { $0.integer == -100 }))

        let resultsInClosedRange = try box.query({ AllTypesEntity.integer.isIn(-1000 ... 200) }).build().find()
        XCTAssertEqual(resultsInClosedRange.count, 2)
        XCTAssert(resultsInClosedRange.contains(where: { $0.integer == -100 }))
        XCTAssert(resultsInClosedRange.contains(where: { $0.integer == 200 }))
    }

    func testDouble_Equals() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(double: 120.10)
        let entity2 = AllTypesEntity.create(double: 120.20)
        let entity3 = AllTypesEntity.create(double: 120.30)
        try box.put([entity1, entity2, entity3])

        let results = try box.query({ AllTypesEntity.double.isEqual(to: 120.15, tolerance: 0.10) }).build().find()
        XCTAssertEqual(results.count, 2)
        XCTAssert(results.contains(where: { $0.aDouble == 120.10 }))
        XCTAssert(results.contains(where: { $0.aDouble == 120.20 }))
    }

    func testDouble_GreaterThan() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(double: 10.003)
        let entity2 = AllTypesEntity.create(double: 100)
        let entity3 = AllTypesEntity.create(double: 1000.8)
        try box.put([entity1, entity2, entity3])

        let results1 = try box.query({ AllTypesEntity.double.isGreaterThan(10.003) }).build().find()
        XCTAssertEqual(results1.count, 2)
        XCTAssert(results1.contains(where: { $0.aDouble == 100 }))
        XCTAssert(results1.contains(where: { $0.aDouble == 1000.8 }))

        let results2 = try box.query({ AllTypesEntity.double > 10.003 }).build().find()
        XCTAssertEqual(results2.count, 2)
        XCTAssert(results2.contains(where: { $0.aDouble == 100 }))
        XCTAssert(results2.contains(where: { $0.aDouble == 1000.8 }))
    }

    func testDouble_Between() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(double: 123.456)
        let entity2 = AllTypesEntity.create(double: 200.99)
        let entity3 = AllTypesEntity.create(double: 123.457)
        try box.put([entity1, entity2, entity3])

        let resultsIsBetween = try box.query({ AllTypesEntity.double.isBetween(123.457, and: 1002.1) }).build().find()
        XCTAssertEqual(resultsIsBetween.count, 2)
        XCTAssert(resultsIsBetween.contains(where: { $0.aDouble == 123.457 }))
        XCTAssert(resultsIsBetween.contains(where: { $0.aDouble == 200.99 }))
    }

    func testString_Equals() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "Isaac")
        let entity2 = AllTypesEntity.create(string: "Asimov")
        let entity3 = AllTypesEntity.create(string: "Foundation")
        try box.put([entity1, entity2, entity3])

        XCTAssertEqual(try box.query({ AllTypesEntity.string.isEqual(to: "Isaac") }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.isEqual(to: "ISAAC") }).build().count(), 0)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isEqual(to: "Isaac", caseSensitive: true)
        }).build().count(), 1)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isEqual(to: "ISAAC", caseSensitive: true)
        }).build().count(), 0)
        XCTAssertEqual(try box.query({ AllTypesEntity.string == "Isaac" }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string == "ISAAC" }).build().count(), 0)

        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isEqual(to: "Isaac", caseSensitive: false)
        }).build().count(), 1)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isEqual(to: "ISAAC", caseSensitive: false)
        }).build().count(), 1)
    }

    func testString_NotEquals() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "Isaac")
        let entity2 = AllTypesEntity.create(string: "Asimov")
        let entity3 = AllTypesEntity.create(string: "Foundation")
        try box.put([entity1, entity2, entity3])

        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isNotEqual(to: "Isaac")
        }).build().count(), 2)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isNotEqual(to: "ISAAC")
        }).build().count(), 3)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isNotEqual(to: "Isaac", caseSensitive: true)
        }).build().count(), 2)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isNotEqual(to: "ISAAC", caseSensitive: true)
        }).build().count(), 3)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string != "Isaac"
        }).build().count(), 2)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string != "ISAAC"
        }).build().count(), 3)

        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isNotEqual(to: "Isaac", caseSensitive: false)
        }).build().count(), 2)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isNotEqual(to: "ISAAC", caseSensitive: false)
        }).build().count(), 2)
    }

    func testString_LessThan() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "ISAAC")
        let entity2 = AllTypesEntity.create(string: "Asimov")
        let entity3 = AllTypesEntity.create(string: "Foundation")
        try box.put([entity1, entity2, entity3])

        let result1 = try box.query({ AllTypesEntity.string.isLessThan("ISAAC") }).build().find()
        XCTAssertEqual(result1.count, 2)
        XCTAssert(result1.contains(where: { $0.string == "Asimov" }))
        XCTAssert(result1.contains(where: { $0.string == "Foundation" }))
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isLessThan("isaac", caseSensitive: false)
        }).build().count(), 2)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isLessThan("isaac", caseSensitive: true)
        }).build().count(), 3)

        XCTAssertEqual(try box.query({ AllTypesEntity.string < "isaac" }).build().count(), 3)
        let result2 = try box.query({ AllTypesEntity.string < "ISAAC" }).build().find()
        XCTAssertEqual(result2.count, 2)
        XCTAssert(result2.contains(where: { $0.string == "Asimov" }))
        XCTAssert(result2.contains(where: { $0.string == "Foundation" }))
    }

    func testString_GreaterThan() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "isaac")
        let entity2 = AllTypesEntity.create(string: "ASImov")
        let entity3 = AllTypesEntity.create(string: "foundation")
        try box.put([entity1, entity2, entity3])

        let result1 = try box.query({ AllTypesEntity.string.isGreaterThan("asimov") }).build().find()
        XCTAssertEqual(result1.count, 2)
        XCTAssert(result1.contains(where: { $0.string == "isaac" }))
        XCTAssert(result1.contains(where: { $0.string == "foundation" }))
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isGreaterThan("ASIMOV", caseSensitive: false)
        }).build().count(), 2)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.isGreaterThan("ASIMOV", caseSensitive: true)
        }).build().count(), 3)

        XCTAssertEqual(try box.query({ AllTypesEntity.string > "ASIMOV" }).build().count(), 3)
        let result2 = try box.query({ AllTypesEntity.string > "asimov" }).build().find()
        XCTAssertEqual(result2.count, 2)
        XCTAssert(result2.contains(where: { $0.string == "isaac" }))
        XCTAssert(result2.contains(where: { $0.string == "foundation" }))
    }

    func testString_Contains() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "iSSaac")
        let entity2 = AllTypesEntity.create(string: "bass")
        let entity3 = AllTypesEntity.create(string: "manuel")
        try box.put([entity1, entity2, entity3])

        XCTAssertEqual(try box.query({ AllTypesEntity.string.contains("SS") }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.contains("ss") }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.contains("SS", caseSensitive: true) }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.contains("ss", caseSensitive: true) }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.contains("SS", caseSensitive: false) }).build().count(), 2)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.contains("ss", caseSensitive: false) }).build().count(), 2)
    }

    func testString_StartsWith() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "ISaac")
        let entity2 = AllTypesEntity.create(string: "ishmael")
        let entity3 = AllTypesEntity.create(string: "Moby Dick")
        try box.put([entity1, entity2, entity3])

        XCTAssertEqual(try box.query({ AllTypesEntity.string.startsWith("IS") }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.startsWith("is") }).build().count(), 1)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.startsWith("IS", caseSensitive: true)
        }).build().count(), 1)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.startsWith("is", caseSensitive: true)
        }).build().count(), 1)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.startsWith("IS", caseSensitive: false)
        }).build().count(), 2)
        XCTAssertEqual(try box.query({
            AllTypesEntity.string.startsWith("is", caseSensitive: false)
        }).build().count(), 2)
    }

    func testString_EndsWith() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "Isaac")
        let entity2 = AllTypesEntity.create(string: "Ishmael")
        let entity3 = AllTypesEntity.create(string: "ManuEL")
        try box.put([entity1, entity2, entity3])

        XCTAssertEqual(try box.query({ AllTypesEntity.string.endsWith("EL") }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.endsWith("el") }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.endsWith("EL", caseSensitive: true) }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.endsWith("el", caseSensitive: true) }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.endsWith("EL", caseSensitive: false) }).build().count(), 2)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.endsWith("el", caseSensitive: false) }).build().count(), 2)
    }

    func testString_InCollection() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "FOO")
        let entity2 = AllTypesEntity.create(string: "bar")
        try box.put([entity1, entity2])

        XCTAssertEqual(try box.query({ AllTypesEntity.string.isIn(["FoO"]) }).build().count(), 0)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.isIn(["foo"]) }).build().count(), 0)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.isIn(["FOO"]) }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.isIn(["FoO"]) }).build().count(), 0)

        XCTAssertEqual(try box.query({ AllTypesEntity.string ∈ ["FoO"] }).build().count(), 0)
        XCTAssertEqual(try box.query({ AllTypesEntity.string ∈ ["foo"] }).build().count(), 0)
        XCTAssertEqual(try box.query({ AllTypesEntity.string ∈ ["FOO"] }).build().count(), 1)

        XCTAssertEqual(try box.query({ AllTypesEntity.string.isIn(["FoO"], caseSensitive: true) }).build().count(), 0)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.isIn(["foo"], caseSensitive: true) }).build().count(), 0)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.isIn(["FOO"], caseSensitive: true) }).build().count(), 1)

        XCTAssertEqual(try box.query({ AllTypesEntity.string.isIn(["FoO"], caseSensitive: false) }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.isIn(["foo"], caseSensitive: false) }).build().count(), 1)
        XCTAssertEqual(try box.query({ AllTypesEntity.string.isIn(["FOO"], caseSensitive: false) }).build().count(), 1)
    }

    func testDate_Equals() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let entity2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let entity3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: +1000))
        try box.put([entity1, entity2, entity3])

        let results1 = try box.query({
            AllTypesEntity.date.isEqual(to: Date(timeIntervalSince1970: 1000))
        }).build().find()
        XCTAssertEqual(results1.count, 1)
        XCTAssert(results1.contains(where: { $0.date?.timeIntervalSince1970 == 1000}))

        let results2 = try box.query({ AllTypesEntity.date == Date(timeIntervalSince1970: 0) }).build().find()
        XCTAssertEqual(results2.count, 1)
        XCTAssert(results2.contains(where: { $0.date?.timeIntervalSince1970 == 0}))
    }

    func testDate_NotEquals() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let entity2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let entity3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: +1000))
        try box.put([entity1, entity2, entity3])

        let results1 = try box.query({
            AllTypesEntity.date.isNotEqual(to: Date(timeIntervalSince1970: 1000))
        }).build().find()
        XCTAssertEqual(results1.count, 2)
        XCTAssert(results1.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))
        XCTAssert(results1.contains(where: { $0.date?.timeIntervalSince1970 == 0}))

        let results2 = try box.query({ AllTypesEntity.date != Date(timeIntervalSince1970: 1000) }).build().find()
        XCTAssertEqual(results2.count, 2)
        XCTAssert(results2.contains(where: { $0.date?.timeIntervalSince1970 == 0}))
        XCTAssert(results2.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))
    }

    func testDate_Before() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let entity2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let entity3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: +1000))
        try box.put([entity1, entity2, entity3])

        let results1 = try box.query({ AllTypesEntity.date.isBefore(Date(timeIntervalSince1970: 500)) }).build().find()
        XCTAssertEqual(results1.count, 2)
        XCTAssert(results1.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))
        XCTAssert(results1.contains(where: { $0.date?.timeIntervalSince1970 == 0}))

        let results2 = try box.query({ AllTypesEntity.date < Date(timeIntervalSince1970: 500) }).build().find()
        XCTAssertEqual(results2.count, 2)
        XCTAssert(results2.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))
        XCTAssert(results2.contains(where: { $0.date?.timeIntervalSince1970 == 0}))
    }

    func testDate_After() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let entity2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let entity3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: +1000))
        try box.put([entity1, entity2, entity3])

        let results1 = try box.query({ AllTypesEntity.date.isAfter(Date(timeIntervalSince1970: 500)) }).build().find()
        XCTAssertEqual(results1.count, 1)
        XCTAssert(results1.contains(where: { $0.date?.timeIntervalSince1970 == 1000.0 }))

        let results2 = try box.query({ AllTypesEntity.date > Date(timeIntervalSince1970: 500) }).build().find()
        XCTAssertEqual(results2.count, 1)
        XCTAssert(results2.contains(where: { $0.date?.timeIntervalSince1970 == 1000}))
    }

    func testDate_InCollection() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let entity2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let entity3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: +1000))
        try box.put([entity1, entity2, entity3])

        let dates = [
            Date(timeIntervalSince1970: 500),
            Date(timeIntervalSince1970: 1000),
            Date(timeIntervalSince1970: 0)
        ]

        let results1 = try box.query({ AllTypesEntity.date.isIn(dates) }).build().find()
        XCTAssertEqual(results1.count, 2)
        XCTAssert(results1.contains(where: { $0.date?.timeIntervalSince1970 == 1000.0 }))
        XCTAssert(results1.contains(where: { $0.date?.timeIntervalSince1970 == 0}))

        let results2 = try box.query({ AllTypesEntity.date ∈ dates }).build().find()
        XCTAssertEqual(results2.count, 2)
        XCTAssert(results2.contains(where: { $0.date?.timeIntervalSince1970 == 1000.0 }))
        XCTAssert(results2.contains(where: { $0.date?.timeIntervalSince1970 == 0}))
    }

    func testDate_Between() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let entity2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let entity3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: +1000))
        try box.put([entity1, entity2, entity3])

        let resultsIsBetween = try box.query({
            AllTypesEntity.date.isBetween(Date(timeIntervalSince1970: -2000), and: Date(timeIntervalSince1970: +50))
        }).build().find()
        XCTAssertEqual(resultsIsBetween.count, 2)
        XCTAssert(resultsIsBetween.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))
        XCTAssert(resultsIsBetween.contains(where: { $0.date?.timeIntervalSince1970 == 0}))

        let resultsInRange1 = try box.query({
            AllTypesEntity.date.isIn(Date(timeIntervalSince1970: -2000) ..< Date(timeIntervalSince1970: 0))
        }).build().find()
        XCTAssertEqual(resultsInRange1.count, 1)
        XCTAssert(resultsInRange1.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))
        let resultsInRange2 = try box.query({
            AllTypesEntity.date ∈ Date(timeIntervalSince1970: -2000) ..< Date(timeIntervalSince1970: 0)
        }).build().find()
        XCTAssertEqual(resultsInRange2.count, 1)
        XCTAssert(resultsInRange2.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))

        let resultsInClosedRange1 = try box.query({
            AllTypesEntity.date.isIn(Date(timeIntervalSince1970: -2000) ... Date(timeIntervalSince1970: +50))
        }).build().find()
        XCTAssertEqual(resultsInClosedRange1.count, 2)
        XCTAssert(resultsInClosedRange1.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))
        XCTAssert(resultsInClosedRange1.contains(where: { $0.date?.timeIntervalSince1970 == 0}))
        let resultsInClosedRange2 = try box.query({
            AllTypesEntity.date ∈ Date(timeIntervalSince1970: -2000) ... Date(timeIntervalSince1970: +50)
        }).build().find()
        XCTAssertEqual(resultsInClosedRange2.count, 2)
        XCTAssert(resultsInClosedRange2.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))
        XCTAssert(resultsInClosedRange2.contains(where: { $0.date?.timeIntervalSince1970 == 0}))
    }

    func testDate_NotInCollection() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let entity2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let entity3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: +1000))
        try box.put([entity1, entity2, entity3])

        let dates = [
            Date(timeIntervalSince1970: 500),
            Date(timeIntervalSince1970: 1000),
            Date(timeIntervalSince1970: 0)
        ]

        let results1 = try box.query({ AllTypesEntity.date.isNotIn(dates) }).build().find()
        XCTAssertEqual(results1.count, 1)
        XCTAssert(results1.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))

        let results2 = try box.query({ AllTypesEntity.date ∉ dates }).build().find()
        XCTAssertEqual(results2.count, 1)
        XCTAssert(results2.contains(where: { $0.date?.timeIntervalSince1970 == -1000}))
    }

    // MARK: -

    func testQueryOperatorPrecedence() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: 1, double: 0, string: "3")
        let entity2 = AllTypesEntity.create(integer: 1, double: 2, string: "0")
        let entity3 = AllTypesEntity.create(integer: 0, double: 2, string: "3")
        try box.put([entity1, entity2, entity3])

        XCTAssertEqual(try box.query({
            AllTypesEntity.integer == 1 && (AllTypesEntity.double > 1.5 || AllTypesEntity.string == "3")
        }).build().find().count, 2)

        // Order of operators should not matter:
        XCTAssertEqual(try box.query({
            (AllTypesEntity.double > 1.5 || AllTypesEntity.string == "3") && AllTypesEntity.integer == 1
        }).build().find().count, 2)

        // But changing precedence with brackets should:
        XCTAssertEqual(try box.query({
            (AllTypesEntity.integer == 1 && AllTypesEntity.double > 1.5) || AllTypesEntity.string == "3"
        }).build().find().count, 3)
    }
}
// swiftlint:enable line_length type_body_length
