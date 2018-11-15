ObjectBox iOS Example
=====================

[![Version](https://img.shields.io/cocoapods/v/ObjectBox.svg?style=flat)](https://cocoapods.org/pods/ObjectBox)
[![License](https://img.shields.io/cocoapods/l/ObjectBox.svg?style=flat)](https://cocoapods.org/pods/ObjectBox)
[![Platform](https://img.shields.io/cocoapods/p/ObjectBox.svg?style=flat)](https://cocoapods.org/pods/ObjectBox)

ObjectBox is a superfast, light-weight object persistence framework for iOS and macOS. This repository includes a notes example app for iOS that demonstrates ObjectBox's Swift API.

- **[Read the guides](https://swift.objectbox.io/)** for detailed explanations
- **[Check out the API docs](http://objectbox.io/docfiles/swift/current/)**
- [Visit our blog](https://objectbox.io/blog)

Installation
------------

ObjectBox is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ObjectBox'
```

Then run `pod install` afterwards to install the framework and its dependencies.

Example
-------

The Example can be found in the  `Example/` subfolder, and uses CocoaPods to acquire the framework:

    cd Example/
    pod install

This will generate a `NotesExample.xcworkspace` that you can launch to try out ObjectBox.

Entity Files
------------

You do not have to add the runtime info needed for serializing Objects to the database yourself. The project is automatically set up so it will use Sourcery to generate the required EntityInfo extensions on your Entity subclasses.

