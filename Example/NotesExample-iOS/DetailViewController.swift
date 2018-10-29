//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!

    func configureView() {
        if  let note = note,
            let contentTextView = contentTextView {
            contentTextView.text = note.text
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    var note: Note? {
        didSet {
            configureView()
        }
    }

}
