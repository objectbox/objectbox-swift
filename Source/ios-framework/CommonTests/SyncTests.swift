//
// Copyright © 2020-2026 ObjectBox Ltd. https://objectbox.io
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
import XCTest
@testable import ObjectBox

enum TestError: Error {
    case loginError(String)
}

/// Tests that require a running Sync server. Use Helpers/run-sync-server-docker.sh to start one.
class SyncTests: XCTestCase {

    class CountingListener: SyncListener {
        var loggedInCount = 0
        var loginFailedCount = 0
        var updatesCompletedCount = 0
        var connectedCount = 0
        var disconnectedCount = 0
        var changesCount = 0
        var allChanges: [[obx_schema_id: SyncChange]] = []

        func loggedIn() {
            loggedInCount += 1
            print("loggedIn: \(loggedInCount)")
        }

        func loginFailed(result: SyncCode) {
            loginFailedCount += 1
            print("loginFailed: \(loginFailedCount)")
        }

        func updatesCompleted() {
            updatesCompletedCount += 1
            print("updatesCompleted: \(updatesCompletedCount)")
        }

        func connected() {
            connectedCount += 1
            print("connected: \(connectedCount)")
        }

        func disconnected() {
            disconnectedCount += 1
            print("disconnected: \(disconnectedCount)")
        }
        
        func changed(_ changes: [obx_schema_id: SyncChange]) {
            changesCount += 1
            allChanges.append(changes)
            let totalPuts = changes.values.reduce(0) { $0 + $1.puts.count }
            let totalRemoves = changes.values.reduce(0) { $0 + $1.removals.count }
            print("changed: \(changesCount), puts: \(totalPuts), removes: \(totalRemoves)")
        }
    }

    var store: Store!

    override func setUpWithError() throws {
        super.setUp()
        store = StoreHelper.tempStore(model: createTestModel(syncEnabled: true))
    }
    
    override func tearDown() {
        // swiftlint:disable:next force_try
        try! store?.closeAndDeleteAllFiles()
        store = nil
        super.tearDown()
    }

    private func createClient(_ store: Store) throws -> SyncClient {
        let configuration = Sync.Configuration(store: store, url: "ws://127.0.0.1:9999")
        configuration.debugLogging = true
        configuration.flags = [.debugLogTxLogs]
        return try Sync.makeClient(configuration: configuration)
    }


    private func loginNewClient(_ store: Store, listener: SyncListener? = nil,
                                completedListener: SyncCompletedListener? = nil,
                                updateRequestMode: RequestUpdatesMode = .auto) throws -> SyncClient {
        let client = try createClient(store)
        try client.setCredentials(SyncCredentials.makeNone())
        client.listener = listener
        if completedListener != nil {
            client.completedListener = completedListener
        }
        client.updateRequestMode = updateRequestMode
        try client.start()
        let result = try client.waitForLoggedInState(timeoutMilliseconds: 1000)
        if result == .success {
            print("A client logged in")
        } else if result == .timeout {
            // We still proceed to detect no server is running
            // throw TestError.loginError("Timeout")
            print("A client failed to log in (timeout)")
        } else {
            // We still proceed to detect no server is running
            //throw TestError.loginError("Failure")
            print("A client failed to log in (failed)")
        }
        return client
    }

    func waitForMinValue(value: inout Int, target: Int, seconds: Int = 3) -> Bool {
        for _ in 0...1000 * seconds {  // 1 sec or until we logged in
            usleep(1000)  // 1 ms
            if value >= target {
                return true
            }
        }
        return false
    }

    private func waitForCount(_ box: Box<AllTypesEntity>, _ count: Int) throws {
        for _ in 1...20 {  // Max total time is 2s: 20 * 100 ms
            if try box.count() == count {
                break
            }
            usleep(100000)
        }
    }

    func testSyncClientConnect() throws {
        let listener = CountingListener()  // only used for "sync completed"; full listener is tested elsewhere
        let client = try loginNewClient(store, completedListener: listener)
        guard client.getState() == .loggedIn else {
            print("Could not log in, skipping further testing (to test locally, use Helpers/run-sync-server-docker.sh)")
            return
        }
        // Waiting for the sync to complete; e.g. we want to have a stable count
        XCTAssert(waitForMinValue(value: &listener.updatesCompletedCount, target: 1))

        let object = AllTypesEntity.create(string: "hello dear")
        object.date = Date()
        let box = store.box(for: AllTypesEntity.self)
        let id1 = try box.put(object).value
        let count1 = try box.count()
        print("Objects in box1 after put:", count1)

        let store2 = StoreHelper.tempStore(model: createTestModel(syncEnabled: true))
        let listener2 = CountingListener()
        let client2 = try loginNewClient(store2, completedListener: listener2)
        XCTAssert(waitForMinValue(value: &listener2.updatesCompletedCount, target: 1))
        let box2 = store2.box(for: AllTypesEntity.self)
        try waitForCount(box2, count1)
        XCTAssertEqual(count1, try box2.count())

        let objectFromClient1 = try box2.get(id: id1)
        XCTAssertNotNil(objectFromClient1)
        XCTAssertEqual(object.date!.unixTimestamp, objectFromClient1!.date!.unixTimestamp)
        XCTAssertEqual(object.string!, objectFromClient1!.string!)

        try client.stop()
        try client2.stop()
    }

