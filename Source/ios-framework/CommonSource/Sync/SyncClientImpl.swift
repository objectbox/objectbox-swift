//  Copyright © 2020-2021 ObjectBox. All rights reserved.

import Foundation

/// Docs are available in SyncClient
class SyncClientImpl: SyncClient {

    /// OBX_sync, nil if closed
    internal var cSync: OpaquePointer?

    private var isStarted = false
    private var credentialsSet = false
    private var store: Store?

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
                let userData = Unmanaged.passUnretained(self).toOpaque()
                obx_sync_listener_login(cSync, loginCallback, userData)
                obx_sync_listener_login_failure(cSync, loginFailureCallback, userData)
            }
        }
    }

    public var completedListener: SyncCompletedListener? {
        didSet {
            if cSync != nil {
                let userData = Unmanaged.passUnretained(self).toOpaque()
                obx_sync_listener_complete(cSync, updatesCompletedCallback, userData)
            }
        }
    }

    // TODO: Not used yet: not public
    var changeListener: SyncChangeListener? {
        didSet {
            if cSync != nil {
                let userData = Unmanaged.passUnretained(self).toOpaque()
                // TODO do not pass nil
                obx_sync_listener_change(cSync, nil, userData)
            }
        }
    }

    public var connectionListener: SyncConnectionListener? {
        didSet {
            if cSync != nil {
                let userData = Unmanaged.passUnretained(self).toOpaque()
                obx_sync_listener_connect(cSync, connectedCallback, userData)
                obx_sync_listener_disconnect(cSync, disconnectedCallback, userData)
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
        set(newValue) {
            let cMode = OBXRequestUpdatesMode(newValue.rawValue)
            if cSync != nil && obx_sync_request_updates_mode(cSync, cMode) == OBX_SUCCESS {
                updateRequestModeStorage = newValue
            }
        }
        get {
            return updateRequestModeStorage
        }
    }

    init(store: Store, server: URL) throws {
        self.store = store
        cSync = obx_sync(store.cStore, server.absoluteString)
        if cSync == nil {
            try checkLastError()
            throw ObjectBoxError.sync(message: "Could not create")  // paranoia, checkLastError() should throw already
        }
        obx_sync_request_updates_mode(cSync, OBXRequestUpdatesMode(updateRequestModeStorage.rawValue))
    }

    deinit {
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
        let cSyncToClose = cSync
        if cSyncToClose != nil {
            cSync = nil

            let associate = store?.syncClient as? SyncClientImpl
            if associate != nil {
                if associate! === self {
                    store!.syncClient = nil
                } // else log error?
            }

            store = nil  // A closed client should release the store

            SyncClientImpl.removeAllListeners(cSyncToClose: cSyncToClose!)
            let err = obx_sync_close(cSyncToClose)
            if err != OBX_SUCCESS {
                // TODO log err?
            }
        }
    }

    public func setCredentials(_ credentials: SyncCredentials) throws {
        try ensureValid()
        // Note: we don't store credentials in Swift memory for security reasons
        let credentialsLength = credentials.data.count
        try credentials.data.withUnsafeBytes { (rawBytes: UnsafeRawBufferPointer) -> Void in
            let cCredsType = OBXSyncCredentialsType(credentials.type.rawValue)
            obx_sync_credentials(cSync, cCredsType, rawBytes.baseAddress, credentialsLength)
            try checkLastError()
            credentialsSet = true
        }
    }

    public func start() throws {
        try ensureValid()
        if !credentialsSet {
            throw ObjectBoxError.illegalState(message: "You must set credentials before starting")
        }

        try checkLastError(obx_sync_start(cSync))
        isStarted = true
    }

    public func stop() throws {
        if cSync != nil {
            try checkLastError(obx_sync_stop(cSync))
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

    static func removeAllListeners(cSyncToClose: OpaquePointer) {
        obx_sync_listener_login(cSyncToClose, nil, nil)
        obx_sync_listener_login_failure(cSyncToClose, nil, nil)
        obx_sync_listener_complete(cSyncToClose, nil, nil)
        // obx_sync_listener_change(cSyncToClose, nil, nil)
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
    callWithSyncClient(userData, action: { (client: SyncClient) -> Void in
        client.loginListener?.loggedIn()
    })
}

private func loginFailureCallback(_ userData: UnsafeMutableRawPointer?, _ cCode: OBXSyncCode) {
    let code = SyncCode(rawValue: cCode.rawValue)!
    callWithSyncClient(userData, action: { (client: SyncClient) -> Void in
        client.loginListener?.loginFailed(result: code)
    })
}

private func connectedCallback(_ userData: UnsafeMutableRawPointer?) {
    callWithSyncClient(userData, action: { (client: SyncClient) -> Void in
        client.connectionListener?.connected()
    })
}

private func disconnectedCallback(_ userData: UnsafeMutableRawPointer?) {
    callWithSyncClient(userData, action: { (client: SyncClient) -> Void in
        client.connectionListener?.disconnected()
    })
}

private func updatesCompletedCallback(_ userData: UnsafeMutableRawPointer?) {
    callWithSyncClient(userData, action: { (client: SyncClient) -> Void in
        client.completedListener?.updatesCompleted()
    })
}

//private func syncChangeCallback(_ userData: UnsafeMutableRawPointer?,
//                                 _ changeArray: UnsafePointer<OBX_sync_change_array>?) {
//    let syncListener = userData!.load(as: SyncListener.self)
//    if let changeArray = changeArray {
//        var result = [obx_schema_id: SyncChange]()
//        for changeIdx in 0 ..< changeArray.pointee.count {
//            let currChangeC = changeArray.pointee.list[changeIdx]
//            var currChangeObject = SyncChange(puts: [], removals: [])
//            for putIdx in 0 ..< (currChangeC.puts?.pointee.count ?? 0) {
//                currChangeObject.puts.append(currChangeC.puts!.pointee.ids[putIdx])
//            }
//            for removalIdx in 0 ..< (currChangeC.removals?.pointee.count ?? 0) {
//                currChangeObject.removals.append(currChangeC.removals!.pointee.ids[removalIdx])
//            }
//            result[currChangeC.entity_id] = currChangeObject
//        }
//        DispatchQueue.main.async {
//            syncListener.changed(result)
//        }
//    } else {
//        print("No change info")
//    }
//}
