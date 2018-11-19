<img width="466" src="https://raw.githubusercontent.com/objectbox/objectbox-swift/master/images/logo.png">

ObjectBox Swift (Alpha)
=======================

[![Version](https://img.shields.io/cocoapods/v/ObjectBox.svg?style=flat)](https://cocoapods.org/pods/ObjectBox)
[![Platform](https://img.shields.io/cocoapods/p/ObjectBox.svg?style=flat)](https://cocoapods.org/pods/ObjectBox)

ObjectBox is a superfast, light-weight object persistence framework.
This Swift API seamlessly persists objects on-device for iOS and macOS.

```swift
let santa = Person(firstName: "Santa", lastName: "Claus")
try personBox.put(santa)

let query: Query<Person> = personBox.query {
    return (Person.firstName.contains("Santa") || Person.age > 100)
           && Person.lastName.isEqual(to: "Claus") 
}
let oldClauses = query.find()
```

Want details? **[Read the guides](https://swift.objectbox.io/)** or
**[check out the API docs](https://objectbox.io/docfiles/swift/current/)**.

Installation
------------

ObjectBox is available through [CocoaPods](https://cocoapods.org).
To install the [pod](https://cocoapods.org/pods/ObjectBox), simply add the following line to your Podfile:

```ruby
pod 'ObjectBox'
```

Then run `pod install` afterwards to install the framework and its dependencies.

Example
-------
In the [Example](Example/) directory, you find a notes example app demonstrating ObjectBox's Swift API.
The example comes with two apps: one for iOS and one for macOS.

To setup the example, use CocoaPods to acquire the framework:

    cd Example/
    pod install

This will generate a `NotesExample.xcworkspace` that you can launch to try out ObjectBox.

Why We Released this Preview
----------------------------

Because your feedback is paramount!
We want ObjectBox not only to be the fastest, but also to be the most Swift-friendly persistence solution.
By releasing it early we can still make adjustments based on your input.

Thus, this preview is really all about you: what do you love? What's amiss?
Where do you struggle in everyday app development?

We're looking forward to receive your comments and requests:

- Take this [short questionaire](https://docs.google.com/forms/d/e/1FAIpQLSd0neiviD0Yal0Tn7921w-XWI2d0ONpLm7TfVKp7OvwW2Tu2A/viewform?usp=sf_link) (takes only 1 or 2 minutes)
- Add [GitHub issues](https://github.com/ObjectBox/objectbox-swift/issues) and 
- Upvote issues you find important by hitting the 👍/+1 reaction button!

Thank you!

What's Missing in the Alpha?
----------------------------

_ObjectBox Swift Alpha_ is a developer preview. 
**It is not ready for production use yet!**
Consider the following limitations:

- No binary compatibility of your on-disk data with future versions. 
- No model migrations: once you persist an entity with 2 properties, you cannot simply add a 3rd property.
  You have to reset the store (e.g. delete the database files) to start from scratch.
- Incomplete functionality: missing relation types, indexes, data observers, object browser.
  This functionality is available at lower layers and has not yet been exposed to Swift.

Keep in touch
-------------
We're obviously not finished here.
[Sign up here](https://objectbox.io/ios-alpha/) for future updates on ObjectBox Swift.

For general news on ObjectBox, [check our blog](https://objectbox.io/blog).

Background: Code generation
---------------------------
ObjectBox Swift generates code at build time for optimal performance at runtime by avoiding reflection etc.
This is automatically done for you and should be transparent. Internally, we use Sourcery for this.

Other languages/bindings
------------------------
ObjectBox is a multi platform database supporting [multiple languages](https://objectbox.io/dev-get-started/): 

* [ObjectBox C API](https://github.com/objectbox/objectbox-c): native speed with zero copy access to FlatBuffer objects;
  also enables porting ObjectBox to other languages.
* [ObjectBox Java](https://github.com/objectbox/objectbox-java): runs on Android, desktop and even servers.

License
-------
All files in this repository are under the Apache 2 license:

    Copyright 2018 ObjectBox Ltd. All rights reserved.
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

