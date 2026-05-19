// Copyright © 2026 ObjectBox Ltd. <https://objectbox.io>
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

import ObjectBox

// objectbox: entity, sync
class BusRoute {
    var id: EntityId<BusRoute> = 0

    // objectbox: syncClock
    var syncClockProp: String = ""

    // objectbox: syncPrecedence
    var syncPrecedenceProp: Double = ""
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    // Generator should fail, nothing to test here
    return 0
}
