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

// swiftlint:disable force_try

import XCTest
import ObjectBox

class ToOneRelationTests: XCTestCase {

    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store.customerOrderStore()
    }

    override func tearDown() {
        try! store?.closeAndDeleteAllFiles()
        store = nil
        super.tearDown()
    }

    func testEmptyRelation() throws {
        let orderBox = store.box(for: Order.self)
        let orderId: Id<Order> = try {
            let order = Order()
            XCTAssertNil(order.customer.target)
            return try orderBox.put(order)
        }()

        guard let order = orderBox.get(orderId) else { XCTFail("Expected to find order"); return }

        XCTAssertNil(order.customer.target)
    }

    func testChangingRelationToExistingObjectAfterInitialPut() throws {
        let existingCustomer = Customer(name: "Existing beforehand")
        try store.box(for: Customer.self).put(existingCustomer)

        let orderBox = store.box(for: Order.self)
        let orderId: Id<Order> = try {
            let order = Order()
            return try orderBox.put(order)
        }()

        if let order = orderBox.get(orderId) {
            order.customer.target = existingCustomer
            try orderBox.put(order)
        } else { XCTFail("Expected to find order"); return }

        if let order = orderBox.get(orderId) {
            if let customer = order.customer.target {
                XCTAssertEqual(customer.name, existingCustomer.name)
                // Backlink
                XCTAssertEqual(customer.orders.count, 1)
                XCTAssertEqual(customer.orders[safe: 0]?.id, orderId)
                XCTAssertEqual(customer.orders[safe: 0]?.customer.target?.name, existingCustomer.name)
            } else {
                XCTFail("Expected to find associated customer in \(order.customer)")
            }
        } else { XCTFail("Expected to find order"); return }
    }

    func testExistingRelationBeforePut() throws {
        let orderBox = store.box(for: Order.self)
        let orderId: Id<Order> = try {
            let customer = Customer(name: "Foo Bar")
            let order = Order()
            order.customer.target = customer
            return try orderBox.put(order)
        }()

        guard let order = orderBox.get(orderId) else { XCTFail("Expected to find order"); return }

        if let customer = order.customer.target {
            XCTAssertEqual(customer.name, "Foo Bar")
        } else {
            XCTFail("Expected to find associated customer")
        }
    }

    func testChangingRelationToNewObjectAfterInitialPut() throws {
        let orderBox = store.box(for: Order.self)
        let orderId: Id<Order> = try {
            let order = Order()
            return try orderBox.put(order)
        }()

        if let order = orderBox.get(orderId) {
            order.customer.target = Customer(name: "After the Fact")
            try orderBox.put(order)
        } else { XCTFail("Expected to find order"); return }

        if let order = orderBox.get(orderId) {
            if let customer = order.customer.target {
                XCTAssertEqual(customer.name, "After the Fact")
            } else {
                XCTFail("Expected to find associated customer")
            }
        } else { XCTFail("Expected to find order"); return }
    }

    // MARK: Backlinks

    func testBacklinkAlone_WithoutBacklinks() throws {
        let customerBox = store.box(for: Customer.self)
        let customer = Customer(name: "A customer")
        let customerId = try customerBox.put(customer)

        guard let fetchedCustomer = customerBox.get(customerId) else { XCTFail("Expected existing customer"); return }

        XCTAssert(fetchedCustomer.orders.isEmpty)
    }

    func testBacklinkAlone_WithForwardLinkNotSaved() throws {
        let customerBox = store.box(for: Customer.self)

        let existingCustomer = Customer(name: "Existing beforehand")

        // Set but do not persist forward relation
        let order = Order()
        order.customer.target = existingCustomer

        let customerId = try customerBox.put(existingCustomer)

        guard let fetchedCustomer = customerBox.get(customerId) else { XCTFail("Expected existing customer"); return }

        XCTAssert(fetchedCustomer.orders.isEmpty)
    }
}

extension Collection {
    subscript (safe index: Self.Index) -> Self.Iterator.Element? {
        return index < endIndex ? self[index] : nil
    }
}
