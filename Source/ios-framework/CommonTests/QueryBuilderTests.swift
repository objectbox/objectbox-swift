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

// swiftlint:disable force_try

func rethrow(_ error: Error) throws {
    throw error
}

class QueryBuilderTests: XCTestCase {

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

    // MARK: - Find All

    func testFindAll_OneEntity() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        do {
            let person = TestPerson(name: "Isaac", age: 98)
            let personId = try personBox.put(person)
            if personId.value == 0 {
                XCTFail("Could not setup box")
                return
            }
            
            let query = try personBox.query().build()
            let result = try query.find()
            XCTAssertEqual(result.count, 1)
            
            XCTAssertEqual(result.first?.id.value, personId.value)
            XCTAssertEqual(result.first?.age, person.age)
            XCTAssertEqual(result.first?.name, person.name)
        } catch {
            XCTAssertNoThrow(try rethrow(error))
        }
    }

    func testFindAll_ThreeEntities() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query().build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 3)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == person1.name
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == person2.name
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == person3.name
        }))
    }
    
    func testFindFirst_ThreeEntities() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query().build()
        let result = try query.findFirst()
        XCTAssertNotNil(result) // Cannot know which one without ordering.
    }

    func testFindFirst_WithCondition() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Octavia", age: 58)
        let person2 = TestPerson(name: "Butler", age: 11)
        let person3 = TestPerson(name: "Kindred", age: 10000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.name == "Octavia" }.build()
        let result = try query.findFirst()
        XCTAssertNotNil(result) // Cannot know which one without ordering.
    }
    
    // MARK: - Find Null/Nonnull
    
    func testFind_Null() {
        let entityBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let entity1 = AllTypesEntity.create(double: 120.10)
        let entity2 = AllTypesEntity.create(string: "Foo")
        let entity3 = AllTypesEntity.create(integer: 9876)
        XCTAssertNoThrow(try entityBox.put([entity1, entity2, entity3]))
        
        XCTAssertEqual(try entityBox.query({ AllTypesEntity.string.isNil() }).build().count(), 2)
        XCTAssertEqual(try entityBox.query({ AllTypesEntity.string.isNotNil() }).build().count(), 1)
        
        XCTAssertEqual(try entityBox.query({ AllTypesEntity.integer.isNil() }).build().count(), 0)
        XCTAssertEqual(try entityBox.query({ AllTypesEntity.integer.isNotNil() }).build().count(), 3)
        
        XCTAssertEqual(try entityBox.query({ AllTypesEntity.double.isNil() }).build().count(), 0)
        XCTAssertEqual(try entityBox.query({ AllTypesEntity.double.isNotNil() }).build().count(), 3)
    }
    
    // MARK: - Find unique
    
    func testFindUnique_1Entity() {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person = TestPerson(name: "Foo", age: 123)
        XCTAssertNoThrow(try personBox.put(person))
        
        do {
            let result = try personBox.query().build().findUnique()!
            XCTAssertEqual(result.name, person.name)
            XCTAssertEqual(result.age, person.age)
        } catch {
            XCTAssertNoThrow(try rethrow(error))
        }
    }
    
    func testFindUnique_2Entities_ThrowsError() {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        XCTAssertNoThrow(try personBox.put([TestPerson(name: "Foo", age: 123), TestPerson(name: "Bar", age: 234)]))
        
        do {
            _ = try personBox.query().build().findUnique()
            XCTAssert(false, "didn't throw, but should have")
        } catch ObjectBoxError.nonUniqueResult {
            XCTAssert(true)
        } catch {
            XCTAssertNoThrow(try rethrow(error))
        }
    }
    
    // MARK: - Find unique
    
    func testCount_EmptyResults() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let count = try personBox.query().build().count()
        XCTAssertEqual(count, 0)
    }
    
    func testCount_1Result() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)

        let person = TestPerson(name: "Foo", age: 123)
        XCTAssertNoThrow(try personBox.put(person))

        let count = try personBox.query().build().count()
        XCTAssertEqual(count, 1)
    }
    
    func testCount_111Results() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        for personIndex in 1...111 {
            let person = TestPerson(name: "\(personIndex)", age: personIndex)
            XCTAssertNoThrow(try personBox.put(person))
        }
        
        let count = try personBox.query().build().count()
        XCTAssertEqual(count, 111)
    }

    // MARK: - Find offset
    
    func testFindWithOffset_EmptyResults() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let result = try personBox.query().build().find(offset: 0)
        XCTAssertEqual(result.count, 0)
    }
    
    func testFindWithOffset_ResultsBeforeOffset() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        XCTAssertNoThrow(try personBox.put([TestPerson(name: "Yancy", age: 123), TestPerson(name: "Butler", age: 234)]))
        
        let result = try personBox.query().build().find(offset: 2)
        XCTAssertEqual(result.count, 0)
    }
    
    func testFindWithOffset_OffsetBetweenResults() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let persons = [TestPerson(name: "Nnedi", age: 123), TestPerson(name: "Okorafor", age: 234)]
        XCTAssertNoThrow(try personBox.put(persons))
        
        let result = try personBox.query().build().find(offset: 1)
        XCTAssertEqual(result.count, 1) // Sort order is undefined in this query
    }
    
    func testFindWithOffsetLimit_BetweenResults() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let persons = [TestPerson(name: "Nnedi", age: 123), TestPerson(name: "Okorafor", age: 234),
                       TestPerson(name: "Kathryn", age: 25), TestPerson(name: "Drennan", age: 10)]
        XCTAssertNoThrow(try personBox.put(persons))
        
        let result = try personBox.query().build().find(offset: 1, limit: 2)
        XCTAssertEqual(result.count, 2) // Sort order is undefined in this query
    }
}

