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
        let orderId: EntityId<Order> = try {
            let order = Order()
            XCTAssertNil(order.customer.target)
            return try orderBox.put(order)
        }()

        guard let order = try orderBox.get(orderId) else { XCTFail("Expected to find order"); return }

        XCTAssertNil(order.customer.target)
    }

    func testChangingRelationToExistingObjectAfterInitialPut() throws {
        let existingCustomer = Customer(name: "Existing beforehand")
        try store.box(for: Customer.self).put(existingCustomer)

        let orderBox = store.box(for: Order.self)
        let orderId: EntityId<Order> = try {
            let order = Order()
            return try orderBox.put(order)
        }()

        if let order = try orderBox.get(orderId) {
            order.customer.target = existingCustomer
            try orderBox.put(order)
        } else { XCTFail("Expected to find order"); return }

        if let order = try orderBox.get(orderId) {
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
        let orderId: EntityId<Order> = try {
            let customer = Customer(name: "Foo Bar")
            let order = Order()
            order.customer.target = customer
            return try orderBox.put(order)
        }()

        guard let order = try orderBox.get(orderId) else { XCTFail("Expected to find order"); return }

        if let customer = order.customer.target {
            XCTAssertEqual(customer.name, "Foo Bar")
        } else {
            XCTFail("Expected to find associated customer")
        }
    }

    func testChangingRelationToNewObjectAfterInitialPut() throws {
        let orderBox = store.box(for: Order.self)
        let orderId: EntityId<Order> = try {
            let order = Order()
            return try orderBox.put(order)
        }()

        if let order = try orderBox.get(orderId) {
            order.customer.target = Customer(name: "After the Fact")
            try orderBox.put(order)
        } else { XCTFail("Expected to find order"); return }

        if let order = try orderBox.get(orderId) {
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

        guard let fetchedCustomer = try customerBox.get(customerId) else {
            XCTFail("Expected existing customer"); return
        }

        XCTAssert(fetchedCustomer.orders.isEmpty)
    }

    func testBacklinkAlone_WithForwardLinkNotSaved() throws {
        let customerBox = store.box(for: Customer.self)

        let existingCustomer = Customer(name: "Existing beforehand")

        // Set but do not persist forward relation
        let order = Order()
        order.customer.target = existingCustomer

        let customerId = try customerBox.put(existingCustomer)

        guard let fetchedCustomer = try customerBox.get(customerId) else {
            XCTFail("Expected existing customer"); return
        }
        
        XCTAssert(fetchedCustomer.orders.isEmpty)
    }
    
    func testLinkQuery() throws {
        let customerBox = store.box(for: Customer.self)
        
        let orderCustomer = Customer(name: "Olivia Orderedit")
        let notOrderCustomer = Customer(name: "Nellie Neverorders")
        
        let order1 = Order()
        order1.customer.target = notOrderCustomer
        try customerBox.put(notOrderCustomer)
        
        let order2 = Order()
        order2.customer.target = orderCustomer
        try customerBox.put(orderCustomer)
        
        let orderBox = store.box(for: Order.self)
        try orderBox.put([order1, order2])
        
        let foundOrders = try orderBox.query().link(Order.customer) {
            Customer.name == "Olivia Orderedit"
            }.build().find()
        XCTAssertEqual(foundOrders.count, 1)
        XCTAssertEqual(foundOrders.first?.customer.target?.name, "Olivia Orderedit")
    }
    
    func testLinkQueryWithAnd() throws {
        let customerBox = store.box(for: Customer.self)
        
        let orderCustomer = Customer(name: "Olivia Orderedit")
        let notOrderCustomer = Customer(name: "Nellie Neverorders")
        let notOrderCustomerEither = Customer(name: "Fran Forgottoorder")

        let order1 = Order()
        order1.name = "This is not an order"
        order1.customer.target = notOrderCustomer
        try customerBox.put(notOrderCustomer)
        
        let order2 = Order()
        order2.name = "Absolutely an order"
        order2.customer.target = orderCustomer
        try customerBox.put(orderCustomer)
        
        let order3 = Order()
        order3.name = order2.name
        order3.customer.target = notOrderCustomerEither
        try customerBox.put(notOrderCustomerEither)
        
        let orderBox = store.box(for: Order.self)
        try orderBox.put([order1, order2, order3])
        
        let foundOrders = try orderBox.query {
            Order.name == order2.name
            }.link(Order.customer) {
                Customer.name == orderCustomer.name
            }.build().find()
        XCTAssertEqual(foundOrders.count, 1)
        XCTAssertEqual(foundOrders.first?.customer.target?.name, "Olivia Orderedit")
    }
    
    func testBacklinkQueryWithAnd() throws {
        let customerBox = store.box(for: Customer.self)
        
        let orderCustomer = Customer(name: "Olivia Orderedit")
        let notOrderCustomer = Customer(name: "Nellie Neverorders")
        let orderCustomer2 = Customer(name: "Melanie Mailme")
        
        let order1 = Order()
        order1.name = "This is not an order"
        order1.customer.target = notOrderCustomer
        try customerBox.put(notOrderCustomer)
        
        let order2 = Order()
        order2.name = "Absolutely an order"
        order2.customer.target = orderCustomer
        try customerBox.put(orderCustomer)
        
        let order3 = Order()
        order3.name = order2.name
        order3.customer.target = orderCustomer2
        try customerBox.put(orderCustomer2)

        let orderBox = store.box(for: Order.self)
        try orderBox.put([order1, order2, order3])
        
        let foundCustomers = try customerBox.query().link(Customer.orders) {
                Order.name == order2.name
            }.build().find()
        XCTAssertEqual(foundCustomers.count, 2)
        
        XCTAssertNotNil(foundCustomers.first(where: { $0.name == orderCustomer.name }))
        XCTAssertNotNil(foundCustomers.first(where: { $0.name == orderCustomer2.name }))
    }
    
    func testToOneBacklinkReset() throws {
        let customerBox = store.box(for: Customer.self)
        
        let orderCustomer = Customer(name: "Olivia Orderedit")
        try customerBox.put(orderCustomer)

        let order1 = Order()
        order1.name = "This is not an order"
        order1.customer.target = orderCustomer

        let order2 = Order()
        order2.name = "Absolutely an order"
        order2.customer.target = orderCustomer
        
        let order3 = Order()
        order3.name = "Shoes"
        order3.customer.target = orderCustomer
        
        let orderBox = store.box(for: Order.self)
        try orderBox.put([order1, order2, order3])
        
        let originalResult = orderCustomer.orders.map { $0.name }.sorted()
        XCTAssertEqual(originalResult.count, 3)
        try orderBox.remove(order2)
        let cachedResult = orderCustomer.orders.map { $0.name }.sorted()
        orderCustomer.orders.reset()
        let changedResult = orderCustomer.orders.map { $0.name }.sorted()
        XCTAssertEqual(changedResult.count, 2)

        XCTAssertEqual(originalResult, cachedResult)
        XCTAssertNotEqual(originalResult, changedResult)
    }
    
    func testToOneReset() throws {
        let customerBox = store.box(for: Customer.self)
        
        let orderCustomer = Customer(name: "Olivia Orderedit")
        try customerBox.put(orderCustomer)

        let order1 = Order()
        order1.name = "This is not an order"
        order1.customer.target = orderCustomer

        let orderBox = store.box(for: Order.self)
        try orderBox.put(order1)
        
        XCTAssertEqual(order1.customer.target!.name, orderCustomer.name) // Loaded backreference matches what we wrote?
        order1.customer.reset()
        XCTAssertEqual(order1.customer.target!.name, orderCustomer.name) // After reset w/o change, still the same?
        
        let readCustomer = try customerBox.get(orderCustomer.id)!
        readCustomer.name = "Hannah Hasordered"
        try customerBox.put(readCustomer)
        XCTAssertNotEqual(orderCustomer.name, readCustomer.name) // Just to be paranoid.

        XCTAssertEqual(order1.customer.target!.name, orderCustomer.name) // Still cached old value?
        order1.customer.reset()
        XCTAssertEqual(order1.customer.target!.name, readCustomer.name) // New value after reset?
    }
}

extension Collection {
    subscript (safe index: Self.Index) -> Self.Iterator.Element? {
        return index < endIndex ? self[index] : nil
    }
}
