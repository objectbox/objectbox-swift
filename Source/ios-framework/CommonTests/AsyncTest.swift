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
}
