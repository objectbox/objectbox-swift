//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

extension Store {
    /// Creates a new ObjectBox.Store in a temporary directory.
    static func createStore() throws -> Store {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: FileManager.SearchPathDomainMask.userDomainMask,
            appropriateFor: nil,
            create: true)
        return try Store(
            directoryPath: directory.path,
            maxDbSizeInKByte: 500,
            fileMode: 0o755,
            maxReaders: 10)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    var store: Store!
    lazy var authorBox: Box<Author> = self.store.box(for: Author.self)
    lazy var noteBox: Box<Note> = self.store.box(for: Note.self)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        try! setupStore()
        setupSplitViewController()
        setupContentViewControllers()
        
        return true
    }

    private func setupStore() throws {
        self.store = try Store.createStore()
        self.store.register(entity: Author.self)
        self.store.register(entity: Note.self)

        if noteBox.isEmpty && authorBox.isEmpty {
            try insertDemoNotes()
        }
    }

    private func insertDemoNotes() throws {
        let peterBrett = Author(name: "Peter V. Brett")
        let georgeMartin = Author(name: "George R. R. Martin")
        try authorBox.put([peterBrett, georgeMartin])

        try noteBox.put([
            Note(title: "Unclaimed idea", text: "This writing is not by anyone in particular."),
            peterBrett.writeNote(title: "The Warded Man", text: "I should make a movie from this book after writing the next novel."),
            peterBrett.writeNote(title: "Daylight War", text: "Who picked the cover art for this? It certainly wasn't me or someone else with taste."),
            georgeMartin.writeNote(title: "Game of Thrones", text: "This book title would've been a better choice than this Ice & Fire stuff all along. Boy, writing this takes long in DOS.")
            ])
    }

    private var splitViewController: UISplitViewController { return window!.rootViewController as! UISplitViewController }

    private func setupSplitViewController() {
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
    }

    private func setupContentViewControllers() {
        let masterViewController = (splitViewController.viewControllers[0] as! UINavigationController).topViewController as! MasterViewController
        masterViewController.noteBox = noteBox
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.note == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}
