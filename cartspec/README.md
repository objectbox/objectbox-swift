ObjectBox Carthage Binary Project Specification
===============================================
This folder contains [ObjectBox.json](ObjectBox.json), a [Chartage "index" for binary frameworks](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#binary-project-specification).
The advantage of using binary distribution is that those are slimmer than the "github" definition.
Using "binary" instead, never causes Carthage to check out the Git repository.
Thus updates are faster and less disk space is used.

Add binary ObjectBox dependency
-------------------------------
In your Cartfile, you typically add a line like this:

    binary "https://raw.githubusercontent.com/objectbox/objectbox-swift/master/cartspec/ObjectBox.json"

For details and up-to-date information, please consult the [installation docs](https://swift.objectbox.io/install).