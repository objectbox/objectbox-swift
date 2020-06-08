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

enum SwiftRefinedTestError: Error {
    case generalError
}

class BoxSwiftRefinedAPITests: XCTestCase {

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

    func rethrow(_ error: Error) throws {
        throw error
    }
    
    func testPutAllRemoveAll() throws {
        let box = store.box(for: AllTypesEntity.self)

        XCTAssert(try box.isEmpty())

        let entities = [1, 2, 3, 4, 5, 6, 7, 8].map(AllTypesEntity.create(long:))
        try box.put(entities)

        XCTAssertEqual(try box.count(), 8)

        XCTAssertEqual(try box.removeAll(), 8)

        XCTAssert(try box.isEmpty())
    }

    func testPutAllRemoveSome() throws {
        let box = store.box(for: AllTypesEntity.self)

        XCTAssert(try box.isEmpty())

        let entities = [1, 2, 3, 4, 5, 6, 7, 8].map(AllTypesEntity.create(long:))
        try box.put(entities)

        XCTAssertEqual(try box.count(), 8)

        XCTAssertEqual(try box.remove(entities.filter({ $0.aLong % 2 == 0 })), 4)

        XCTAssertEqual(try box.count(), 4)
        XCTAssertEqual(try box.all().map { $0.aLong }.sorted(), [1, 3, 5, 7])
    }

    func testPutAllRemoveSomeWithUnput() throws {
        let box = store.box(for: AllTypesEntity.self)

        XCTAssert(try box.isEmpty())

        let entities = [1, 2, 3, 4, 5, 6, 7, 8].map(AllTypesEntity.create(long:))
        try box.put(entities.filter({ $0.aLong != 5 }))

        XCTAssertEqual(try box.count(), 7)

        let removedCount = try! box.remove(entities)
        XCTAssertEqual(removedCount, 7)
        XCTAssertEqual(try box.count(), 0)
    }

    func testPutAllRemoveSomeWithNonexisting() throws {
        let box = store.box(for: AllTypesEntity.self)
        
        XCTAssert(try box.isEmpty())
        
        let entities = [1, 2, 3, 4, 5, 6, 7, 8].map(AllTypesEntity.create(long:))
        try box.put(entities)
        XCTAssertEqual(try box.count(), 8)

        try box.remove(entities[4])
        XCTAssertEqual(try box.count(), 7)
        
        let numDeleted = try box.remove(entities)
        XCTAssertEqual(numDeleted, 7)
    }
    
    func testRemoveUnputRaisesException() throws {
        let box = store.box(for: TestPerson.self)

        let person = TestPerson()
        person.name = "Fred"
        person.age = 42

        XCTAssert(try box.isEmpty())

        XCTAssertFalse(try box.remove(person))
    }

    func testPutGetUpdatePutAgain() throws {
        let box = store.box(for: TestPerson.self)

        XCTAssertEqual(try box.count(), 0)

        let person = TestPerson()
        person.name = "Fred"
        person.age = 42
        let entityId = try box.put(person)
        XCTAssertEqual(try box.count(), 1)

        guard let fetchedPerson = try box.get(entityId) else {
            XCTFail("Expected person with \(entityId)")
            return
        }

        XCTAssertEqual(fetchedPerson.id.value, entityId.value)
        XCTAssertEqual(fetchedPerson.name, person.name)
        XCTAssertEqual(fetchedPerson.age, person.age)

        fetchedPerson.name = "Barney"

        let entityId2 = try box.put(fetchedPerson)
        XCTAssertEqual(entityId2, entityId)
        XCTAssertEqual(try box.count(), 1)

        if let fetchedPerson2 = try box.get(entityId2) {
            XCTAssertEqual(fetchedPerson2.id.value, entityId.value)
            XCTAssertEqual(fetchedPerson2.name, "Barney")
            XCTAssertEqual(fetchedPerson2.age, person.age)
        } else {
            XCTFail("Expected person with \(entityId2)")
        }
    }

    func testPutGetRemove() throws {
        let box = store.box(for: TestPerson.self)

        XCTAssert(try box.isEmpty())

        let person = TestPerson()
        person.name = "Fred"
        person.age = 42
        let entityId = try box.put(person)

        XCTAssertEqual(try box.count(), 1)

        let person2 = TestPerson()
        person2.name = "Barney"
        person2.age = 40
        let entityId2 = try box.put(person2)
        XCTAssertNotEqual(entityId, entityId2)

        XCTAssertEqual(try box.count(), 2)

        if let fetchedPerson = try box.get(entityId) {
            XCTAssertEqual(person.name, fetchedPerson.name)
            XCTAssertEqual(person.age, fetchedPerson.age)
        } else {
            XCTFail("Expected person with \(entityId)")
        }

        if let fetchedPerson2 = try box.get(entityId2) {
            XCTAssertEqual(person2.name, fetchedPerson2.name)
            XCTAssertEqual(person2.age, fetchedPerson2.age)
        } else {
            XCTFail("Expected person with \(entityId2)")
        }

        try box.remove(entityId)

        XCTAssertEqual(try box.count(), 1)

        XCTAssertNil(try box.get(entityId))
        XCTAssertNotNil(try box.get(entityId2))

        try box.remove(person2)

        XCTAssertEqual(try box.count(), 0)
    }

    func testNestedWriteTransactionRollback() throws {
        let box = store.box(for: TestPerson.self)

        XCTAssert(try box.isEmpty())

        do {
            try store.runInTransaction {
                _ = try box.put(TestPerson.irrelevant)
                try self.store.runInTransaction {
                    throw SwiftRefinedTestError.generalError
                }
            }
            XCTFail("Expected to rethrow")
        } catch SwiftRefinedTestError.generalError {
            XCTAssert(true)
        } catch {
            XCTAssertNoThrow(try rethrow(error))
        }

        XCTAssert(try box.isEmpty())
    }
}
// swiftlint:enable identifier_name
