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

import ObjectBox

// swiftlint:disable all
class Customer: Entity {
    var id: EntityId<Customer>
    var name: String

    // sourcery: backlink = "customer"
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
    var id: EntityId<Order>
    var date: Date
    var customer: ToOne<Customer>
    var name: String

    required init() {
        self.id = 0
        self.customer = nil
        self.date = Date()
        self.name = ""
    }
}

fileprivate func cModel() throws -> OpaquePointer {
    let modelBuilder = try ModelBuilder()
    try Customer.buildEntity(modelBuilder: modelBuilder)
    try Order.buildEntity(modelBuilder: modelBuilder)
    return modelBuilder.finish()
}

extension ObjectBox.Store {
    static func customerOrderStore() -> Store {
        let store = StoreHelper.tempStore(model: try! cModel())
        return store
    }
}


// MARK: - Generated Code

// This code is equivalent to our `EntityInfo.generated.swift` code, minus the convenience Store.init() and cModel()
//  from generated code (we have a custom one above)

extension Customer: __EntityRelatable {
    typealias EntityType = Customer

    var _id: EntityId<Customer> {
        return self.id
    }
}

extension Customer: EntityInspectable {
    typealias EntityBindingType = CustomerCursor
    
    /// Generated metadata used by ObjectBox to persist the entity.
    static var entityInfo = EntityInfo(name: "Customer", id: 4)
    static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Customer.self, id: 4, uid: 1004)
        try entityBuilder.addProperty(name: "id", type: EntityId<Customer>.entityPropertyType, flags: [.id], id: 1, uid: 1)
        try entityBuilder.addProperty(name: "name", type: String.entityPropertyType, id: 2, uid: 2)
        try entityBuilder.lastProperty(id: 2, uid: 2)
        modelBuilder.lastEntity(id: 4, uid: 1004)
        modelBuilder.lastIndex(id: 0, uid: 0)
    }
}

extension Customer {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Customer.id == myId }
    static var id: Property<Customer, EntityId<Customer>, Void> { return Property<Customer, EntityId<Customer>, Void>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Customer.name.startsWith("X") }
    static var name: Property<Customer, String, Void> { return Property<Customer, String, Void>(propertyId: 2, isPrimaryKey: false) }
    
    static var orders: ToManyProperty<Order> { return ToManyProperty<Order>(.valuePropertyId(3)) }

    fileprivate  func __setId(identifier: Id) {
        self.id = EntityId(identifier)
    }
}

/// Generated service type to handle persisting and reading entity data. Exposed through `Customer.entityBinding`.
class CustomerCursor: EntityBinding {
    
    typealias EntityType = Customer
    typealias IdType = EntityId<Customer>

    required init() {}
    
    func setEntityIdUnlessStruct(of entity: Customer, to entityId: Id) {
        entity.__setId(identifier: entityId)
    }
    
    func entityId(of entity: Customer) -> Id {
        return entity.id.value
    }

    func collect(fromEntity entity: Customer, id: Id, propertyCollector: FlatBufferBuilder, store: Store) {
        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.name), 2 + 2*2))

        propertyCollector.collect(id, at: 2 + 2*1)

        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
        }
    }

    internal func postPut(fromEntity entity: EntityType, id: Id, store: Store) {
        if entityId(of: entity) == 0 { // Written for first time? Attach ToMany relations:
            let orders = ToMany<Order>.backlink(
                sourceBox: store.box(for: ToMany<Order>.ReferencedType.self),
                sourceProperty: ToMany<Order>.ReferencedType.customer,
                targetId: EntityId<Customer>(id))
            if !entity.orders.isEmpty {
                orders.replace(entity.orders)
            }
            entity.orders = orders
        }
    }
    func createEntity(entityReader: FlatBufferReader, store: Store) -> Customer {
        let entity = Customer()

        entity.id = entityReader.read(at: 2 + 2*1)

        entity.name = entityReader.read(at: 2 + 2*2)
        entity.orders = ToMany<Order>.backlink(
            sourceBox: store.box(for: ToMany<Order>.ReferencedType.self),
            sourceProperty: ToMany<Order>.ReferencedType.customer,
            targetId: entity.id)
        return entity
    }
}

