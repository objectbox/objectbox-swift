//  Copyright © 2018 ObjectBox. All rights reserved.

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let string = representedObject as? String {
            textView.string = string
        }
    }

    override var representedObject: Any? {
        didSet {
            guard let representedObject = representedObject else { return }
            guard let string = representedObject as? String else { preconditionFailure("representedObject must be a String") }
            guard isViewLoaded else { return }
            textView.string = string
        }
    }
}
