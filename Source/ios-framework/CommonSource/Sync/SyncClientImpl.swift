//  Copyright © 2020-2026 ObjectBox. https://objectbox.io

import Foundation

/// Docs are available in SyncClient
class SyncClientImpl: SyncClient {

    /// OBX_sync, nil if closed
    internal var cSync: OpaquePointer?

    private var isStarted = false
    private var credentialsSet = false
    private var store: Store?

    /// Enable debug logging for sync client lifecycle and callbacks
    public let debugLogging: Bool

    private func debugLog(_ message: String) {
        if debugLogging {
            print("[Client] \(message)")
        }
    }

    // Listener notes:
    // 1) we pass self (SyncClient) as user data to C-style callbacks:
    // thus we can check if the client is closed before calling the listener.
    // 2) Converting self to a UnsafeMutableRawPointer using an Unmanaged was inspired here:
    // https://forums.swift.org/t/passing-a-pointer-to-self-to-c-function/4154
    // 3) Strictly speaking, there remains a race condition if the SyncListener is destroyed:
    // although we deregister listeners on close(), a C callback may still be fired concurrently.
    // This is somewhat intercepted by checking isClosed() before calling the listener.

    public var callListenersInMainThread = false

    public var loginListener: SyncLoginListener? {
        didSet {
            if cSync != nil {
                if loginListener != nil {
                    debugLog("loginListener set, registering callbacks")
                    let userData = Unmanaged.passUnretained(self).toOpaque()
                    obx_sync_listener_login(cSync, loginCallback, userData)
                    obx_sync_listener_login_failure(cSync, loginFailureCallback, userData)
                } else {
                    debugLog("loginListener set to nil, deregistering callbacks")
                    obx_sync_listener_login(cSync, nil, nil)
                    obx_sync_listener_login_failure(cSync, nil, nil)
                }
            }
        }
    }

    public var completedListener: SyncCompletedListener? {
        didSet {
            if cSync != nil {
                if completedListener != nil {
                    debugLog("completedListener set, registering callback")
                    let userData = Unmanaged.passUnretained(self).toOpaque()
                    obx_sync_listener_complete(cSync, updatesCompletedCallback, userData)
                } else {
                    debugLog("completedListener set to nil, deregistering callback")
                    obx_sync_listener_complete(cSync, nil, nil)
                }
            }
        }
    }

    public var changeListener: SyncChangeListener? {
        didSet {
            if cSync != nil {
                if changeListener != nil {
                    debugLog("changeListener set, registering callback")
                    let userData = Unmanaged.passUnretained(self).toOpaque()
                    obx_sync_listener_change(cSync, changesCallback, userData)
                } else {  // remove by setting to nil
                    debugLog("changeListener set to nil, deregistering callback")
                    obx_sync_listener_change(cSync, nil, nil)
                }
            }
        }
    }

    public var connectionListener: SyncConnectionListener? {
        didSet {
            if cSync != nil {
                if connectionListener != nil {
                    debugLog("connectionListener set, registering callbacks")
                    let userData = Unmanaged.passUnretained(self).toOpaque()
                    obx_sync_listener_connect(cSync, connectedCallback, userData)
                    obx_sync_listener_disconnect(cSync, disconnectedCallback, userData)
                } else {
                    debugLog("connectionListener set to nil, deregistering callbacks")
                    obx_sync_listener_connect(cSync, nil, nil)
                    obx_sync_listener_disconnect(cSync, nil, nil)
                }
            }
        }
    }

    public var listener: SyncListener? {
        didSet {
            loginListener = listener
            completedListener = listener
            changeListener = listener
            connectionListener = listener
        }
    }

    private var updateRequestModeStorage = RequestUpdatesMode.auto


    public var updateRequestMode: RequestUpdatesMode {
        get {
            return updateRequestModeStorage
        }
        set(newValue) {
            let cMode = OBXRequestUpdatesMode(newValue.rawValue)
            if cSync != nil && obx_sync_request_updates_mode(cSync, cMode) == OBX_SUCCESS {
                updateRequestModeStorage = newValue
            }
        }
    }

