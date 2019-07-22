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

// Internal implementation of queries that doesn't require templates.
//
// - You obtain Query instances from a Box. (See the Box+Query extension.)
// - PropertyQuery can be modified to change query conditions.

internal class QueryInternal: NSObject {
    internal var cQueryBuilder: OpaquePointer! /*OBX_query_builder*/
    internal var query: OpaquePointer! /*OBX_query*/
    internal var cQuery: OpaquePointer { /*OBX_query*/
        if query == nil {
            query = obx_query_create(cQueryBuilder)
            throwLastFatalError() // TODO: Log or something?
            obx_qb_close(cQueryBuilder)
            cQueryBuilder = nil
        }
        return query
    }
    internal var isEmpty: Bool = true
    internal var store: Store
    internal var entityInfo: EntityInfo
    
    internal init(queryBuilder: OpaquePointer, store: Store, entityInfo: EntityInfo, isEmpty: Bool) {
        cQueryBuilder = queryBuilder
        self.store = store
        self.entityInfo = entityInfo
        self.isEmpty = isEmpty
    }

    deinit {
        if cQueryBuilder != nil {
            obx_qb_close(cQueryBuilder)
            cQueryBuilder = nil
        }
        if query != nil {
            obx_query_close(query)
            query = nil
        }
    }
    
    internal func property<E: EntityInspectable & __EntityRelatable,
        T: EntityPropertyTypeConvertible>(_ property: PropertyDescriptor) -> PropertyQuery<E, T> {
        return PropertyQuery(query: cQuery, propertyId: property.propertyId, entityInfo: self.entityInfo, store: store)
    }
    
    // MARK: - Parameter changes
    
    internal func setParameters(property: PropertyDescriptor, to collection: [Int64]) {
        if property.type == .long {
            let numParams = Int32(collection.count)
            collection.withContiguousStorageIfAvailable { ptr -> Void in
                obx_query_int64_params_in(cQuery, entityInfo.entitySchemaId, property.propertyId, ptr.baseAddress,
                                          numParams)
            }
        } else {
            let i32collection = collection.map { Int32($0) }
            let numParams = Int32(i32collection.count)
            i32collection.withContiguousStorageIfAvailable { ptr -> Void in
                obx_query_int32_params_in(cQuery, entityInfo.entitySchemaId, property.propertyId, ptr.baseAddress,
                                          numParams)
            }
        }
        throwLastFatalError()
    }
    
    internal func setParametersForPropertyWithAlias(_ alias: String, to collection: [Int64]) {
        let numParams = Int32(collection.count)
        collection.withContiguousStorageIfAvailable { ptr -> Void in
            obx_query_int64_params_in_alias(cQuery, alias, ptr.baseAddress, numParams)
        }
        throwLastFatalError()
    }
    
    internal func setParametersForPropertyWithAlias(_ alias: String, to collection: [Int32]) {
        let numParams = Int32(collection.count)
        collection.withContiguousStorageIfAvailable { ptr -> Void in
            obx_query_int32_params_in_alias(cQuery, alias, ptr.baseAddress, numParams)
        }
        throwLastFatalError()
    }
    
    internal func setParameter(property: PropertyDescriptor, to value: Int64) {
        obx_query_int_param(cQuery, entityInfo.entitySchemaId, property.propertyId, value)
        throwLastFatalError()
    }
    
    internal func setParameter(alias: String, to value: Int64) {
        obx_query_int_param_alias(cQuery, alias, value)
        throwLastFatalError()
    }
    
    internal func setParameters(property: PropertyDescriptor, to value1: Int64, _ value2: Int64) {
        obx_query_int_params(cQuery, entityInfo.entitySchemaId, property.propertyId, value1, value2)
        throwLastFatalError()
    }

    internal func setParameters(alias: String, to value1: Int64, _ value2: Int64) {
        obx_query_int_params_alias(cQuery, alias, value1, value2)
        throwLastFatalError()
    }
    
    internal func setParameter(property: PropertyDescriptor, to value: Double) {
        obx_query_double_param(cQuery, entityInfo.entitySchemaId, property.propertyId, value)
        throwLastFatalError()
    }
    
    internal func setParameter(alias: String, to value: Double) {
        obx_query_double_param_alias(cQuery, alias, value)
        throwLastFatalError()
    }
    
    internal func setParameters(property: PropertyDescriptor, to value1: Double, _ value2: Double) {
        obx_query_double_params(cQuery, entityInfo.entitySchemaId, property.propertyId, value1, value2)
        throwLastFatalError()
    }
    
    internal func setParameters(alias: String, to value1: Double, _ value2: Double) {
        obx_query_double_params_alias(cQuery, alias, value1, value2)
        throwLastFatalError()
    }
    
    internal func setParameter(property: PropertyDescriptor, to value: String) {
        obx_query_string_param(cQuery, entityInfo.entitySchemaId, property.propertyId, value)
        throwLastFatalError()
    }
    
    internal func setParameter(alias: String, to value: String) {
        obx_query_string_param_alias(cQuery, alias, value)
        throwLastFatalError()
    }
    
    internal func setParameters(property: PropertyDescriptor, to collection: [String]) {
        let numStrings = Int32(collection.count)
        var strings: [UnsafePointer?] = collection.map { ($0 as NSString).utf8String }
        strings.withContiguousMutableStorageIfAvailable { ptr -> Void in
            obx_query_string_params_in(cQuery, entityInfo.entitySchemaId, property.propertyId, ptr.baseAddress,
                                       numStrings)
        }
        throwLastFatalError()
    }
    
    internal func setParameters(alias: String, to collection: [String]) {
        let numStrings = Int32(collection.count)
        var strings: [UnsafePointer?] = collection.map { ($0 as NSString).utf8String }
        strings.withContiguousMutableStorageIfAvailable { ptr -> Void in
            obx_query_string_params_in_alias(cQuery, alias, ptr.baseAddress, numStrings)
        }
        throwLastFatalError()
    }

}