extension Order: __EntityRelatable {
    typealias EntityType = Order

    var _id: EntityId<Order> {
        return self.id
    }
}

extension Order: EntityInspectable {
    public typealias EntityBindingType = OrderCursor
    
    /// Generated metadata used by ObjectBox to persist the entity.
    static var entityInfo = EntityInfo(name: "Order", id: 5)
    static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Order.self, id: 5, uid: 1005)
        try entityBuilder.addProperty(name: "id", type: EntityId<Order>.entityPropertyType, flags: [.id], id: 1, uid: 3)
        try entityBuilder.addProperty(name: "date", type: Date.entityPropertyType, id: 2, uid: 4)
        try entityBuilder.addToOneRelation(name: "customer", targetEntityInfo: ToOne<Customer>.Target.entityInfo, id: 3, uid: 5, indexId: 1, indexUid: 66223399)
        try entityBuilder.addProperty(name: "name", type: String.entityPropertyType, id: 4, uid: 6)
        try entityBuilder.lastProperty(id: 4, uid: 6)
        modelBuilder.lastEntity(id: 5, uid: 1005)
        modelBuilder.lastIndex(id: 1, uid: 66223399)
    }
}

extension Order {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Order.id == myId }
    static var id: Property<Order, EntityId<Order>, Void> { return Property<Order, EntityId<Order>, Void>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Order.date.isBefore(lastSunday) }
    static var date: Property<Order, Date, Void> { return Property<Order, Date, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity relation property information.
    static var customer: Property<Order, EntityId<ToOne<Customer>.Target>, ToOne<Customer>.Target> { return Property(propertyId: 3) }

    static var name: Property<Order, String, Void> { return Property<Order, String, Void>(propertyId: 4, isPrimaryKey: false) }

    fileprivate  func __setId(identifier: Id) {
        self.id = EntityId(identifier)
    }
}

/// Generated service type to handle persisting and reading entity data. Exposed through `Order.entitySchemaId`.
class OrderCursor: EntityBinding {
    typealias EntityType = Order
    typealias IdType = EntityId<Order>

    required init() {}
    
    func setEntityIdUnlessStruct(of entity: Order, to entityId: Id) {
        entity.__setId(identifier: entityId)
    }
    
    func entityId(of entity: Order) -> Id {
        return entity.id.value
    }

    func collect(fromEntity entity: Order, id: Id, propertyCollector: FlatBufferBuilder, store: Store) {
        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.name), 2 + 2*4))
        
        propertyCollector.collect(id, at: 2 + 2*1)
        
        propertyCollector.collect(entity.date, at: 2 + 2*2)
        propertyCollector.collect(entity.customer, at: 2 + 2*3, store: store)

        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
        }
    }

    internal func postPut(fromEntity entity: EntityType, id: Id, store: Store) {
        if entityId(of: entity) == 0 { // Written for first time? Attach ToMany relations:
            entity.customer.attach(to: store.box(for: Customer.self))
        }
    }
    internal func setToOneRelation(_ propertyId: obx_schema_id, of entity: EntityType, to entityId: Id?) {
        switch propertyId {
        case 3:
            entity.customer.targetId = (entityId != nil) ? EntityId<Customer>(entityId!) : nil
        default:
            fatalError("Attempt to change nonexistent ToOne relation with ID \(propertyId)")
        }
    }
    func createEntity(entityReader: FlatBufferReader, store: Store) -> Order {
        let entity = Order()

        entity.id = entityReader.read(at: 2 + 2*1)

        entity.date = entityReader.read(at: 2 + 2*2)
        entity.customer = entityReader.read(at: 2 + 2*3, store: store)
        entity.name = entityReader.read(at: 2 + 2*4)
        return entity
    }
}