    init(configuration: Sync.Configuration) throws {
        self.debugLogging = configuration.debugLogging
        self.store = configuration.store

        // Create sync options
        guard let opt = obx_sync_opt(configuration.store.cStore) else {
            try checkLastError()
            throw ObjectBoxError.sync(message: "Could not create sync options")
        }

        // Track whether obx_sync_create consumed the options (it always frees them on success or failure)
        var optConsumed = false
        defer {
            if !optConsumed {
                obx_sync_opt_free(opt)
            }
        }

        // Add URLs (at least one required, validated by Sync.makeClient)
        for url in configuration.urls {
            try checkLastError(obx_sync_opt_add_url(opt, url))
        }

        // Add certificate paths
        for certPath in configuration.certificatePaths {
            try checkLastError(obx_sync_opt_add_cert_path(opt, certPath))
        }

        // Set flags if any
        if configuration.flags.rawValue != 0 {
            try checkLastError(obx_sync_opt_flags(opt, configuration.flags.rawValue))
        }

        // Create sync client from options (obx_sync_create always frees opt, even on error)
        optConsumed = true
        cSync = obx_sync_create(opt)
        if cSync == nil {
            try checkLastError()
            throw ObjectBoxError.sync(message: "Could not create sync client")
        }

        obx_sync_request_updates_mode(cSync, OBXRequestUpdatesMode(updateRequestModeStorage.rawValue))

        // Set credentials if provided
        if !configuration.credentials.isEmpty {
            try setCredentials(configuration.credentials)
        }

        // Set filter variables if provided
        for (name, value) in configuration.filterVariables {
            try putFilterVariable(name: name, value: value)
        }

        debugLog("init completed, cSync=\(String(describing: cSync))")
    }

    deinit {
        debugLog("deinit called")
        close()
    }

    public func getState() -> SyncState {
        if cSync != nil {
            let state = obx_sync_state(cSync)
            return SyncState(rawValue: state.rawValue)!
        } else {
            return .dead
        }
    }

    public func getStateString() -> String {
        switch getState() {
        case .created: return "created"
        case .started: return "started"
        case .connected: return "connected"
        case .loggedIn: return "loggedIn"
        case .disconnected: return "disconnected"
        case .stopped: return "stopped"
        case .dead: return "dead"
        }
    }

    public func isClosed() -> Bool {
        return cSync == nil
    }

    public func close() {
        debugLog("closing, cSync=\(String(describing: cSync))")
        let cSyncToClose = cSync
        if cSyncToClose != nil {
            cSync = nil

            let associate = store?.syncClient as? SyncClientImpl
            if associate != nil {
                if associate! === self {
                    store!.syncClient = nil
                } else {
                    debugLog("closing: store.syncClient is not self")
                }
            }

            store = nil  // A closed client should release the store

            removeAllListeners(cSyncToClose: cSyncToClose!)
            debugLog("closing C sync")
            let err = obx_sync_close(cSyncToClose)
            if err != OBX_SUCCESS {
                debugLog("close(): obx_sync_close returned error \(err)")
            }
            debugLog("close completed")
        } else {
            debugLog("already closed")
        }
    }

    public func putFilterVariable(name: String, value: String) throws {
        try ensureValid()
        try checkLastError(obx_sync_filter_variables_put(cSync, name, value))
    }

    public func removeFilterVariable(_ name: String) throws {
        try ensureValid()
        try checkLastError(obx_sync_filter_variables_remove(cSync, name))
    }

    public func removeAllFilterVariables() throws {
        try ensureValid()
        try checkLastError(obx_sync_filter_variables_remove_all(cSync))
    }

    public func setCredentials(_ credentials: SyncCredentials) throws {
        try ensureValid()
        // Note: we don't store credentials in Swift memory for security reasons
        if let data = credentials.data {
            let credentialsLength = data.count
            try data.withUnsafeBytes { (rawBytes: UnsafeRawBufferPointer) in
                let cCredsType = OBXSyncCredentialsType(credentials.type.rawValue)
                obx_sync_credentials(cSync, cCredsType, rawBytes.baseAddress, credentialsLength)
                try checkLastError()
                credentialsSet = true
            }
        } else if let username = credentials.username {
            let cCredsType = OBXSyncCredentialsType(credentials.type.rawValue)
            obx_sync_credentials_user_password(cSync, cCredsType, username, credentials.password!)
            try checkLastError()
            credentialsSet = true
        } else {
            throw ObjectBoxError.illegalArgument(message: "Credentials neither contain bytes data nor user/password")
        }
    }

