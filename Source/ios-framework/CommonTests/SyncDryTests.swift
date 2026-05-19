//
// Copyright (c) 2020-2025 ObjectBox. All rights reserved.
//

import Foundation
import XCTest
@testable import ObjectBox

// NOTE these tests have a different implementation on sync branch
// which has an ObjectBox database library with Sync feature available to test.

class SyncDryTests: XCTestCase {

    var store: Store!

    override func setUp() {
        super.setUp()
        store = StoreHelper.tempStore(model: createTestModel())
    }

    override func tearDown() {
        super.tearDown()
        // swiftlint:disable:next force_try
        try! store?.closeAndDeleteAllFiles()
        store = nil
    }

    func testSyncClientAvailable() throws {
        XCTAssertFalse(Sync.isAvailable())

        let credentials = SyncCredentials.makeNone()
        var client: SyncClient?
        XCTAssertThrowsError(client = try Sync.makeClient(
                store: store, urlString: "ws://127.0.0.1:9999", credentials: credentials)) { error in
            XCTAssertNotNil(error as? ObjectBoxError)
        }

        if client != nil { // Never, just ensure some basics compile
            client?.listener = AllListener()
            try client!.start()
            try client!.stop()
            client!.close()
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

        func changed(_ changes: [obx_schema_id: SyncChange]) {
        }

    }

}
