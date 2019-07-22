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

// Of the form `ToMany<OtherEntity, Self>`. Initialize with `nil` when you define properties.
// Use the `backlinks` static factory to create Backlink instances.
//
// Code generator will figure out a call to the value-ful initializer.

/// Declaration of a to-many relationship to objects of a certain type.
///
/// Initialize with `nil` in your type declarations. The code generator will set different values.
///
/// Example:
///
///     class Customer: Entity {
///         var id: Id<Customer> = 0
///
///         /// Annotation with Source's property name is required; Order is "Source", Customer is "Target"
///         // objectbox: backlink = "customer"
///         var orders: ToMany<Order, Customer> = nil
///         // ...
///     }
///
///     class Order: Entity {
///         var id: Id<Order> = 0
///         var customer: ToOne<Customer> = nil
///         // ...
///     }
///
/// ## Removing relations
///
/// Since this type only supports backlinks at the moment, you cannot modify relations from
/// this end. You have to set the relation from `Source` to `Target` to `nil` instead:
///
///     // You cannot set `aCustomer.orders = nil`, so:
///     let order = Array(aCustomer.orders)
///     orders.forEach { order in
///         order.customer = nil
///     }
///     store.box(for: Order.self).put(orders)
///
/// - Note: Not ready for storing to-many relations. Used only to get access to backlinks from
///   `ToOne` relations. Use the `// objectbox: backlink = "propertyName"` annotation to tell the code
///   generator which property of `ToMany.Source` should be used to determine the backlinks.
public final class ToMany<S: EntityInspectable & __EntityRelatable, T: EntityInspectable & __EntityRelatable>:
    ExpressibleByNilLiteral
where S == S.EntityBindingType.EntityType, T == T.EntityBindingType.EntityType {

    /// The type that is having the relation to its many `Target` objects.
    ///
    /// - Note: Since we only support backlinks at the moment, this is the type of object that
    ///   you will get when evaluating the backlink.
    public typealias Source = S

    /// The type of the objects that this relation points to.
    ///
    /// - Note: Since we only support backlinks at the moment, this is the type that you want to
    ///   see the backlinks for.
    public typealias Target = T

    private let backlinkResolver: (() -> [Source])
    private lazy var collection: [Source] = {
        return backlinkResolver()
    }()

    /// Initialize an empty backlink relation.
    ///
    /// Use this during object creation. The actual `ToMany` initialization with resolvable
    /// backlinks happens in `ToMany.backlink(sourceBox:sourceProperty:targetId:)` which is
    /// called by the code generator.
    public init(nilLiteral: ()) {
        self.backlinkResolver = { [] }
    }

    /// Used to denote this just supports backlinks so far.
    /// `sourceProperty` is the property on Source that will be used to search for backlinks.
    public static func backlink(sourceBox: Box<Source>,
                                sourceProperty: Property<Source, Id<Target>>,
                                targetId: Id<Target>) -> ToMany<Source, Target> {
        return ToMany(sourceBox: sourceBox, sourceProperty: sourceProperty, targetId: targetId)
    }

    internal init(sourceBox: Box<Source>,
                  sourceProperty: Property<Source, Id<Target>>,
                  targetId: Id<Target>) {
        precondition(!targetId.needsIdGeneration, "Can form Backlinks for persisted entities only.")
        self.backlinkResolver = {
            do {
                return try sourceBox
                    .backlinkIds(propertyId: sourceProperty.propertyId, entityId: targetId.value)
                    .compactMap { sourceBox.get($0) }
            } catch {
                fatalError("Error resolving backlinks.")
            }
        }
    }
}

// MARK: - RandomAccessCollection

extension ToMany: RandomAccessCollection {
    public typealias Index = Int

    /// The position of the first element in a nonempty collection.
    public var startIndex: Index { return collection.startIndex }

    /// The collections "past the end" position -- that is, the position one greater
    /// than the last valid subscript argument.
    public var endIndex: Index { return collection.endIndex }

    // swiftlint:disable identifier_name
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than `endIndex`.
    /// - Returns: The index immediately after `i`.
    public func index(after i: Index) -> Index {
        return collection.index(after: i)
    }

    /// Returns the position immediately before the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than `startIndex`.
    /// - Returns: The index immediately before `i`.
    public func index(before i: Index) -> Index {
        return collection.index(before: i)
    }
    // swiftlint:enable identifier_name
    /// Enable accessing elements of the relation as e.g. `customer[0]` via array subscript operator.
    public subscript(position: Index) -> Source {
        return collection[position]
    }
}

// MARK: - Description

extension ToMany: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        return "\(collection)"
    }
}

extension ToMany: CustomDebugStringConvertible {
    /// :nodoc:
    public var debugDescription: String {
        let mirror = Mirror(reflecting: self)
        return "\(mirror.subjectType)(\(collection))"
    }
}