// MARK: - Find by property: Equals

class QueryBuilderFindByPropertyEqualTests: XCTestCase {
    
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

    func testFind_Equals_Integer() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = personBox.query { TestPerson.age == 98 }
        let result = try query.build().find()
        XCTAssertEqual(result.count, 1)
        
        XCTAssertEqual(result.first?.age, person1.age)
        XCTAssertEqual(result.first?.name, person1.name)
    }

    func testFind_Equals_Double() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(double: 120.10)
        let person2 = AllTypesEntity.create(double: 120.20)
        let person3 = AllTypesEntity.create(double: 120.30)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = personBox.query { AllTypesEntity.double.isBetween(120.15 - 0.10, and: 120.15 + 0.10) }
        let result = try query.build().find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 120.10
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 120.20
        }))
    }

    func testFind_Equals_String() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(string: "Foo")
        XCTAssertNoThrow(try personBox.put(person1))
        
        let count = try personBox.query({
            AllTypesEntity.string.isEqual(to: "foO", caseSensitive: true)
        }).build().find().count
        XCTAssertEqual(count, 0)
        let count2 = try personBox.query({
            AllTypesEntity.string.isEqual(to: "foO", caseSensitive: false)
        }).build().find().count
        XCTAssertEqual(count2, 1)
        let count3 = try personBox.query({
            AllTypesEntity.string.isEqual(to: "Foo", caseSensitive: true)
        }).build().find().count
        XCTAssertEqual(count3, 1)
        
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string.isEqual(to: "foO")
        }).build().find().count, 0)
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string.isEqual(to: "Foo")
        }).build().find().count, 1)
        
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string == "foO"
        }).build().find().count, 0)
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string == "Foo"
        }).build().find().count, 1)
    }
    
    func testFind_Equals_Date() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 123456))
        let person2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 999999))
        XCTAssertNoThrow(try personBox.put([person1, person2]))
        
        let count = try personBox.query {
            AllTypesEntity.date.isEqual(to: Date(timeIntervalSince1970: 123456))
        }.build().find().count
        XCTAssertEqual(count, 1)
    }
    
    func testFind_NotEquals_Integer() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.age != 98 }.build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Asimov" && obj.age == 12
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Foundation" && obj.age == 1000
        }))
    }

    func testFind_NotEquals_Date() {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 123456))
        let person2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 999999))
        let person3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 56565656))
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.date.isNotEqual(to: Date(timeIntervalSince1970: 123456))
        }).build().find().count, 2)
    }

    func testFind_NotEquals_String() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.name != "Asimov" }.build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Isaac"
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Foundation"
        }))
    }
    
}

// MARK: - Find by property: Greater/Less

class QueryBuilderFindByPropertyGrLessTests: XCTestCase {
    
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
    
