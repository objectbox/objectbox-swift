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

/// Class used together with ModelBuilder by the code generator to specify the fields and their indexes in an entity.
/// Typical usage is:
///
///     let eBuilder = mBuilder.entityBuilder(for: MyEntity.self, id: 1, uid: 1001)
///     eBuilder.addProperty(name: "id", type: .long, flags: [.id, .unsigned], id: 1, uid: 1001)
///     eBuilder.addProperty(name: "userName", type: .string, id: 2, uid: 1002)
///     eBuilder.lastProperty(id: 2, uid: 1002)
///
/// and so on. Note that there may be only one `EntityBuilder` in existence at any one time.
/// It is currently not supported to use a previous `EntityBuilder` after creating a new one using `ModelBuilder`'s
/// `entityBuilder()` method.
/// See `ModelBuilder` for more.
///
/// You usually don't have to deal with this class.
public class EntityBuilder<T> {
    
    private var entityInfo: EntityInfo
    private var model: OpaquePointer
    
    internal init(entityInfo: EntityInfo, model: OpaquePointer) {
        self.entityInfo = entityInfo
        self.model = model
    }
    
    /// Add the given property to this entity.
    public func addProperty(name: String, type: OBXPropertyType, flags: EntityPropertyFlag = [], id propertyID: UInt32,
                            uid UID: UInt64, indexId indexID: UInt32 = 0, indexUid indexUID: UInt64 = 0) throws {
        let err1 = obx_model_property(model, name, type, propertyID, UID)
        try check(error: err1, message: String(utf8String: obx_last_error_message())!)
        let err2 = obx_model_property_flags(model,
                                            OBXPropertyFlags(rawValue: OBXPropertyFlags.RawValue(flags.rawValue)))
        try check(error: err2, message: String(utf8String: obx_last_error_message())!)
        if indexID != 0 && indexUID != 0 {
            let err3 = obx_model_property_index_id(model, indexID, indexUID)
            try check(error: err3, message: String(utf8String: obx_last_error_message())!)
        }
    }
    
    // swiftlint:disable function_parameter_count
    /// Add a to-one-relation (e.g. a pointer from a parent to its children) to the model.
    public func addToOneRelation(name: String, targetEntityInfo: EntityInfo, flags: EntityPropertyFlag = [],
                                 id propertyID: UInt32, uid propertyUID: UInt64, indexId indexID: UInt32,
                                 indexUid indexUID: UInt64) throws {
        var finalFlags = flags
        finalFlags.insert(.indexed)
        finalFlags.insert(.indexPartialSkipZero)
        
        try addProperty(name: name, type: .relation, flags: finalFlags, id: propertyID, uid: propertyUID,
                        indexId: indexID, indexUid: indexUID)
        
        let err1 = obx_model_property_relation(model, targetEntityInfo.entityName, indexID, indexUID)
        try check(error: err1, message: String(utf8String: obx_last_error_message())!)
    }
    // swiftlint:enable function_parameter_count

    /// Register the highest property ID used for this entity.
    public func lastProperty(id propertyID: UInt32, uid propertyUID: UInt64) throws {
        let err1 = obx_model_entity_last_property_id(model, propertyID, propertyUID)
        try check(error: err1, message: String(utf8String: obx_last_error_message())!)
    }
}
