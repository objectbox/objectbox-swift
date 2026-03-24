//
// Copyright (c) 2020-2025 ObjectBox. All rights reserved.
//

import Foundation
import XCTest
@testable import ObjectBox

// NOTE these tests have a different implementation on sync branch
// which has an ObjectBox database library with Sync feature available to test.

class SyncDryTests: XCTestCase {

    private let testSyncUrl = "ws://127.0.0.1:9999"
    private let testSyncUrl2 = "ws://127.0.0.1:9998"
    private let testSyncUrlSecure = "wss://127.0.0.1:9999"

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

    private func createClient() throws -> SyncClient {
        return try Sync.makeClient(configuration: Sync.Configuration(store: store, url: testSyncUrl))
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
        let client = try Sync.makeClient(configuration: Sync.Configuration(store: store, url: testSyncUrl))
        client.close()

        // Test empty URLs array
        XCTAssertThrowsError(try Sync.makeClient(configuration: Sync.Configuration(store: store, urls: []))) { error in
            XCTAssertNotNil(error as? ObjectBoxError)
        }
    }

    func testSyncClientCredentials() throws {
        let configuration = Sync.Configuration(store: store, url: testSyncUrl)
        configuration.credentials = [SyncCredentials.makeNone()]
        let client = try Sync.makeClient(configuration: configuration)
        try client.setCredentials(SyncCredentials.makeSharedSecret("foo"))
        try client.start()
        try client.stop()
    }

    func testSyncClientCredentialsMultiple() throws {
        let configuration = Sync.Configuration(store: store, url: testSyncUrl)
        configuration.credentials = [SyncCredentials.makeJwtIdToken("jwt-id-test"),
                                     SyncCredentials.makeJwtAccessToken("jwt-access-test"),
                                     SyncCredentials.makeJwtRefreshToken("jwt-refresh-test"),
                                     SyncCredentials.makeJwtCustomToken("jwt-custom-token")]
        let client = try Sync.makeClient(configuration: configuration)
        try client.setCredentials([SyncCredentials.makeJwtIdToken("jwt-id-test"),
                                   SyncCredentials.makeJwtAccessToken("jwt-access-test"),
                                   SyncCredentials.makeJwtRefreshToken("jwt-refresh-test"),
                                   SyncCredentials.makeJwtCustomToken("jwt-custom-token")
                                  ])
        try client.start()
        try client.stop()
    }

    // Only a quick smoke test as for a full test a server is required
    func testSyncClientFilterVariables() throws {
        let configuration = Sync.Configuration(store: store, url: testSyncUrl)
        configuration.filterVariables = ["test-var-1": "test value 1", "test-var-2": "test value 2"]
        let client = try Sync.makeClient(configuration: configuration)
        defer { client.close() }

        try client.putFilterVariable(name: "test-var-2", value: "test value 2")
        try client.removeFilterVariable("test-var-2")
        try client.putFilterVariable(name: "test-var-2", value: "")
        try client.removeAllFilterVariables()

        XCTAssertThrowsError(try client.putFilterVariable(name: "", value: "value"))
    }

    // Only a quick smoke test for passing certificate paths
    func testSyncClientCertificatePaths() throws {
        // One dummy path, one valid path (macOS homebrew OpenSSL)
        let configuration = Sync.Configuration(store: store, url: testSyncUrlSecure)
        configuration.certificatePaths = ["/etc/fonts", "/usr/local/etc/openssl@3/cert.pem"]
        let client = try Sync.makeClient(configuration: configuration)
        defer { client.close() }
        usleep(100000)  // Sleep 100ms to let the client initialize (won't connect, but that's ok)
    }

    // MARK: - Configuration API Tests

    func testSyncClientConfiguration() throws {
        let configuration = Sync.Configuration(store: store, url: testSyncUrl)
        configuration.credentials = [SyncCredentials.makeNone()]
        configuration.debugLogging = true

        let client = try Sync.makeClient(configuration: configuration)
        defer { client.close() }

        XCTAssertEqual(client.getState(), SyncState.created)
        try client.start()
        XCTAssertEqual(client.getState(), SyncState.started)
    }

    func testSyncClientConfigurationMultipleUrls() throws {
        let configuration = Sync.Configuration(store: store, urls: [testSyncUrl, testSyncUrl2])
        configuration.credentials = [SyncCredentials.makeNone()]

        XCTAssertEqual(configuration.urls.count, 2)

        let client = try Sync.makeClient(configuration: configuration)
        defer { client.close() }
        XCTAssertEqual(client.getState(), SyncState.created)
    }

    func testSyncClientConfigurationWithFlags() throws {
        let configuration = Sync.Configuration(store: store, url: testSyncUrl)
        configuration.flags = [.debugLogIdMapping, .keepDataOnSyncError]

        let client = try Sync.makeClient(configuration: configuration)
        defer { client.close() }
        try client.setCredentials(SyncCredentials.makeNone())
        try client.start()
    }

    func testSyncClientConfigurationWithFilterVariables() throws {
        let configuration = Sync.Configuration(store: store, url: testSyncUrl)
        configuration.filterVariables = ["test-var-1": "test value 1", "test-var-2": "test value 2"]

        let client = try Sync.makeClient(configuration: configuration)
        defer { client.close() }
        // Filter variables should already be set from configuration
    }

    func testSyncClientConfigurationNoUrl() throws {
        // Empty URLs array should fail
        XCTAssertThrowsError(try Sync.makeClient(configuration: Sync.Configuration(store: store, urls: []))) { error in
            XCTAssertNotNil(error as? ObjectBoxError)
        }
    }

    // MARK: - Deprecated API Tests (backward compatibility)

    @available(*, deprecated)  // Silence deprecation warning for this test
    func testDeprecatedMakeClientStillWorks() throws {
        // Test that the deprecated API still works for backward compatibility
        let client = try Sync.makeClient(store: store, urlString: testSyncUrl,
                                         credentials: SyncCredentials.makeNone())
        defer { client.close() }

        XCTAssertEqual(client.getState(), SyncState.created)
        try client.start()
        XCTAssertEqual(client.getState(), SyncState.started)
    }

    class ChangeListener: SyncChangeListener {
        func changed(_ changes: [obx_schema_id: SyncChange]) {

        }
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

        func changed(_ changes: [obx_schema_id: SyncChange]) {
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
    
    // Quick test for API availability. Proper test (that requires a server) in `SyncTests`.
    func testSyncClientOutgoingMessageCount() throws {
        let client = try createClient()
        defer { client.close() }
        try client.setCredentials(SyncCredentials.makeNone())
        try client.start()
        XCTAssertEqual(try client.outgoingMessagesCount(), 0)
    }

}
