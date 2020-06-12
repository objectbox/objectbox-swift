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

extension Box {
    internal func idArray<T: EntityInspectable>(_ sourceIds: UnsafeMutablePointer<OBX_id_array>?, type: T.Type = T.self)
        -> [T.EntityBindingType.IdType] {
            var result = [T.EntityBindingType.IdType]()
            if let sourceIds = sourceIds?.pointee {
                // swiftlint:disable opening_brace
                result = [T.EntityBindingType.IdType](unsafeUninitializedCapacity: sourceIds.count)
                { ptr, initializedCount in
                    for idIndex in 0 ..< sourceIds.count {
                        ptr[idIndex] = T.EntityBindingType.IdType(sourceIds.ids[idIndex])
                    }
                    initializedCount = sourceIds.count
                }
                // swiftlint:enable opening_brace
            }
            return result
    }

    internal func backlinkIds(propertyId: UInt32, entityId: Id) throws -> [EntityType.EntityBindingType.IdType] {
        let sourceIds = obx_box_get_backlink_ids(cBox, propertyId, entityId)
        try checkLastError()
        defer { obx_id_array_free(sourceIds) }
        return idArray(sourceIds, type: EntityType.self)
    }
    
    internal func relationTargetIds<TargetType: EntityInspectable & __EntityRelatable>(
        relationId: obx_schema_id,
        sourceId: Id,
        targetType: TargetType.Type = TargetType.self) throws -> [TargetType.EntityBindingType.IdType]
        where TargetType == TargetType.EntityBindingType.EntityType {
            let targetIds = obx_box_rel_get_ids(cBox, relationId, sourceId)
            try checkLastError()
            defer { obx_id_array_free(targetIds) }
            return idArray(targetIds, type: TargetType.self)
    }
    
    internal func relationSourceIds<SourceType: EntityInspectable & __EntityRelatable>(
        relationId: obx_schema_id,
        targetId: Id,
        targetType: SourceType.Type = SourceType.self) throws -> [SourceType.EntityBindingType.IdType]
        where SourceType == SourceType.EntityBindingType.EntityType {
            let sourceIds = obx_box_rel_get_backlink_ids(cBox, relationId, targetId)
            try checkLastError()
            defer { obx_id_array_free(sourceIds) }
            return idArray(sourceIds, type: SourceType.self)
    }
    
    internal func removeRelation(relationId: obx_schema_id, sourceId: Id, targetId: Id) throws {
        if sourceId == 0 {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Owning object hasn't been put yet.")
        }
        if targetId == 0 {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Referenced object hasn't been put yet.")
        }
        let obxErr = obx_box_rel_remove(cBox, relationId, sourceId, targetId)
        try check(error: obxErr, message: "Could not remove relation data")
    }
    
    internal func putRelation(relationId: obx_schema_id, sourceId: Id, targetId: Id) throws {
        if sourceId == 0 {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Owning object hasn't been put yet.")
        }
        if targetId == 0 {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Referenced object hasn't been put yet.")
        }
        let obxErr = obx_box_rel_put(cBox, relationId, sourceId, targetId)
        try check(error: obxErr, message: "Could not add relation data")
    }
}