    func testFind_Less_Integer() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.age < 98 }.build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 1)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Asimov" && obj.age == 12
        }))
    }
    
    func testFind_Less_Double() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(double: 123.456)
        let person2 = AllTypesEntity.create(double: 200.99)
        let person3 = AllTypesEntity.create(double: 123.457)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { AllTypesEntity.double.isLessThan(123.457) }.build()
        let result: [AllTypesEntity] = try query.find()
        XCTAssertEqual(result.count, 1)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 123.456
        }))
    }
    
    func testFind_Less_String() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.name < "Isaac" }.build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Asimov"
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Foundation"
        }))
    }

    func testFind_Less_String_CaseSensitivity() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(string: "Foo")
        XCTAssertNoThrow(try personBox.put(person1))
        
        
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string.isLessThan("foo", caseSensitive: false)
        }).build().find().count, 0)
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string.isLessThan("foo", caseSensitive: true)
        }).build().find().count, 1)
    }

    func testFind_Less_Date() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let person2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let person3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 1000))
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { AllTypesEntity.date.isBefore(Date(timeIntervalSince1970: 500)) }.build()
        let result: [AllTypesEntity] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == -1000
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == 0
        }))
    }
    
    func testFind_Greater_Integer() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.age > 98 }.build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 1)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Foundation" && obj.age == 1000
        }))
    }
    
    func testFind_Greater_Double() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(double: 123.456)
        let person2 = AllTypesEntity.create(double: 200.99)
        let person3 = AllTypesEntity.create(double: 123.457)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = personBox.query { AllTypesEntity.double.isGreaterThan(123.456) }
        let result: [AllTypesEntity] = try query.build().find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 200.99
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 123.457
        }))
    }
    
    func testFind_Greater_String() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = personBox.query { TestPerson.name > "Asimov" }
        let result: [TestPerson] = try query.build().find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Isaac"
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Foundation"
        }))
    }
    
    func testFind_Greater_String_CaseSensitivity() {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(string: "bar")
        XCTAssertNoThrow(try personBox.put(person1))
        
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string.isGreaterThan("Bar", caseSensitive: false)
        }).build().find().count, 0)
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string.isGreaterThan("Bar", caseSensitive: true)
        }).build().find().count, 1)
    }
    
    func testFind_Greater_Date() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let person2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let person3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 1000))
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { AllTypesEntity.date.isAfter(Date(timeIntervalSince1970: 500)) }.build()
        let result: [AllTypesEntity] = try query.find()
        XCTAssertEqual(result.count, 1)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == 1000
        }))
    }

}

class QueryBuilderRangeTests: XCTestCase {
    
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

    func testFind_Between_Integer_PositiveAndNegative() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(integer: -100)
        let person2 = AllTypesEntity.create(integer: 0)
        let person3 = AllTypesEntity.create(integer: 200)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { AllTypesEntity.integer.isBetween(-200, and: 50) }.build()
        let result: [AllTypesEntity] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.integer == -100
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.integer == 0
        }))
    }
    
    func testFind_Between_Integer_BoundsExceedValues() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.age.isBetween(5, and: 500) }.build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Isaac" && obj.age == 98
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Asimov" && obj.age == 12
        }))
    }
    
    func testFind_Between_Integer_HigherValueFirst() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.age.isBetween(500, and: 5) }.build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Isaac" && obj.age == 98
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Asimov" && obj.age == 12
        }))
    }
    
    func testFind_Between_Integer_BoundsEqualValues() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.age.isBetween(12, and: 98) }.build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Isaac" && obj.age == 98
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Asimov" && obj.age == 12
        }))
    }

    func testFind_Between_Double_BoundsExceedValues() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(double: 123.456)
        let person2 = AllTypesEntity.create(double: 200.99)
        let person3 = AllTypesEntity.create(double: 123.457)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { AllTypesEntity.double.isBetween(20.0, and: 1000.0) }.build()
        let result: [AllTypesEntity] = try query.find()
        XCTAssertEqual(result.count, 3)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 123.456
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 200.99
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 123.457
        }))
    }

    func testFind_Between_Double_HigherValueFirst() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(double: 123.456)
        let person2 = AllTypesEntity.create(double: 200.99)
        let person3 = AllTypesEntity.create(double: 123.457)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { AllTypesEntity.double.isBetween(400.8, and: 2.1) }.build()
        let result: [AllTypesEntity] = try query.find()
        XCTAssertEqual(result.count, 3)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 123.456
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 200.99
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 123.457
        }))
    }

    func testFind_Between_Double_BoundsEqualValues() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(double: 123.456)
        let person2 = AllTypesEntity.create(double: 200.99)
        let person3 = AllTypesEntity.create(double: 123.457)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { AllTypesEntity.double.isBetween(123.457, and: 200.99) }.build()
        let result: [AllTypesEntity] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 200.99
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.aDouble == 123.457
        }))
    }

    func testFind_Between_Date() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let person2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let person3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 1000))
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query {
            AllTypesEntity.date.isBetween(Date(timeIntervalSince1970: -2000), and: Date(timeIntervalSince1970: 50))
        }.build()
        let result: [AllTypesEntity] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == -1000
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == 0
        }))
    }
    
}

