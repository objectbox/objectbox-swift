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

internal class Transaction {
    private(set) var isClosed: Bool = false
    private(set) var isWritable: Bool
    internal var cTransaction: OpaquePointer? /* OBX_txn */
    
    init(store: Store, writable: Bool) throws {
        isWritable = writable
        if isWritable {
            cTransaction = obx_txn_write(store.cStore)
        } else {
            cTransaction = obx_txn_read(store.cStore)
        }
        try checkLastError()
    }
    
    deinit {
        try? close()
    }
    
    func commit() throws {
        assert(!isClosed)
        assert(isWritable)
        obx_txn_success(cTransaction)
        cTransaction = nil
        isClosed = true
        try checkLastError()
    }
    
    func close() throws {
        guard !isClosed else { return }
        
        if cTransaction != nil {
            obx_txn_close(cTransaction)
        }
        cTransaction = nil
        isClosed = true
        try checkLastError()
    }
}
