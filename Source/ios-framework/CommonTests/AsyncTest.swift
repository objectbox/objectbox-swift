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
@testable import ObjectBox // Give us access to internal methods like box(for: EntityInfo)

// swiftlint:disable force_try

class AsyncBoxTests: XCTestCase {
    
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
    
    func testAsyncPut() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let taylor = TestPerson(name: "Taylor Swift", age: 29)
        let amy = TestPerson(name: "Amy Winehouse", age: 27)
        let taylorId = try box.async.put(taylor)
        try box.async.put(amy)
        store.awaitAsyncSubmitted()
        
        let readTaylor = try box.get(taylorId)
        XCTAssertEqual(readTaylor?.name, "Taylor Swift")
        let readAmy = try box.get(amy.id)
        XCTAssertEqual(readAmy?.name, "Amy Winehouse")
    }
    
    func testAsyncInsert() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let taylor = TestPerson(name: "Taylor Swift", age: 29)
        let amy = TestPerson(name: "Amy Winehouse", age: 27)
        amy.id = try box.async.put(taylor, mode: .insert)
        store.awaitAsyncSubmitted()
        
        try box.async.put(amy, mode: .insert)
        store.awaitAsyncSubmitted()
        
        let readTaylor = try box.get(amy.id) // Amy shouldn't have overwritten Taylor.
        XCTAssertEqual(readTaylor?.name ?? "", taylor.name)
        XCTAssertEqual(try box.count(), 1)
    }
    
    func testAsyncUpdate() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let taylor = TestPerson(name: "Taylor Swift", age: 29)
        try box.async.put(taylor, mode: .update)
        store.awaitAsyncSubmitted()
        
        XCTAssertTrue(try box.isEmpty())

        let taylorId = try box.async.put(taylor, mode: .insert)
        store.awaitAsyncSubmitted()

        XCTAssertEqual(try box.count(), 1)

        let amy = TestPerson(name: "Amy Winehouse", age: 27)
        amy.id = taylorId
        try box.async.put(amy, mode: .update)
        store.awaitAsyncSubmitted()
        
        XCTAssertEqual(try box.count(), 1)

        let readAmy = try box.get(amy.id)
        XCTAssertEqual(readAmy?.name ?? "", amy.name)
    }
    
    func testAsyncMultiPut() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let taylor = TestPerson(name: "Taylor Swift", age: 29)
        let amy = TestPerson(name: "Amy Winehouse", age: 27)
        try box.async.put([taylor, amy])
        store.awaitAsyncSubmitted()
        
        let readTaylor = try box.get(taylor.id)
        XCTAssertEqual(readTaylor?.name, "Taylor Swift")
        let readAmy = try box.get(amy.id)
        XCTAssertEqual(readAmy?.name, "Amy Winehouse")
    }
    
    func testAsyncRemove() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let taylor = TestPerson(name: "Taylor Swift", age: 29)
        let amy = TestPerson(name: "Amy Winehouse", age: 27)
        let aimee = TestPerson(name: "Aimee Allen", age: 37)
        try box.put([taylor, amy, aimee])
 
        let readTaylor = try box.get(taylor.id)
        XCTAssertEqual(readTaylor?.name, "Taylor Swift")
        let readAmy = try box.get(amy.id)
        XCTAssertEqual(readAmy?.name, "Amy Winehouse")

        try box.async.remove([taylor, amy])
        store.awaitAsyncSubmitted()
        XCTAssertNil(try box.get(taylor.id))
        XCTAssertNil(try box.get(amy.id))
        XCTAssertEqual(try box.get(aimee.id)?.name, "Aimee Allen")
        
        try box.async.remove(aimee)
        store.awaitAsyncSubmitted()
        
        XCTAssertNil(try box.get(aimee.id))
    }

    func testAsyncPutImmutable() throws {
        let box = store.box(for: StructEntity.self)

        let taylor = StructEntity(id: 0, message: "Taylor Swift", date: Date())
        let amy = StructEntity(id: 0, message: "Amy Winehouse", date: Date())
        let taylorId = try box.async.put(taylor)
        let amyId = try box.async.put(amy)
        store.awaitAsyncSubmitted()

        XCTAssertEqual(amy.id.value, 0)
        XCTAssertEqual(taylor.id.value, 0)

        let readTaylor = try box.get(taylorId)
        XCTAssertEqual(readTaylor?.message, "Taylor Swift")
        let readAmy = try box.get(amyId)
        XCTAssertEqual(readAmy?.message, "Amy Winehouse")
    }

    func testAsyncMultiPutImmutable() throws {
        let box = store.box(for: StructEntity.self)

        let taylor = StructEntity(id: 0, message: "Taylor Swift", date: Date())
        let amy = StructEntity(id: 0, message: "Amy Winehouse", date: Date())
        let putIDs = try box.async.put([taylor, amy])
        store.awaitAsyncSubmitted()

        XCTAssertEqual(amy.id.value, 0)
        XCTAssertEqual(taylor.id.value, 0)

        let readTaylor = try box.get(putIDs.first!)
        XCTAssertEqual(readTaylor?.message, "Taylor Swift")
        let readAmy = try box.get(putIDs.last!)
        XCTAssertEqual(readAmy?.message, "Amy Winehouse")
    }
    
    func testAsyncRemoveID() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let taylor = TestPerson(name: "Taylor Swift", age: 29)
        let amy = TestPerson(name: "Amy Winehouse", age: 27)
        let aimee = TestPerson(name: "Aimee Allen", age: 37)
        try box.put([taylor, amy, aimee])
        
        let readTaylor = try box.get(taylor.id)
        XCTAssertEqual(readTaylor?.name, "Taylor Swift")
        let readAmy = try box.get(amy.id)
        XCTAssertEqual(readAmy?.name, "Amy Winehouse")
        
        try box.async.remove([taylor.id, amy.id])
        store.awaitAsyncSubmitted()
        XCTAssertNil(try box.get(taylor.id))
        XCTAssertNil(try box.get(amy.id))
        XCTAssertEqual(try box.get(aimee.id)?.name, "Aimee Allen")
        
        try box.async.remove(aimee.id)
        store.awaitAsyncSubmitted()
        
        XCTAssertNil(try box.get(aimee.id))
    }

    func testAsyncCompletion() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let taylor = TestPerson(name: "Taylor Swift", age: 29)
        let amy = TestPerson(name: "Amy Winehouse", age: 27)
        let aimee = TestPerson(name: "Aimee Allen", age: 37)
        try box.put([taylor, amy, aimee])
        store.awaitAsyncCompleted()
        
        XCTAssertEqual(try box.get(aimee.id)?.name, "Aimee Allen")
    }

    func testVarArgPutGetRemove() throws {
        let box: Box<TestPerson> = store.box(for: TestPerson.self)
        
        let person1 = TestPerson(name: "Jesse Faden", age: 29)
        let person2 = TestPerson(name: "Κασσάνδρα", age: 1000)
        let person3 = TestPerson(name: "Samus Aran", age: 33)
        let person4 = TestPerson(name: "Faith Connors", age: 10)
        let person5 = TestPerson(name: "Jane Shepard", age: -135)
        let person6 = TestPerson(name: "Aveline de Grandpré", age: 37)

        try box.async.put(person1, person2, person3, person4, person5, person6)
        store.awaitAsyncCompleted()
        XCTAssertEqual(try box.count(), 6)
        
        try box.async.remove(person1, person3)
        store.awaitAsyncCompleted()
        XCTAssertEqual(try box.count(), 4)
        
        try box.async.remove(person4.id, person2.id)
        store.awaitAsyncCompleted()
        XCTAssertEqual(try box.count(), 2)
        
        try box.async.remove(person5.id.value, person6.id.value)
        store.awaitAsyncCompleted()
        XCTAssertEqual(try box.count(), 0)
    }
}