class QueryBuilderCollectionTests: XCTestCase {
    
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
    
    func testFind_InCollection_Integer() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.age.isIn([1, 98, 12, 666]) }.build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Isaac" && obj.age == 98
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Asimov" && obj.age == 12
        }))
    }
    
    func testFind_InCollection_String() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.name.isIn(["Isaac", "Frank", "Herbert", "Asimov"]) }.build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Isaac" && obj.age == 98
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Asimov" && obj.age == 12
        }))
    }

    func testFind_InCollection_String_CaseSensitivity() {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(string: "FOO")
        let person2 = AllTypesEntity.create(string: "bar")
        XCTAssertNoThrow(try personBox.put([person1, person2]))
        
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string.isIn(["FoO", "Bar"], caseSensitive: false)
        }).build().find().count, 2)
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string.isIn(["foo", "BaR"], caseSensitive: true)
        }).build().find().count, 0)
        XCTAssertEqual(try personBox.query({
            AllTypesEntity.string.isIn(["FOO", "BaR"], caseSensitive: true)
        }).build().find().count, 1)
    }

    func testFind_InCollection_Date() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let person2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 0))
        let person3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 1000))
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let dates = [Date(timeIntervalSince1970: 500),
                     Date(timeIntervalSince1970: 1000),
                     Date(timeIntervalSince1970: 0)]
        let query = try personBox.query { AllTypesEntity.date.isIn(dates) }.build()
        let result: [AllTypesEntity] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == 1000
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == 0
        }))
    }
    
    func testFind_NotInCollection_Integer() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let result: [TestPerson] = try personBox.query({ TestPerson.age.isNotIn([5, 1000, 98]) }).build().find()
        XCTAssertEqual(result.count, 1)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Asimov" && obj.age == 12
        }))
    }

    func testFind_NotInCollection_Date() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(date: Date(timeIntervalSince1970: -1000))
        let person2 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 100))
        let person3 = AllTypesEntity.create(date: Date(timeIntervalSince1970: 1000))
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let dates = [Date(timeIntervalSince1970: 500),
                     Date(timeIntervalSince1970: 1000),
                     Date(timeIntervalSince1970: 100)]
        let result: [AllTypesEntity] = try personBox.query({ AllTypesEntity.date.isNotIn(dates) }).build().find()
        XCTAssertEqual(result.count, 1)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == -1000
        }))
    }
    
    func testFind_StartsWith_String() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Ishmael", age: 56)
        let person3 = TestPerson(name: "Moby Dick", age: 5)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let result: [TestPerson] = try personBox.query({ TestPerson.name.startsWith("Is") }).build().find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Isaac"
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Ishmael"
        }))
    }
    
    func testFind_StartsWith_String_CaseSensitivity() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "ishmael", age: 56)
        let person3 = TestPerson(name: "Moby Dick", age: 5)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        XCTAssertEqual(try personBox.query({
            TestPerson.name.startsWith("Is") }).build().find().count, 1)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.startsWith("is")
        }).build().find().count, 1)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.startsWith("Is", caseSensitive: true)
        }).build().find().count, 1)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.startsWith("is", caseSensitive: true)
        }).build().find().count, 1)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.startsWith("Is", caseSensitive: false)
        }).build().find().count, 2)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.startsWith("is", caseSensitive: false)
        }).build().find().count, 2)
    }
    
    func testFind_EndsWith_String() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Ishmael", age: 56)
        let person3 = TestPerson(name: "Manuel", age: 12)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let result = try personBox.query({ TestPerson.name.endsWith("el") }).build().find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Manuel"
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Ishmael"
        }))
    }
    
    func testFind_EndsWith_String_CaseSensitivity() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Ishmael", age: 56)
        let person3 = TestPerson(name: "ManuEL", age: 12)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        XCTAssertEqual(try personBox.query({
            TestPerson.name.endsWith("EL")
        }).build().find().count, 1)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.endsWith("el")
        }).build().find().count, 1)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.endsWith("EL", caseSensitive: false)
        }).build().find().count, 2)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.endsWith("el", caseSensitive: false)
        }).build().find().count, 2)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.endsWith("EL", caseSensitive: true)
        }).build().find().count, 1)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.endsWith("el", caseSensitive: true)
        }).build().find().count, 1)
    }
    
    func testFind_Contains_String() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Bart", age: 56)
        let person3 = TestPerson(name: "Manuel", age: 12)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let result = try personBox.query({ TestPerson.name.contains("s") }).build().find()
        XCTAssertEqual(result.count, 1)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.name == "Isaac"
        }))
    }
    
    func testFind_Contains_String_CaseSensitivity() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "iSSaac", age: 98)
        let person2 = TestPerson(name: "Bass", age: 56)
        let person3 = TestPerson(name: "manuel", age: 12)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        XCTAssertEqual(try personBox.query({
            TestPerson.name.contains("SS")
        }).build().find().count, 1)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.contains("ss")
        }).build().find().count, 1)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.contains("SS", caseSensitive: false)
        }).build().find().count, 2)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.contains("ss", caseSensitive: false)
        }).build().find().count, 2)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.contains("SS", caseSensitive: true)
        }).build().find().count, 1)
        XCTAssertEqual(try personBox.query({
            TestPerson.name.contains("ss", caseSensitive: true)
        }).build().find().count, 1)
    }
}

