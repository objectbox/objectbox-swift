
ObjectBox iOS Example
=====================

ObjectBox is a superfast, light-weight object persistence framework for iOS and macOS. This repository includes a notes example app for iOS that demonstrates ObjectBox's Swift API.

- **[Read the guides](https://swift.objectbox.io/)** for detailed explanations
- [Check out the code on GitHub][swiftrepo]
- [Visit our blog](https://objectbox.io/blog)

[swiftrepo]: https://github.com/ObjectBox/objectbox-swift
[obio]: https://objectbox.io/

Building
--------

The Example can be found in the  `Example/` subfolder, and uses CocoaPods to acquire the framework:

    cd Example/
    pod install

This will generate a `NotesExample.xcworkspace` that you can launch to try out ObjectBox.

Entity Files
------------

You do not have to add the runtime info needed for serializing Objects to the database yourself. The project is automatically set up so it will use Sourcery to generate the required EntityInfo extensions on your Entity subclasses.

