//
// Copyright © 2019-2020 ObjectBox Ltd. All rights reserved.
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

/// Thin wrapper around OBX_txn.
/// Note that Swift does not support RAII, so please call close() if you do not call commit() (e.g. read transactions):
/// this ensures to release resources asap.
/// Also not that usually there no strict 'defer' needed for closing, it's not that critical to compromise on perf.
class Transaction {
    let isWritable: Bool
    var cTransaction: OpaquePointer? /* OBX_txn */
    var isClosed: Bool { cTransaction == nil }

    init(store: Store, writable: Bool) throws {
        isWritable = writable
        if isWritable {
            cTransaction = obx_txn_write(try store.ensureCStore())
        } else {
            cTransaction = obx_txn_read(try store.ensureCStore())
        }
        try checkLastError()
    }

    deinit {
        try? close()
    }

    func commit() throws {
        guard let tx = cTransaction else {
            throw ObjectBoxError.illegalState(message: "Cannot commit an already closed transaction")
        }
        cTransaction = nil

        obx_txn_success(tx)
        try checkLastError()
    }

    /// Call this if you do not call commit(), e.g. for read transactions: release resources asap (Swift has no RAII).
    /// See class comments for details.
    func close() throws {
        guard let tx = cTransaction else { return }
        cTransaction = nil
        obx_txn_close(tx)
        try checkLastError()
    }
}