// MARK: - Ordering

class QueryBuilderOrderTests: XCTestCase {
    
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
    
    func testFind_OrderedAscending() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.age != 98 }.ordered(by: TestPerson.age).build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssertEqual(result.first?.age, person2.age)
        XCTAssertEqual(result.first?.name, person2.name)
        XCTAssertEqual(result.last?.age, person3.age)
        XCTAssertEqual(result.last?.name, person3.name)
    }
    
    func testFind_OrderedDescending() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query { TestPerson.age != 98 }.ordered(by: TestPerson.age, flags: .descending).build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssertEqual(result.first?.age, person3.age)
        XCTAssertEqual(result.first?.name, person3.name)
        XCTAssertEqual(result.last?.age, person2.age)
        XCTAssertEqual(result.last?.name, person2.name)
    }
    
    func testFind_AllOrderedDescending() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query().ordered(by: TestPerson.age, flags: .descending).build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 3)
        
        XCTAssertEqual(result.first?.age, person3.age)
        XCTAssertEqual(result.first?.name, person3.name)
        XCTAssertEqual(result[1].age, person1.age)
        XCTAssertEqual(result[1].name, person1.name)
        XCTAssertEqual(result.last?.age, person2.age)
        XCTAssertEqual(result.last?.name, person2.name)
    }
    
    func testFind_AllOrderedAscending() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query().ordered(by: TestPerson.age).build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 3)
        
        XCTAssertEqual(result.first?.age, person2.age)
        XCTAssertEqual(result.first?.name, person2.name)
        XCTAssertEqual(result[1].age, person1.age)
        XCTAssertEqual(result[1].name, person1.name)
        XCTAssertEqual(result.last?.age, person3.age)
        XCTAssertEqual(result.last?.name, person3.name)
    }
    
    func testFind_AllStringsOrderedDescending() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query().ordered(by: TestPerson.name, flags: .descending).build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 3)
        
        XCTAssertEqual(result.first?.age, person1.age)
        XCTAssertEqual(result.first?.name, person1.name)
        XCTAssertEqual(result[1].age, person3.age)
        XCTAssertEqual(result[1].name, person3.name)
        XCTAssertEqual(result.last?.age, person2.age)
        XCTAssertEqual(result.last?.name, person2.name)
    }
    
    func testFind_AllStringsOrderedAscending() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Isaac", age: 98)
        let person2 = TestPerson(name: "Asimov", age: 12)
        let person3 = TestPerson(name: "Foundation", age: 1000)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let query = try personBox.query().ordered(by: TestPerson.name).build()
        let result: [TestPerson] = try query.find()
        XCTAssertEqual(result.count, 3)
        
        XCTAssertEqual(result.first?.age, person2.age)
        XCTAssertEqual(result.first?.name, person2.name)
        XCTAssertEqual(result[1].age, person3.age)
        XCTAssertEqual(result[1].name, person3.name)
        XCTAssertEqual(result.last?.age, person1.age)
        XCTAssertEqual(result.last?.name, person1.name)
    }
    
    // TODO: Property Queries don't sort yet in the core, so this test always fails:
