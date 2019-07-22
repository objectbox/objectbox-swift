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
/// we could write `where ValueType == Id<T>`.)
public protocol IdBase {
    /// Numerical value of the ID.
    var value: EntityId { get }
}

// swiftlint:disable type_name
/// Object identifier type.
///
/// Object identifiers are wrappers for `EntityId` values which are `UInt64`. These are used for persisted objects.
/// Identifiers are assigned by the framework automatically when you call `Box.put`.
///
/// A value of `0` indicates the object hasn't been persisted, yet.
public struct Id<E: Entity>: IdBase, Hashable {

    /// Numerical value of the ID.
    public let value: EntityId

    internal var needsIdGeneration: Bool { return value == 0 }

    /// Convenient short-hand initializer
    public init(_ identifier: EntityId) {
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
// swiftlint:enable type_name

// MARK: ExpressibleByIntegerLiteral

extension Id: ExpressibleByIntegerLiteral {
    /// Initializer to use integer literals directly, as in:
    ///
    ///    var id: Id<Person> = 123
    ///
    /// - Parameter value: The integer value.
    public init(integerLiteral value: EntityId) {
        self.init(value)
    }
}

// MARK: - Description

extension Id: CustomStringConvertible {
    /// A textual representation of this instance.
    public var description: String {
        return "\(String(describing: type(of: self)))(\(value))"
    }
}
