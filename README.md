<p align="center">
 <img width="466" src="https://raw.githubusercontent.com/objectbox/objectbox-swift/master/images/logo.png" alt="ObjectBox">
</p>

<p align="center">
  <a href="https://swift.objectbox.io/getting-started">Getting Started</a> •
  <a href="https://swift.objectbox.io">Documentation</a> •
  <a href="https://github.com/objectbox/objectbox-swift/tree/main/Example">Example Apps</a> •
  <a href="https://github.com/objectbox/objectbox-swift/issues">Issues</a>
</p>

<p align="center">
  <a href="#add-objectbox-to-your-project">
    <img src="https://img.shields.io/cocoapods/v/ObjectBox.svg" alt="Version">
  </a>
  <a href="#add-objectbox-to-your-project">
    <img src="https://img.shields.io/cocoapods/p/ObjectBox.svg?color=17A6A6" alt="Platform">
  </a>
</p>

# ObjectBox Swift Database - swiftly persist objects and on-device vector database for iOS & macOS

Powerful & superfast database for Swift that's also easy to use. Persist Swift objects quickly and reliably on-device on
iOS and macOS.

## Demo code

```swift
// objectbox: entity
class Person {
    var id: Id = 0
    var firstName: String = ""
    var lastName: String = ""
    
    init() {}
    
    init(id: Id = 0, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}

let store = try Store(directoryPath: "person-db")
let box = store.box(for: Person.self)

var person = Person(firstName: "Joe", lastName: "Green")
let id = try box.put(person) // Create

person = try box.get(id)!    // Read

person.lastName = "Black"
try box.put(person)          // Update

try box.remove(person.id)    // Delete

let query = try box.query {  // Query
    Person.firstName == "Joe"
    && Person.lastName.startsWith("B")
}.build()
let people: [Person] = try query.find()
```

Want details? **[Read the guide](https://swift.objectbox.io/)** or
**[check out the API reference](https://objectbox.io/docfiles/swift/current/)**.

## Why use ObjectBox for Swift data persistence?

Simple but powerful; frugal but fast: The ObjectBox NoSQL database offers an intuitive Swift API that's easy to pick up,
fun to work with, and incredibly fast, making it sustainable in many ways. Its frugal recource use (CPU, memory, 
battery / power) makes ObjectBox an ideal and sustainable choice for iOS apps. So why not give it a try right away? 
Check out the [installation section below](#add-objectbox-to-your-project). You can also star this repository for later 🌟

### Features

🧠 **Artificial Intelligence** - superfast [on-device vector search](https://docs.objectbox.io/on-device-ann-vector-search).\
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

## Add ObjectBox to your project

ObjectBox is available as a

- [CocoaPods](https://swift.objectbox.io/install#cocoapods) pod
- [Swift Package](https://swift.objectbox.io/install#swift-package)

See [Install ObjectBox Swift](https://swift.objectbox.io/install) for details and alternative setup options.

## Example

In the [Example](Example) directory, you'll find a "Notes" example app demonstrating ObjectBox's Swift API.
The example comes with two apps: one for iOS and one for macOS. The iOS example is a full GUI application, whereas the 
macOS example runs a few operations and then exits.

## Changelog

For notable and important changes in new releases, read the [changelog](CHANGELOG.md).

## Development

The source code for ObjectBox's Swift binding can be found [in the Source folder](Source/README.md) of this repository.

## Background: code generation

ObjectBox Swift Database uses generated code for optimal performance at runtime by avoiding reflection etc.

It uses [a fork of Sourcery](https://github.com/objectbox/objectbox-swift-generator) for this.

## Already using ObjectBox?

We're on a mission to bring joy, delight and sustainability to app developers. **To do this, we need your help:** Please
fill in this 2-minute [Anonymous Feedback Form](https://forms.gle/LvVjN6jfFHuivxZX6). Let us know what you love and what is amiss, so we can improve.

**We're looking forward to receiving your comments and requests:**

- Add [GitHub issues](https://github.com/ObjectBox/objectbox-swift/issues)
- Upvote issues you find important by hitting the 👍 reaction button
- Drop us a line via contact📧objectbox.io
- ⭐ this repository, if you like what you see

Thank you! 🙏

Keep in touch: For general news on ObjectBox, [check our blog](https://objectbox.io/blog)!

## Cross-platform database: Mobile, Desktop, Browser, Embedded, IoT

ObjectBox is a cross-platform database supporting sustainable app development in [multiple native languages](https://objectbox.io/dev-get-started/):

- [ObjectBox C and C++ SDK](https://github.com/objectbox/objectbox-c): native speed with zero copy access to objects on embedded devices
- [ObjectBox Java and Kotlin SDK](https://github.com/objectbox/objectbox-java): runs on Android, desktop, and servers.
- [ObjectBox Dart and Flutter SDK](https://github.com/objectbox/objectbox-dart): persist Dart objects & build cross-platform apps using Flutter.
- [ObjectBox Go SDK](https://github.com/objectbox/objectbox-go): great for IoT, data-driven tools, and server applications.
  also enables porting ObjectBox to other languages.

## License

```text
Copyright 2018-2025 ObjectBox Ltd. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Note that this license applies to the code in this repository only.
See our website on details about all [licenses for ObjectBox components](https://objectbox.io/faq/#license-pricing).
