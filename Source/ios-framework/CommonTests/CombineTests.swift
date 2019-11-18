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
import ObjectBox
import Combine

// swiftlint:disable identifier_name force_try

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class TestSubscriber<T: __EntityRelatable & EntityInspectable>: Subscriber {
    typealias Input = [T]
    typealias Failure = ObjectBoxError
    
    internal var results = [[T]]()
    internal let group = DispatchGroup()
    internal var error: Failure?
    var numResultsExpected = Int.max
    
    init() {
        group.enter()
    }
    
    func receive(subscription: Subscription) {
        print("Subscription started.")
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        print("Data Received \(input).")
        results.append(input)
        return .max(numResultsExpected - results.count)
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        if case Subscribers.Completion<Failure>.failure(let error) = completion {
            self.error = error
        }
        print("Subscription completed.")
        group.leave()
    }
    
    func wait() {
        group.wait()
    }
}


class CombineTests: XCTestCase {
    
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
    
    func testBoxSubscription() throws {
        if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            let queue = DispatchQueue(label: "io.objectbox.tests.BoxSubscriptionQueue")
            let box: Box<TestPerson> = store.box(for: TestPerson.self)
            
            let testSubscriber = TestSubscriber<TestPerson>()
            testSubscriber.numResultsExpected = 3
            box.publisher.receive(subscriber: testSubscriber, dispatchQueue: queue)
            
            let person1 = TestPerson(name: "Søren🙈", age: 42)
            try box.put(person1)
            
            let person2 = TestPerson(name: "κόσμε", age: 40)
            try box.put(person2)
            
            print("Waiting")
            testSubscriber.wait()
            
            XCTAssertNil(testSubscriber.error, "No error occurred in subscription")
            
            let allPersons = [person1, person2]
            
            print("Checking")
            XCTAssertEqual(testSubscriber.results.count, 3)
            
            for i in 0 ... 2 {
                let persons = (i < testSubscriber.results.count) ? testSubscriber.results[i] : []
                XCTAssertEqual(persons.count, i)
                let expectedPersons = Array(allPersons[..<i])
                XCTAssert(persons == expectedPersons)
            }
        }
    }
    
    func testBoxSubscriptionModify() throws {
        if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            let queue = DispatchQueue(label: "io.objectbox.tests.BoxSubscriptionQueue")
            let box: Box<TestPerson> = store.box(for: TestPerson.self)
            
            let testSubscriber = TestSubscriber<TestPerson>()
            testSubscriber.numResultsExpected = 3
            box.publisher.receive(subscriber: testSubscriber, dispatchQueue: queue)
            
            let originalPerson = TestPerson(name: "Søren🙈", age: 42)
            try box.put(originalPerson)
            
            let changedPerson = TestPerson(name: "κόσμε", age: 40)
            changedPerson.id = originalPerson.id
            try box.put(changedPerson)
            
            print("Waiting")
            testSubscriber.wait()
            
            XCTAssertNil(testSubscriber.error, "No error occurred in subscription")
            
            print("Checking")
            XCTAssertEqual(testSubscriber.results.count, 3)
            
            XCTAssert(testSubscriber.results[0] == [])
            XCTAssert(testSubscriber.results[1] == [originalPerson])
            XCTAssert(testSubscriber.results[2] == [changedPerson])
        }
    }

    func testBoxSubscriptionRemove() throws {
        if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            let queue = DispatchQueue(label: "io.objectbox.tests.BoxSubscriptionQueue")
            let box: Box<TestPerson> = store.box(for: TestPerson.self)
            
            let testSubscriber = TestSubscriber<TestPerson>()
            testSubscriber.numResultsExpected = 4
            box.publisher.receive(subscriber: testSubscriber, dispatchQueue: queue)
            
            let person1 = TestPerson(name: "Søren🙈", age: 42)
            try box.put(person1)
            
            let person2 = TestPerson(name: "κόσμε", age: 40)
            try box.put(person2)
            
            try box.remove(person2)
            
            print("Waiting")
            testSubscriber.wait()
            
            XCTAssertNil(testSubscriber.error, "No error occurred in subscription")
            
            let allPersons = [person1, person2]
            
            print("Checking")
            XCTAssertEqual(testSubscriber.results.count, 4)
            
            for i in 0 ... 2 {
                let persons = (i < testSubscriber.results.count) ? testSubscriber.results[i] : []
                XCTAssertEqual(persons.count, i)
                let expectedPersons = Array(allPersons[..<i])
                XCTAssert(persons == expectedPersons)
            }
            
            let persons = testSubscriber.results[3]
            XCTAssertEqual(persons.count, 1)
            let expectedPersons = Array(allPersons[..<1])
            XCTAssert(persons == expectedPersons)
        }
    }
    
    func testQuerySubscription() throws {
        if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            let queue = DispatchQueue(label: "io.objectbox.tests.QuerySubscriptionQueue")
            let box: Box<TestPerson> = store.box(for: TestPerson.self)
            
            let testSubscriber = TestSubscriber<TestPerson>()
            testSubscriber.numResultsExpected = 4
            let query = try box.query({ TestPerson.name.endsWith("nna") }).build()
            query.publisher.receive(subscriber: testSubscriber, dispatchQueue: queue)
            
            let person1 = TestPerson(name: "Donna", age: 97)
            try box.put(person1)
            
            let person2 = TestPerson(name: "Lindsey", age: 80)
            try box.put(person2)
            
            let person3 = TestPerson(name: "Anna", age: 12)
            try box.put(person3)
            
            print("Waiting")
            testSubscriber.wait()
            
            XCTAssertNil(testSubscriber.error, "No error occurred in subscription")
            
            print("Checking \(testSubscriber.results)")
            // We must report 3 changes here at least, but actually return a spurious 3rd change because we internally
            // subscribe for changes to the box, not the query, hence >= 2.
            XCTAssertGreaterThanOrEqual(testSubscriber.results.count, 2)
            
            // Initial state matches?
            let persons0 = testSubscriber.results[0]
            XCTAssertEqual(persons0.count, 0)
            XCTAssert(persons0 == [])
            
            // First change we make:
            let persons1 = testSubscriber.results[1]
            XCTAssertEqual(persons1.count, 1)
            XCTAssert(persons1 == [person1])
            
            // Spurious change mentioned above here.
            
            let persons3 = testSubscriber.results.last ?? []
            XCTAssertEqual(persons3.count, 2)
            let cmp = { (a: TestPerson, b: TestPerson) in (a.name ?? "") > (b.name ?? "") }
            XCTAssert(persons3.sorted(by: cmp) == [person1, person3].sorted(by: cmp))
        }
    }
    
    func testQuerySubscriptionModify() throws {
        if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            let queue = DispatchQueue(label: "io.objectbox.tests.QuerySubscriptionQueue")
            let box: Box<TestPerson> = store.box(for: TestPerson.self)
            
            let testSubscriber = TestSubscriber<TestPerson>()
            testSubscriber.numResultsExpected = 4
            let query = try box.query({ TestPerson.name.endsWith("nna") }).build()
            query.publisher.receive(subscriber: testSubscriber, dispatchQueue: queue)
            
            let person1 = TestPerson(name: "Donna", age: 97)
            try box.put(person1)
            
            let person2 = TestPerson(name: "Lindsey", age: 80)
            try box.put(person2)
            
            let person3 = TestPerson(name: "Anna", age: 12)
            person3.id = person2.id
            try box.put(person3)
            
            print("Waiting")
            testSubscriber.wait()
            
            XCTAssertNil(testSubscriber.error, "No error occurred in subscription")
            
            print("Checking \(testSubscriber.results)")
            // We must report 3 changes here at least, but actually return a spurious 3rd change because we internally
            // subscribe for changes to the box, not the query, hence >= 2.
            XCTAssertGreaterThanOrEqual(testSubscriber.results.count, 2)
            
            // Initial state matches?
            let persons0 = testSubscriber.results[0]
            XCTAssertEqual(persons0.count, 0)
            XCTAssert(persons0 == [])
            
            // First change we make:
            let persons1 = testSubscriber.results[1]
            XCTAssertEqual(persons1.count, 1)
            XCTAssert(persons1 == [person1])
            
            // Spurious change mentioned above here.
            
            let persons3 = testSubscriber.results[3]
            XCTAssertEqual(persons3.count, 2)
            let cmp = { (a: TestPerson, b: TestPerson) in (a.name ?? "") > (b.name ?? "") }
            XCTAssert(persons3.sorted(by: cmp) == [person1, person3].sorted(by: cmp))
        }
    }

    func testQuerySubscriptionRemove() throws {
        if #available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            let queue = DispatchQueue(label: "io.objectbox.tests.QuerySubscriptionQueue")
            let box: Box<TestPerson> = store.box(for: TestPerson.self)
            
            let testSubscriber = TestSubscriber<TestPerson>()
            testSubscriber.numResultsExpected = 5
            let query = try box.query({ TestPerson.name.endsWith("nna") }).build()
            query.publisher.receive(subscriber: testSubscriber, dispatchQueue: queue)
            
            let person1 = TestPerson(name: "Donna", age: 97)
            try box.put(person1)
            
            let person2 = TestPerson(name: "Lindsey", age: 80)
            try box.put(person2)
            
            let person3 = TestPerson(name: "Anna", age: 12)
            try box.put(person3)
            
            try box.remove(person3)
            
            print("Waiting")
            testSubscriber.wait()
            
            XCTAssertNil(testSubscriber.error, "No error occurred in subscription")
            
            print("Checking \(testSubscriber.results)")
            // We must report 3 changes here at least, but actually return a spurious 3rd change because we internally
            // subscribe for changes to the box, not the query, hence >= 2.
            XCTAssertGreaterThanOrEqual(testSubscriber.results.count, 2)
            
            // Initial state matches?
            let persons0 = testSubscriber.results[0]
            XCTAssertEqual(persons0.count, 0)
            XCTAssert(persons0 == [])
            
            // First change we make:
            let persons1 = testSubscriber.results[1]
            XCTAssertEqual(persons1.count, 1)
            XCTAssert(persons1 == [person1])
            
            // Spurious change mentioned above here.
            
            let persons3 = testSubscriber.results[3]
            XCTAssertEqual(persons3.count, 2)
            let cmp = { (a: TestPerson, b: TestPerson) in (a.name ?? "") > (b.name ?? "") }
            XCTAssert(persons3.sorted(by: cmp) == [person1, person3].sorted(by: cmp))
            
            let persons4 = testSubscriber.results[4]
            XCTAssertEqual(persons4.count, 1)
            XCTAssert(persons4 == [person1])
        }
    }
}
