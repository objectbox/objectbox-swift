//
// Copyright © 2019-2025 ObjectBox Ltd. All rights reserved.
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

import ObjectBox

// Note: the EntityInfo.generated.swift and model.json for this are generated using
// the generate.sh script in this directory.
//
// TODO/Warning: Existing tests use a manually built model, check Helpers/TestEntities.swift!

// swiftlint:disable all
class Customer: Entity {
    var id: Id
    var name: String

    // objectbox: backlink = "customer"
    var orders: ToMany<Order>

    required init() {
        self.id = 0
        self.name = ""
        self.orders = nil
    }

    convenience init(name: String) {
        self.init()
        self.name = name
        self.orders = nil
    }
}

class Order: Entity {
    var id: Id
    var date: Date
    var customer: ToOne<Customer>
    var name: String

    required init() {
        self.id = 0
        self.customer = nil
        self.date = Date()
        self.name = ""
    }

    convenience init(name: String = "", target: Customer? = nil) {
        self.init()
        self.name = name
        customer.target = target
    }

}
