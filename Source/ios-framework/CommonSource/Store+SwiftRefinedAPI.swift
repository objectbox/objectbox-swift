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

import Foundation

extension Store {

    /// A type that's marked as an `Entity` _and_ provides its own metadata.
    public typealias InspectableEntity = Entity & EntityInspectable & __EntityRelatable

    // MARK: Transaction Management

    /// Runs the given block inside a read/write transaction.
    ///
    /// Takes care of flattening nested transaction calls into a single transaction, and rolling back changes for you
    /// on error. You can e.g. wrap multiple `put` calls into a single write transaction to increase performance by
    /// re-using the resources of a single transaction to read and write data.
    ///
    /// You can nest read-only transaction into read/write transactions, but not vice versa.
    ///
    /// - Parameter block: Code that needs to run in a read/write transaction.
    /// - Returns: The forwarded result of `block`.
    /// - Throws: rethrows errors thrown inside, plus any ObjectBoxError that makes sense.
    public func runInTransaction<T>(_ block: () throws -> T) throws -> T {
        var result: T!

        try obx_runInTransaction({ _ in
            result = try block()
        })

        return result
    }
    
    internal func obx_runInTransaction<T>(_ block: (Transaction) throws -> T) throws -> T {
        var result: T!
        
        try obx_runInTransaction({ txn in
            result = try block(txn)
        })
    
        return result
    }
    
    internal func obx_runInTransaction(_ block: (Transaction) throws -> Void) throws {
        let transaction = try Transaction(store: self, writable: true)
        try block(transaction)
        try transaction.commit()
    }

    /// :nodoc::
    public func runInTransaction(_ block: () throws -> Void) throws {
        try obx_runInTransaction({ _ in
            try block()
        })
    }
    
    /// Runs the given block inside a read(-only) transaction.
    ///
    /// Takes care of flattening nested transaction calls into a single transaction, and rolling back changes for you
    /// on error. You can e.g. wrap multiple `get` calls into a single read transaction to increase performance by
    /// re-using the resources for reading data into memory.
    ///
    /// You can nest read-only transaction into read/write transactions, but not vice versa.
    ///
    /// - Parameter block: Code that needs to run in a read or read/write transaction.
    /// - Returns: The forwarded result of `block`.
    /// - Throws: rethrows errors thrown inside, plus any ObjectBoxError that makes sense.
    public func runInReadOnlyTransaction<T>(_ block: () throws -> T) throws -> T {
        return try obx_runInReadOnlyTransaction({ _ in
            return try block()
        })
    }
    
    /// :nodoc:
    public func runInReadOnlyTransaction(_ block: () throws -> Void) throws {
        try obx_runInReadOnlyTransaction({ _ in
            try block()
        })
    }
    
    internal func obx_runInReadOnlyTransaction<T>(_ block: (Transaction) throws -> T) throws -> T {
        var result: T!
        
        try obx_runInReadOnlyTransaction({ txn in
            result = try block(txn)
        })
        
        return result
    }

    internal func obx_runInReadOnlyTransaction(_ block: (Transaction) throws -> Void) throws {
        let transaction = try Transaction(store: self, writable: false)
        try block(transaction)
    }
}
