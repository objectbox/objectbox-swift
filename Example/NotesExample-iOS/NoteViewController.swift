//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

extension Notification.Name {
    static var noteTitleDidChange: Notification.Name { return .init("OB_NoteTitleDidChange") }
}

class NoteViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!

    var noteBox: Box<Note> = Services.instance.noteBox

    func configureView() {
        guard let note = note else { return }

        self.navigationItem.title = note.title

        if let contentTextView = contentTextView {
            contentTextView.text = note.text
        }
    }

    /// Model object.
    var note: Note? {
        didSet {
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rename", style: .plain, target: self, action: #selector(renameNote))

        contentTextView.delegate = self
        configureView()
    }
}

// MARK: - Rename Note

extension NoteViewController {

    @objc
    func renameNote(_ sender: Any?) {
        guard let note = note else { return }

        let alertController = UIAlertController.init(title: "Change Note Title", message: nil, preferredStyle: .alert)

        alertController.addTextField {
            $0.placeholder = "Title"
            $0.text = note.title
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let renameAction = UIAlertAction(title: "Rename", style: .default) { _ in
            guard let textField = alertController.textFields?.first else { return }
            guard let newTitle = textField.text else { return }
            self.changeNoteTitle(to: newTitle)
        }
        alertController.addAction(renameAction)

        present(alertController, animated: true, completion: nil)
    }

    func changeNoteTitle(to newTitle: String) {
        guard let note = self.note else { return }

        let oldTitle = note.title
        note.title = newTitle
        try! noteBox.put(note)

        configureView()

        NotificationCenter.default.post(
            name: .noteTitleDidChange,
            object: note,
            userInfo: [ "oldValue" : oldTitle, "newValue" : newTitle])
    }
}

// MARK: - Change Note Text

extension NoteViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        note?.text = textView.text
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let note = self.note else { return }
        try! noteBox.put(note)
    }

}
