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

// TODO can we have something like XCTAssertThrowsError but for fatal errors?
//      E.g. https://marcosantadev.com/test-swift-fatalerror

// swiftlint:disable type_body_length force_try
class QueryTests: XCTestCase {
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

    // MARK: - setParameter

    func testSetParameter_Long_SingleParameter() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(long: 100)
        let entity2 = AllTypesEntity.create(long: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ AllTypesEntity.long.isEqual(to: 100) }).build()
        query.setParameter(AllTypesEntity.long, to: 200)
        let results = try query.find()
        XCTAssertEqual(results.count, 1)
        XCTAssert(results.contains(where: { $0.aLong == 200 }))

        // Trying 2 param setter throws
        //XCTAssertThrowsError(query.setParameters(AllTypesEntity.long, to: 99, -123))

        // Trying collection param setter throws
        //XCTAssertThrowsError(query.setParameters(AllTypesEntity.long, to: [1]))
    }

    func testSetParameter_Long_SingleParameterAliased() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(long: 100)
        let entity2 = AllTypesEntity.create(long: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ "the long" .= AllTypesEntity.long.isEqual(to: 100) }).build()
        query.setParameter("the long", to: 200)
        let results = try query.find()
        XCTAssertEqual(results.count, 1)
        XCTAssert(results.contains(where: { $0.aLong == 200 }))

        // Trying 2 param setter throws
        //XCTAssertThrowsError(query.setParameters("the long", to: 99, -123))

        // Trying collection param setter throws
        //XCTAssertThrowsError(query.setParameters("the long", to: [1]))
    }

    func testSetParameter_Long_TwoParameters() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(long: -100)
        let entity2 = AllTypesEntity.create(long: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ AllTypesEntity.long.isBetween(50, and: 60) }).build()
        XCTAssertEqual(try query.count(), 0)
        query.setParameters(AllTypesEntity.long, to: 90, 300)
        XCTAssertEqual(try query.count(), 1)
        query.setParameters(AllTypesEntity.long, to: -300, 300)
        let results = try query.find()
        XCTAssertEqual(results.count, 2)
        XCTAssert(results.contains(where: { $0.aLong == -100 }))
        XCTAssert(results.contains(where: { $0.aLong == 200 }))

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter(AllTypesEntity.long, to: 200))

        // Trying collection param setter throws
        //XCTAssertThrowsError(query.setParameters(AllTypesEntity.long, to: [1]))
    }

    func testSetParameter_Long_TwoParametersAliased() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(long: -100)
        let entity2 = AllTypesEntity.create(long: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ "longs" .= AllTypesEntity.long.isBetween(50, and: 60) }).build()
        XCTAssertEqual(try query.count(), 0)
        query.setParameters("longs", to: 90, 300)
        XCTAssertEqual(try query.count(), 1)
        query.setParameters("longs", to: -300, 300)
        let results = try query.find()
        XCTAssertEqual(results.count, 2)
        XCTAssert(results.contains(where: { $0.aLong == -100 }))
        XCTAssert(results.contains(where: { $0.aLong == 200 }))

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter("longs", to: 200))

        // Trying collection param setter throws
        //XCTAssertThrowsError(query.setParameters("longs", to: [1]))
    }

    func testSetParameter_Long_Collection() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(long: -100)
        let entity2 = AllTypesEntity.create(long: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ AllTypesEntity.long.isIn([100, 200, 300]) }).build()
        XCTAssertEqual(try query.count(), 1)
        query.setParameters(AllTypesEntity.long, to: [90, 300])
        XCTAssertEqual(try query.count(), 0)
        query.setParameters(AllTypesEntity.long, to: [-100, 200])
        let results = try query.find()
        XCTAssertEqual(results.count, 2)
        XCTAssert(results.contains(where: { $0.aLong == -100 }))
        XCTAssert(results.contains(where: { $0.aLong == 200 }))

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter(AllTypesEntity.long, to: 200))

        // Trying 2 param setter throws
        //XCTAssertThrowsError(query.setParameters(AllTypesEntity.long, to: 90, 300))
    }

    func testSetParameter_Long_CollectionAliased() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(long: -100)
        let entity2 = AllTypesEntity.create(long: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ "longzz" .= AllTypesEntity.long.isIn([100, 200, 300]) }).build()
        XCTAssertEqual(try query.count(), 1)
        query.setParameters("longzz", to: [90, 300])
        XCTAssertEqual(try query.count(), 0)
        query.setParameters("longzz", to: [-100, 200])
        let results = try query.find()
        XCTAssertEqual(results.count, 2)
        XCTAssert(results.contains(where: { $0.aLong == -100 }))
        XCTAssert(results.contains(where: { $0.aLong == 200 }))

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter("longzz", to: 200))

        // Trying 2 param setter throws
        //XCTAssertThrowsError(query.setParameters("longzz", to: 90, 300))
    }

    func testSetParameter_Integer_SingleParameter() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: 100)
        let entity2 = AllTypesEntity.create(integer: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ AllTypesEntity.integer.isEqual(to: 100) }).build()
        query.setParameter(AllTypesEntity.integer, to: 200)
        let results = try query.find()
        XCTAssertEqual(results.count, 1)
        XCTAssert(results.contains(where: { $0.integer == 200 }))

        // Trying 2 param setter throws
        //XCTAssertThrowsError(query.setParameters(AllTypesEntity.integer, to: 99, -123))

        // Trying collection param setter throws
        //XCTAssertThrowsError(query.setParameters(AllTypesEntity.integer, to: [1]))
    }

    func testSetParameter_Integer_SingleParameterAliased() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: 100)
        let entity2 = AllTypesEntity.create(integer: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ "an int" .= AllTypesEntity.integer.isEqual(to: 100) }).build()
        query.setParameter("an int", to: 200)
        let results = try query.find()
        XCTAssertEqual(results.count, 1)
        XCTAssert(results.contains(where: { $0.integer == 200 }))

        // Trying 2 param setter throws
        //XCTAssertThrowsError(query.setParameters("an int", to: 99, -123))

        // Trying collection param setter throws
        //XCTAssertThrowsError(query.setParameters("an int", to: [1]))
    }

    func testSetParameter_Integer_TwoParameters() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: -100)
        let entity2 = AllTypesEntity.create(integer: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ AllTypesEntity.integer.isBetween(50, and: 60) }).build()
        XCTAssertEqual(try query.count(), 0)
        query.setParameters(AllTypesEntity.integer, to: 90, 300)
        XCTAssertEqual(try query.count(), 1)
        query.setParameters(AllTypesEntity.integer, to: -300, 300)
        let results = try query.find()
        XCTAssertEqual(results.count, 2)
        XCTAssert(results.contains(where: { $0.integer == -100 }))
        XCTAssert(results.contains(where: { $0.integer == 200 }))

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter(AllTypesEntity.integer, to: 200))

        // Trying collection param setter throws
        //XCTAssertThrowsError(query.setParameters(AllTypesEntity.integer, to: [1]))
    }

    func testSetParameter_Integer_TwoParametersAliased() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: -100)
        let entity2 = AllTypesEntity.create(integer: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ "twintegers" .= AllTypesEntity.integer.isBetween(50, and: 60) }).build()
        XCTAssertEqual(try query.count(), 0)
        query.setParameters("twintegers", to: 90, 300)
        XCTAssertEqual(try query.count(), 1)
        query.setParameters("twintegers", to: -300, 300)
        let results = try query.find()
        XCTAssertEqual(results.count, 2)
        XCTAssert(results.contains(where: { $0.integer == -100 }))
        XCTAssert(results.contains(where: { $0.integer == 200 }))

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter("twintegers", to: 200))

        // Trying collection param setter throws
        //XCTAssertThrowsError(query.setParameters("twintegers", to: [1]))
    }

    func testSetParameter_Integer_Collection() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: -100)
        let entity2 = AllTypesEntity.create(integer: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ AllTypesEntity.integer.isIn([100, 200, 300]) }).build()
        XCTAssertEqual(try query.count(), 1)
        query.setParameters(AllTypesEntity.integer, to: [90, 300])
        XCTAssertEqual(try query.count(), 0)
        query.setParameters(AllTypesEntity.integer, to: [-100, 200])
        let results = try query.find()
        XCTAssertEqual(results.count, 2)
        XCTAssert(results.contains(where: { $0.integer == -100 }))
        XCTAssert(results.contains(where: { $0.integer == 200 }))

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter(AllTypesEntity.integer, to: 200))

        // Trying 2 param setter throws
        //XCTAssertThrowsError(query.setParameters(AllTypesEntity.integer, to: 90, 300))
    }

    func testSetParameter_Integer_CollectionAliased() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: -100)
        let entity2 = AllTypesEntity.create(integer: 200)
        try box.put([entity1, entity2])

        let query = try box.query({ "collectintegers" .= AllTypesEntity.integer.isIn([100, 200, 300]) }).build()
        XCTAssertEqual(try query.count(), 1)
        query.setParameters("collectintegers", to: [90, 300])
        XCTAssertEqual(try query.count(), 0)
        query.setParameters("collectintegers", to: [-100, 200])
        let results = try query.find()
        XCTAssertEqual(results.count, 2)
        XCTAssert(results.contains(where: { $0.integer == -100 }))
        XCTAssert(results.contains(where: { $0.integer == 200 }))

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter("collectintegers", to: 200))

        // Trying 2 param setter throws
        //XCTAssertThrowsError(query.setParameters("collectintegers", to: 90, 300))
    }
    
    func testSetParameter_Bool_SingleParameter() throws {
        let box = store.box(for: AllTypesEntity.self)
        
        let entity1 = AllTypesEntity.create(boolean: true)
        let entity2 = AllTypesEntity.create(boolean: false)
        let entity3 = AllTypesEntity.create(boolean: true)
        try box.put([entity1, entity2, entity3])
        XCTAssertEqual(try box.count(), 3)
        
        let query = try box.query({ AllTypesEntity.boolean.isEqual(to: true) }).build()
        var results = try query.find()
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].boolean, true)
        XCTAssertEqual(results[1].boolean, true)
        
        query.setParameter(AllTypesEntity.boolean, to: false)
        results = try query.find()
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].boolean, false)
        XCTAssertEqual(results[0].id, entity2.id)
    }

    func testQueryUnsigned() throws {
        let box = store.box(for: AllTypesEntity.self)
        
        let entity1 = AllTypesEntity.create(unsigned: ~3)
        let entity2 = AllTypesEntity.create(unsigned: 42)
        let entity3 = AllTypesEntity.create(unsigned: 0)
        try box.put([entity1, entity2, entity3])
        XCTAssertEqual(try box.count(), 3)
        
        let query = try box.query({ AllTypesEntity.unsigned > 100 }).build()
        let greater0 = try query.findUnique()!
        XCTAssertEqual(greater0.unsigned, ~3)

        let propertyQuery = query.property(AllTypesEntity.unsigned)
        XCTAssertEqual(try propertyQuery.max(), ~3)
        query.setParameter(AllTypesEntity.unsigned, to: 10)
        XCTAssertEqual(try propertyQuery.min(), 42)
        XCTAssertEqual(try propertyQuery.sum(), (~3 & 0xFFFFFFFF) + 42)
        XCTAssertEqual(try propertyQuery.average(), (Double(~3 & 0xFFFFFFFF) + 42) / 2.0)
        XCTAssertEqual(try propertyQuery.averageInt(), UInt32(((~3 & 0xFFFFFFFF) + 42) / 2))

        query.setParameter(AllTypesEntity.unsigned, to: UInt32(~4 & 0xFFFFFFFF))
        XCTAssertEqual(try propertyQuery.count(), 1)
        XCTAssertEqual(try propertyQuery.averageInt(), UInt32(~3 & 0xFFFFFFFF))
        let result: UInt32 = try propertyQuery.find()[0]
        XCTAssertEqual(result, UInt32(~3 & 0xFFFFFFFF))
    }

    func testSetParameter_Double_Equality() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(double: 2.2)
        let entity2 = AllTypesEntity.create(double: 5.5)
        try box.put([entity1, entity2])

        let query = try box.query({ AllTypesEntity.double.isEqual(to: 2.2, tolerance: 0.5) }).build()
        XCTAssertFalse(try query.find().isEmpty)
        query.setParameters(AllTypesEntity.double, to: 6.0, 0.5) // 0.5 ... 6.0
        XCTAssertEqual(try query.find().count, 2)
        query.setParameters(AllTypesEntity.double, to: 5.0, 6.0) // 5.0 ... 6.0
        let results = try query.find()
        XCTAssertEqual(results.count, 1)
        XCTAssert(results.contains(where: { $0.aDouble == 5.5 }))

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter(AllTypesEntity.double, to: 5.5))
    }

    func testSetParameter_Double_EqualityAliased() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(double: 2.2)
        let entity2 = AllTypesEntity.create(double: 5.5)
        try box.put([entity1, entity2])

        let query = try box.query({ "a double" .= AllTypesEntity.double.isEqual(to: 2.2, tolerance: 0.5) }).build()
        XCTAssertFalse(try query.find().isEmpty)
        query.setParameters("a double", to: 6.0, 0.5) // 0.5 ... 6.0
        XCTAssertEqual(try query.find().count, 2)
        query.setParameters("a double", to: 5.0, 6.0) // 5.0 ... 6.0
        let results = try query.find()
        XCTAssertEqual(results.count, 1)
        XCTAssert(results.contains(where: { $0.aDouble == 5.5 }))

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter("a double", to: 5.5))
    }

    func testSetParameter_Double_SingleParameter() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(double: 2.2)
        let entity2 = AllTypesEntity.create(double: 5.5)
        try box.put([entity1, entity2])

        let query = try box.query({ AllTypesEntity.double.isGreaterThan(1.0) }).build()
        XCTAssertEqual(try query.find().count, 2)
        query.setParameter(AllTypesEntity.double, to: 3.0)
        XCTAssertEqual(try query.find().count, 1)

        // Trying 2 param setter throws
        //XCTAssertThrowsError(query.setParameters(AllTypesEntity.double, to: 1.0, 6.0))
    }

    func testSetParameter_Double_SingleParameterAliased() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(double: 2.2)
        let entity2 = AllTypesEntity.create(double: 5.5)
        try box.put([entity1, entity2])

        let query = try box.query({ "single double" .= AllTypesEntity.double.isGreaterThan(1.0) }).build()
        XCTAssertEqual(try query.find().count, 2)
        query.setParameter("single double", to: 3.0)
        XCTAssertEqual(try query.find().count, 1)

        // Trying 2 param setter throws
        //XCTAssertThrowsError(query.setParameters("single double", to: 1.0, 6.0))
    }

    func testSetParameter_String_SingleParameter() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "Foo")
        let entity2 = AllTypesEntity.create(string: "Bar")
        try box.put([entity1, entity2])

        let query = try box.query({ AllTypesEntity.string.isGreaterThan("C") }).build()
        XCTAssertEqual(try query.count(), 1)
        query.setParameter(AllTypesEntity.string, to: "A")
        XCTAssertEqual(try query.count(), 2)

        // Trying collection param setter throws
        //XCTAssertThrowsError(query.setParameters(AllTypesEntity.string, to: ["x"]))
    }

    func testSetParameter_String_SingleParameterAliased() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "Foo")
        let entity2 = AllTypesEntity.create(string: "Bar")
        try box.put([entity1, entity2])

        let query = try box.query({ "a string" .= AllTypesEntity.string.isGreaterThan("C") }).build()
        XCTAssertEqual(try query.count(), 1)
        query.setParameter("a string", to: "A")
        XCTAssertEqual(try query.count(), 2)

        // Trying collection param setter throws
        //XCTAssertThrowsError(query.setParameters("a string", to: ["x"]))
    }

    func testSetParameter_String_Collection() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "Foo")
        let entity2 = AllTypesEntity.create(string: "Bar")
        try box.put([entity1, entity2])

        let query = try box.query({ AllTypesEntity.string.isIn(["Zoo", "Foo"]) }).build()
        XCTAssertEqual(try query.count(), 1)
        query.setParameters(AllTypesEntity.string, to: ["Shmoo", "Boo"])
        XCTAssertEqual(try query.count(), 0)
        query.setParameters(AllTypesEntity.string, to: ["Foo", "Bar"])
        XCTAssertEqual(try query.count(), 2)

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter(AllTypesEntity.string, to: "x"))
    }

    func testSetParameter_String_CollectionAliased() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(string: "Foo")
        let entity2 = AllTypesEntity.create(string: "Bar")
        try box.put([entity1, entity2])

        let query = try box.query({ "string coll" .= AllTypesEntity.string.isIn(["Zoo", "Foo"]) }).build()
        XCTAssertEqual(try query.count(), 1)
        query.setParameters("string coll", to: ["Shmoo", "Boo"])
        XCTAssertEqual(try query.count(), 0)
        query.setParameters("string coll", to: ["Foo", "Bar"])
        XCTAssertEqual(try query.count(), 2)

        // Trying 1 param setter throws
        //XCTAssertThrowsError(query.setParameter("string coll", to: "x"))
    }

    func testSetParameter_MultipleAliases() throws {
        let box = store.box(for: AllTypesEntity.self)

        let entity1 = AllTypesEntity.create(integer: 111, double: 26.89, string: "Markus")
        let entity2 = AllTypesEntity.create(integer: 999, double: 888.888, string: "Zarkus")
        try box.put([entity1, entity2])

        let query = try box.query({
            "firstLetter" .= AllTypesEntity.string.startsWith("M")
                && "minAge" .= AllTypesEntity.integer > 300
        }).build()
        XCTAssertEqual(try query.count(), 0)
        query.setParameter("firstLetter", to: "Z")
        XCTAssertEqual(try query.count(), 1)
        query.setParameter("firstLetter", to: "")
        query.setParameter("minAge", to: 21)
        XCTAssertEqual(try query.count(), 2)
    }
    
    func testRemoveQuery() throws {
        let personBox: Box<TestPerson> = store.box()
        
        let person1 = TestPerson(name: "Talia Winters", age: 59)
        let person2 = TestPerson(name: "Susan Ivanova", age: 53)
        let person3 = TestPerson(name: "Lyta Alexander", age: 61)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        XCTAssertEqual(try personBox.query().build().count(), 3)

        let deletedCount = try personBox.query({ TestPerson.name.contains("er") }).build().remove()
        XCTAssertEqual(deletedCount, 2)
        XCTAssertEqual(try personBox.query().build().count(), 1)

        XCTAssertEqual(try personBox.query().build().find().first?.name, "Susan Ivanova")
    }

    func testFindIdsQuery() throws {
        let personBox: Box<TestPerson> = store.box()
        
        let person1 = TestPerson(name: "Talia Winters", age: 59)
        let person2 = TestPerson(name: "Susan Ivanova", age: 53)
        let person3 = TestPerson(name: "Lyta Alexander", age: 61)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let writtenPersonIDs = try personBox.query().build().find()
        XCTAssertEqual(writtenPersonIDs.count, 3)
        
        let matchingIDs = try personBox.query({ TestPerson.name.contains("er") }).build().findIds()
        XCTAssertEqual(matchingIDs.count, 2)
        
        XCTAssert(matchingIDs.contains(person1.id))
        XCTAssert(matchingIDs.contains(person3.id))
    }
    
    func testQueryDebugDescription() throws {
        let box = store.box(for: AllTypesEntity.self)
        
        let query = try box.query({ "longs" .= AllTypesEntity.long.isBetween(50, and: 60) }).build()
        let queryDescription = "\(query)"
        XCTAssert(queryDescription.contains("1 condition"))
        XCTAssert(queryDescription.contains("aLong"))
        XCTAssert(queryDescription.contains("50"))
        XCTAssert(queryDescription.contains("60"))
        
        query.setParameters("longs", to: 90, 300)
        let queryDescription3 = "\(query)"
        XCTAssert(queryDescription3.contains("1 condition"))
        XCTAssert(queryDescription3.contains("aLong"))
        XCTAssertFalse(queryDescription3.contains("50"))
        XCTAssertFalse(queryDescription3.contains("60"))
        XCTAssert(queryDescription3.contains("90"))
        XCTAssert(queryDescription3.contains("300"))

        let query2 = try box.query({ AllTypesEntity.integer.isEqual(to: 42) }).build()
        let queryDescription2 = "\(query2)"
        XCTAssert(queryDescription2.contains("1 condition"))
        XCTAssert(queryDescription2.contains("integer"))
        XCTAssert(queryDescription2.contains("42"))
    }
}