    func testSyncListeners() throws {
        let listener1 = CountingListener()
        let client1 = try loginNewClient(store, listener: listener1)
        guard listener1.loggedInCount == 1 else {
            print("Could not log in, skipping further testing (to test locally, use Helpers/run-sync-server-docker.sh)")
            return
        }
        XCTAssertGreaterThan(listener1.connectedCount, 0)
        // Waiting for the sync to complete; e.g. we want to have a stable count
        XCTAssert(waitForMinValue(value: &listener1.updatesCompletedCount, target: 1))
        let completedCount1Initial = listener1.updatesCompletedCount

        let store2 = StoreHelper.tempStore(model: createTestModel(syncEnabled: true))
        let listener2 = CountingListener()
        let client2 = try loginNewClient(store2, listener: listener2)
        XCTAssertGreaterThan(listener2.connectedCount, 0)
        XCTAssert(waitForMinValue(value: &listener2.updatesCompletedCount, target: 1))
        let completedCount2Initial = listener2.updatesCompletedCount

        let box1 = store.box(for: AllTypesEntity.self)
        let box2 = store2.box(for: AllTypesEntity.self)
        let entityTypeId = AllTypesEntity.entityInfo.entitySchemaId

        // Capture initial change counts after login sync
        let changesCount1Initial = listener1.changesCount
        let changesCount2Initial = listener2.changesCount

        // Client1 puts an object
        let object1 = AllTypesEntity.create(string: "from client1")
        let id1 = try box1.put(object1).value
        print("Client1 put object with id:", id1)

        // Verify client2 receives the change (note: clients don't see their own local writes in change listener)
        try waitForCount(box2, 1)
        XCTAssert(waitForMinValue(value: &listener2.changesCount, target: changesCount2Initial + 1))
        let changes2ForEntity = listener2.allChanges.compactMap { $0[entityTypeId] }
        let putIds2 = changes2ForEntity.flatMap { $0.puts }
        XCTAssertTrue(putIds2.contains(Id(id1)), "Client2 should see put ID \(id1) in changes: \(listener2.allChanges)")
        XCTAssert(waitForMinValue(value: &listener2.updatesCompletedCount, target: completedCount2Initial + 1),
                  "Client2 should receive updatesCompleted after sync")

        // Client2 puts an object
        let changesCount1BeforePut2 = listener1.changesCount
        let object2 = AllTypesEntity.create(string: "from client2")
        let id2 = try box2.put(object2).value
        print("Client2 put object with id:", id2)

        // Verify client1 receives the change
        try waitForCount(box1, 2)
        XCTAssert(waitForMinValue(value: &listener1.changesCount, target: changesCount1BeforePut2 + 1))
        let changes1ForEntity2 = listener1.allChanges.compactMap { $0[entityTypeId] }
        let putIds1After = changes1ForEntity2.flatMap { $0.puts }
        XCTAssertTrue(putIds1After.contains(Id(id2)),
                      "Client1 should see put ID \(id2) in changes: \(listener1.allChanges)")

        // Client1 removes an object
        let changesCount2BeforeRemove = listener2.changesCount
        try box1.remove(id1)
        print("Client1 removed object with id:", id1)

        // Verify client2 receives the removal (note: clients don't see their own local writes in change listener)
        try waitForCount(box2, 1)
        XCTAssert(waitForMinValue(value: &listener2.changesCount, target: changesCount2BeforeRemove + 1))
        let changes2AfterRemove = listener2.allChanges.compactMap { $0[entityTypeId] }
        let removeIds2 = changes2AfterRemove.flatMap { $0.removals }
        XCTAssertTrue(removeIds2.contains(Id(id1)),
                      "Client2 should see removal ID \(id1) in changes: \(listener2.allChanges)")

        // Verify completion listeners were called
        print("Client1 updatesCompleted count: \(listener1.updatesCompletedCount) (initial: \(completedCount1Initial))")
        print("Client2 updatesCompleted count: \(listener2.updatesCompletedCount) (initial: \(completedCount2Initial))")

        try client1.stop()
        try client2.stop()
    }

    func testSyncClientHeartbeat() throws {
        let client = try loginNewClient(store, updateRequestMode: .manual)
        guard client.getState() == .loggedIn else {
            print("Could not log in, skipping further testing (to test locally, use Helpers/run-sync-server-docker.sh)")
            return
        }
        // To be checked manually at server with debug logging enabled
        try client.sendHeartbeat()
        try client.sendHeartbeat()
        try client.sendHeartbeat()
        try client.setHeartbeatInterval(milliseconds: 1000)
        for _ in 1...10 {
            sleep(1)
            print("State:", client.getState())
        }
    }

    func testSyncClientOutgoingMessagesCount() throws {
        let client = try loginNewClient(store, updateRequestMode: .manual)
        defer { client.close() }
        guard client.getState() == .loggedIn else {
            print("Could not log in, skipping further testing (to test locally, use Helpers/run-sync-server-docker.sh)")
            return
        }
        let initialCount = try client.outgoingMessagesCount()
        let object = AllTypesEntity.create(string: "hello")
        let box = store.box(for: AllTypesEntity.self)
        try box.put(object)
        let countAfterPut = try client.outgoingMessagesCount()
        XCTAssertEqual(initialCount, 0)
        // Note that this check can fail if the outgoing queue is processed fast enough.
        // Should this become a regular occurence, maybe change this test to log the client in after the put.
        XCTAssertGreaterThan(countAfterPut, initialCount)
    }

}
