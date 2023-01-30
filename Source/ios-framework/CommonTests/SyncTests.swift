//
// Copyright (c) 2020 ObjectBox. All rights reserved.
//

import Foundation
import XCTest
@testable import ObjectBox

enum TestError: Error {
    case loginError(String)
}

class SyncTests: XCTestCase {

    class CountingListener: SyncListener {
        var loggedInCount = 0
        var loginFailedCount = 0
        var updatesCompletedCount = 0
        var connectedCount = 0
        var disconnectedCount = 0
        var changesCount = 0

        func loggedIn() {
            loggedInCount += 1
        }

        func loginFailed(result: SyncCode) {
            loginFailedCount += 1
        }

        func updatesCompleted() {
            updatesCompletedCount += 1
        }

        func connected() {
            connectedCount += 1
        }

        func disconnected() {
            disconnectedCount += 1
        }

    }

    var store: Store!

    override func setUpWithError() throws {
        super.setUp()
        store = StoreHelper.tempStore(model: createTestModel())
    }

    private func createClient(_ store: Store) throws -> SyncClient {
        try Sync.makeClient(store: store, urlString: "ws://127.0.0.1:9999")
    }


    private func loginNewClient(_ store: Store, listener: CountingListener? = nil,
                                updateRequestMode: RequestUpdatesMode = .auto) throws -> SyncClient {
        let client = try createClient(store)
        try client.setCredentials(SyncCredentials.makeNone())
        client.listener = listener
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
        let listener = CountingListener()
        let client = try loginNewClient(store, listener: listener)
        guard listener.loggedInCount == 1 else {
            print("Could not login, skipping further testing")
            if #available(OSX 10.12, *) {
                let serverExe = try findServerExe()
                if serverExe != nil {
                    print("Try running this command:")
                    print(serverExe!, " --unsecured-no-authentication", "--bind ws://0.0.0.0:9999",
                            "--browser-bind 0.0.0.0:9980", "--model",
                            "ios-framework/CommonTests/Helpers/test-model.json")
                }
            }
            return
        }
        XCTAssertGreaterThan(listener.connectedCount, 0)

        XCTAssert(waitForMinValue(value: &listener.updatesCompletedCount, target: 1))
        let updatesCompletedCountInitial: Int = listener.updatesCompletedCount

        let object = AllTypesEntity.create(string: "hello dear")
        object.date = Date()
        let box = store.box(for: AllTypesEntity.self)
        let id1 = try box.put(object).value
        let count1 = try box.count()
        print("Objects in box1 after sync completion:", count1)

        let store2 = StoreHelper.tempStore(model: createTestModel())
        let listener2 = CountingListener()
        let client2 = try loginNewClient(store2, listener: listener2)
        XCTAssert(waitForMinValue(value: &listener2.updatesCompletedCount, target: 1))
        let box2 = store2.box(for: AllTypesEntity.self)
        try waitForCount(box2, count1)
        XCTAssertEqual(count1, try box2.count())

        let objectFromClient1 = try box2.get(id: id1)
        XCTAssertNotNil(objectFromClient1)
        XCTAssertEqual(object.date!.unixTimestamp, objectFromClient1!.date!.unixTimestamp)  // unixTimestamp to avoid FP
        XCTAssertEqual(object.string!, objectFromClient1!.string!)

        let object2 = AllTypesEntity.create(string: "oh my")
        object2.date = Date()
        let id2 = try box2.put(object2).value
        XCTAssertNotEqual(id1, id2)

        // NewDataPusher is not yet sending MSG_APPLY_TX_FLAGS_HISTORY_UPTODATE -> completed listener not fired:
        // XCTAssert(waitForMinValue(value: &listener.updatesCompletedCount, target: updatesCompletedCountInitial + 1))
        try waitForCount(box, count1 + 1)
        XCTAssertEqual(try box.count(), count1 + 1)
        let objectFromClient2 = try box.get(id: id2)
        XCTAssertEqual(object2.date!.unixTimestamp, objectFromClient2!.date!.unixTimestamp)
        XCTAssertEqual(object2.string!, objectFromClient2!.string!)

        // No RAII in Swift; use clients again to also silence "Initialization ... was never used";
        // also withExtendedLifetime() is awkward
        try client.stop()
        try client2.stop()
    }

    func testSyncClientHeartbeat() throws {
        let client = try loginNewClient(store, updateRequestMode: .manual)
        guard client.getState() == .loggedIn else {
            print("Could not login, skipping further testing")
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


    // Maybe we could start the server automatically...
    @available(macOS 10.12, *)
    func findServerExe() throws -> String? {
        #if os(macOS)
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let baseDir = home + "/dev/objectbox/"
        let buildDirs = ["cmake-build-debug", "cmake-build-release", "cbuild/Debug", "cbuild/Release"]
        let relPathToExe = "/objectbox/src/main/cpp/sync/server/sync-server"
        var newestDate: Date?
        var chosenPath: String?

        for buildDir in buildDirs {
            let path = baseDir + buildDir + relPathToExe
            if FileManager.default.isExecutableFile(atPath: path) {
                let attrs = try FileManager.default.attributesOfItem(atPath: path)
                let date = attrs[FileAttributeKey.modificationDate] as? Date
                let size = attrs[FileAttributeKey.size]
                print("A sync server was found: ", date ?? "?", path, ", size:", size ?? 0)
                if newestDate == nil || (date != nil && date!.unixTimestamp > newestDate!.unixTimestamp) {
                    newestDate = date
                    chosenPath = path
                }
            }
        }
        return chosenPath
        #else
        return nil
        #endif
    }

}
