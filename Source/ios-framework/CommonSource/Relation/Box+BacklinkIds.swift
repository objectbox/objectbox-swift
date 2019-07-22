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
    public func backlinkIds(propertyId: UInt32, entityId: EntityId) throws -> [Id<EntityType>] {
        var result = [Id<EntityType>]()
        let sourceIds = obx_box_backlink_ids(cBox, propertyId, entityId)
        try checkLastError()
        defer { obx_id_array_free(sourceIds) }
        if let sourceIds = sourceIds?.pointee {
            for idIndex in 0 ..< sourceIds.count {
                result.append(Id<EntityType>(sourceIds.ids[idIndex]))
            }
        }
        
        return result
    }
}
