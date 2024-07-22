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

import ObjectBox
import XCTest

class ScalarVectorTests: XCTestCase {
    
    var store: Store!
    
    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        store = try! Store.testEntities()
    }

    override func tearDown() {
        // swiftlint:disable:next force_try
        try! store?.closeAndDeleteAllFiles()
        store = nil
        super.tearDown()
    }
    
    func testPutAndGet() throws {
        let box: Box<VectorTestEntity> = store.box()
        let testEntity = VectorTestEntity()
        testEntity.floatArray = [-200.01, 200.01]
        testEntity.floatArrayNull = testEntity.floatArray
        let id = try box.put(testEntity)
        let read = try box.get(id)!
        XCTAssertEqual(read.floatArray, [-200.01, 200.01])
        XCTAssertEqual(read.floatArrayNull, [-200.01, 200.01])
    }
    
    func testPutAndGetDefaultValues() throws {
        let box: Box<VectorTestEntity> = store.box()
        let id = try box.put(VectorTestEntity())
        let read = try box.get(id)!
        XCTAssertEqual(read.floatArray, [])
        XCTAssertEqual(read.floatArrayNull, nil)
    }
    
}
