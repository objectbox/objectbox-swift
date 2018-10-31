//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class AuthorsOverviewViewController: UITableViewController {

    @IBOutlet weak var createAuthorBarButtonItem: UIBarButtonItem!

    var authorEditingViewController: AuthorEditingViewController? = nil
    var authors = [Author]()

    var authorBox: Box<Author> = Services.instance.authorBox


    private var authorAddedSubscription: NotificationToken!
    private var authorNameChangeSubscription: NotificationToken!

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

        self.refreshAuthors()

        authorAddedSubscription = NotificationCenter.default.observe(name: .authorAdded, object: nil) { _ in
            self.refreshAuthors()
        }

        authorNameChangeSubscription = NotificationCenter.default.observe(name: .authorNameDidChange, object: nil) { _ in
            self.refreshAuthors()
        }
    }

    private func refreshAuthors() {
        authors = authorBox.all()
        guard let tableView = self.tableView else { return }
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    private func deleteAuthor(at index: Int) {
        let authorId = authors[index].id
        authors.remove(at: index)
        try! authorBox.remove(authorId)
        NotificationCenter.default.post(name: .authorRemoved, object: nil, userInfo: [ "authorId" : authorId.value ])
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
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

}
