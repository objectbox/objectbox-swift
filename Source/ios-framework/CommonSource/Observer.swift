//
// Copyright © 2018-2022 ObjectBox Ltd. All rights reserved.
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

import Foundation

internal func observerCallback(_ ptr: UnsafeMutableRawPointer?) {
    let context: Observer = Unmanaged.fromOpaque(ptr!).takeUnretainedValue()
    // Before obx_observer_close() checked for locking failures, we had it freezing sporadically here:
    // the observer context deinited from this method (not sure why yet...) causing a call to obx_observer_close().
    // After the change to obx_observer_close() this did not occur anymore (also no errors on obx_observer_close()!?)
    context.dispatchQueue.async {
        context.changeHandler()
    }
}

/// An opaque object that serves as a reference to a change subscription on a Box or Query.
/// Keep a strong reference to this object (in a property or a global) as long as you want to receive
/// callbacks. Let this object deinit to cancel your subscription.
///
/// You obtain an Observer from one of a `Box`'s or `Query`'s `subscribe()` methods.
public class Observer {
    private var cObserver: OpaquePointer?
    internal var changeHandler: () -> Void
    internal var dispatchQueue: DispatchQueue
    
    /// Flags to pass to the various `subscribe` calls on `Box` and `Query`.
    public struct Flags: OptionSet {
        /// :nodoc:
        public let rawValue: Int
        
        /// Immediately send the current value so the receiver is initialized with current state?
        public static let sendInitial = Flags(rawValue: 1 << 0)
        /// Don't subscribe. Usually this is used in combination with `.sendInitial` to seed a
        /// not-live-updating snapshot (e.g. when printing).
        public static let dontSubscribe = Flags(rawValue: 1 << 1)
        
        /// :nodoc:
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    internal init(store: Store, entityId: obx_schema_id, dispatchQueue: DispatchQueue,
                  changeHandler: @escaping () -> Void) {
        self.dispatchQueue = dispatchQueue
        self.changeHandler = changeHandler
        cObserver = obx_observe_single_type(store.cStore, entityId, observerCallback,
                                            Unmanaged.passUnretained(self).toOpaque())
    }
    
    deinit {
        unsubscribe()
    }
    
    /// Terminate your subscription. This object will automatically call this method when it is deinited,
    /// but since not using an object in Swift can lead to warnings, this method is provided so you
    /// can unsubscribe explicitly and make the Swift compiler aware the object _is_ being used.
    public func unsubscribe() {
        if let observerToClose = cObserver {
            cObserver = nil
            let err = obx_observer_close(observerToClose)
            if err != OBX_SUCCESS {
                cObserver = observerToClose  // We can (should) try again on error
            }
            checkLastErrorNoThrow(err)
        }
    }
}

extension Box {
    /// Receive a callback whenever an entity in this box is added/removed or modified.
    /// This variant does not pass the objects in the box to your callback for the case where
    /// you just want to display their count
    /// or are even interested only in whether there are objects or not.
    /// - Parameter dispatchQueue: The dispatch queue on which you want your callback to be called.
    /// - Parameter flags: Flags to control behavior of the subscription
    /// - Parameter changeHandler: A closure to be called when a change occurs.
    /// - Returns: An object representing your observer connection.
    /// As long as this object exists, your callback will be called.
    /// If you no longer want to receive callbacks, let go of your reference to this object so it is deinited.
    /// - SeeAlso: Box.subscribe(dispatchQueue:,resultHandler:)
    public func subscribe(dispatchQueue: DispatchQueue = DispatchQueue.main,
                          flags: Observer.Flags = [.sendInitial],
                          changeHandler: @escaping () -> Void) -> Observer {
        let observer = Observer(store: store, entityId: EntityType.entityInfo.entitySchemaId,
                                dispatchQueue: dispatchQueue, changeHandler: changeHandler)
        if flags.contains(.sendInitial) {
            dispatchQueue.async(execute: observer.changeHandler)
        }
        if flags.contains(.dontSubscribe) {
            observer.unsubscribe()
            if !flags.contains(.sendInitial) {
                fatalError(".dontSubscribe passed without .sendInitial, subscription does nothing.")
            }
        }
        return observer
    }
    