//    func testFind_StringPropertiesOrderedAscending() {
//        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
//
//        let person1 = TestPerson(name: "Isaac", age: 98)
//        let person2 = TestPerson(name: "Asimov", age: 12)
//        let person3 = TestPerson(name: "Foundation", age: 1000)
//        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
//
//        let query = personBox.query().ordered(by: TestPerson.age)
//        let result: [Int64] = query.property(TestPerson.age).findInt64s()
//        XCTAssertEqual(result.count, 3)
//
//        XCTAssertEqual(result.first, Int64(person2.age))
//        XCTAssertEqual(result[1], Int64(person1.age))
//        XCTAssertEqual(result.last, Int64(person3.age))
//    }

}

// MARK: - And/Or operators
    
class QueryBuilderAndOrOperatorTests: XCTestCase {
    
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
        
    func testAnd_TwoConditions() throws {
        let personBox: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Foomuel", age: 1)
        let person2 = TestPerson(name: "Barmuel", age: 2)
        let person3 = TestPerson(name: "Foozelot", age: 3)
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let result = try personBox.query({
            TestPerson.name.startsWith("Foo") && TestPerson.name.endsWith("el")
        }).build().find()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Foomuel")
        XCTAssertEqual(result.first?.age, 1)
    }
    
    func testOr_TwoConditions() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(integer: 100, double: 1.1, string: "One")
        let person2 = AllTypesEntity.create(integer: 200, double: 2.2, string: "Two")
        let person3 = AllTypesEntity.create(integer: 300, double: 3.3, string: "Three")
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        let result = try personBox.query({ AllTypesEntity.string.startsWith("Thr")
            || AllTypesEntity.integer.isGreaterThan(150) }).build().find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.string == "Three" && obj.integer == 300 && obj.aDouble == 3.3
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.string == "Two" && obj.integer == 200 && obj.aDouble == 2.2
        }))
    }

    func testMixedOperators_ExplicitAndBeforeOr() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(integer: 100, double: 1.1, string: "One")
        let person2 = AllTypesEntity.create(integer: 200, double: 2.2, string: "Two")
        let person3 = AllTypesEntity.create(integer: 300, double: 3.3, string: "Three")
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        // ("T" && <250) || ==3.0
        let result = try personBox.query({
            (AllTypesEntity.string.startsWith("T") && AllTypesEntity.integer.isLessThan(250))
                || AllTypesEntity.double.isEqual(to: 3.0, tolerance: 0.5)
        }).build().find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.string == "Two" && obj.integer == 200 && obj.aDouble == 2.2
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.string == "Three" && obj.integer == 300 && obj.aDouble == 3.3
        }))
    }

    func testMixedOperators_ExplicitAndAfterOr() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(integer: 100, double: 1.1, string: "One")
        let person2 = AllTypesEntity.create(integer: 200, double: 2.2, string: "Two")
        let person3 = AllTypesEntity.create(integer: 300, double: 3.3, string: "Three")
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        // (==1.0 || "T") && >250
        let result = try personBox.query({
            (AllTypesEntity.double.isEqual(to: 1.0, tolerance: 0.5) || AllTypesEntity.string.startsWith("T"))
                && AllTypesEntity.integer.isGreaterThan(250)
        }).build().find()
        XCTAssertEqual(result.count, 1)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.string == "Three" && obj.integer == 300 && obj.aDouble == 3.3
        }))
    }

    func testMixedOperators_ImplicitAndBeforeOr() throws {
        let personBox: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)
        
        let person1 = AllTypesEntity.create(integer: 100, double: 1.1, string: "One")
        let person2 = AllTypesEntity.create(integer: 200, double: 2.2, string: "Two")
        let person3 = AllTypesEntity.create(integer: 300, double: 3.3, string: "Three")
        XCTAssertNoThrow(try personBox.put([person1, person2, person3]))
        
        // "T" && (<250 || ==3.0)
        let result = try personBox.query({
            AllTypesEntity.string.startsWith("T")
                && (AllTypesEntity.integer.isLessThan(250) || AllTypesEntity.double.isEqual(to: 3.0, tolerance: 0.5))
        }).build().find()
        XCTAssertEqual(result.count, 2)
        
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.string == "Two" && obj.integer == 200 && obj.aDouble == 2.2
        }))
        XCTAssert(result.contains(where: { obj -> Bool in
            obj.string == "Three" && obj.integer == 300 && obj.aDouble == 3.3
        }))
    }
}
