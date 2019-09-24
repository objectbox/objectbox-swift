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

/// Used to constrain extensions:
///
///    extension Property where ValueType: IdBase { ... }
///
/// (Swift doesn't have parameterized extensions, or else
/// we could write `where ValueType == EntityId<T>`.)
public protocol IdBase: Hashable, EntityPropertyTypeConvertible {
    init(_ entityId: Id)
    
    /// Numerical value of the ID.
    var value: Id { get }
}

public protocol UntypedIdBase: IdBase {}

extension Id: UntypedIdBase {
    // public init(_ entityId: Id) not needed because Id can already be initialized with itself.
    public var value: Id { return self } // Every Id is usable like a IdBase, too, now.
}

extension Int64: UntypedIdBase {
    public init(_ entityId: Id) {
        self.init(bitPattern: entityId)
    }
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
