ObjectBox Swift Sources
=======================

This folder contains the Swift sources for ObjectBox. This is the API you primarily touch when working with ObjectBox.

These Swift classes internally use [ObjectBox's C API](https://github.com/objectbox/objectbox-c), implemented by the libObjectBoxCore library. 

Repository Contents
-------------------

- `ios-framework/`: The Cocoa Swift framework.
    - `docs/swift_output/`: The generated framework documentation.
- `external/`: git submodule and pre-built binary container. This contains the ObjectBoxCore static libraries and our code generator.
- `download_dependencies.command`: Script for downloading libObjectBoxCore into `externals`. You must run this script before you can build the framework.
- `docs/`: Documentation and discussion of concepts, ideas, and approaches to bring ObjectBox to Swift.

Setup
-----

* Install Xcode 10.2+ (Swift 5.x) with command line tools prepared to build from the shell
* Run `git submodule update --init --recursive` to get external dependencies
* Run `make build_swiftlint` to build the build SwiftLint from source into its `external/SwiftLint/.build` directory.
* The Sourcery submodule contains a `_build.command` script that you can double-click to build a release-ready version of the code generator.
* Build the framework using the `ObjectBox.xcodeproj`

To build the project for release:

* Install [Carthage][], e.g. using Homebrew: `brew install carthage`
* Run `cd ios-framework/; make all` to build the frameworks from source with Carthage
* The `ios-framework/cocoapod/make_podspec_and_zip.command` script can be double-clicked to build a release-ready archive and Podspec file.

[Carthage]: https://github.com/Carthage/Carthage

### Generate the Documentation

You need to have [jazzy](https://github.com/realm/jazzy) installed to generate documentation from the Swift code:

* Install jazzy. Run `bundle install` from the project root to install jazzy as a local dependency.
* Inside `ios-framework/`, jazzy is configured inside [Makefile](ios-framework/Makefile).
  Run `make generate_swift_docs`, which will execute `bundle exec jazzy` with all the configuration options set for you.
* Jazzy uses the [README.md](ios-framework/README.md) as a front page
* The result is stored inside `ios-framework/docs/swift_output/`.

Distributing the Framework
--------------------------

Distribution of the framework as closed source works across these channels:

- **CocoaPods**, by setting the `.podspec`'s `vendored_frameworks` to point to the build products of the macOS and iOS framework targets. (The `make_podspec_and_zip.command` script takes care of this)
- **Carthage**, by uploading a `.zip` of the frameworks as binary attachments to a GitHub's release.

## Build with Carthage

The easiest way to build the framework is using the dependency manager [Carthage][] as a build tool:

    $ carthage build --no-skip-current

In addition to building the dependencies (there are none), the `--no-skip-current` flag ensures the current project itself is built. That's what we'll be shipping with both Carthage and CocoaPods.

To generate the Carthage-compatible release:

    $ carthage archive ObjectBox

This will put all build products in a `.zip`. On client machines, Carthage downloads and unzips the contents into their local framework build directory next to other dependencies that may be built from source.

Note that the build products built with Swift 4.2 will not be compatible with Swift 5 onward. So we have to ship updated binaries until Swift reaches ABI stability, lest the releases become useless.

## Build without Carthage

You need a "fat" framework that works both on the iPhone Simulator on macOS (x86 architecture) and real devices (armv7 and arm64 architectures).

The `iOS-Fat-Framework` target compiles for both architectures and merges the results into a single build product: a single framework, and a single dSYM file.

- Select the `iOS-Fat-Framework` scheme.
- Make sure the scheme's Build Configuration is set to "Release".
- Make sure the target device is "Generic iOS Device" or a real device, not a simulator. (Or else you only get a `-iphonesimulator` build and `lipo` fails.)

Find the result in `ios-framework/ObjectBox-iOS-Aggregate.build/`

This is essentially what comes for free with Carthage. Xcode 10 changed the build system a bit. The build script is adjusted accordingly. But you may have to adjust the script a bit for future Xcode versions; that's another point of failure you wouldn't have to worry about with Carthage.

iOS Framework Project Organization
----------------------------------

You look at and build the framework itself via `ios-framework/ObjectBox.xcodeproj`.

* `ObjectBox.xcproject` targets
    * `ObjectBox-macOS` builds the `ObjectBox.framework` for the macOS platform
    * `ObjectBoxTests-macOS` builds the unit tests for the macOS framework
    * `ObjectBox-iOS` builds the `ObjectBox.framework` for the iOS platform
    * `ObjectBoxTests-iOS` builds the unit tests for the iOS framework
    * `iOS-Fat-Framework` builds a universal binary of the iOS framework needed for distribution, with code both for device and simulator
    * `CodeGenTests` Runs a shell script that performs integration tests for various features. This will run the Sourcery code generator over files and then compile the result against the framework.
* `ObjectBox.xcproject` main groups and directories
    * `CommonSource` contains all code to be shared by the framework of the macOS and iOS platforms.
        * `ObjectBox.h` is the framework umbrella header where all public C and ObjC header files are listed. These are either intended for use by app developers, or required to be visible for the Swift extensions.
        * `ObjectBoxC.h` is a modified version of the C API's `objectbox.h` header generated by the `generate_ObjectBoxC_header.rb` script so it can be imported into Swift and doesn't have a name collision with `ObjectBox.h` on case-insensitive file systems.
        * The directory itself contains general purpose types like `Store` and `Box`. The important sub-groups are `Entities`, `Relation`, and `Query`.
    * `CommonTests` contains all code to be shared by tests for the macOS and iOS platforms
    * `ObjectBox-macOS` contains macOS-specific files, including the framework's Info.plist
    * `ObjectBox-iOS` contains iOS-specific files, including the framework's Info.plist

Caveats
-------

To make to-one relations and their backlinks work, the `Entity` protocol was extended to require (1) an `EntityType` typealias, and (2) an `_id` property. The former was needed to disambiguate which concrete entity we're talking about when all we have is the protocol type, and this in turn is needed to specify the generic type requirement of `EntityId<T>`. Since the `Entity` protocol itself is intended to be no more than a convenient code annotation (which Sourcery can filter on), it's advised to get rid of this as soon as possible and find a different way to get the data needed for associations in Swift, for example using an `IdGetter<T>` like we do in Java and injecting it into `EntityInfo` from generated code.

How to Use the Framework
------------------------

- The example project in this repository is a good starting point to see how to interact with the framework.
- Have a look at the `ios-framework/CommonTests/Test Entities/RelatedEntities.swift` file to see how self-contained entity code & generated cursor code look. You should be able to copy and paste the contents into a test app if you want. This should also help in case you cannot get the code generator running in 2024 :)

## How to Write App Code

Define entities:

    import ObjectBox
    final class Person: Entity {
        var id: Id = 0
        var age: Int
        var name: String
        var birthdate: Date

        required init() {
            self.name = ""
            self.age = 0
            self.birthdate = Date()
        }
    }

Properties have to be mutable so they can be set after initialization in generated code.

Run the code generator. This will configure a `ModelBuilder` and get the `Data` representation of it. It also generates an `EntityBinding` implementation for each entity with the property offsets calculated for you. Doing this manually is error-prone and tedious.

Create and set up the ObjectBox types:

    let directory: String = "/path/to/the/store"
    let store: Store = try Store(directoryPath: directory)
    let personBox: Box<Person> = store.box(for: Person.self)

This will call into the the generated (!) initializer that uses the private model builder's `modelBytes()` automatically.

Then you're all set to use entities with ObjectBox:

    let person = Person(name: "Fry", age: 28, birthdate: Date(timeIntervalSince1970: 123456))
    assert(person.id.value == 0) // Initial value

    let personId = try personBox.put(person)
    assert(person.id == personId) // ID is set after put
    
    // Get by ID
    assert(try personBox.get(personId) != nil)
    
    // Get collections of entities
    _ = try personBox.all()
    _ = try personBox.query({ Person.name == "Fry" }).build().find()

That's it, it works now!
