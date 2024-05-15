//
// Copyright © 2019-2023 ObjectBox Ltd. All rights reserved.
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
@testable import ObjectBox // Give us access to internal methods like box(for: EntityInfo)

// swiftlint:disable identifier_name type_body_length force_try

enum BoxTestError: Error {
    case generalError
    case generalError2
}

class BoxTests: XCTestCase {

    var store: Store!

    override func setUp() {
        super.setUp()
        store = StoreHelper.tempStore(model: createTestModel(), maxDbSizeInKByte: 200 * 1024)
    }

    override func tearDown() {
        try! store?.closeAndDeleteAllFiles()
        store = nil
        super.tearDown()
    }

    func testGetNonexistingIDInEmptyBox() {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        XCTAssertEqual(try box.count(), 0)
        XCTAssertNil(try box.get(EntityId<TestPerson>(12345)))
    }

    func testPutGet() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        XCTAssertEqual(try box.count(), 0)

        let person1 = TestPerson(name: "Søren🙈", age: 42)
        let person1Id = try box.put(person1)

        XCTAssertNotEqual(person1Id.value, 0)
        XCTAssertEqual(try box.count(), 1)

        let person2 = TestPerson(name: "κόσμε", age: 40)
        let person2Id = try box.put(person2)

        XCTAssertNotEqual(person2Id.value, 0)
        XCTAssertEqual(try box.count(), 2)

        XCTAssertNotEqual(person1Id, person2Id)

        let fetchedPerson1 = try box.get(person1Id)
        XCTAssertNotNil(fetchedPerson1)
        XCTAssertEqual(fetchedPerson1?.name, person1.name)
        XCTAssertEqual(fetchedPerson1?.age, person1.age)

