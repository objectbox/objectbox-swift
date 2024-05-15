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
ObjectBox is available as a [CocoaPods](https://cocoapods.org) pod. [See the docs](https://swift.objectbox.io/install) for details and alternative setup options.

If you are new to CocoaPods, [check out their website](https://cocoapods.org) for an introduction and installation instructions.

To add the ObjectBox Swift dependency, add the following line to your `Podfile`:

```ruby
  pod 'ObjectBox'
```

Then run these commands in your project directory to install the ObjectBox framework:

```bash
pod install --repo-update
Pods/ObjectBox/setup.rb
```

Then open your Xcode workspace (.xcworkspace) instead of the Xcode project (.xcodeproj).

Now, you are all set to define your first ObjectBox entities;
e.g. check the [getting started guide](https://swift.objectbox.io/getting-started) or the [example](#example) described below.

### CocoaPods troubleshooting

If `pod install` fails, try updating CocoaPods first:

    gem update xcodeproj && gem update cocoapods && pod repo update

## Updating to newer ObjectBox versions

Update the ObjectBox pod and re-run the setup script:

```shell
pod repo update
pod update ObjectBox
Pods/ObjectBox/setup.rb
```

<a name="example"></a>Example
-----------------------------
In the [Example](Example/) directory, you'll find a "Notes" example app demonstrating ObjectBox's Swift API.
The example comes with two apps: one for iOS and one for macOS. The iOS example is a full GUI application, whereas the macOS example runs a few operations and then exits.

## Swift versions

Here's a list of ObjectBox releases, and the Swift versions they were compiled with:

| ObjectBox version(s) | Swift version |
|:--------------------:|:-------------:|
|        2.0.0         |      5.9      |
|        1.9.2         |      5.9      |
|        1.9.1         |      5.9      |
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

Development
-----------
The source code for ObjectBox's Swift binding can be found [in the Source folder](Source/README.md) of this repository.

Background: code generation
---------------------------
ObjectBox Swift Database generates code at build time for optimal performance at runtime by avoiding reflection etc.
This is automatically done for you and should be transparent.
Internally, we use [a fork of Sourcery](https://github.com/objectbox/objectbox-swift-generator) for this.

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

    Copyright 2018-2023 ObjectBox Ltd. All rights reserved.
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

Note that this license applies to the code in this repository only.
See our website on details about all [licenses for ObjectBox components](https://objectbox.io/faq/#license-pricing).
