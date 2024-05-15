//
// Copyright (c) 2020 ObjectBox. All rights reserved.
//

import Foundation
import XCTest
@testable import ObjectBox

class SyncDryTests: XCTestCase {

    var store: Store!

    override func setUp() {
        super.setUp()
        store = StoreHelper.tempStore(model: createTestModel())
    }
    
    override func tearDown() {
        super.tearDown()
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

    }

}
