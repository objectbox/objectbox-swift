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

/// ID for objects (entities) stored in ObjectBox. Each entity class/struct must have an ID.
public typealias Id = UInt64

// TODO get rid of the remaining file

/// Protocol an ObjectBox ID must conform to. Currently, there are two major types that can be used as IDs:
/// - `EntityId<E>` which is a generic, type-safe ID struct
/// - Id (or Int64) which is a simpler data type usable for IDs.
/// Most methods that require you to specify an ID accept either type of ID.
///
/// Also used to constrain extensions:
///
///    extension Property where ValueType: IdBase { ... }
///
/// (Swift doesn't have parameterized extensions, or else
/// we could write `where ValueType == EntityId<T>`.)
public protocol IdBase: Hashable, EntityPropertyTypeConvertible {
    /// Initialize this (possibly type-specific) ID with an untyped ID as e.g. returned by the core.
    init(_ entityId: Id)
    
    /// Return this (possibly type-specific) ID as an untyped ID as needed to e.g. pass to the core.
    var value: Id { get }
}

/// A type that is usable as an object ID that doesn't enforce the type of entity it is for.
public protocol UntypedIdBase: IdBase {}

extension Id: UntypedIdBase {
    // public init(_ entityId: Id) not needed because Id can already be initialized with itself.
    /// :nodoc:
    public var value: Id { return self } // Every Id is usable like a IdBase, too, now.
}

extension Int64: UntypedIdBase {
    /// :nodoc:
    public init(_ entityId: Id) {
        self.init(bitPattern: entityId)
    }
    /// :nodoc:
    public var value: Id { return UInt64(bitPattern: self) } // Every Int64 is usable like a IdBase, too, now.
}


extension IdBase {
    internal var needsIdGeneration: Bool { return value == 0 }
}

/// Object identifier type.
///
/// Object identifiers are wrappers for `Id` values which are `UInt64`. These are used for persisted objects.
/// Identifiers are assigned by the framework automatically when you call `Box.put`.
///
/// A value of `0` indicates the object hasn't been persisted, yet.
public struct EntityId<R: EntityInspectable & __EntityRelatable>: IdBase, Hashable {
    /// Numerical value of the ID.
    public let value: Id

    /// Initializer required by IdBase (but also a convenient short-hand).
    public init(_ identifier: Id) {
        self.value = identifier
    }

    /// The hash value.
    ///
    /// - Discussion: Hash values are not guaranteed to be equal across different executions of
    ///   your program. Do not save hash values to use during a future execution.
    public func hash(into hasher: inout Hasher) {
        return value.hash(into: &hasher)
    }
}

// MARK: ExpressibleByIntegerLiteral

extension EntityId: ExpressibleByIntegerLiteral {
    /// Initializer to use integer literals directly, as in:
    ///
    ///    var id: EntityId<Person> = 123
    ///
    /// - Parameter value: The integer value.
    public init(integerLiteral value: Id) {
        self.init(value)
    }
}

// MARK: - Description

extension EntityId: CustomStringConvertible {
    /// A textual representation of this instance.
    public var description: String {
        return "\(String(describing: type(of: self)))(\(value))"
    }
}
