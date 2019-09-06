//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class MasterViewController: UITableViewController {

    lazy var noteBox: Box<Note> = Services.instance.noteBox
    lazy var authorBox: Box<Author> = Services.instance.authorBox

    private var noteAddedSubscription: NotificationToken!
    private var noteRemovedSubscription: NotificationToken!
    private var authorRemovedSubscription: NotificationToken!
    private var authorAddedSubscription: NotificationToken!

    override func viewDidLoad() {
        super.viewDidLoad()

        clearsSelectionOnViewWillAppear = true
        
        noteAddedSubscription = NotificationCenter.default.observe(name: .noteAdded, object: nil) { _ in
            self.tableView.reloadData()
        }

        noteRemovedSubscription = NotificationCenter.default.observe(name: .noteRemoved, object: nil) { _ in
            self.tableView.reloadData()
        }

        authorAddedSubscription = NotificationCenter.default.observe(name: .authorAdded, object: nil) { _ in
            self.tableView.reloadData()
        }

        authorRemovedSubscription = NotificationCenter.default.observe(name: .authorRemoved, object: nil) { _ in
            self.tableView.reloadData()
        }
    }

    @IBAction func replaceWithDemoData(_ sender: Any?) {
        try! Services.instance.replaceWithDemoData()
        tableView.reloadData()
    }
}

// MARK: - Table View

extension MasterViewController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = "\(noteBox.count())"
            } else if indexPath.row == 1 {
                cell.detailTextLabel?.text = "\(authorBox.count())"
            }
        }

        return cell
    }
}

// MARK: - Segues

extension MasterViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNotes" {
            let controller = segue.destination as! NotesOverviewViewController
            controller.filterBy(authorId: nil)
        } else if segue.identifier == "createNote" {
            let controller = (segue.destination as! UINavigationController).topViewController as! NoteEditingViewController
            controller.mode = .draft
            controller.note = Note()
        }
    }

    @IBAction func unwindFromDraftingNote(segue: UIStoryboardSegue) {
        // no op
    }
    
}
