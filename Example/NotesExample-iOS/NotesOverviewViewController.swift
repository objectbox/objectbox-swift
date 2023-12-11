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

        let authorId: Id?
        let query: Query<Note>
        var queryObserver: Observer?

        init(authorId: Id?, noteBox: Box<Note> = Services.instance.noteBox) {
            self.authorId = authorId?.value

            if let authorId = authorId {
                query = try! noteBox.query { Note.author.isEqual(to: authorId) }.build()
            } else {
                query = try! noteBox.query().build()
            }
        }

        func notes() -> [Note] {
            return try! query.find()
        }
    }

    func filterBy(authorId: Id?) {
        filter = Filter(authorId: authorId)
    }

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        filter.queryObserver = filter.query.subscribe { notes, _ in
            self.notes = notes
            guard let tableView = self.tableView else { return }
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        filter.queryObserver = nil
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
        } else if segue.identifier == "createNote" {
            let controller = (segue.destination as! UINavigationController).topViewController as! NoteEditingViewController
            controller.mode = .draft
            controller.note = {
                let draft = Note()
                draft.author.targetId = filter.authorId != nil ? EntityId<Author>(filter.authorId!) : nil
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
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

}
