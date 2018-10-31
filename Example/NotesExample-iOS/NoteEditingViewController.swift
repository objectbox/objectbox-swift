//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class NoteEditingViewController: UITableViewController {

    enum Mode {
        case edit, draft
    }

    var mode: Mode = .edit {
        didSet {
            configureNavigationItemsForMode()
        }
    }

    
    @IBOutlet weak var cancelDraftBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveDraftBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorPickerView: UIPickerView!
    @IBOutlet weak var contentTextView: UITextView!

    lazy var authorModel: AuthorModel = AuthorModel(authorBox: Services.instance.authorBox)
    var noteBox: Box<Note> = Services.instance.noteBox

    func configureView() {
        guard let note = note else { return }

        self.navigationItem.title = note.title

        if let tableView = tableView {
            tableView.reloadData()
        }

        if let authorPickerView = authorPickerView {
            refreshAuthors()
            authorPickerView.reloadAllComponents()
            authorPickerView.selectRow(authorModel.selectedPickerRow(for: note), inComponent: 0, animated: false)
        }

        if let titleTextField = titleTextField {
            titleTextField.text = note.title
        }

        if let contentTextView = contentTextView {
            contentTextView.text = note.text
        }
    }

    func configureNavigationItemsForMode() {
        switch mode {
        case .edit:
            navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true

            navigationItem.rightBarButtonItem = nil

        case .draft:
            navigationItem.leftBarButtonItem = cancelDraftBarButtonItem
            navigationItem.leftItemsSupplementBackButton = false

            navigationItem.rightBarButtonItem = saveDraftBarButtonItem
        }
    }

    private func refreshAuthors() {
        self.authorModel = AuthorModel(authorBox: Services.instance.authorBox)
    }

    /// Model object.
    var note: Note? {
        didSet {
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
}

// MARK: Drafting Notes

extension NoteEditingViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cancelDraft" {
            self.note = nil
        } else if segue.identifier == "saveDraft" {
            guard let note = self.note else { preconditionFailure() }
            try! noteBox.put(note)
        }
    }

}

// MARK: - Rename Note

extension NoteEditingViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        let title = textField.text ?? ""
        changeNoteTitle(to: title)
    }

    func changeNoteTitle(to newTitle: String) {
        guard let note = self.note else { return }

        let oldTitle = note.title
        note.title = newTitle

        // Do not autosave drafts
        guard self.mode == .edit else { return }

        try! noteBox.put(note)

        NotificationCenter.default.post(
            name: .noteTitleDidChange,
            object: note,
            userInfo: [ "oldValue" : oldTitle, "newValue" : newTitle])
    }
}

// MARK: - Change Author

extension NoteEditingViewController: UIPickerViewDelegate  {

    struct AuthorModel {
        private let authors: [Author]
        let pickerItems: [String]

        init(authorBox: Box<Author>) {
            self.authors = authorBox.all().sorted(by: { $0.name < $1.name })
            self.pickerItems = authors
                .map { $0.name }
                .prepending("(None)")
        }

        func author(pickerRow: Int) -> Author? {
            if pickerRow == 0 {
                return nil
            } else {
                return authors[pickerRow - 1]
            }
        }

        func title(pickerRow: Int) -> String {
            return pickerItems[pickerRow]
        }

        func selectedPickerRow(for note: Note) -> Int {
            guard let authorId = note.author.targetId else { return 0 }
            guard let authorIndex = authors.firstIndex(where: { $0.id == authorId }) else { return 0 }
            return authorIndex + 1
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickedAuthor = authorModel.author(pickerRow: row)
        changeNoteAuthor(to: pickedAuthor)
    }

    func changeNoteAuthor(to newAuthor: Author?) {
        guard let note = self.note else { return }

        let oldAuthorId = note.author.targetId
        note.author.target = newAuthor

        // Do not autosave drafts
        guard self.mode == .edit else { return }

        try! noteBox.put(note)

        let changeUserInfo: [String: Any] = {
            var result: [String: Any] = [:]
            if let oldAuthorId = oldAuthorId {
                result["oldValue"] = oldAuthorId.value
            }
            if let newAuthorId = newAuthor?.id {
                result["newValue"] = newAuthorId.value
            }
            return result
        }()

        NotificationCenter.default.post(
            name: .noteAuthorDidChange,
            object: note,
            userInfo: changeUserInfo)
    }
}

extension NoteEditingViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return authorModel.pickerItems.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        precondition(component == 0)
        return authorModel.title(pickerRow: row)
    }

}

// MARK: - Change Note Text

extension NoteEditingViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        note?.text = textView.text
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Do not autosave drafts
        guard self.mode == .edit else { return }
        guard let note = self.note else { return }
        try! noteBox.put(note)
    }

}