    public func setCredentials(_ credentials: [SyncCredentials]) throws {
        try ensureValid()

        var oneCredentialSet = false

        for (index, credential) in credentials.enumerated() {
            let isLast = index + 1 == credentials.count
            if let data = credential.data {
                let credentialsLength = data.count
                try data.withUnsafeBytes { (rawBytes: UnsafeRawBufferPointer) in
                    let cCredsType = OBXSyncCredentialsType(credential.type.rawValue)
                    // TODO Need new C API
                    obx_sync_credentials_add(cSync, cCredsType, rawBytes.baseAddress, credentialsLength, isLast)
                    try checkLastError()
                    oneCredentialSet = true
                }
            } else if let username = credential.username {
                let cCredsType = OBXSyncCredentialsType(credential.type.rawValue)
                obx_sync_credentials_add_user_password(cSync, cCredsType, username, credential.password!, isLast)
                try checkLastError()
                oneCredentialSet = true
            } else {
                throw ObjectBoxError.illegalArgument(
                    message: "Credentials neither contain bytes data nor user/password")
            }
        }
        if oneCredentialSet {
            credentialsSet = true
        }
    }

    public func start() throws {
        debugLog("start() called")
        try ensureValid()
        if !credentialsSet {
            throw ObjectBoxError.illegalState(message: "You must set credentials before starting")
        }

        try checkLastError(obx_sync_start(cSync))
        isStarted = true
        debugLog("start() completed")
    }

    public func stop() throws {
        debugLog("stop() called")
        if cSync != nil {
            try checkLastError(obx_sync_stop(cSync))
            debugLog("stop() completed")
        } else {
            debugLog("stop(): cSync was nil")
        }
    }

    @discardableResult
    public func requestUpdates(subscribe: Bool = false) throws -> Bool {
        try ensureValid()
        return try checkLastErrorSuccessFlag(obx_sync_updates_request(cSync, subscribe))
    }

    @discardableResult
    func requestUpdates() throws -> Bool {
        return try requestUpdates(subscribe: false)
    }

    @discardableResult
    func requestUpdatesAndSubscribe() throws -> Bool {
        return try requestUpdates(subscribe: true)
    }

    @discardableResult
    public func cancelUpdates() throws -> Bool {
        try ensureValid()
        return try checkLastErrorSuccessFlag(obx_sync_updates_cancel(cSync))
    }

    @discardableResult
    public func fullSync() throws -> Bool {
        try ensureValid()
        return try checkLastErrorSuccessFlag(obx_sync_full(cSync))
    }

    private func ensureValid() throws {
        if cSync == nil {  // While C API should guard against this, this is the better error to throw
            throw ObjectBoxError.illegalState(message: "Sync client already closed")
        }
    }

    func removeAllListeners(cSyncToClose: OpaquePointer) {
        debugLog("removing all listeners")
        obx_sync_listener_login(cSyncToClose, nil, nil)
        obx_sync_listener_login_failure(cSyncToClose, nil, nil)
        obx_sync_listener_complete(cSyncToClose, nil, nil)
        obx_sync_listener_change(cSyncToClose, nil, nil)
        obx_sync_listener_connect(cSyncToClose, nil, nil)
        obx_sync_listener_disconnect(cSyncToClose, nil, nil)
    }

    func waitForLoggedInState(timeoutMilliseconds: UInt) throws -> SuccessTimeOut {
        try ensureValid()
        let result = obx_sync_wait_for_logged_in_state(cSync, UInt64(timeoutMilliseconds))
        if result == OBX_SUCCESS {
            return .success
        } else if result == OBX_NO_SUCCESS {
            return .failure
        } else if result == OBX_TIMEOUT {
            return .failure
        } else {
            try checkLastError(obx_sync_full(cSync))  // Should throw now as non of the 3 expected results matched
            return .failure
        }
    }

