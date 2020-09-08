//  Copyright © 2020 ObjectBox. All rights reserved.

/// Main API for client sync; create an instance via Sync.makeClient().
/// The sync client will start trying to connect after start() is called.
public protocol SyncClient: class {

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
    func requestUpdates() throws

    /// If automatic updates have been turned off via `updateRequestMode`, this allows manual interaction:
    /// requests the latest updates from the server and subscribes for future updates, which the server will "push".
    /// Note: use `cancelUpdates()` to stop receiving further updates (pushes).
    func requestUpdatesAndSubscribe() throws

    /// Requests the server to stop sending updates.
    /// Use `requestUpdates()` or `requestUpdatesAndSubscribe()` to request updates again.
    func cancelUpdates() throws

    /// Experimental/Advanced API: requests a sync of all previous changes from the server.
    func fullSync() throws

}
