//
// Copyright © 2024 ObjectBox Ltd. All rights reserved.
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

public class PropertyBuilder {
    
    private var model: OpaquePointer
    
    init(_ model: OpaquePointer) {
        self.model = model
    }
    
    // swiftlint:disable function_parameter_count
    public func hnswParams(dimensions: Int,
                           neighborsPerNode: UInt32?,
                           indexingSearchCount: UInt32?,
                           flags: [HnswFlags]?,
                           distanceType: HnswDistanceType?,
                           reparationBacklinkProbability: Float?, 
                           vectorCacheHintSizeKB: Int?) throws {
        try checkLastError(obx_model_property_index_hnsw_dimensions(model, dimensions))
        if neighborsPerNode != nil {
            try checkLastError(obx_model_property_index_hnsw_neighbors_per_node(model, neighborsPerNode!))
        }
        if indexingSearchCount != nil {
            try checkLastError(obx_model_property_index_hnsw_indexing_search_count(model, indexingSearchCount!))
        }
        if flags != nil {
            try checkLastError(obx_model_property_index_hnsw_flags(model, flags!.rawValue))
        }
        if distanceType != nil {
            try checkLastError(obx_model_property_index_hnsw_distance_type(
                model, OBXVectorDistanceType(rawValue: UInt32(distanceType!.rawValue))))
        }
        if reparationBacklinkProbability != nil {
            try checkLastError(obx_model_property_index_hnsw_reparation_backlink_probability(
                model, reparationBacklinkProbability!))
        }
        if vectorCacheHintSizeKB != nil {
            try checkLastError(obx_model_property_index_hnsw_vector_cache_hint_size_kb(model, vectorCacheHintSizeKB!))
        }
    }
    // swiftlint:enable function_parameter_count
}
