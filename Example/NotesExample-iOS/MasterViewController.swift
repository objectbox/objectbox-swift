//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class MasterViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNote(_:)))
        navigationItem.rightBarButtonItem = addButton

    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func createNote(_ sender: Any?) {
        
    }
}

// MARK: - Segues

extension MasterViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNotes" {
            // no op
        }
    }

}
