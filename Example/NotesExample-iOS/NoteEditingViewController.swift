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

    func configureNavigationItemsForMode() {
        guard isViewLoaded else { return }

        switch mode {
        case .edit:
            navigationItem.leftBarButtonItem = splitViewController!.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true

            navigationItem.rightBarButtonItem = nil

        case .draft:
            navigationItem.leftBarButtonItem = cancelDraftBarButtonItem
            navigationItem.leftItemsSupplementBackButton = false

            navigationItem.rightBarButtonItem = saveDraftBarButtonItem
        }
    }
    
    @IBOutlet weak var cancelDraftBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveDraftBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorPickerView: UIPickerView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var modificationDateLabel: UILabel!
    
    lazy var authorModel: AuthorModel = AuthorModel(authorBox: Services.instance.authorBox)
    var noteBox: Box<Note> = Services.instance.noteBox

    func configureView() {
        guard let note = note else { return }

        self.navigationItem.title = mode == .edit ? note.title : "Create Note"

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

        self.refreshCreationDate()
        self.refreshModificationDate()
    }

    private func refreshCreationDate() {
        guard let creationDateLabel = creationDateLabel, let note = note else { return }

        var dateString: String?
        if let creationDate = note.creationDate {
            dateString = DateFormatter.localizedString(from: creationDate, dateStyle: .short, timeStyle: .short)
        }
        creationDateLabel.text = dateString ?? "--"
    }

    private func refreshModificationDate() {
        guard let modificationDateLabel = modificationDateLabel, let note = note else { return }
        
        var dateString: String?
        if let modificationDate = note.modificationDate {
            dateString = DateFormatter.localizedString(from: modificationDate, dateStyle: .short, timeStyle: .short)
        }
        modificationDateLabel.text = dateString ?? "--"
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

    override func viewWillAppear(_ animated: Bool) {
        configureNavigationItemsForMode()
        super.viewWillAppear(animated)
    }
}

// MARK: Drafting Notes

extension NoteEditingViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Commit editing changes before leaving
        if titleTextField.isFirstResponder { titleTextField.resignFirstResponder() }
        if contentTextView.isFirstResponder { contentTextView.resignFirstResponder() }

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

        note.title = newTitle

        // Do not autosave drafts
        guard self.mode == .edit else { return }

        try! noteBox.put(note)

        refreshModificationDate()
    }
}

// MARK: - Change Author

extension NoteEditingViewController: UIPickerViewDelegate  {

    struct AuthorModel {
        private let authors: [Author]
        let pickerItems: [String]

        init(authorBox: Box<Author>) {
            self.authors = try! authorBox.all().sorted(by: { $0.name < $1.name })
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
            guard let authorIndex = authors.firstIndex(where: { $0.id == authorId.value }) else { return 0 }
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
        note.modificationDate = Date()

        // Do not autosave drafts
        guard self.mode == .edit else { return }

        try! noteBox.put(note)

        refreshModificationDate()
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
        refreshModificationDate()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Do not autosave drafts
        guard self.mode == .edit else { return }
        guard let note = self.note else { return }
        try! noteBox.put(note)
    }

}