        let fetchedPerson2 = try box.get(person2Id)
        XCTAssertNotNil(fetchedPerson2)
        XCTAssertEqual(fetchedPerson2?.name, person2.name)
        XCTAssertEqual(fetchedPerson2?.age, person2.age)
    }

    func testGetArrayAndDictionary() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        XCTAssertEqual(try box.count(), 0)

        let person1Id = try box.put(TestPerson(name: "Foo", age: 55))
        let person2Id = try box.put(TestPerson(name: "Bar", age: 66))
        let person3Id = try box.put(TestPerson(name: "Baz", age: 77))

        XCTAssertNotEqual(person1Id.value, 0)
        XCTAssertNotEqual(person2Id.value, 0)
        XCTAssertNotEqual(person3Id.value, 0)
        XCTAssertEqual(try box.count(), 3)

        let objects = try box.get([person3Id.value, person1Id.value])
        XCTAssertEqual(["Baz", "Foo"], objects.map { $0.name })

        let objects1 = try box.get([42, 27, person3Id.value, person1Id.value], maxCount: 1)
        XCTAssertEqual(["Baz"], objects1.map { $0.name })

        let entitiesById = try box.getAsDictionary([person3Id, person1Id])
        XCTAssertEqual(entitiesById.count, 2)
        XCTAssertEqual(entitiesById[person1Id]?.name, "Foo")
        XCTAssertNil(entitiesById[person2Id])
        XCTAssertEqual(entitiesById[person3Id]?.name, "Baz")
    }

    func testPutGet_AllPropertyTypes() throws {
        let box: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)

        let entity = AllTypesEntity()
        entity.boolean = true
        entity.integer = Int32.max - 10
        entity.unsigned = UInt32.max - 3
        entity.aDouble = 12345.9876
        entity.date = Date(timeIntervalSince1970: 1234567890)
        entity.string = "a string"

        let entityId = try box.put(entity)

        XCTAssertNotEqual(entityId.value, 0)
        XCTAssertEqual(try box.count(), 1)

        let fetchedEntity = try box.get(entityId)
        XCTAssertNotNil(fetchedEntity)
        XCTAssertEqual(fetchedEntity?.boolean, entity.boolean)
        XCTAssertEqual(fetchedEntity?.integer, entity.integer)
        XCTAssertEqual(fetchedEntity?.unsigned, entity.unsigned)
        XCTAssertEqual(fetchedEntity?.aDouble, entity.aDouble)
        XCTAssertEqual(fetchedEntity?.date, entity.date)
        XCTAssertEqual(fetchedEntity?.string, entity.string)
    }


    func testPutGet_Dates() throws {
        let box: Box<AllTypesEntity> = store.box(for: AllTypesEntity.self)

        try box.put([AllTypesEntity.create(date: Date(timeIntervalSince1970: 0)),
                     AllTypesEntity.create(date: Date(timeIntervalSince1970: 1)),
                     AllTypesEntity.create(date: Date(timeIntervalSince1970: 2))])

        XCTAssertEqual(try box.count(), 3)

        let allEntities = try box.all()
        XCTAssertEqual(allEntities.count, 3)
        XCTAssert(allEntities.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == 0
        }))
        XCTAssert(allEntities.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == 1
        }))
        XCTAssert(allEntities.contains(where: { obj -> Bool in
            obj.date?.timeIntervalSince1970 == 2
        }))
    }

    func testPutGetStruct() throws {
        let box: Box<StructEntity> = store.box(for: StructEntity.self)

        XCTAssertEqual(try box.count(), 0)

        let entity1 = StructEntity(id: EntityId<StructEntity>(0), message: "Carol Kaehler wrote the docs.",
                date: Date(timeIntervalSince1970: -500))
        let entity1Id = try box.put(entity1)

        XCTAssertNotEqual(entity1Id.value, 0)
        XCTAssertEqual(try box.count(), 1)

        let entity2 = StructEntity(id: EntityId<StructEntity>(0),
                message: "Kristee Kreitman and Marge Boots did the art 👩‍🎨",
                date: Date(timeIntervalSince1970: 900))
        let entity2Written = try box.put(struct: entity2)

        XCTAssertNotEqual(entity2Written.id.value, 0)
        XCTAssertEqual(try box.count(), 2)

        XCTAssertNotEqual(entity1Id, entity2Written.id)

        let fetchedEntity1 = try box.get(entity1Id)
        XCTAssertNotNil(fetchedEntity1)
        XCTAssertEqual(fetchedEntity1?.message, entity1.message)
        XCTAssertEqual(fetchedEntity1?.date, entity1.date)

        let fetchedEntity2 = try box.get(entity2Written.id)
        XCTAssertNotNil(fetchedEntity2)
        XCTAssertEqual(fetchedEntity2?.message, entity2.message)
        XCTAssertEqual(fetchedEntity2?.date, entity2.date)
    }

    func testPutInWriteTransactionRollback() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        XCTAssertEqual(try box.count(), 0)

        XCTAssertThrowsError(try store.runInTransaction {
            try box.put(TestPerson.irrelevant)

            throw BoxTestError.generalError
        })

        XCTAssertEqual(try box.count(), 0)
    }

    func testPutSameEntityTwice() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        let person = TestPerson(name: "Ryu", age: 20)

        let firstPersonId = try box.put(person)
        XCTAssertNotEqual(firstPersonId.value, 0)

        let secondPersonId = try box.put(person)
        XCTAssertNotEqual(secondPersonId.value, 0)

        XCTAssertEqual(secondPersonId, firstPersonId)
    }

    func testNestedWriteTransactionRollback() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        XCTAssertEqual(try box.count(), 0)

        XCTAssertThrowsError(try store.obx_runInTransaction(writable: true, { _ in
            try box.put(TestPerson.irrelevant)

            try store.obx_runInTransaction(writable: true, { _ in
                try box.put(TestPerson.irrelevant)

                throw BoxTestError.generalError2
            })
        }))

        XCTAssertEqual(try box.count(), 0)
    }

    func testWriteAfterTransactionFailureIsRolledBack() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        XCTAssertEqual(try box.count(), 0)

        XCTAssertThrowsError(try store.obx_runInTransaction(writable: true, { _ in
            try store.obx_runInTransaction(writable: true, { _ in
                throw BoxTestError.generalError2
            })

            XCTAssertNoThrow(try box.put(TestPerson.irrelevant))
        }))

        // TODO: Should the put itself be aborted or error-out? (Would need an early exit flag like isClosed)
        XCTAssertEqual(try box.count(), 0)
    }

    func testBigObjects() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        // Precondition
        XCTAssertEqual(try box.count(), 0)

        // 3x page size (4096) to meet the 32-bit limits
        let longString = String(repeating: "A", count: 3 * 4096)
        let shortString = "Adam Short"
        let id1 = try box.put(TestPerson(name: longString))
        let id2 = try box.put(TestPerson(name: shortString))

        XCTAssertEqual(try box.count(), 2)

        do {
            let objects = try box.all()
            XCTAssertEqual(objects.count, 2)
            XCTAssertEqual(objects[0].name, longString)
            XCTAssertEqual(objects[1].name, shortString)
        }

        do {
            let objects = try box.allContiguous()
            XCTAssertEqual(objects.count, 2)
            XCTAssertEqual(objects[0].name, longString)
            XCTAssertEqual(objects[1].name, shortString)
        }

        do {
            let objects = try box.getAsDictionary([id1, id2])
            XCTAssertEqual(objects.count, 2)
            XCTAssertEqual(objects[id1]!.name, longString)
            XCTAssertEqual(objects[id2]!.name, shortString)
        }

        XCTAssertEqual(2, Int(try box.removeAll()))
        XCTAssertEqual(try box.count(), 0)
    }

    func testPutGetAllRemoveAll() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        // Precondition
        XCTAssertEqual(try box.count(), 0)

        let count = 100
        var persons = [TestPerson]()
        for i in 0..<count {
            persons.append(TestPerson(name: "\(i)", age: i))
        }

        try box.put(persons)

        XCTAssertEqual(try box.count(), count)

        let allEntities = try box.all().sorted { (obj1, obj2) -> Bool in
            return (obj1.name ?? "").compare(obj2.name ?? "", options: .numeric) == .orderedAscending
        }
        for i in 0..<count {
            XCTAssertEqual(allEntities[i].name, "\(i)")
            XCTAssertEqual(allEntities[i].age, i)
        }

        XCTAssertEqual(count, Int(try box.removeAll()))
        XCTAssertEqual(try box.count(), 0)
    }

    func testCountMax() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        XCTAssertEqual(try box.count(limit: 0), 0) // 0 == no limit
        XCTAssertEqual(try box.count(limit: 1), 0)
        XCTAssertEqual(try box.count(limit: 10000), 0)

        let count = 100
        var persons = [TestPerson]()
        for i in 0..<count {
            persons.append(TestPerson(name: "\(i)", age: i))
        }

        try box.put(persons)

        XCTAssertFalse(try box.isEmpty())
        XCTAssertEqual(try box.count(limit: 0), 100) // 0 == no limit
        XCTAssertEqual(try box.count(limit: 1), 1)
        XCTAssertEqual(try box.count(limit: 100), 100)
        XCTAssertEqual(try box.count(limit: 101), 100)
        XCTAssertEqual(try box.count(limit: 10000), 100)
    }

    func testRemoveById() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        XCTAssertEqual(try box.count(), 0)

        let person1Id = try box.put(TestPerson(name: "🤢", age: 123))
        let person2Id = try box.put(TestPerson(name: "🍒", age: 234))

        XCTAssertNotEqual(person1Id.value, 0)
        XCTAssertNotEqual(person2Id.value, 0)

        XCTAssertEqual(try box.count(), 2)
        XCTAssertNotEqual(person1Id, person2Id)

        XCTAssertNoThrow(try box.remove(person2Id))
        XCTAssertEqual(try box.count(), 1)
        XCTAssertEqual(try box.all().first?.name, "🤢")
    }

    func testContains() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var persons = [TestPerson]()
        for i in 0..<10 {
            persons.append(TestPerson(name: "Johnny \(i)", age: i))
        }

        try box.put(persons)

        XCTAssert(try box.contains(persons[2].id))
        XCTAssert(try box.contains([persons[6].id, persons[2].id, persons[5].id, persons[8].id]))
        try box.remove(persons[5].id)
        XCTAssertFalse(try box.contains([persons[6].id, persons[2].id, persons[5].id, persons[8].id]))
    }

    // MARK: - visiting

    func testForEach() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var persons = [TestPerson]()
        for i in 0..<10 {
            persons.append(TestPerson(name: "Johnny \(i)", age: i))
        }

        try box.put(persons)

        var personCount = 0
        try box.forEach { person in
            let currPerson = persons.first { $0.age == person.age }
            XCTAssertEqual(currPerson?.age, person.age)
            personCount += 1
        }
        XCTAssertEqual(persons.count, personCount)
    }

    func testForEachThrows() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var persons = [TestPerson]()
        for i in 0..<4 {
            persons.append(TestPerson(name: "Johnny \(i)", age: i))
        }

        try box.put(persons)

        var currAge = 0
        XCTAssertThrowsError(try box.forEach { person in
            XCTAssertEqual(currAge, person.age)
            currAge += 1
            throw BoxTestError.generalError
        })
        XCTAssertEqual(1, currAge)
    }

    func testVisit() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var persons = [TestPerson]()
        for i in 0..<10 {
            persons.append(TestPerson(name: "Johnny \(i)", age: i))
        }

        try box.put(persons)

        var currAge = 0
        try box.visit { person in
            XCTAssertEqual(currAge, person.age)
            currAge += 1
            return currAge < 5
        }
        XCTAssertEqual(5, currAge)
    }

    func testVisitThrows() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var persons = [TestPerson]()
        for i in 0..<2 {
            persons.append(TestPerson(name: "Johnny \(i)", age: i))
        }

        try box.put(persons)

        var currAge = 0
        XCTAssertThrowsError(try box.visit { person in
            XCTAssertEqual(currAge, person.age)
            currAge += 1
            throw BoxTestError.generalError
        })
        XCTAssertEqual(1, currAge)
    }

    func testForIn() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var persons = [TestPerson]()
        for i in 0..<10 {
            persons.append(TestPerson(name: "Johnny \(i)", age: i))
        }

        try box.put(persons)

        var personCount = 1
        try box.for(persons.map { $0.id }.dropFirst().dropLast()) { person in
            let currPerson = persons.first { $0.age == person?.age }
            XCTAssertEqual(currPerson?.age, person?.age)
            personCount += 1
        }
        XCTAssertEqual(persons.count - 1, personCount)
    }

    func testForInThrows() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var persons = [TestPerson]()
        for i in 0..<4 {
            persons.append(TestPerson(name: "Johnny \(i)", age: i))
        }

        try box.put(persons)

        var personCount = 1
        XCTAssertThrowsError(try box.for(persons.map { $0.id }.dropFirst().dropLast()) { person in
            let currPerson = persons.first { $0.age == person?.age }
            XCTAssertEqual(currPerson?.age, person?.age)
            personCount += 1
            throw BoxTestError.generalError
        })
        XCTAssertEqual(2, personCount)
    }

    func testVisitIn() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var persons = [TestPerson]()
        for i in 0..<10 {
            persons.append(TestPerson(name: "Johnny \(i)", age: i))
        }

        try box.put(persons)

        var personCount = 1
        try box.visit(persons.map { $0.id }.dropFirst().dropLast()) { person in
            let currPerson = persons.first { $0.age == person?.age }
            XCTAssertEqual(currPerson?.age, person?.age)
            personCount += 1
            return personCount < 5
        }
        XCTAssertEqual(5, personCount)
    }

    func testVisitInThrows() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var persons = [TestPerson]()
        for i in 0..<4 {
            persons.append(TestPerson(name: "Johnny \(i)", age: i))
        }

        try box.put(persons)

        var personCount = 1
        XCTAssertThrowsError(try box.visit(persons.map { $0.id }.dropFirst().dropLast()) { person in
            let currPerson = persons.first { $0.age == person?.age }
            XCTAssertEqual(currPerson?.age, person?.age)
            personCount += 1
            throw BoxTestError.generalError
        })
        XCTAssertEqual(2, personCount)
    }

    func testBoxDescription() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        let debugDescription = "\(box)"
        XCTAssert(debugDescription.hasPrefix("<ObjectBox.Box"))
        XCTAssert(debugDescription.contains("TestPerson"))
    }
    
    /// The internal changeHandler of an Observer that queries the box is executed async on a dispatch queue.
    /// This helps to wait for the queue to complete. If not done a following box operation might have modified
    /// the box contents already leading to unexpected results.
    class SubscriptionHelper<T> {
        internal var results = [[T]]()
        lazy var resultHandler: ([T], ObjectBoxError?) -> Void = { items,_ in
            print("Called back.")
            self.results.append(items)
            self.group.leave()
        }
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "io.objectbox.BoxSubscriptionQueue")
        
        func waitForQueue<R>(operation: () -> R) -> R {
            group.enter()
            let result = operation()
            XCTAssertEqual(group.wait(timeout: .now() + .seconds(5)), .success)
            return result
        }
        
        func waitForQueue(operation: () throws -> Void) throws {
            group.enter()
            try operation()
            XCTAssertEqual(group.wait(timeout: .now() + .seconds(5)), .success)
        }
    }

    func testBoxSubscription() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var subscription: Observer

        let subHelper = SubscriptionHelper<TestPerson>()
        subscription = subHelper.waitForQueue {
            box.subscribe(dispatchQueue: subHelper.queue, resultHandler: subHelper.resultHandler)
        }

        let person1 = TestPerson(name: "Søren🙈", age: 42)
        try subHelper.waitForQueue {
            try box.put(person1)
        }
        
        let person2 = TestPerson(name: "κόσμε", age: 40)
        try subHelper.waitForQueue {
            try box.put(person2)
        }

        print("Checking")
        XCTAssertEqual(subHelper.results.count, 3)

        print("Adding sequence point")
        let allPersons = [person1, person2]
        
        for i in 0...2 {
            let persons = (i < subHelper.results.count) ? subHelper.results[i] : []
            XCTAssertEqual(persons.count, i)
            let expectedPersons = (i > 0) ? Array(allPersons[..<i]) : []
            XCTAssert(persons == expectedPersons)
        }

        subscription.unsubscribe()
    }

    func testBoxSubscriptionSingle() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var subscription: Observer

        let person1 = TestPerson(name: "Søren🙈", age: 42)
        try box.put(person1)
        
        let subHelper = SubscriptionHelper<TestPerson>()
        subscription = subHelper.waitForQueue {
            box.subscribe(dispatchQueue: subHelper.queue, flags: [.sendInitial, .dontSubscribe], resultHandler: subHelper.resultHandler)
        }

        let person2 = TestPerson(name: "κόσμε", age: 40)
        subHelper.group.enter()
        try box.put(person2)
        // No results should be received
        let waitResult = subHelper.group.wait(timeout: .now() + .seconds(5))
        XCTAssertEqual(waitResult, .timedOut)
        subHelper.group.leave() // Manually leave

        print("Checking")
        XCTAssertEqual(subHelper.results.count, 1)

        let persons = subHelper.results[0]
        XCTAssertEqual(persons.count, 1)
        XCTAssert(persons == [person1])

        subscription.unsubscribe()
    }

    func testBoxSubscriptionNoInitial() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        var subscription: Observer
        
        let subHelper = SubscriptionHelper<TestPerson>()
        subHelper.group.enter()
        subscription = box.subscribe(dispatchQueue: subHelper.queue, flags: [], resultHandler: subHelper.resultHandler)
        // No results should be received
        let waitResult = subHelper.group.wait(timeout: .now() + .seconds(5))
        XCTAssertEqual(waitResult, .timedOut)
        subHelper.group.leave() // Manually leave
        
        let person1 = TestPerson(name: "Søren🙈", age: 42)
        try subHelper.waitForQueue {
            try box.put(person1)
        }

        let person2 = TestPerson(name: "κόσμε", age: 40)
        try subHelper.waitForQueue {
            try box.put(person2)
        }

        print("Adding sequence point")
        let allPersons = [person1, person2]

        print("Checking")
        XCTAssertEqual(subHelper.results.count, 2)

        for i in 1...2 {
            let persons = (i <= subHelper.results.count) ? subHelper.results[i - 1] : []
            XCTAssertEqual(persons.count, i)
            let expectedPersons = (i > 0) ? Array(allPersons[..<i]) : []
            XCTAssert(persons == expectedPersons)
        }

        subscription.unsubscribe()
    }

    func testVarArgPutGetRemove() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        let person1 = TestPerson(name: "Jesse Faden", age: 29)
        let person2 = TestPerson(name: "Κασσάνδρα", age: 1000)
        let person3 = TestPerson(name: "Samus Aran", age: 33)
        let person4 = TestPerson(name: "Faith Connors", age: 10)
        let person5 = TestPerson(name: "Jane Shepard", age: -135)
        let person6 = TestPerson(name: "Aveline de Grandpré", age: 37)

        try box.put(person1, person2, person3, person4, person5, person6)
        XCTAssertEqual(try box.count(), 6)

        try box.remove(person1, person3)
        XCTAssertEqual(try box.count(), 4)

        try box.remove(person4.id, person2.id)
        XCTAssertEqual(try box.count(), 2)

        try box.remove(person5.id.value, person6.id.value)
        XCTAssertEqual(try box.count(), 0)
    }

    func testCollectionPutCall() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        let person1 = TestPerson(name: "Jesse Faden", age: 29)
        let person2 = TestPerson(name: "Κασσάνδρα", age: 1000)
        let persons: Set = [person1, person2]

        try box.put(persons)
        XCTAssertEqual(try box.count(), 2)
    }

    func testPutModifiableStruct() throws {
        let box: Box<StructEntity> = store.box(for: StructEntity.self)

        XCTAssertEqual(try box.count(), 0)

        var entity1 = StructEntity(id: EntityId<StructEntity>(0), message: "Carol Kaehler wrote the docs.",
                date: Date(timeIntervalSince1970: -500))
        _ = try box.put(&entity1)

        XCTAssertNotEqual(entity1.id.value, 0)
        XCTAssertEqual(try box.count(), 1)
    }


    func testPutModifiableStructs() throws {
        let box: Box<StructEntity> = store.box(for: StructEntity.self)

        XCTAssertEqual(try box.count(), 0)

        var entities = [
            StructEntity(id: EntityId<StructEntity>(0), message: "Woke up.",
                    date: Date(timeIntervalSince1970: 600)),
            StructEntity(id: EntityId<StructEntity>(0), message: "Brushed my teeth.",
                    date: Date(timeIntervalSince1970: 1600)),
            StructEntity(id: EntityId<StructEntity>(0), message: "Went to the subway.",
                    date: Date(timeIntervalSince1970: 2600))

        ]
        try box.put(&entities)

        XCTAssertNotEqual(entities[0].id.value, 0)
        XCTAssertNotEqual(entities[0].id.value, entities[1].id.value)
        XCTAssertNotEqual(entities[1].id.value, 0)
        XCTAssertNotEqual(entities[1].id.value, entities[2].id.value)
        XCTAssertNotEqual(entities[2].id.value, 0)
        XCTAssertNotEqual(entities[2].id.value, entities[0].id.value)
        XCTAssertEqual(try box.count(), 3)
    }

    func testInsert() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        let person1 = TestPerson(name: "Darth Savik", age: 42)
        let person1Id = try box.put(person1, mode: .insert)

        XCTAssertNotEqual(person1Id.value, 0)
        XCTAssertEqual(try box.count(), 1)

        let person2 = TestPerson(name: "Satele Shan", age: 40)
        person2.id = person1Id
        XCTAssertThrowsError(try box.put(person2, mode: .insert))
    }

    func testUpdate() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)

        let person1 = TestPerson(name: "Darth Savik", age: 42)
        XCTAssertThrowsError(try box.put(person1, mode: .update))
        let person1Id = try box.put(person1, mode: .insert)

        XCTAssertNotEqual(person1Id.value, 0)
        XCTAssertEqual(try box.count(), 1)

        let person2 = TestPerson(name: "Satele Shan", age: 40)
        person2.id = person1Id
        XCTAssertNoThrow(try box.put(person2, mode: .update))
    }

    func testUniqueViolated() throws {
        let box: Box<UniqueEntity> = store.box(for: UniqueEntity.self)
        try box.put(UniqueEntity(name: "same"))
        XCTAssertThrowsError(try box.put(UniqueEntity(name: "same"))) { error in
            let obxErr = error as? ObjectBoxError
            XCTAssertNotNil(obxErr)
        }
        try box.put(UniqueEntity(name: "not same"))
    }

    func testUniqueBulk() throws {
        let box: Box<UniqueEntity> = store.box(for: UniqueEntity.self)
        let extensive = false // Switch to true locally for extensive testing that takes longer
        let count = extensive ? 10000 : 1000
        var objects = [UniqueEntity]()

        for run in 1...(extensive ? 10 : 1) {
            print("Run #", run)
            objects.removeAll()
            try box.removeAll()
            XCTAssertEqual(try box.count(), 0)

            for i in 0..<count {
                let object = UniqueEntity(name: "0000000\(i)",
                        content: UUID().uuidString,
                        content2: String(repeating: "*", count: i / 2)
                )
                object.str30 = "Some string that is of medium size."
                object.str55 = "Another fine string that is not empty."
                objects.append(object)
            }
            try box.put(objects)
            XCTAssertEqual(try box.count(), count)
        }
        try store.closeAndDeleteAllFiles()  // DB may have grown quite a bit, delete to free disk space
    }
}
