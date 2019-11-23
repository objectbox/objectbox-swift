ObjectBox Example
=================
The "Notes" example app demonstrate ObjectBox's Swift API.
The example comes with two apps: one for iOS and one for macOS. The iOS example is a full GUI application, whereas the macOS example runs a few operations and then exits.

Example setup
-------------
Just like in any other project, you need te setup CocoaPods and ObjectBox.
Simply run `./setup.sh` inside this directory, or copy paste this into a terminal:

    pod install # if that fails, update CocoaPods (see Installation)
    Pods/ObjectBox/setup.rb

This will generate a `NotesExample.xcworkspace` that you can launch to try out ObjectBox.

Updating to newer ObjectBox versions
------------------------------------
    pod repo update
    pod update
    Pods/ObjectBox/setup.rb