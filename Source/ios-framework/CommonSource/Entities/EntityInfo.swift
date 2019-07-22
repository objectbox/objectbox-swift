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

/// Used by the code generator to associate a Swift class with its counterpart in the model of the ObjectBox database.
public class EntityInfo {
    /// The name of the entity in the database (may differ from the Swift class name).
    private(set) public var entityName: String
    /// The local ID number assigned to this type of entity in the database.
    private(set) public var entitySchemaId: UInt32 = 0
    
    /// Create an EntityInfo for a class with the given name and ID in the database.
    public init(name entityName: String, id schemaId: UInt32) {
        self.entityName = entityName
        self.entitySchemaId = schemaId
    }
}
