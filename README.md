<img width="466" src="https://raw.githubusercontent.com/objectbox/objectbox-swift/master/images/logo.png">

Swift Database - swiftly persist objects on iOS and macOS
===============
[![Version](https://img.shields.io/cocoapods/v/ObjectBox.svg?style=flat)](#cocoapods)
[![Platform](https://img.shields.io/cocoapods/p/ObjectBox.svg?style=flat)](#cocoapods)

ObjectBox is a superfast, light-weight Swift database persisting Swift objects fast, easily, and fully ACID-compliant on-device on iOS and macOS.
On top, it comes with an [out-of-the-box Data Sync](https://objectbox.io/sync/) handling the complexity of occassionally connected devices, networking and conflict resolution code for you. Build apps that reliably sync between devices and any backend, offline on-premise or online with the Cloud.

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

High-performance Swift database
-------------
🏁 **High performance** on restricted devices, like IoT gateways, micro controllers, ECUs etc.\
🪂 **Resourceful** with minimal CPU, power and Memory usage for maximum flexibility and sustainability\
🔗 **Relations:** object links / relationships are built-in\
💻 **Multiplatform:** Linux, Windows, Android, iOS, macOS

🌱 **Scalable:** handling millions of objects resource-efficiently with ease\
💐 **Queries:** filter data as needed, even across relations\
🦮 **Statically typed:** compile time checks & optimizations\
📃 **Automatic schema migrations:** no update scripts needed

**And much more than just data persistence**\
👥 **[ObjectBox Sync](https://objectbox.io/sync/):** keeps data in sync between devices and servers\
🕒 **[ObjectBox TS](https://objectbox.io/time-series-database/):** time series extension for time based data

Enjoy ❤️

<a name="cocoapods"></a>Adding ObjectBox to your project
--------------------------------------------------------
[CocoaPods](https://cocoapods.org) is recommended to set up ObjectBox in your project.
See the [installation docs](https://swift.objectbox.io/install) for alternative setups,
or the [New to CocoaPods?](#new-to-cocoapods) section below for a quick intro.
To install the `ObjectBox` pod, add the following line to your Podfile:

```ruby
  pod 'ObjectBox'
```

Then run this to install the ObjectBox framework:

```bash
cd /path/to/your/project/folder/ # whatever folder your Podfile is in.
pod install
Pods/ObjectBox/setup.rb myproject.xcodeproj # whatever your Xcode project is named
```

And, don't forget to close the Xcode project (.xcodeproj) and open the workspace (.xcworkspace) instead.
Now, you are all set to define your first ObjectBox entities;
e.g. check the [getting started guide](https://swift.objectbox.io/getting-started) or the [example](#example) described below. 

### <a name="new-to-cocoapods"></a>New to CocoaPods?

[CocoaPods](https://cocoapods.org) is a dependency manager and sets up libraries like ObjectBox in your Xcode project.
To install it, run this in a terminal: 

```bash
sudo gem install cocoapods
```

In CocoaPods, you keep track of used libraries in a file called "Podfile".
If you don't have this file yet, navigate to your Xcode project folder and use CocoaPods to create one:

```bash
pod init
```

### CocoaPods troubleshooting

If `pod install` fails, try updating CocoaPods first:

    gem update xcodeproj && gem update cocoapods && pod repo update

### Swift versions

Here's a list of ObjectBox releases, and the Swift versions they were compiled with:

| ObjectBox version(s) | Swift version |
|:--------------------:|:-------------:|
|        1.5.0         |     5.3(.2)   |        
|        1.4.1         |      5.3      |        
|      1.3, 1.4.0      |      5.2      |        
|         1.2          |      5.1      |

This might be relevant, e.g. when using Carthage. For various reasons, we recommend using the latest version.

<a name="example"></a>Example
-----------------------------
In the [Example](Example/) directory, you'll find a "Notes" example app demonstrating ObjectBox's Swift API.
The example comes with two apps: one for iOS and one for macOS. The iOS example is a full GUI application, whereas the macOS example runs a few operations and then exits.

To setup the example, use CocoaPods to acquire the framework:

    cd Example/
    pod install # if that fails, update CocoaPods (see Installation)
    Pods/ObjectBox/setup.rb

This will generate a `NotesExample.xcworkspace` that you can launch to try out ObjectBox.

Background: code generation
---------------------------
ObjectBox Swift Database generates code at build time for optimal performance at runtime by avoiding reflection etc.
This is automatically done for you and should be transparent.
Internally, we use [a fork of Sourcery](https://github.com/objectbox/objectbox-swift-generator) for this.

Source code
-----------
Source code for ObjectBox's Swift binding can be found [in the Source folder](Source/README.md).

Cross-platform database: Mobile, Desktop, Browser, Embedded, IoT
------------------------
ObjectBox is a cross-platform database supporting [multiple native languages](https://objectbox.io/dev-get-started/): 

* [ObjectBox Java/Kotlin Database](https://github.com/objectbox/objectbox-java): runs on Android, desktop, and servers.
* [Golang Data Persistence](https://github.com/objectbox/objectbox-go): great for IoT, data-driven tools, and server applications. 
* [C and C++ Database](https://github.com/objectbox/objectbox-c): native speed with zero copy access to objects on embedded devices
  also enables porting ObjectBox to other languages.
* [Flutter/Dart Database](https://github.com/objectbox/objectbox-dart/): persist Dart objects & build cross-platform apps using Flutter.

How can I help ObjectBox?
---------------------------
We're on a mission to bring joy and delight to Mobile app developers.
We want ObjectBox not only to be the fastest Swift database, but also the swiftiest Swift data persistence, making you enjoy coding with ObjectBox.

To do that, we want your feedback: what do you love? What's amiss? Where do you struggle in everyday app development?

**We're looking forward to receiving your comments and requests:**

- Add [GitHub issues](https://github.com/ObjectBox/objectbox-swift/issues) 
- Upvote issues you find important by hitting the 👍/+1 reaction button
- Drop us a line via [@ObjectBox_io](https://twitter.com/ObjectBox_io/)
- ⭐ us, if you like what you see 

Thank you! 🙏

Keep in touch: For general news on ObjectBox, [check our blog](https://objectbox.io/blog)!

License
-------
All files in this repository are under the Apache 2 license:

    Copyright 2018-2021 ObjectBox Ltd. All rights reserved.
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

