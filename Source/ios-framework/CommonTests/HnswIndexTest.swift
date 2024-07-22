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

/// This mirrors HNSW object tests in the core library with a focus on Swift API.
class HnswIndexTest: XCTestCase {
    
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
    
    func testQuery() throws {
        let box: Box<HnswObject> = store.box()
        var testObjects = [HnswObject]()
        // start at 1
        for i in 1...10 {
            testObjects.append(HnswObject(name: "node" + String(i), floatVector: [Float(i), Float(i)]))
        }
        try box.put(testObjects)
        
        let searchVector: [Float] = [5.0, 4.5]
        let query = try box
            .query { HnswObject.floatVector.nearestNeighbors(queryVector: searchVector, maxCount: 2) }
            .build()
        
        // Standard search
        let regularQuery = try query.find()
        XCTAssertEqual(regularQuery.count, 2)
        // For regular queries, the results are ordered by their ID (not distance)
        let object4 = regularQuery[0]
        let object5 = regularQuery[1]
        XCTAssertEqual(object4.name, "node4")
        XCTAssertEqual(object5.name, "node5")
        
        // Find nearest 3 nodes (IDs) with score
        query.setParameter(HnswObject.floatVector, to: 3)
        let withIds = try query.findIdsWithScores()
        XCTAssertEqual(withIds.count, 3)
        XCTAssertEqual(withIds[0].id, object5.id)
        XCTAssertEqual(withIds[0].score, 0.25)
        XCTAssertEqual(withIds[1].id, object4.id)
        XCTAssertEqual(withIds[1].score, 1.25)
        XCTAssertEqual(withIds[2].id, object5.id + 1)
        XCTAssertEqual(withIds[2].score, 3.25)
        
        // Find nearest 3 nodes (objects) with score
        let withObjects = try query.findWithScores()
        XCTAssertEqual(withObjects.count, 3)
        XCTAssertEqual(withObjects[0].object.name, "node5")
        XCTAssertEqual(withObjects[0].score, 0.25)
        XCTAssertEqual(withObjects[1].object.name, "node4")
        XCTAssertEqual(withObjects[1].score, 1.25)
        XCTAssertEqual(withObjects[2].object.name, "node6")
        XCTAssertEqual(withObjects[2].score, 3.25)
        
        // Find the closest node only
        query.setParameter(HnswObject.floatVector, to: 1)
        let closest = try query.findUnique()
        XCTAssertNotNil(closest)
        XCTAssertEqual(closest!.name, "node5")
        
        // Set another vector and find the closest node to it
        let searchVector2: [Float] = [7.7, 7.7]
        query.setParameter(HnswObject.floatVector, to: searchVector2)
        let closest2 = try query.findUnique()
        XCTAssertNotNil(closest2)
        XCTAssertEqual(closest2!.name, "node8")
    }
    
