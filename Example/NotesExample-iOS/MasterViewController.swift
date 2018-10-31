//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class MasterViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
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
