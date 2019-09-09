//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit

class AuthorCreationViewController: UITableViewController {

    @IBOutlet weak var authorNameTextField: UITextField!

    var authorDraft: Author!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.authorDraft = Author()
    }

}

// MARK: - Name Author

extension AuthorCreationViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        authorDraft.name = textField.text ?? ""
    }

}

// MARK: - Navigation

extension AuthorCreationViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Commit editing the author name before leaving
        if authorNameTextField.isFirstResponder { authorNameTextField.resignFirstResponder() }

        if segue.identifier == "cancelAuthorDraft" {
            authorDraft = Author()
        } else if segue.identifier == "saveAuthorDraft" {
            try! Services.instance.authorBox.put(authorDraft)
        }
    }

}
