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

import Combine
import Foundation

/// :nodoc:
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Observer: Subscription {
    /// :nodoc:
    public func request(_ demand: Subscribers.Demand) {
        // We only inform on changes.
    }
    
    /// :nodoc:
    public func cancel() {
        unsubscribe()
    }
}

// MARK: -

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Box {
    /// Return a Combine publisher for this box that you can subscribe to, to be notified of changes in this box.
    public var publisher: BoxPublisher<EntityType> {
        return store.lazyAttachedObject(key: "BoxPublisher<\(EntityType.self)>") {
            return BoxPublisher<EntityType>(store: store)
        }
    }
}

/// Combine publisher for an ObjectBox box. You obtain an instance of this type via the `publisher` property on `Box`.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class BoxPublisher<E>: Publisher
where E: EntityInspectable & __EntityRelatable, E.EntityBindingType.EntityType == E {
    /// The result type of this publisher.
    public typealias Output = [E]
    /// The error type of this publisher.
    public typealias Failure = ObjectBoxError
    
    /// The store this publisher operates on.
    private weak var store: Store!
    private var subscribers = [SubscriberId: Observer]()
    private var subscriberIdSeed: SubscriberId = 0
    private let subscriberLock = DispatchSemaphore(value: 1)

    internal init(store: Store) {
        self.store = store
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
    
    private func setSubscriber(id: SubscriberId, observer: Observer?) {
        subscriberLock.wait()
        defer { subscriberLock.signal() }
        subscribers[id] = observer
    }

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
    /// Return a Combine publisher for this query that you can subscribe to.
    public var publisher: QueryPublisher<EntityType> {
        let keyString = "QueryPublisher<\(EntityType.self)>\(Unmanaged.passUnretained(self).toOpaque())"
        return store.lazyAttachedObject(key: keyString) {
            return QueryPublisher<EntityType>(query: self)
        }
    }
}

/// Combine publisher for an ObjectBox query. You obtain an instance of this type via the `publisher` property on
/// `Query`.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class QueryPublisher<E>: Publisher
where E: EntityInspectable & __EntityRelatable, E.EntityBindingType.EntityType == E {
    /// The result type of this publisher.
    public typealias Output = [E]
    /// The error type of this publisher.
    public typealias Failure = ObjectBoxError
    
    /// The query this publisher operates on.
    var query: Query<E>
    private var subscribers = [SubscriberId: Observer]()
    private var subscriberIdSeed: SubscriberId = 0
    private let subscriberLock = DispatchSemaphore(value: 1)

    internal init(query: Query<E>) {
        self.query = query
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
    
    private func setSubscriber(id: SubscriberId, observer: Observer?) {
        subscriberLock.wait()
        defer { subscriberLock.signal() }
        subscribers[id] = observer
    }

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
