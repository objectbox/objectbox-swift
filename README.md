<p align="center">
 <img width="466" src="https://raw.githubusercontent.com/objectbox/objectbox-swift/master/images/logo.png">
</p>

<p align="center">
  <a href="https://swift.objectbox.io/getting-started">Getting Started</a> •
  <a href="https://swift.objectbox.io">Documentation</a> •
  <a href="https://github.com/objectbox/objectbox-dart/tree/main/objectbox/example">Example Apps</a> •
  <a href="https://github.com/objectbox/objectbox-dart/issues">Issues</a>
</p>

<p align="center">
  <a href="#cocoapods">
    <img src="https://img.shields.io/cocoapods/v/ObjectBox.svg?style=flat-square" alt="Version">
  </a>
  <a href="#cocoapods">
    <img src="https://img.shields.io/cocoapods/p/ObjectBox.svg?style=flat-square&color=17A6A6" alt="Platform">
  </a>
  <a href="https://github.com/objectbox/objectbox-swift/blob/main/LICENSE.txt">
    <img src="https://img.shields.io/github/license/objectbox/objectbox-swift?logo=apache&style=flat-square" alt="Apache 2.0 license">
  </a>
  <a href="https://twitter.com/ObjectBox_io">
    <img src="https://img.shields.io/twitter/follow/objectbox_io?color=%20%2300aced&logo=twitter&style=flat-square" alt="Follow @ObjectBox_io">
  </a>
</p>

Swift Database - swiftly persist objects on iOS & macOS
===============

Powerful & superfast database for Swift that's also easy to use. Persist Swift objects quickly and reliably on-device on iOS and macOS.

## Demo code

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

## Table of Contents
- [Why use ObjectBox for Swift data persistence?](#why-use-objectbox-for-swift-data-persistence)
    - [Features](#features)
- [Adding ObjectBox to your project](#adding-objectbox-to-your-project)
    - [New to CocoaPods?](#new-to-cocoapods)
    - [CocoaPods troubleshooting](#cocoapods-troubleshooting)
    - [Swift Versions](#swift-versions)
- [Example](#example)
- [Background: code generation](#background-code-generation)
- [Source code](#source-code)
- [Already using ObjectBox?](#already-using-objectbox)
- [Cross-platform database: Mobile, Desktop, Browser, Embedded, IoT](#cross-platform-database-mobile-desktop-browser-embedded-iot)
- [License](#license)

## Why use ObjectBox for Swift data persistence?

Simple but powerful; frugal but fast: The ObjectBox NoSQL database offers an intuitive Swift API that's easy to pick up, fun to work with, and incredibly fast, making it sustainable in many ways. Its frugal recource use (CPU, memory, battery / power) makes ObjectBox an ideal and sustainable choice for iOS apps. So why not give it a try right away? Check out the [installation section below](#adding-objectbox-to-your-project). You can also star this repository for later 🌟

On top, ObjectBox comes with an [out-of-the-box Data Sync](https://objectbox.io/sync/) handling the complexity of occassionally connected devices, networking and conflict resolution code for you. Build apps that reliably sync between devices and any backend, offline on-premise or online with the Cloud.

### Features
🏁 **High performance** on restricted devices, like IoT gateways, micro controllers, ECUs etc.\
💚 **Resourceful** with minimal CPU, power and Memory usage for maximum flexibility and sustainability\
🔗 **Relations:** object links / relationships are built-in\
💻 **Multiplatform:** Linux, Windows, Android, iOS, macOS

🌱 **Scalable:** handling millions of objects resource-efficiently with ease\
💐 **Queries:** filter data as needed, even across relations\
🦮 **Statically typed:** compile time checks & optimizations\
📃 **Automatic schema migrations:** no update scripts needed

**And much more than just data persistence**\
👥 **[ObjectBox Sync](https://objectbox.io/sync/):** keeps data in sync between devices and servers\
🕒 **[ObjectBox TS](https://objectbox.io/time-series-database/):** time series extension for time based data


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
|        1.9.0         |     5.8.1     |
|        1.8.1         |     5.7.2     |        
|        1.8.0         |     5.7.1     |        
|        1.7.0         |      5.5      |        
|        1.6.0         |      5.4      |        
|        1.5.0         |    5.3(.2)    |        
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

Already using ObjectBox?
---------------------------

We're on a mission to bring joy, delight and sustainability to app developers. **To do this, we need your help:** Please fill in this 2-minute [Anonymous Feedback Form](https://forms.gle/LvVjN6jfFHuivxZX6). Let us know what you love and what is amiss, so we can improve.

**We're looking forward to receiving your comments and requests:**

- Add [GitHub issues](https://github.com/ObjectBox/objectbox-swift/issues) 
- Upvote issues you find important by hitting the 👍/+1 reaction button
- Drop us a line via [@ObjectBox_io](https://twitter.com/ObjectBox_io/)
- ⭐ us, if you like what you see 

Thank you! 🙏

Keep in touch: For general news on ObjectBox, [check our blog](https://objectbox.io/blog)!


Cross-platform database: Mobile, Desktop, Browser, Embedded, IoT
------------------------
ObjectBox is a cross-platform database supporting sustainable app development in [multiple native languages](https://objectbox.io/dev-get-started/): 

* [Java/Kotlin Database](https://github.com/objectbox/objectbox-java): runs on Android, desktop, and servers.
* [Golang Database](https://github.com/objectbox/objectbox-go): great for IoT, data-driven tools, and server applications. 
* [C and C++ Database](https://github.com/objectbox/objectbox-c): native speed with zero copy access to objects on embedded devices
  also enables porting ObjectBox to other languages.
* [Flutter/Dart Database](https://github.com/objectbox/objectbox-dart/): persist Dart objects & build cross-platform apps using Flutter.


License
-------
All files in this repository are under the Apache 2 license:

    Copyright 2018-2022 ObjectBox Ltd. All rights reserved.
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

