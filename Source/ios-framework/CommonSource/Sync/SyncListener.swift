//
// Copyright (c) 2020 ObjectBox. All rights reserved.
//

/// Listens to login events.
public protocol SyncLoginListener {
    /// Called on a successful login.
    /// 
    /// At this point the connection to the sync destination was established and
    /// entered an operational state, in which data can be sent both ways.
    func loggedIn()

    /// Called on a login failure with a `result` code specifying the issue.
    func loginFailed(result: SyncCode)
}

/// Listens to sync completed events.
public protocol SyncCompletedListener {
    /// Called each time a sync was "completed", in the sense that the client 
    /// caught up with the current server state. The client is "up-to-date".
    func updatesCompleted()
}

/// A collection of changes made to one entity type during a sync transaction.
/// Delivered via `SyncChangeListener`.
/// 
/// IDs of changed objects are available via `puts` and those of removed objects via `removals`.
public struct SyncChange {
    /// IDs of objects that have been changed; e.g. have been put/updated/inserted.
    var puts = [Id]()
    /// IDs of objects that have been removed.
    var removals = [Id]()
}

/// Notifies of fine granular changes on the object level happening during sync.
///
/// - Note: Enabling fine granular notification can slightly reduce performance.
///
/// See also `SyncCompletedListener` for the general sync listener.
public protocol SyncChangeListener {
//    /// Called each time when data `changes` from sync were applied locally.
//    func changed(_ changes: [obx_schema_id: SyncChange])
}

/// Listens to sync connection events.
public protocol SyncConnectionListener {
    /// 
    func connected()
    /// Called when the client is disconnected from the sync server, e.g. due to a network error.
    /// 
    /// Depending on the configuration, the sync client typically tries to reconnect automatically,
    /// triggering a `SyncLoginListener` again.
    func disconnected()
}

/// Listens to all possible sync events. See each protocol for detailed information.
public protocol SyncListener: SyncLoginListener, SyncCompletedListener, SyncChangeListener, SyncConnectionListener {

}