    func testLimitOffset() throws {
        let box: Box<HnswObject> = store.box()
        var testObjects = [HnswObject]()
        // start at 1
        for i in 1...15 {
            testObjects.append(HnswObject(name: "node_" + String(i), floatVector: [Float(i), Float(i)]))
        }
        try box.put(testObjects)
        
        let searchVector: [Float] = [3.1, 3.1]
        let maxResultCount = 4
        let query = try box
            .query { 
                // Also testing setParameter with alias
                "nn" .= HnswObject.floatVector.nearestNeighbors(queryVector: searchVector, maxCount: maxResultCount)
            }
            .build()
        
        // No offset
        // Note: score-based find defaults to score-based result ordering
        let expectedNoOffset: [UInt64] = [3, 4, 2, 5]
        XCTAssertEqual(try query.findWithScores().map({ i in i.object.id }), expectedNoOffset)
        XCTAssertEqual(try query.findIdsWithScores().map({ i in i.id }), expectedNoOffset)
        XCTAssertEqual(try query.findIds().map({ i in i.value }), [2, 3, 4, 5])
        
        // Offset 1
        let expectedOffset1: [UInt64] = [4, 2, 5]
        XCTAssertEqual(try query.findWithScores(offset: 1).map({ i in i.object.id }), expectedOffset1)
        XCTAssertEqual(try query.findIdsWithScores(offset: 1).map({ i in i.id }), expectedOffset1)
        XCTAssertEqual(try query.findIds(offset: 1).map({ i in i.value }), [3, 4, 5])
        
        // Offset = nearest-neighbour max search count
        let empty: [UInt64] = []
        XCTAssertEqual(try query.findWithScores(offset: maxResultCount).map({ i in i.object.id }), empty)
        XCTAssertEqual(try query.findIdsWithScores(offset: maxResultCount).map({ i in i.id }), empty)
        XCTAssertEqual(try query.findIds(offset: maxResultCount).map({ i in i.value }), empty)
        
        // Offset out of bounds
        let offset100 = 100
        XCTAssertEqual(try query.findWithScores(offset: offset100).map({ i in i.object.id }), empty)
        XCTAssertEqual(try query.findIdsWithScores(offset: offset100).map({ i in i.id }), empty)
        XCTAssertEqual(try query.findIds(offset: offset100).map({ i in i.value }), empty)
        
        // Check limit 5 to 1
        query.setParameter("nn", to: [8.9, 8.8])
        query.setParameter("nn", to: 5)
        var expectedLimit: [UInt64] = [9, 8, 10, 7, 11]
        for limit in (1...5).reversed() {
            XCTAssertEqual(try query.findWithScores(limit: limit).map({ i in i.object.id }), expectedLimit)
            XCTAssertEqual(try query.findIdsWithScores(limit: limit).map({ i in i.id }), expectedLimit)
            
            expectedLimit.removeLast() // for next iteration
        }
        
        // Check offset & limit together
        let expectedSkip1: [UInt64] = [8, 10, 7, 11]
        XCTAssertEqual(try query.findWithScores(offset: 1, limit: 5).map({ i in i.object.id }), expectedSkip1)
        XCTAssertEqual(try query.findIdsWithScores(offset: 1, limit: 5).map({ i in i.id }), expectedSkip1)
        
        let expectedSkip1Limit3: [UInt64] = [8, 10, 7]
        XCTAssertEqual(try query.findWithScores(offset: 1, limit: 3).map({ i in i.object.id }), expectedSkip1Limit3)
        XCTAssertEqual(try query.findIdsWithScores(offset: 1, limit: 3).map({ i in i.id }), expectedSkip1Limit3)
        
        let expectedSkip2Limit2: [UInt64] = [10, 7]
        XCTAssertEqual(try query.findWithScores(offset: 2, limit: 2).map({ i in i.object.id }), expectedSkip2Limit2)
        XCTAssertEqual(try query.findIdsWithScores(offset: 2, limit: 2).map({ i in i.id }), expectedSkip2Limit2)
    }
    
