<img width="466" src="https://raw.githubusercontent.com/objectbox/objectbox-swift/master/images/logo.png">

ObjectBox Swift
===============
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
}.build()
let oldClauses = query.find()
```

Want details? **[Read the guides](https://swift.objectbox.io/)** or
**[check out the API docs](https://objectbox.io/docfiles/swift/current/)**.

Installation
------------
[CocoaPods](https://cocoapods.org) is recommended to set up ObjectBox in your project.
See the [installation docs](https://swift.objectbox.io/install) for alternative setups,
or the [New to CocoaPods?](#new-to-cocoapods) section below for a quick intro.
To install the [ObjectBox pod](https://cocoapods.org/pods/ObjectBox), add the following line to your Podfile:

```ruby
pod 'ObjectBox'
```

Then run this to install the ObjectBox framework:

```bash
cd /path/to/your/project/folder/ # whatever folder your Podfile is in.
pod install
Pods/ObjectBox/setup.rb myproject.xcodeproj # whatever your Xcode project is named
```

Now you are all set to define your first ObjectBox entities;
e.g. check the [getting started guide] or the [example](#example) described below. 

### <a name="new-to-cocoapods"></a>New to CocoaPods?

[CocoaPods](https://cocoapods.org) it is a dependency manager and sets up libraries like ObjectBox in your xcode project.
To install it, run this in a terminal: 

```bash
sudo gem install cocoapods
```

In CocoaPods, you keep track of used libraries in a file called "Podfile".
If you don't have this file yet, navigate to your xcode project folder and use CocoaPod to create one:

```bash
pod init
```

### CocoaPods troubleshooting

If `pod install` fails, try updating CocoaPods first:

    gem update xcodeproj && gem update cocoapods && pod repo update

<a name="example"></a>Example
-----------------------------
In the [Example](Example/) directory, you find a notes example app demonstrating ObjectBox's Swift API.
The example comes with two apps: one for iOS and one for macOS.

To setup the example, use CocoaPods to acquire the framework:

    cd Example/
    pod install # if that fails, update CocoaPods (see Installation)
    Pods/ObjectBox/setup.rb

This will generate a `NotesExample.xcworkspace` that you can launch to try out ObjectBox.

How can ObjectBox Help You?
---------------------------
We want ObjectBox to be not only the fastest, but also the most Swift-friendly persistence solution.

To do that, we want your feedback: what do you love? What's amiss?
Where do you struggle in everyday app development?

We're looking forward to receiving your comments and requests:

- Take this [short questionaire](https://docs.google.com/forms/d/e/1FAIpQLSd0neiviD0Yal0Tn7921w-XWI2d0ONpLm7TfVKp7OvwW2Tu2A/viewform?usp=sf_link) (takes only 1 or 2 minutes)
- Add [GitHub issues](https://github.com/ObjectBox/objectbox-swift/issues) and 
- Upvote issues you find important by hitting the 👍/+1 reaction button!

Thank you!

Keep in touch
-------------
We're obviously not finished here.
[Sign up here](https://objectbox.io/ios-alpha/) for future updates on ObjectBox Swift.

For general news on ObjectBox, [check our blog](https://objectbox.io/blog).

Background: code generation
---------------------------
ObjectBox Swift generates code at build time for optimal performance at runtime by avoiding reflection etc.
This is automatically done for you and should be transparent.
Internally, we use [a fork of Sourcery](https://github.com/objectbox/objectbox-swift-generator) for this.

Source code
-----------
Source code for ObjectBox's Swift binding can be found [in the Source folder](Source/README.md).

Other languages/bindings
------------------------
ObjectBox is a multi platform database supporting [multiple languages](https://objectbox.io/dev-get-started/): 

* [ObjectBox C API](https://github.com/objectbox/objectbox-c): native speed with zero copy access to FlatBuffer objects;
  also enables porting ObjectBox to other languages.
* [ObjectBox Java](https://github.com/objectbox/objectbox-java): runs on Android, desktop and even servers.

License
-------
All files in this repository are under the Apache 2 license:

    Copyright 2018-2019 ObjectBox Ltd. All rights reserved.
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

