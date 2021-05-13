//  Copyright © 2020-2021 ObjectBox. All rights reserved.

/// Main API for client sync; create an instance via Sync.makeClient().
/// The sync client will start trying to connect after start() is called.
public protocol SyncClient: AnyObject {

    var callListenersInMainThread: Bool { get set }

    /// Sets a listener to observe login events. Replaces a previously set listener.
    /// Set to `nil` to remove the listener.
    var loginListener: SyncLoginListener? { get set }

    /// Sets a listener to observe sync completed events. Replaces a previously set listener.
    /// Set to `nil` to remove the listener.
    var completedListener: SyncCompletedListener? { get set }

    // TODO: Not used yet: not public
    /// Sets a listener to observe sync changes. Replaces a previously set listener.
    /// Set to `nil` to remove the listener.
    var changeListener: SyncChangeListener? { get set }

    /// Sets a listener to observe sync connection events. Replaces a previously set listener.
    /// Set to `nil` to remove the listener.
    var connectionListener: SyncConnectionListener? { get set }

    /// Sets a listener to observe all sync events. Replaces a previously set listener.
    /// Set to `nil` to remove the listener.
    ///
    /// - Note: This replaces any specific listeners, e.g. a login listener.
    var listener: SyncListener? { get set }

    /// Configures how sync updates are received from the server.
    /// If automatic sync updates are turned off, they will need to be requested manually.
    var updateRequestMode: RequestUpdatesMode { get set }

    /// Gets the current sync client state.
    func getState() -> SyncState

    /// Gets the current sync client state as a String.
    func getStateString() -> String

    /// Returns if this sync client is closed and can no longer be used.
    func isClosed() -> Bool

    /// Closes and cleans up all resources used by this sync client.
    /// It can no longer be used afterwards, make a new sync client instead.
    /// Does nothing if this sync client has already been closed.
    func close()

    /// Sets credentials to authenticate the client with the server.
    /// Build credentials using e.g. `SyncCredentials.makeSharedSecret(secret)`.
    func setCredentials(_ credentials: SyncCredentials) throws

    /// Once the sync client is configured, you can "start" it to initiate synchronization.
    /// This method triggers communication in the background and will return immediately.
    /// If the synchronization destination is reachable, this background thread will connect to the server,
    /// log in (authenticate) and, depending on "update request mode", start syncing data.
    /// If the device, network or server is currently offline, connection attempts will be retried later using
    /// increasing backoff intervals.
    func start() throws

    /// Stops this sync client. Does nothing if it is already stopped or closed.
    func stop() throws

    /// If automatic updates have been turned off via `updateRequestMode`, this allows manual interaction:
    /// requests the latest updates from the server once (without subscribing for future updates).
    /// - Returns true if the request was likely sent (e.g. the sync client is in "logged in" state)
    /// - Returns false if the request was not sent (and will not be sent in the future).
    @discardableResult
    func requestUpdates() throws -> Bool

    /// If automatic updates have been turned off via `updateRequestMode`, this allows manual interaction:
    /// requests the latest updates from the server and subscribes for future updates, which the server will "push".
    /// Note: use `cancelUpdates()` to stop receiving further updates (pushes).
    /// - Returns true if the request was likely sent (e.g. the sync client is in "logged in" state)
    /// - Returns false if the request was not sent (and will not be sent in the future).
    @discardableResult
    func requestUpdatesAndSubscribe() throws -> Bool

    /// Requests the server to stop sending updates.
    /// Use `requestUpdates()` or `requestUpdatesAndSubscribe()` to request updates again.
    /// - Returns true if the request was likely sent (e.g. the sync client is in "logged in" state)
    /// - Returns false if the request was not sent (and will not be sent in the future).
    @discardableResult
    func cancelUpdates() throws -> Bool

    /// Experimental/Advanced API: requests a sync of all previous changes from the server.
    /// - Returns true if the request was likely sent (e.g. the sync client is in "logged in" state)
    /// - Returns false if the request was not sent (and will not be sent in the future).
    @discardableResult
    func fullSync() throws -> Bool

    /// Waits for the sync client to get into SyncState.loggedIn or until the given timeout is reached.
    /// For an asynchronous alternative, please check the listeners.
    /// - Parameter timeoutMilliseconds: Must be greater than 0
    /// - Returns SuccessTimeOut.success if SyncState.loggedIn has been reached within the given timeout
    /// - Returns SuccessTimeOut.timeout if the given timeout was reached before a relevant state change was detected.
    /// - Returns SuccessTimeOut.failure if a state was reached within the given timeout that is unlikely to result in
    ///           a successful login, e.g. "disconnected".
    func waitForLoggedInState(timeoutMilliseconds: UInt) throws -> SuccessTimeOut

    /// Sends a heartbeat immediately, e.g. to detect that the network connection is still operational.
    /// - Returns true if the request was likely sent (e.g. the sync client is in "logged in" state)
    /// - Returns false if the request was not sent (and will not be sent in the future).
    @discardableResult
    func sendHeartbeat() throws -> Bool

    /// Sets the interval in which the client sends "heartbeat" messages to the server, keeping the connection alive.
    /// To detect disconnects early on the client side, you can also use heartbeats with a smaller interval.
    /// Use with caution, setting a low value (i.e. sending heartbeat very often) may cause an excessive network usage
    /// as well as high server load (with many clients).
    ///
    /// - Parameter milliseconds: interval in milliseconds; the default is 25 minutes (1 500 000 milliseconds),
    ///                           which is also the allowed maximum.
    /// - Throws: if value is not in the allowed range, e.g. larger than the maximum (1 500 000).
    func setHeartbeatInterval(milliseconds: UInt) throws

}