    @discardableResult
    func sendHeartbeat() throws -> Bool {
        try ensureValid()
        guard getState() == .loggedIn else { return false }  // TODO move this into C
        return try checkLastErrorSuccessFlag(obx_sync_send_heartbeat(cSync))
    }

    func setHeartbeatInterval(milliseconds: UInt) throws {
        try ensureValid()
        try checkLastError(obx_sync_heartbeat_interval(cSync, UInt64(milliseconds)))
    }
    
    func outgoingMessagesCount() throws -> UInt {
        try outgoingMessagesCount(limit: 0)
    }

    func outgoingMessagesCount(limit: UInt) throws -> UInt {
        try ensureValid()
        var count: UInt64 = 0
        try checkLastError(obx_sync_outgoing_message_count(cSync, UInt64(limit), &count))
        return UInt(count)
    }
}

private func callWithSyncClient(_ userData: UnsafeMutableRawPointer?, action: @escaping (SyncClient) -> Void) {
    let syncClient = Unmanaged<SyncClientImpl>.fromOpaque(userData!).takeUnretainedValue()
    if !syncClient.isClosed() {
        if syncClient.callListenersInMainThread {
            DispatchQueue.main.async {
                if !syncClient.isClosed() {
                    action(syncClient)
                }
            }
        } else {
            action(syncClient)
        }
    }
}

private func loginCallback(_ userData: UnsafeMutableRawPointer?) {
    callWithSyncClient(userData, action: { (client: SyncClient) in
        client.loginListener?.loggedIn()
    })
}

private func loginFailureCallback(_ userData: UnsafeMutableRawPointer?, _ cCode: OBXSyncCode) {
    let code = SyncCode(rawValue: cCode.rawValue)!
    callWithSyncClient(userData, action: { (client: SyncClient) in
        client.loginListener?.loginFailed(result: code)
    })
}

private func connectedCallback(_ userData: UnsafeMutableRawPointer?) {
    callWithSyncClient(userData, action: { (client: SyncClient) in
        client.connectionListener?.connected()
    })
}

private func disconnectedCallback(_ userData: UnsafeMutableRawPointer?) {
    callWithSyncClient(userData, action: { (client: SyncClient) in
        client.connectionListener?.disconnected()
    })
}

private func updatesCompletedCallback(_ userData: UnsafeMutableRawPointer?) {
    callWithSyncClient(userData, action: { (client: SyncClient) in
        client.completedListener?.updatesCompleted()
    })
}

private func changesCallback(
    _ userData: UnsafeMutableRawPointer?,
    _ cSyncChangeArray: UnsafePointer<OBX_sync_change_array>?
) {
    guard let cSyncChangeArray = cSyncChangeArray else { return }
    let count = cSyncChangeArray.pointee.count
    guard count > 0, let list = cSyncChangeArray.pointee.list else { return }
    var syncChanges: [obx_schema_id: SyncChange] = [:]
    for i in (0 ..< count) {
        let cSyncChange = list[i]
        var putEntityIds: [Id] = []
        var removeEntityIds: [Id] = []
        let entityId = cSyncChange.entity_id
        if let cPutsArrayPtr = cSyncChange.puts, let arr = cPutsArrayPtr.pointee.ids {
            let size = cPutsArrayPtr.pointee.count
            for k in (0 ..< size) {
                putEntityIds.append(arr[k] as Id)
            }
        }
        if let cRemovalsArrayPtr = cSyncChange.removals, let arr = cRemovalsArrayPtr.pointee.ids {
            let size = cRemovalsArrayPtr.pointee.count
            for k in (0 ..< size) {
                removeEntityIds.append(arr[k] as Id)
            }
        }
        syncChanges[entityId] = SyncChange(puts: putEntityIds, removals: removeEntityIds)
    }
    callWithSyncClient(userData, action: { (client: SyncClient) in
        client.changeListener?.changed(syncChanges)
    })
}
