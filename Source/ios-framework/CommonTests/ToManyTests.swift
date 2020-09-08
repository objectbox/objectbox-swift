//
// Copyright © 2020 ObjectBox Ltd. All rights reserved.
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

/// Tests for the ToMany (backlink) side of one-to-many relations (property based).
/// Tests for standalone many-to-many relations should go into ManyToManyTests.
class ToManyTests: OneToManyTestCase {

    func testToManyReset() throws {
        let customer = Customer(name: "Carla Customa")
        try customerBox.put(customer)

        let order1 = Order(name: "Apples", target: customer)
        let order2 = Order(name: "Oranges", target: customer)
        let order3 = Order(name: "Shoes", target: customer)
        try orderBox.put([order1, order2, order3])

        let originalResult = customer.orders.map { $0.name }.sorted()
        XCTAssertEqual(originalResult.count, 3)
        try orderBox.remove(order2)
        let cachedResult = customer.orders.map { $0.name }.sorted()
        customer.orders.reset()
        let changedResult = customer.orders.map { $0.name }.sorted()
        XCTAssertEqual(changedResult.count, 2)

        XCTAssertEqual(originalResult, cachedResult)
        XCTAssertNotEqual(originalResult, changedResult)
    }

    func testToManyLatePut() throws {
        let apples = Order(name: "Apples")
        try orderBox.put(apples)

        let customer = Customer(name: "Larry Late")
        var toMany: ToMany<Order> = customer.orders

        XCTAssertEqual(toMany.count, 0)
        toMany.append(apples)

        try customerBox.put(customer)

        // Watch out; put() just changed the ToMany object (we should change that some time):
        XCTAssertFalse(toMany === customer.orders)
        XCTAssertThrowsError(try toMany.applyToDb())

        try customer.orders.applyToDb()
        XCTAssertEqual(apples.customer.targetId?.value, customer.id.value)

        try assertTargetValuesNowAndAfterApplyToDb(customer.orders, ["Apples"])
    }

    func testPutTargetObjectsNotYetPut() throws {
        let customer = Customer(name: "Chuck")
        let customerId = try customerBox.put(customer).value

        let apples = Order(name: "Apples")
        let shoes = Order(name: "Shoes")
        let oranges = Order(name: "Oranges")

        // Append all, remove "Shoes", and apply
        customer.orders.append(apples)
        customer.orders.append(shoes)
        customer.orders.append(oranges)
        XCTAssertEqual(customer.orders.count, 3)
        customer.orders.removeAll(where: {$0.name == "Shoes"})
        let expectedOrders = ["Apples", "Oranges"]
        try assertTargetValuesNowAndAfterApplyToDb(customer.orders, expectedOrders)

        // Verify order objects have been updated
        XCTAssertEqual(apples.customer.target?.id.value, customerId)
        XCTAssert(shoes.customer.target === nil)
        XCTAssertEqual(oranges.customer.target?.id.value, customerId)

        // Verify orders where put correctly including to-one pointing to customerId
        let orders = try orderBox.all()
        XCTAssertEqual(orders.map {$0.name}.sorted(), expectedOrders)
        XCTAssertEqual(orders.map { ($0.customer.targetId?.value ?? 0)}.sorted(), [customerId, customerId] )

        // Verify with new customer object from DB
        let customer2 = try customerBox.get(customerId)
        try assertTargetValuesNowAndAfterApplyToDb(customer2!.orders, expectedOrders)
    }

    /// Init ToOnes and reset the backlink ToMany
    func testToManyModifications() throws {
        let customer = Customer(name: "Carla Customa")
        try customerBox.put(customer)

        let apples = Order(name: "Apples", target: customer)
        let oranges = Order(name: "Oranges", target: customer)
        let shoes = Order(name: "Shoes", target: customer)
        try orderBox.put([apples, oranges, shoes])

        var toMany: ToMany<Order> = customer.orders

        toMany.removeAll()
        toMany.append(oranges)
        try assertTargetValuesNowAndAfterApplyToDb(toMany, ["Oranges"])

        toMany.removeFirst()
        try assertTargetValuesNowAndAfterApplyToDb(toMany, [])
        toMany.removeAll()
        try assertTargetValuesNowAndAfterApplyToDb(toMany, [])

        toMany.replaceSubrange(toMany.startIndex..<toMany.endIndex, with: [apples, shoes])
        try assertTargetValuesNowAndAfterApplyToDb(toMany, ["Apples", "Shoes"])

        toMany.insert(oranges, at: toMany.startIndex + 1)
        try assertTargetValuesNowAndAfterApplyToDb(toMany, ["Apples", "Oranges", "Shoes"])

        XCTAssert(toMany.reversed().reversed().canInteractWithDb)
    }

    private func assertTargetValuesNowAndAfterApplyToDb(_ toMany: ToMany<Order>, _ values: [String]) throws {
        XCTAssertEqual(values, toMany.map { $0.name }.sorted())

        try toMany.applyToDb()
        toMany.reset()
        XCTAssertEqual(values, toMany.map { $0.name }.sorted())
    }

    func testToMany_unsavedHost() throws {
        let customer = Customer(name: "Chuck")
        XCTAssertEqual(customer.orders.count, 0)
        let apples = Order(name: "Apples", target: customer)
        customer.orders.append(apples)
        XCTAssertFalse(customer.orders.canInteractWithDb)
        try customerBox.put(customer)
        XCTAssert(customer.orders.canInteractWithDb)
        XCTAssertNotEqual(customer.id, 0)

        XCTAssertNotEqual(apples.id, 0)
        XCTAssertEqual(try orderBox.count(), 1)

        try customer.orders.applyToDb()
        XCTAssertNotEqual(apples.id, 0)
        XCTAssertEqual(try orderBox.count(), 1)
    }
}
