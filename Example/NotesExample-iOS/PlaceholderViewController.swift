//  Copyright © 2018 ObjectBox. All rights reserved.

import UIKit

class PlaceholderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
    }
    
    @IBAction func unwindToPlaceholder(segue: UIStoryboardSegue) {
        // no op
    }

}
