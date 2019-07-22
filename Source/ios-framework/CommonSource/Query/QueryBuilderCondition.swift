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

/// :nodoc:
public class QueryBuilderCondition {
    internal let cCondition: obx_qb_cond
    internal let queryBuilder: OpaquePointer!
    
    init(_ condition: obx_qb_cond, builder: OpaquePointer!) {
        cCondition = condition
        queryBuilder = builder
    }
}

/// :nodoc:
public class PropertyQueryBuilderCondition: QueryBuilderCondition {
}