    /// Receive a callback whenever an entity in this box is added/removed or modified.
    /// The callback receives the current list of entities in this box as a parameter,
    /// allowing you to e.g. feed it to Combine or an Rx subscriber.
    /// - Parameter dispatchQueue: The dispatch queue on which you want your callback to be called.
    /// - Parameter flags: Flags to control behavior of the subscription
    /// - Parameter resultHandler: A closure that will be passed an array of the objects in this box
    /// whenever the box contents change.
    /// - Returns: An object representing your observer connection.
    /// As long as the Observer object exists, your callback will be called.
    /// If you no longer want to receive callbacks, let go of your reference to this object so it is deinited.
    /// - SeeAlso: Box.subscribe(dispatchQueue:,changeHandler:)
    public func subscribe(dispatchQueue: DispatchQueue = DispatchQueue.main,
                          flags: Observer.Flags = [.sendInitial],
                          resultHandler: @escaping ([EntityType], ObjectBoxError?) -> Void) -> Observer {
        let observer = Observer(store: store, entityId: EntityType.entityInfo.entitySchemaId,
                                dispatchQueue: dispatchQueue, changeHandler: {
                                    let result: [EntityType]
                                    var resultError: ObjectBoxError?
                                    do {
                                        result = try self.all()
                                    } catch let error as ObjectBoxError {
                                        resultError = error
                                        result = []
                                    } catch {
                                        // Should never reach this spot, but since functions can only declare they
                                        // throw, but not that they only throw one type of error, we have to also
                                        // cover the remaining cases or the compiler is unhappy.
                                        resultError = .unexpected(error: error)
                                        result = []
                                    }
                                    resultHandler(result, resultError)
        })
        if flags.contains(.sendInitial) {
            dispatchQueue.async(execute: observer.changeHandler)
        }
        if flags.contains(.dontSubscribe) {
            observer.unsubscribe()
            if !flags.contains(.sendInitial) {
                fatalError(".dontSubscribe passed without .sendInitial, subscription does nothing.")
            }
        }
        return observer
    }

    /// Variant of subscribe() that is faster due to using ContiguousArray.
    public func subscribeContiguous(dispatchQueue: DispatchQueue = DispatchQueue.main,
                                    flags: Observer.Flags = [.sendInitial],
                                    resultHandler:
        @escaping (ContiguousArray<EntityType>, ObjectBoxError?) -> Void) -> Observer {
        let observer = Observer(store: store, entityId: EntityType.entityInfo.entitySchemaId,
                                dispatchQueue: dispatchQueue, changeHandler: {
                                    let result: ContiguousArray<EntityType>
                                    var resultError: ObjectBoxError?
                                    do {
                                        result = try self.allContiguous()
                                    } catch let error as ObjectBoxError {
                                        resultError = error
                                        result = []
                                    } catch {
                                        // Should never reach this spot, but since functions can only declare they
                                        // throw, but not that they only throw one type of error, we have to also
                                        // cover the remaining cases or the compiler is unhappy.
                                        resultError = .unexpected(error: error)
                                        result = []
                                    }
                                    resultHandler(result, resultError)
        })
        if flags.contains(.sendInitial) {
            dispatchQueue.async(execute: observer.changeHandler)
        }
        if flags.contains(.dontSubscribe) {
            observer.unsubscribe()
            if !flags.contains(.sendInitial) {
                fatalError(".dontSubscribe passed without .sendInitial, subscription does nothing.")
            }
        }
        return observer
    }
}

extension Query {
    /// Receive a callback whenever an entity in this query is added/removed or modified.
    /// This method takes no parameters and is intended for the case where you do not want to display the objects,
    /// but want to for example run a property query or count the entities in the query without retrieving their data.
    /// - Parameter dispatchQueue: The dispatch queue on which you want your callback to be called.
    /// - Parameter flags: Flags to control behavior of the subscription
    /// - Parameter changeHandler: A closure to be called when a change occurs.
    /// - Returns: An object representing your observer connection.
    /// As long as the Observer object exists, your callback will be called.
    /// If you no longer want to receive callbacks, let go of your reference to this object so it is deinited.
    /// - important: There may be spurious calls to your callback when your query results haven't actually changed,
    /// but something else in this box has.
    /// - SeeAlso: Query.subscribe(dispatchQueue:,resultHandler:)
    public func subscribe(dispatchQueue: DispatchQueue = DispatchQueue.main,
                          flags: Observer.Flags = [.sendInitial],
                          changeHandler: @escaping () -> Void) -> Observer {
        let observer = Observer(store: store, entityId: EntityType.entityInfo.entitySchemaId,
                                dispatchQueue: dispatchQueue, changeHandler: changeHandler)
        if flags.contains(.sendInitial) {
            dispatchQueue.async(execute: observer.changeHandler)
        }
        if flags.contains(.dontSubscribe) {
            observer.unsubscribe()
        }
        return observer
    }

