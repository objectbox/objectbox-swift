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

internal class Cursor<E: __EntityRelatable & EntityInspectable> where E == E.EntityBindingType.EntityType {
    typealias EntityType = E
    
    private(set) var cCursor: OpaquePointer!
    private let entityBinding = EntityType.entityBinding
    
    init(transaction: Transaction) throws {
        cCursor = obx_cursor(transaction.cTransaction, E.entityInfo.entitySchemaId)
        if cCursor == nil {
            try checkLastError()
            throw ObjectBoxError.illegalState(message: "Cursor creation failed, but no error was set")
        }
    }
    
    deinit {
        obx_cursor_close(cCursor)
    }
    
    func idForPut(_ entity: EntityType) -> Id {
        return obx_cursor_id_for_put(cCursor, entityBinding.entityId(of: entity).value)
    }
    
    func put(id entityId: Id, data: OBX_bytes, mode: PutMode) throws {
        try checkLastError(obx_cursor_put4(cCursor, entityId, data.data, data.size, OBXPutMode(mode.rawValue)))
    }
    
    func remove(_ entity: EntityType) throws -> Bool {
        let entityId = entityBinding.entityId(of: entity).value
        guard entityId != 0 else { return false }
        let err = obx_cursor_remove(cCursor, entityId)
        if err == OBX_NOT_FOUND {
            obx_last_error_clear()
            return false
        }
        try checkLastError(err)
        return true
    }

    func remove(_ entityId: Id) throws -> Bool {
        guard entityId != 0 else { return false }
        let err = obx_cursor_remove(cCursor, entityId)
        if err == OBX_NOT_FOUND {
            obx_last_error_clear()
            return false
        }
        try checkLastError(err)
        return true
    }
    
    func contains(_ entityId: Id) throws -> Bool {
        let err = obx_cursor_seek(cCursor, entityId)
        if err == OBX_NOT_FOUND { return false }
        try checkLastError(err)
        return true
    }
 
    /// Returned pointer is only valid for the duration of the current transaction.
    func get(_ entityId: Id) throws -> OBX_bytes {
        var bytes = OBX_bytes(data: nil, size: 0)
        var ptr: UnsafeRawPointer?
        try checkLastError(obx_cursor_first(cCursor, &ptr, &bytes.size))
        bytes.data = UnsafeRawPointer(ptr)
        return bytes
    }

    /// Returned pointer is only valid for the duration of the current transaction.
    /// - Returns: result.data == nil if there are no more items.
    func first() throws -> OBX_bytes {
        var bytes = OBX_bytes(data: nil, size: 0)
        var ptr: UnsafeRawPointer?
        let err = obx_cursor_first(cCursor, &ptr, &bytes.size)
        if err == OBX_NOT_FOUND { obx_last_error_clear(); return bytes }
        try checkLastError(err)
        bytes.data = UnsafeRawPointer(ptr)
        return bytes
    }
    
    /// Returned pointer is only valid for the duration of the current transaction.
    /// - Returns: result.data == nil if there are no more items.
    func next() throws -> OBX_bytes {
        var bytes = OBX_bytes(data: nil, size: 0)
        var ptr: UnsafeRawPointer?
        let err = obx_cursor_next(cCursor, &ptr, &bytes.size)
        if err == OBX_NOT_FOUND { obx_last_error_clear(); return bytes }
        try checkLastError(err)
        bytes.data = UnsafeRawPointer(ptr)
        return bytes
    }
}
