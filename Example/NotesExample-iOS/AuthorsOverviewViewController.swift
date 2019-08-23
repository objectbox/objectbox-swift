//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class AuthorsOverviewViewController: UITableViewController {

    @IBOutlet weak var createAuthorBarButtonItem: UIBarButtonItem!

    var authorEditingViewController: AuthorEditingViewController? = nil
    var authors = [Author]()

    var authorBox: Box<Author> = Services.instance.authorBox
    private var authorBoxObserver: Observer?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [
            createAuthorBarButtonItem,
            editButtonItem
        ]

        if let split = splitViewController {
            let controllers = split.viewControllers
            authorEditingViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? AuthorEditingViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        authorBoxObserver = authorBox.subscribe { authors, _ in
            self.authors = authors
            guard let tableView = self.tableView else { return }
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authorBoxObserver = nil
    }

    private func deleteAuthor(at index: Int) {
        let authorId = authors[index].id
        try! authorBox.remove(authorId)
    }

}

// MARK: - Segues

extension AuthorsOverviewViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAuthor" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let author = authors[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! AuthorEditingViewController
                controller.author = author
            }
        }
    }

    @IBAction func unwindFromDraftingAuthor(segue: UIStoryboardSegue) {
        // no op
    }

}

// MARK: - Table View

extension AuthorsOverviewViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AuthorCell", for: indexPath)

        let author = authors[indexPath.row]
        cell.textLabel!.text = author.name
        cell.detailTextLabel!.text = "\(author.notes.count) Notes"

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteAuthor(at: indexPath.row)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

}
