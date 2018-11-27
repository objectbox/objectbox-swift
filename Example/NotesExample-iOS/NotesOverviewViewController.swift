//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class NotesOverviewViewController: UITableViewController {

    @IBOutlet weak var createNoteBarButtonItem: UIBarButtonItem!

    var noteViewController: NoteEditingViewController? = nil
    var notes = [Note]()

    var noteBox: Box<Note> = Services.instance.noteBox
    private lazy var filter: Filter = .all

    struct Filter {
        static var all: Filter { return Filter(authorId: nil) }

        let authorId: Id<Author>?
        let query: Query<Note>

        init(authorId: Id<Author>?, noteBox: Box<Note> = Services.instance.noteBox) {
            self.authorId = authorId

            if let authorId = authorId {
                query = noteBox.query { Note.author == authorId }
            } else {
                query = noteBox.query()
            }
        }

        func notes() -> [Note] {
            return query.find()
        }
    }

    func filterBy(authorId: Id<Author>?) {
        filter = Filter(authorId: authorId)
    }

    private var noteAddedSubscription: NotificationToken!
    private var noteRemovedSubscription: NotificationToken!
    private var noteTitleChangeSubscription: NotificationToken!
    private var noteAuthorChangeSubscription: NotificationToken!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [
            createNoteBarButtonItem,
            editButtonItem
        ]

        if let split = splitViewController {
            let controllers = split.viewControllers
            noteViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? NoteEditingViewController
        }

        refreshNotes()

        noteAddedSubscription = NotificationCenter.default.observe(name: .noteAdded, object: nil) { _ in
            self.refreshNotes()
        }

        noteRemovedSubscription = NotificationCenter.default.observe(name: .noteRemoved, object: nil) { notification in
            guard notification.object as AnyObject !== self else { return }
            self.refreshNotes()
        }

        noteTitleChangeSubscription = NotificationCenter.default.observe(name: .noteTitleDidChange, object: nil) { _ in
            self.refreshNotes()
        }

        noteAuthorChangeSubscription = NotificationCenter.default.observe(name: .noteAuthorDidChange, object: nil) { _ in
            self.refreshNotes()
        }
    }

    private func refreshNotes() {
        notes = filter.notes()
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
        NotificationCenter.default.post(name: .noteRemoved, object: self, userInfo: [ "noteId" : noteId.value ])
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
        } else if segue.identifier == "createNote" {
            let controller = (segue.destination as! UINavigationController).topViewController as! NoteEditingViewController
            controller.mode = .draft
            controller.note = {
                let draft = Note()
                draft.author.targetId = filter.authorId
                draft.modificationDate = Date()
                return draft
            }()
        }
    }

    @IBAction func unwindFromDraftingNote(segue: UIStoryboardSegue) {
        // Same action name as in `MasterViewController` to intercept the action/response
        // and unwind to this scene when it was presented from here.
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
