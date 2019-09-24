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

#if COMBINE_SUPPORT
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Observer: Subscription {
    public func request(_ demand: Subscribers.Demand) {
        // We only inform on changes.
    }
    
    public func cancel() {
        unsubscribe()
    }
}

// MARK: -

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Box {
    public var publisher: BoxPublisher<EntityType> {
        return store.lazyAttachedObject(key: "BoxPublisher<\(EntityType.self)>") {
            return BoxPublisher<EntityType>(store: store)
        }
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class BoxPublisher<E>: Publisher
where E: EntityInspectable & __EntityRelatable, E.EntityBindingType.EntityType == E {
    public typealias Output = [E]
    public typealias Failure = ObjectBoxError
    
    private var store: Store
    private var subscribers = [SubscriberId: Observer]()
    private var subscriberIdSeed: SubscriberId = 0
    private let subscriberLock = DispatchSemaphore(value: 1)

    init(store: Store) {
        Swift.print("Create publisher for box \(E.self)")
        self.store = store
    }
    
    deinit {
        Swift.print("Destroy publisher for box \(E.self)")
    }
    
    /// Register a combine subscriber to be notified whenever entities are added/modified/removed.
    /// Notifications are dispatched on the main queue.
    /// - Parameter subscriber: The subscriber you want to receive the subscription.
    public func receive<S>(subscriber: S)
        where S: Subscriber, BoxPublisher.Failure == S.Failure, BoxPublisher.Output == S.Input {
        receive(subscriber: subscriber, dispatchQueue: DispatchQueue.main)
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension BoxPublisher {
    private typealias SubscriberId = Int
    
    private func nextSubscriberId() -> SubscriberId {
        subscriberLock.wait()
        defer { subscriberLock.signal() }
        let initialId = subscriberIdSeed
        while subscribers[subscriberIdSeed] != nil {
            subscriberIdSeed &+= 1 // Add with wraparound.
            if subscriberIdSeed == initialId {
                // You will run out of addressable memory long before you will ever hit this, but let's be paranoid.
                fatalError("Out of subscriber ID slots. Are you leaking subscriptions?")
            }
        }
        return subscriberIdSeed
    }
    
    // swiftlint:disable identifier_name
    private func setSubscriber(id: SubscriberId, observer: Observer?) {
        subscriberLock.wait()
        defer { subscriberLock.signal() }
        subscribers[id] = observer
    }
    // swiftlint:enable identifier_name

    /// Register a combine subscriber to be notified whenever entities are added/modified/removed.
    /// - Parameter subscriber: The subscriber you want to receive the subscription.
    /// - Parameter dispatchQueue: The queue on which new data and completion are to be delivered.
    public func receive<S>(subscriber: S, dispatchQueue: DispatchQueue)
        where S: Subscriber, BoxPublisher.Failure == S.Failure, BoxPublisher.Output == S.Input {
        let box = store.box(for: E.self)
        let subscriberId = nextSubscriberId()
        
        let observer = box.subscribe(dispatchQueue: dispatchQueue, resultHandler: { entities, error in
            if let error = error {
                self.setSubscriber(id: subscriberId, observer: nil)
                subscriber.receive(completion: .failure(error))
                return
            }
            
            let demand = subscriber.receive(entities)
            switch demand {
            case .unlimited:
                break
            case .none:
                self.setSubscriber(id: subscriberId, observer: nil)
                subscriber.receive(completion: .finished)
            default:
                break
            }
        })
        setSubscriber(id: subscriberId, observer: observer)
        subscriber.receive(subscription: observer)
    }
}

// MARK: -

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Query {
    public var publisher: QueryPublisher<EntityType> {
        return store.lazyAttachedObject(key: "QueryPublisher<\(EntityType.self)>") {
            return QueryPublisher<EntityType>(query: self)
        }
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class QueryPublisher<E>: Publisher
where E: EntityInspectable & __EntityRelatable, E.EntityBindingType.EntityType == E {
    public typealias Output = [E]
    public typealias Failure = ObjectBoxError
    
    var query: Query<E>
    private var subscribers = [SubscriberId: Observer]()
    private var subscriberIdSeed: SubscriberId = 0
    private let subscriberLock = DispatchSemaphore(value: 1)

    init(query: Query<E>) {
        Swift.print("Create publisher for query \(E.self)")
        self.query = query
    }
    
    deinit {
        Swift.print("Destroy publisher for query \(E.self)")
    }
    
    /// Register a combine subscriber to be notified whenever the query's contents change.
    /// Notifications are dispatched on the main queue.
    /// - Parameter subscriber: The subscriber you want to receive the subscription.
    /// - important: There may be spurious calls to your callback when your query results haven't actually changed,
    /// but something else in this box has.
    public func receive<S>(subscriber: S)
        where S: Subscriber, QueryPublisher.Failure == S.Failure, QueryPublisher.Output == S.Input {
        receive(subscriber: subscriber, dispatchQueue: DispatchQueue.main)
    }
}
 
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension QueryPublisher {
    private typealias SubscriberId = Int
    
    private func nextSubscriberId() -> SubscriberId {
        subscriberLock.wait()
        defer { subscriberLock.signal() }
        let initialId = subscriberIdSeed
        while subscribers[subscriberIdSeed] != nil {
            subscriberIdSeed &+= 1 // Add with wraparound.
            if subscriberIdSeed == initialId {
                // You will run out of addressable memory long before you will ever hit this, but let's be paranoid.
                fatalError("Out of subscriber ID slots. Are you leaking subscriptions?")
            }
        }
        return subscriberIdSeed
    }
    
    // swiftlint:disable identifier_name
    private func setSubscriber(id: SubscriberId, observer: Observer?) {
        subscriberLock.wait()
        defer { subscriberLock.signal() }
        subscribers[id] = observer
    }
    // swiftlint:enable identifier_name

    /// Register a combine subscriber to be notified whenever the query's contents change.
    /// - Parameter subscriber: The subscriber you want to receive the subscription.
    /// - Parameter dispatchQueue: The queue on which new data and completion are to be delivered.
    /// - important: There may be spurious calls to your callback when your query results haven't actually changed,
    /// but something else in this box has.
    public func receive<S>(subscriber: S, dispatchQueue: DispatchQueue)
        where S: Subscriber, QueryPublisher.Failure == S.Failure, QueryPublisher.Output == S.Input {
        let subscriberId = nextSubscriberId()
        
        let observer = query.subscribe(dispatchQueue: dispatchQueue, resultHandler: { entities, error in
            if let error = error {
                self.setSubscriber(id: subscriberId, observer: nil)
                subscriber.receive(completion: .failure(error))
                return
            }
            
            Swift.print("Notify publisher")
            let demand = subscriber.receive(entities)
            switch demand {
            case .unlimited:
                break
            case .none:
                Swift.print("\tUnsubscribe")
                self.setSubscriber(id: subscriberId, observer: nil)
                subscriber.receive(completion: .finished)
            default:
                break
            }
        })
        setSubscriber(id: subscriberId, observer: observer)
        subscriber.receive(subscription: observer)
    }
}

#endif /*COMBINE_SUPPORT*/