    // swiftlint:disable function_body_length
    func testFilteredSearchName() throws {
        let appleGroup = RelatedNamedEntity("Apple")
        let bananaGroup = RelatedNamedEntity("Banana")
        let miscGroup = RelatedNamedEntity("Misc")
        try store.box().putAndReturnIDs([
            appleGroup,
            bananaGroup,
            miscGroup
        ])
        
        let box: Box<HnswObject> = store.box()
        try box.put([
            HnswObject(name: "Banana tree", floatVector: [-1.5, -1.5], target: bananaGroup),
            HnswObject(name: "Bunch of banana", floatVector: [-0.5, -0.5], target: bananaGroup),
            HnswObject(name: "Apple seed", floatVector: [0.5, 0.5], target: appleGroup),
            HnswObject(name: "Banana", floatVector: [1.5, 1.5], target: bananaGroup),
            HnswObject(name: "Apple", floatVector: [2.5, 2.5], target: appleGroup),
            HnswObject(name: "Apple juice", floatVector: [3.5, 3.5], target: appleGroup),
            HnswObject(name: "Peach", floatVector: [4.5, 4.5], target: miscGroup),
            HnswObject(name: "appleication", floatVector: [5.5, 5.5], target: miscGroup),
            HnswObject(name: "One banana", floatVector: [6.5, 6.5], target: miscGroup)
        ])
        
        // Search nearest starting with "Apple"
        let queryApple = try box
            .query {
                HnswObject.floatVector.nearestNeighbors(queryVector: [2.7, 2.5], maxCount: 9)
                && HnswObject.name.startsWith("Apple")
            }.build()
        
        let apples = try queryApple.findWithScores()
        XCTAssertEqual(apples.count, 3)
        XCTAssertEqual(apples[0].object.id, 5)
        XCTAssertEqual(apples[0].object.name, "Apple")
        XCTAssertEqual(apples[1].object.id, 6)
        XCTAssertEqual(apples[1].object.name, "Apple juice")
        XCTAssertEqual(apples[2].object.id, 3)
        XCTAssertEqual(apples[2].object.name, "Apple seed")
        
        // Search nearest ending with "banana" (ignore case)
        let queryBanana = try box
            .query {
                HnswObject.floatVector.nearestNeighbors(queryVector: [2.7, 2.5], maxCount: 9)
                && HnswObject.name.endsWith("Banana", caseSensitive: false)
            }.build()
        let bananas = try queryBanana.findWithScores()
        XCTAssertEqual(bananas.count, 3)
        XCTAssertEqual(bananas[0].object.id, 4)
        XCTAssertEqual(bananas[0].object.name, "Banana")
        XCTAssertEqual(bananas[1].object.id, 2)
        XCTAssertEqual(bananas[1].object.name, "Bunch of banana")
        XCTAssertEqual(bananas[2].object.id, 9)
        XCTAssertEqual(bananas[2].object.name, "One banana")
        
        // Search nearest equals to "Peach"
        let queryPeach = try box
            .query {
                HnswObject.floatVector.nearestNeighbors(queryVector: [2.7, 2.5], maxCount: 9)
                && HnswObject.name.isEqual(to: "Peach")
            }.build()
        let peaches = try queryPeach.findWithScores()
        XCTAssertEqual(peaches.count, 1)
        XCTAssertEqual(peaches[0].object.id, 7)
        XCTAssertEqual(peaches[0].object.name, "Peach")
        
        // Get nearest items that either ends with "juice" or "banana"
        let queryEnds = try box
            .query {
                HnswObject.floatVector.nearestNeighbors(queryVector: [2.7, 2.5], maxCount: 9)
                && (HnswObject.name.endsWith("juice") || HnswObject.name.endsWith("banana", caseSensitive: false))
            }.build()
        let ends = try queryEnds.findWithScores()
        XCTAssertEqual(ends.count, 4)
        XCTAssertEqual(ends[0].object.name, "Apple juice")
        XCTAssertEqual(ends[1].object.name, "Banana")
        XCTAssertEqual(ends[2].object.name, "Bunch of banana")
        XCTAssertEqual(ends[3].object.name, "One banana")
        
        // Get "Apple" group elements and among those, take the one that ends with "juice"
        let queryRel = try box
            .query {
                HnswObject.floatVector.nearestNeighbors(queryVector: [2.7, 2.5], maxCount: 9)
                && HnswObject.name.endsWith("juice")
            }.link(HnswObject.rel) { RelatedNamedEntity.name.isEqual(to: "Apple") }
            .build()
        let juice = try queryRel.findWithScores()
        XCTAssertEqual(juice.count, 1)
        XCTAssertEqual(juice[0].object.id, 6)
        XCTAssertEqual(juice[0].object.name, "Apple juice")
    }
    // swiftlint:enable function_body_length
}
