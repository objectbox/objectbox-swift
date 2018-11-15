//
// Copyright © 2018 ObjectBox Ltd. All rights reserved.
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

/// Object property type to indicate a to-one relation to another object.
///
/// Initialize with `nil` in your type declarations.
///
/// - You can set the value to `nil` to remove the relation. You can also set `target` or `targetId` to `nil`.
/// - You can set `target` to an object to set the relation. Call `Box.put(_:)` to persist the changes.
/// - You can set `targetId` to an object's ID to set the relation. Call `Box.put(_:)` to persist the changes.
///
/// ## Example
///
///     class Person: Entity {
///         var spouse: ToOne<Person> = nil
///     }
///
///     let personBox: Box<Person> = store.box(for: Person.self)
///     let amanda: Person = ...
///     let bob: Person = ...
///
///     amanda.spouse.target = bob
///     personBox.put(amanda)
///
///
/// ## Remove a relation
///
///     amanda.spouse.target = nil
///     // ... or ...
///     amanda.spouse.targetId = nil
///     // ... are equivalent to:
///     amanda.spouse = nil
///     // ... whis is a short version of:
///     amanda.spouse = ToOne<Person>(target: nil)
///
public final class ToOne<T>: ExpressibleByNilLiteral
where T: Store.InspectableEntity {

    /// The type of object this relation will produce.
    public typealias Target = T

    private var _lazyTarget: LazyProxyRelation<Target>

    /// Whether the relation was set to a target object.
    public var hasValue: Bool {
        return _lazyTarget.hasValue
    }

    /// Access to the relation's target, if any. Set to `nil` to remove the relation.
    ///
    /// Alternatively, you can also overwrite the whole relation:
    ///
    ///     order.customer.target = nil
    ///     // ... is equivalent to:
    ///     order.customer = nil
    ///     // ... whis is a short version of:
    ///     order.customer = ToOne<Customer>(target: nil)
    ///
    /// - Note: Call `Box.put(_:)` to persist changes.
    public var target: Target? {
        get {
            return _lazyTarget.target
        }
        set {
            _lazyTarget.target = newValue
        }
    }

    /// Access to the ID of the relation's target, if any. Set to `nil` to remove the relation.
    ///
    /// Alternatively, you can also overwrite the whole relation:
    ///
    ///     order.customer.target = nil
    ///     // ... is equivalent to:
    ///     order.customer = nil
    ///     // ... whis is a short version of:
    ///     order.customer = ToOne<Customer>(target: nil)
    ///
    /// - Note: Call `Box.put(_:)` to persist changes.
    public var targetId: Id<Target>? {
        get {
            return _lazyTarget.targetId
        }
        set {
            _lazyTarget.targetId = newValue
        }
    }
    /// Initialize an empty relation.
    ///
    /// Use this during entity creation, like:
    ///
    ///    class Order {
    ///        var customer: ToOne<Customer> = nil
    ///        // ...
    ///    }
    public required init(nilLiteral: ()) {
        self._lazyTarget = LazyProxyRelation<Target>(box: nil, initialState: .none)
    }

    /// Initialize a relation with a target set from the get-go.
    ///
    /// - Parameter entity: Target entity, or `nil` if the relation is empty.
    public required init(_ entity: Target?) {
        self._lazyTarget = LazyProxyRelation<Target>(box: nil, initialState: .init(entity: entity))
    }

    // swiftlint:disable identifier_name
    internal init(box: Box<Target>, id: Id<Target>) {
        self._lazyTarget = LazyProxyRelation<Target>(box: box, initialState: .init(id: id))
    }
    // swiftlint:enable identifier_name
}

// MARK: - Description

extension ToOne: CustomStringConvertible {
    /// A textual representation of this instance.
    public var description: String {
        let targetDescription: String = {
            if let target = target {
                return "\(target)"
            } else {
                return "nil"
            }
        }()
        return "ToOne(\(targetDescription))"
    }
}

extension ToOne: CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        let mirror = Mirror(reflecting: self)
        return "\(mirror.subjectType)(\(_lazyTarget.debugDescription))"
    }
}
