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

/// Base protocol all supported property types conform to.
///
/// To write your own custom enums and types to a database, use the
/// `// objectbox: convert` annotation.
public protocol EntityPropertyTypeConvertible {
    /// The primitive type supported by the ObjectBox C API that this type will map to.
    ///
    static var entityPropertyType: PropertyType { get }
}
