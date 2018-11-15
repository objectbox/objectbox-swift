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
/// In the current version, you cannot easily make your custom value types be convertible to
/// ObjectBox-supported property types. This would be the start, though.
/// See the `EntityPropertyType` enum for a list of possible values.
public protocol EntityPropertyTypeConvertible {
    static var entityPropertyType: EntityPropertyType { get }
}
