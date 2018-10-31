//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit

class AuthorCreationViewController: UITableViewController {

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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        authorDraft.name = textField.text ?? ""
        return true
    }

}

// MARK: - Navigation

extension AuthorCreationViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cancelAuthorDraft" {
            authorDraft = Author()
        } else if segue.identifier == "saveAuthorDraft" {
            let authorId = try! Services.instance.authorBox.put(authorDraft)
            NotificationCenter.default.post(name: .authorAdded, object: authorDraft, userInfo: [ "authorId" : authorId.value ])
        }
    }

}
