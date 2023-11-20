ObjectBox Example
=================
The "Notes" example app demonstrate ObjectBox's Swift API.
The example comes with two apps: one for iOS and one for macOS. The iOS example is a full GUI application, whereas the macOS example runs a few operations and then exits.

Example setup
-------------
Just like in any other project, you need to set up CocoaPods and ObjectBox.
Simply run `./setup.sh` inside this directory, or run these commands in a terminal:

    pod install --repo-update # if that fails, update CocoaPods (see Installation)
    Pods/ObjectBox/setup.rb

This will generate a `NotesExample.xcworkspace` that you can launch to try out ObjectBox.
