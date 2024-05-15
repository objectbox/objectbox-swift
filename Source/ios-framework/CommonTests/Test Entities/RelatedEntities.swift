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

fileprivate func cModel() throws -> OpaquePointer {
    let modelBuilder = try ObjectBox.ModelBuilder()
    try Customer.buildEntity(modelBuilder: modelBuilder)
    try Order.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 2, uid: 4696988777145786880)
    modelBuilder.lastIndex(id: 1, uid: 6572619879603300096)
    return modelBuilder.finish()
}

extension ObjectBox.Store {
    static func customerOrderStore() -> Store {
        let store = StoreHelper.tempStore(model: try! cModel())
        return store
    }
}


// MARK: - Generated Code

// This is updated by running generate.rb on this file:
// - replace the model.json with relations-model.json (to keep UIDs),
// - in generate.rb change file name to `RelatedEntities.swift` and run it, then
// - manually copying over the entity class extensions from `EntityInfo.generated.swift`
//   and any relevant changes to the custom ObjectBox.Store and cModel() above.

extension Customer: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Customer

    internal var _id: EntityId<Customer> {
        return EntityId<Customer>(self.id.value)
    }
}

extension Customer: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = CustomerBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Customer", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Customer.self, id: 1, uid: 3108946752808668672)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 4599907934352290304)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 4753378302570674176)

        try entityBuilder.lastProperty(id: 2, uid: 4753378302570674176)
    }
}

extension Customer {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Customer.id == myId }
    internal static var id: Property<Customer, Id, Id> { return Property<Customer, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Customer.name.startsWith("X") }
    internal static var name: Property<Customer, String, Void> { return Property<Customer, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Use `Customer.orders` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var orders: ToManyProperty<Order> { return ToManyProperty(.valuePropertyId(3)) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Customer {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Customer, Id, Id> { return Property<Customer, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<Customer, String, Void> { return Property<Customer, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Use `.orders` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var orders: ToManyProperty<Order> { return ToManyProperty(.valuePropertyId(3)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Customer.EntityBindingType`.
internal class CustomerBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = Customer
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) throws {
        if entityId(of: entity) == 0 {  // New object was put? Attach relations now that we have an ID.
            let orders = ToMany<Order>.backlink(
                sourceBox: store.box(for: ToMany<Order>.ReferencedType.self),
                sourceProperty: ToMany<Order>.ReferencedType.customer,
                targetId: EntityId<Customer>(id.value))
            if !entity.orders.isEmpty {
                orders.replace(entity.orders)
            }
            entity.orders = orders
            try entity.orders.applyToDb()
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Customer()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.orders = ToMany<Order>.backlink(
            sourceBox: store.box(for: ToMany<Order>.ReferencedType.self),
            sourceProperty: ToMany<Order>.ReferencedType.customer,
            targetId: EntityId<Customer>(entity.id.value))
        return entity
    }
}



extension Order: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Order

    internal var _id: EntityId<Order> {
        return EntityId<Order>(self.id.value)
    }
}

extension Order: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = OrderBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Order", id: 2)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Order.self, id: 2, uid: 4696988777145786880)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 7043323637153822208)
        try entityBuilder.addProperty(name: "date", type: PropertyType.date, id: 2, uid: 1093928144598205440)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 4, uid: 8814640457730390784)
        try entityBuilder.addToOneRelation(name: "customer", targetEntityInfo: ToOne<Customer>.Target.entityInfo, flags: [.indexed, .indexPartialSkipZero], id: 3, uid: 2829338735976216064, indexId: 1, indexUid: 6572619879603300096)

        try entityBuilder.lastProperty(id: 4, uid: 8814640457730390784)
    }
}

extension Order {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Order.id == myId }
    internal static var id: Property<Order, Id, Id> { return Property<Order, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Order.date > 1234 }
    internal static var date: Property<Order, Date, Void> { return Property<Order, Date, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Order.name.startsWith("X") }
    internal static var name: Property<Order, String, Void> { return Property<Order, String, Void>(propertyId: 4, isPrimaryKey: false) }
    internal static var customer: Property<Order, EntityId<ToOne<Customer>.Target>, ToOne<Customer>.Target> { return Property(propertyId: 3) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Order {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Order, Id, Id> { return Property<Order, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .date > 1234 }

    internal static var date: Property<Order, Date, Void> { return Property<Order, Date, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<Order, String, Void> { return Property<Order, String, Void>(propertyId: 4, isPrimaryKey: false) }

    internal static var customer: Property<Order, ToOne<Customer>.Target.EntityBindingType.IdType, ToOne<Customer>.Target> { return Property<Order, ToOne<Customer>.Target.EntityBindingType.IdType, ToOne<Customer>.Target>(propertyId: 3) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Order.EntityBindingType`.
internal class OrderBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = Order
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.date, at: 2 + 2 * 2)
        try propertyCollector.collect(entity.customer, at: 2 + 2 * 3, store: store)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 4)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) throws {
        if entityId(of: entity) == 0 {  // New object was put? Attach relations now that we have an ID.
            entity.customer.attach(to: store.box(for: Customer.self))
        }
    }
    internal func setToOneRelation(_ propertyId: obx_schema_id, of entity: EntityType, to entityId: ObjectBox.Id?) {
        switch propertyId {
            case 3:
                entity.customer.targetId = (entityId != nil) ? EntityId<Customer>(entityId!) : nil
            default:
                fatalError("Attempt to change nonexistent ToOne relation with ID \(propertyId)")
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Order()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.date = entityReader.read(at: 2 + 2 * 2)
        entity.name = entityReader.read(at: 2 + 2 * 4)

        entity.customer = entityReader.read(at: 2 + 2 * 3, store: store)
        return entity
    }
}
