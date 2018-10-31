//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class NotesOverviewViewontroller: UITableViewController {

    @IBOutlet var notesTableView: UITableView!
    var noteViewController: NoteViewController? = nil
    var notes = [Note]()

    var noteBox: Box<Note> = Services.instance.noteBox

    private func configureContent() {
        notes = noteBox.all()
        refreshNotes()
    }

    private var noteTitleChangeSubscription: NotificationToken!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            noteViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? NoteViewController
        }

        configureContent()

        noteTitleChangeSubscription = NotificationCenter.default.observe(name: .noteTitleDidChange, object: nil) { _ in
            self.refreshNotes()
        }
    }

    private func refreshNotes() {
        guard let notesTableView = notesTableView else { return }
        notesTableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
}

// MARK: - Segues

extension NotesOverviewViewontroller {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNote" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let note = notes[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! NoteViewController
                controller.note = note
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

}

// MARK: - Table View

extension NotesOverviewViewontroller {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let note = notes[indexPath.row]
        cell.textLabel!.text = note.title
        cell.detailTextLabel!.text = note.author.target?.name ?? ""
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

}
