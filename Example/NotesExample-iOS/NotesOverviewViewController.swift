//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class NotesOverviewViewController: UITableViewController {

    var noteViewController: NoteEditingViewController? = nil
    var notes = [Note]()

    var noteBox: Box<Note> = Services.instance.noteBox
    private lazy var query: Query<Note> = self.noteBox.query()

    func filterBy(authorId: Id<Author>?) {
        if let authorId = authorId {
            query = noteBox.query { Note.authorId == authorId }
        } else {
            query = self.noteBox.query()
        }
    }

    private func configureContent() {
        notes = query.find()
        refreshNotes()
    }

    private var noteTitleChangeSubscription: NotificationToken!
    private var noteAuthorChangeSubscription: NotificationToken!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            noteViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? NoteEditingViewController
        }

        configureContent()

        noteTitleChangeSubscription = NotificationCenter.default.observe(name: .noteTitleDidChange, object: nil) { _ in
            self.refreshNotes()
        }

        noteAuthorChangeSubscription = NotificationCenter.default.observe(name: .noteAuthorDidChange, object: nil) { _ in
            self.refreshNotes()
        }
    }

    private func refreshNotes() {
        guard let tableView = self.tableView else { return }
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    private func deleteNote(at index: Int) {
        let noteId = notes[index].id
        notes.remove(at: index)
        try! noteBox.remove(noteId)
    }

}

// MARK: - Segues

extension NotesOverviewViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNote" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let note = notes[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! NoteEditingViewController
                controller.mode = .edit
                controller.note = note
            }
        }
    }

}

// MARK: - Table View

extension NotesOverviewViewController {

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
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNote(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

}
