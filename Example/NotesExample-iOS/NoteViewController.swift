//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

extension Notification.Name {
    static var noteTitleDidChange: Notification.Name { return .init("OB_NoteTitleDidChange") }
}

class NoteViewController: UITableViewController {

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

// MARK: - Rename Note

extension NoteViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        let title = textField.text ?? ""
        changeNoteTitle(to: title)
    }

    func changeNoteTitle(to newTitle: String) {
        guard let note = self.note else { return }

        let oldTitle = note.title
        note.title = newTitle
        try! noteBox.put(note)

        NotificationCenter.default.post(
            name: .noteTitleDidChange,
            object: note,
            userInfo: [ "oldValue" : oldTitle, "newValue" : newTitle])
    }
}

// MARK: - Change Author

extension NoteViewController: UIPickerViewDelegate  {

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
        note.author.target = newAuthor
        try! noteBox.put(note)
    }
}

extension NoteViewController: UIPickerViewDataSource {

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

extension NoteViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        note?.text = textView.text
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let note = self.note else { return }
        try! noteBox.put(note)
    }

}