    /// Receive a callback whenever an entity in this query is added/removed or modified.
    /// The callback receives the query result as a parameter, allowing you to
    /// e.g. feed it to Combine or an Rx subscriber.
    /// - Parameter dispatchQueue: The dispatch queue on which you want your callback to be called.
    /// - Parameter flags: Flags to control behavior of the subscription
    /// - Parameter resultHandler: A closure that will be passed an array of the objects in this query
    /// whenever the query contents change.
    /// - Returns: An object representing your observer connection.
    /// As long as the Observer object exists, your callback will be called.
    /// If you no longer want to receive callbacks, let go of your reference to this object so it is deinited.
    /// - important: There may be spurious calls to your callback when your query results haven't actually changed,
    /// but something else in this box has.
    /// - SeeAlso: Query.subscribe(dispatchQueue:,changeHandler:)
    public func subscribe(dispatchQueue: DispatchQueue = DispatchQueue.main,
                          flags: Observer.Flags = [.sendInitial],
                          resultHandler: @escaping ([EntityType], ObjectBoxError?) -> Void) -> Observer {
        let observer = Observer(store: store, entityId: EntityType.entityInfo.entitySchemaId,
                                dispatchQueue: dispatchQueue, changeHandler: {
                                    let result: [EntityType]
                                    var resultError: ObjectBoxError?
                                    do {
                                        result = try self.find()
                                    } catch let error as ObjectBoxError {
                                        resultError = error
                                        result = []
                                    } catch {
                                        // Should never reach this spot, but since functions can only declare they
                                        // throw, but not that they only throw one type of error, we have to also
                                        // cover the remaining cases or the compiler is unhappy.
                                        resultError = .unexpected(error: error)
                                        result = []
                                    }
                                    resultHandler(result, resultError)
        })
        if flags.contains(.sendInitial) {
            dispatchQueue.async(execute: observer.changeHandler)
        }
        if flags.contains(.dontSubscribe) {
            observer.unsubscribe()
        }
        return observer
    }
    
    /// Variant of subscribe() that is faster due to using ContiguousArray.
    public func subscribeContiguous(dispatchQueue: DispatchQueue = DispatchQueue.main,
                                    flags: Observer.Flags = [.sendInitial],
                                    resultHandler:
        @escaping (ContiguousArray<EntityType>, ObjectBoxError?) -> Void) -> Observer {
        let observer = Observer(store: store, entityId: EntityType.entityInfo.entitySchemaId,
                                dispatchQueue: dispatchQueue, changeHandler: {
                                    let result: ContiguousArray<EntityType>
                                    var resultError: ObjectBoxError?
                                    do {
                                        result = try self.findContiguous()
                                    } catch let error as ObjectBoxError {
                                        resultError = error
                                        result = []
                                    } catch {
                                        // Should never reach this spot, but since functions can only declare they
                                        // throw, but not that they only throw one type of error, we have to also
                                        // cover the remaining cases or the compiler is unhappy.
                                        resultError = .unexpected(error: error)
                                        result = []
                                    }
                                    resultHandler(result, resultError)
        })
        if flags.contains(.sendInitial) {
            dispatchQueue.async(execute: observer.changeHandler)
        }
        if flags.contains(.dontSubscribe) {
            observer.unsubscribe()
        }
        return observer
    }

}
