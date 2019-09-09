//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class AuthorEditingViewController: UITableViewController {

    var authorBox: Box<Author> = Services.instance.authorBox

    var author: Author? = nil {
        didSet {
            configureView()
        }
    }

    @IBOutlet weak var authorNameTextField: UITextField!
    @IBOutlet weak var noteCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    private func configureView() {
        guard let author = author else { return }

        if let tableView = tableView {
            tableView.reloadData()
        }

        if let authorNameTextField = authorNameTextField {
            authorNameTextField.text = author.name
        }

        if let noteCountLabel = noteCountLabel {
            noteCountLabel.text = "\(author.notes.count) Notes"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItem = splitViewController!.displayModeButtonItem
        super.viewWillAppear(animated)
    }

}

// MARK: - Navigation

extension AuthorEditingViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Commit editing the author name before leaving
        if authorNameTextField.isFirstResponder { authorNameTextField.resignFirstResponder() }

        if segue.identifier == "showAuthorNotes" {
            guard let authorId = self.author?.id else { return }
            let controller = segue.destination as! NotesOverviewViewController
            controller.filterBy(authorId: authorId)
        }
    }

}

// MARK: - Rename Author

extension AuthorEditingViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        let name = textField.text ?? ""
        renameAuthor(to: name)
    }

    func renameAuthor(to newName: String) {
        guard let author = self.author else { return }

        author.name = newName
        try! authorBox.put(author)
    }
}
