//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit
import ObjectBox

class DetailViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!

    var noteBox: Box<Note> = Services.instance.noteBox

    func configureView() {
        if  let note = note,
            let contentTextView = contentTextView {
            contentTextView.text = note.text
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentTextView.delegate = self

        configureView()
    }

    var note: Note? {
        didSet {
            configureView()
        }
    }

}

extension DetailViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        note?.text = textView.text
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let note = self.note else { return }
        try! noteBox.put(note)
    }

}
