//
// Copyright (c) 2020 ObjectBox. All rights reserved.
//

import Foundation
import XCTest
@testable import ObjectBox

class SyncDryTests: XCTestCase {

    var store: Store!

    override func setUpWithError() throws {
        super.setUp()
        store = StoreHelper.tempStore(model: createTestModel())
    }

    private func createClient() throws -> SyncClient {
        try Sync.makeClient(store: store, url: URL(string: "ws://127.0.0.1:9999")!)
    }

    func testSyncClientAvailable() throws {
        XCTAssert(Sync.isAvailable())
    }

    func testSyncClientStartStopClose() throws {
        let client = try createClient()
        try client.setCredentials(SyncCredentials.makeNone())
        XCTAssertEqual(client.getState(), SyncState.created)
        try client.start()
        XCTAssertEqual(client.getState(), SyncState.started)
        XCTAssertThrowsError(try client.start()) { error in
            XCTAssertNotNil(error as? ObjectBoxError)
        }
        try client.stop()
        XCTAssertEqual(client.getState(), SyncState.stopped)
        try client.stop()  // Double stop
        client.close()
        XCTAssertEqual(client.getState(), SyncState.dead)
        client.close()  // Double close
    }

    func testSyncClientStoreAssociation() throws {
        let client = try createClient()
        XCTAssert(store.syncClient === client)

        XCTAssertThrowsError(try createClient()) { error in
            XCTAssertNotNil(error as? ObjectBoxError)
        }

        client.close()
        XCTAssertNil(store.syncClient)  // Not associated anymore

        let client2 = try createClient()  // Allowed after closing client
        XCTAssert(store.syncClient === client2)
    }

    func testSyncClientStartWithoutCredentials() throws {
        XCTAssertThrowsError(try createClient().start()) { error in
            XCTAssertNotNil(error as? ObjectBoxError)
        }
    }

    func testMakeSyncClientUrlString() throws {
        let client = try Sync.makeClient(store: store, urlString: "ws://127.0.0.1:9999")
        client.close()

        XCTAssertThrowsError(try Sync.makeClient(store: store, urlString: "")) { error in
            XCTAssertNotNil(error as? ObjectBoxError)
        }
    }

    func testSyncClientCredentials() throws {
        let client = try Sync.makeClient(store: store, urlString: "ws://127.0.0.1:9999",
                credentials: SyncCredentials.makeNone())
        try client.setCredentials(SyncCredentials.makeSharedSecret("foo"))
        try client.start()
        try client.stop()
    }

    class ChangeListener: SyncChangeListener {
    }

    class LoginListener: SyncLoginListener {
        func loggedIn() {
        }

        func loginFailed(result: SyncCode) {
        }

    }

    class AllListener: SyncListener {
        func loggedIn() {
        }

        func loginFailed(result: SyncCode) {
        }

        func updatesCompleted() {
        }

        func connected() {
        }

        func disconnected() {
        }

    }

    func testSyncClientListeners() throws {
        let client = try createClient()

        client.changeListener = ChangeListener()
        client.changeListener = ChangeListener()

        client.loginListener = LoginListener()
        client.loginListener = LoginListener()

        client.listener = AllListener()
        client.listener = AllListener()
    }

}
