ObjectBox Swift Sources
=======================
This folder contains the Swift sources for ObjectBox. This is the API you primarily touch when working with ObjectBox.

These Swift classes internally use [ObjectBox's C API](https://github.com/objectbox/objectbox-c), implemented by the libObjectBoxCore library. 

Repository Contents
-------------------
- `ios-framework/`: The Cocoa Swift framework.
    - `docs/swift_output/`: The generated framework documentation.
- `external/`: git submodule and/or pre-built binary container.
   This contains the ObjectBoxCore static libraries and our code generator.
- `docs/`: Documentation and discussion of concepts, ideas, and approaches to bring ObjectBox to Swift.

**Scripts** and how they depend on each other (subject to future simplifications):

- `fetch_dependencies.command`: populates `external/objectbox-static` with libObjectBoxCore.
  libObjectBoxCore is a crucial requirement build the Swift framework.
- `create-xcframework.sh`: builds the multi-platform archive containing binaries for multiple platforms and architectures.

Tests
-----
ObjectBox comes with a couple of tests of different categories:

* Unit tests: `ios-framework/CommonTests`, based on XCTestCase
* Integration tests "CodeGen": `ios-framework/CodeGenTests` run via script (for now only via Xcode/xcodebuild);
  uses a separate Xcode project and an ObjectBox generator executable to generate actual binding classes.
  [README](ios-framework/CodeGenTests/README.md)
* Integration tests "IntegrationTests": `ios-framework/IntegrationTests`, currently not maintained, run via script;
  somewhat similar to CodeGen; subject to a general clean up; see also its [README](ios-framework/IntegrationTests/Readme.md)
* External integration test project: https://github.com/objectbox/objectbox-swift-integration-test
  runs "real projects" with "full ObjectBox round-trip" on internal CI and CircleCI

Setup
-----
* Install latest Xcode (Swift 5.3+) with command line tools prepared to build from the shell
  * Note: After Xcode updates, you may have to reinstall the CLI tools via `xcode-select --install`
* Ensure you have homebrew (e.g. setup.sh uses it to install [Carthage](https://github.com/Carthage/Carthage))
* Using homebrew, install basic build tools like cmake and ccache
* Run `./setup.sh` (see the [setup.sh](setup.sh) file for more comments if you want)
* Open Xcode project in ios-framework/ObjectBox.xcodeproj

To build the project for release:

* Run `cd ios-framework/; make all` to build the frameworks from source with Carthage
* The `ios-framework/cocoapod/make-release.command` script can be double-clicked to build a release-ready archive and Podspec file.

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

- **CocoaPods**, by setting the `.podspec`'s `vendored_frameworks` to point to the build products of the macOS and iOS framework targets.
  (The `make-release.command` script takes care of this)
- **Carthage**, by uploading a `.zip` of the frameworks as binary attachments to a GitHub's release.

## Build with Carthage

The easiest way to build the framework is using the dependency manager [Carthage][] as a build tool:

    $ carthage build --no-skip-current

In addition to building the dependencies (there are none), the `--no-skip-current` flag ensures the current project itself is built.
That's what we'll be shipping with both Carthage and CocoaPods.

To generate the Carthage-compatible release:

    $ carthage archive ObjectBox

This will put all build products in a `.zip`. On client machines, Carthage downloads and unzips the contents into their local framework build directory next to other dependencies that may be built from source.

## Build without Carthage

You need a "fat" framework that works both on the iPhone Simulator on macOS (x64) and real devices (arm64).

The `iOS-Fat-Framework` target compiles for both architectures and merges the results into a single build product: a single framework, and a single dSYM file.

- Select the `iOS-Fat-Framework` scheme.
- Make sure the scheme's Build Configuration is set to "Release".
- Make sure the target device is "Generic iOS Device" or a real device, not a simulator. (Or else you only get a `-iphonesimulator` build and `lipo` fails.)

Find the result in `ios-framework/ObjectBox-iOS-Aggregate.build/`

This is essentially what comes for free with Carthage. Xcode 10 changed the build system a bit. The build script is adjusted accordingly. But you may have to adjust the script a bit for future Xcode versions; that's another point of failure you wouldn't have to worry about with Carthage.

Swift Framework Project Organization
------------------------------------
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

Build notes
-----------
* SwiftLint (macOS build only): calls `swiftlint lint --config .swiftlint-macOS.yml`
  * Edit .swiftlint-macOS.yml file to customize (e.g. "id" is OK despite less than 3 chars)

Caveats
-------
To make to-one relations and their backlinks work, the `Entity` protocol was extended to require (1) an `EntityType` typealias, and (2) an `_id` property. The former was needed to disambiguate which concrete entity we're talking about when all we have is the protocol type, and this in turn is needed to specify the generic type requirement of `Id<T>`. Since the `Entity` protocol itself is intended to be no more than a convenient code annotation (which Sourcery can filter on), it's advised to get rid of this as soon as possible and find a different way to get the data needed for associations in Swift, for example using an `IdGetter<T>` like we do in Java and injecting it into `EntityInfo` from generated code.

How to Use the Framework
------------------------
- The example project in this repository is a good starting point to see how to interact with the framework.
- Have a look at the `ios-framework/CommonTests/Test Entities/RelatedEntities.swift` file to see how self-contained entity code & generated cursor code look. You should be able to copy and paste the contents into a test app if you want. This should also help in case you cannot get the code generator running in 2024 :)

## How to Write App Code

Define entities:

    import ObjectBox
    final class Person: Entity {
        var id: Id<Person> = 0
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
    let store: Store = try! Store(directoryPath: directory)
    let personBox: Box<Person> = store.box(for: Person.self)

This will call into the the generated (!) initializer that uses the private model builder's `modelBytes()` automatically.

Then you're all set to use entities with ObjectBox:

    let person = Person(name: "Fry", age: 28, birthdate: Date(timeIntervalSince1970: 123456))
    assert(person.id.value == 0) // Initial value

    let personId = try personBox.put(person)
    assert(person.id == personId) // ID is set after put
    
    // Get by ID
    assert(personBox.get(personId) != nil)
    
    // Get collections of entities
    _ = personBox.all()
    _ = personBox.query({ Person.name == "Fry" }).build().find()

That's it, it works now!

Testing from commandline
------------------------
To execute all unit tests:
```shell script
cd ios-framework
make unit_test
```

To execute a specific test. Change the last argument to specify your test. You can also execute a group/class by removing the last one/two parts of the filter.
Note: `xcpretty` cleans up the output so you wan't see all the compiler calls but it also hides failed tests output. So once you see a failure, run without `xcpretty` to read the error. 
```shell script
xcodebuild -derivedDataPath ./DerivedData test -project ObjectBox.xcodeproj -scheme ObjectBox-macOS -destination 'platform=OS X,arch=x86_64' -only-testing ObjectBoxTests-macOS/StoreTests/test32vs64BitForOs | xcpretty
xcodebuild -derivedDataPath ./DerivedData test -project ObjectBox.xcodeproj -scheme ObjectBox-iOS -destination 'platform=iOS Simulator,name=iPhone 11' -only-testing ObjectBoxTests-iOS/StoreTests/test32vs64BitForOs | xcpretty
```

