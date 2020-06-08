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

import Foundation

/// Used by generated Swift code to hydrate an entity from the store.
/// Is used by the code generator; the actual implementation is in `FlatBufferReader`.

public protocol EntityReader {
    
    /// - Returns: false if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> Bool
    
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> Int8
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> Int16
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> Int32
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> Int64

    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> UInt8
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> UInt16
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> UInt32
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> UInt64

    /// Reads the given Int64 from the database as an Int.
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> Int
    /// Reads the given UInt64 from the database as an UInt.
    /// - Returns: 0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> UInt

    /// - Returns: 0.0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> Float
    /// - Returns: 0.0 if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> Double

    func read(at index: UInt16) -> Date
    /// - Returns: empty string if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> String
    /// - Returns: zero-length Data if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> Data
    /// - Returns: zero-length array if a value is not present in the buffer
    ///         (e.g. because it got added to the schema after this entity was written)
    func read(at index: UInt16) -> [UInt8]

    /// - Returns: The ID read, if present, or the invalid ID of 0 if no ID was present.
    func read<E: EntityInspectable & __EntityRelatable>(at index: UInt16) -> EntityId<E>
        where E == E.EntityBindingType.EntityType
    /// - Returns: A to-one relation, ID will == 0 if the relation hasn't been connected yet.
    func read<T: EntityInspectable & __EntityRelatable>(at index: UInt16, store: Store) -> ToOne<T>
        where T == T.EntityBindingType.EntityType

    // MARK: Optional properties

    /// :nodoc:
    func read(at index: UInt16) -> Bool?
    
    /// :nodoc:
    func read(at index: UInt16) -> Int8?
    /// :nodoc:
    func read(at index: UInt16) -> Int16?
    /// :nodoc:
    func read(at index: UInt16) -> Int32?
    /// :nodoc:
    func read(at index: UInt16) -> Int64?

    /// :nodoc:
    func read(at index: UInt16) -> UInt8?
    /// :nodoc:
    func read(at index: UInt16) -> UInt16?
    /// :nodoc:
    func read(at index: UInt16) -> UInt32?
    /// :nodoc:
    func read(at index: UInt16) -> UInt64?

    /// :nodoc:
    func read(at index: UInt16) -> Float?
    /// :nodoc:
    func read(at index: UInt16) -> Double?

    /// :nodoc:
    func read(at index: UInt16) -> Int?
    /// :nodoc:
    func read(at index: UInt16) -> UInt?

    /// :nodoc:
    func read(at index: UInt16) -> Date?
    /// :nodoc:
    func read(at index: UInt16) -> String?
    /// :nodoc:
    func read(at index: UInt16) -> Data?
    /// :nodoc:
    func read(at index: UInt16) -> [UInt8]?
}
