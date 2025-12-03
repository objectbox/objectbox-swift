# ObjectBox Swift Sources

This folder contains the Swift sources for ObjectBox. This is the API you primarily touch when working with ObjectBox.

These Swift classes internally use [ObjectBox's C API](https://github.com/objectbox/objectbox-c), implemented by the libObjectBoxCore library.

## Repository Contents

- `ios-framework/`: The ObjectBox Swift framework. Uses a special static ObjectBox C library for macOS/iOS, see `fetch_dependencies.command` below.
  - `docs/swift_output/`: The generated framework documentation.
- `external/`: git submodule and/or pre-built binary container.
   This contains the ObjectBoxCore static libraries and the [ObjectBox Swift code generator](https://github.com/objectbox/objectbox-swift-generator).

**Scripts** and how they depend on each other (subject to future simplifications):

- `fetch_dependencies.command`: populates `external/objectbox-static` with libObjectBoxCore.
  libObjectBoxCore is a crucial requirement build the Swift framework.
- `ios-framework/Makefile`: combines `fetch_dependencies.command` and a Carthage build to create the Swift framework.
- `create-xcframework.sh`: builds the multi-platform archive containing binaries for multiple platforms and architectures.

### Tests

ObjectBox comes with a couple of tests of different categories:

- Unit tests: `ios-framework/CommonTests`, based on XCTestCase
- Generator tests (see [README](ios-framework/CodeGenTests/README.md)): `ios-framework/CodeGenTests` are run by building the CodenGenTests target with Xcode/xcodebuild (which runs a script that must be launched by Xcode/xcodebuild);
  uses a separate Xcode project and an ObjectBox generator executable to generate actual binding classes and assert the generator and database operations.
- (Outdated) Integration tests "IntegrationTests": `ios-framework/IntegrationTests`, currently not maintained, run via script;
  somewhat similar to CodeGen; subject to a general clean up; see [README](ios-framework/IntegrationTests/Readme.md)
- External integration test project: https://github.com/objectbox/objectbox-swift-integration-test
  runs "real projects" with "full ObjectBox round-trip" on internal CI and CircleCI

### Xcode Project Organization

You look at and build the framework itself via `ios-framework/ObjectBox.xcodeproj`.

- `ObjectBox.xcproject` targets
  - `ObjectBox-macOS`, `ObjectBox-iOS` and `ObjectBox-iOS Simulator` build the `ObjectBox.framework` for each platform
  - `ObjectBoxTests-macOS`, `ObjectBoxTests-iOS` and `ObjectBoxTests-iOS Simulator` build unit tests for each platforms framework
  - `iOS-Fat-Framework` builds a universal binary of the iOS framework needed for distribution, with code both for device and simulator
  - `CodeGenTests` runs a script that runs generator tests, see notes for tests above
- `ObjectBox.xcproject` main groups and directories
  - `CommonSource` contains all code to be shared by the framework of the macOS and iOS platforms.
    - `ObjectBox.h` is the framework umbrella header where all public C and ObjC header files are listed. These are either intended for use by app developers, or required to be visible for the Swift extensions.
    - `objectbox-c.h` and `objectbox-c-sync.h` are modified copies of the C API's header files created by the `fetch_dependencies.command` script so they can be imported into Swift and do not collide with `ObjectBox.h` on case-insensitive file systems.
    - The directory itself contains general purpose types like `Store` and `Box`. The important sub-groups are `Entities`, `Relation`, and `Query`.
  - `CommonTests` contains all code to be shared by tests for the macOS and iOS platforms, see notes on tests above
  - `ObjectBox-macOS`, `ObjectBox-iOS` and `ObjectBox-iOS Simulator` contain platform-specific files, including the framework's Info.plist

## Development

- Ensure a recent Xcode version is installed (see section below, Swift 5.9+).
- Ensure [homebrew](https://brew.sh/) is installed, e.g. setup.sh uses it.
- Ensure [rbenv](https://github.com/rbenv/rbenv) and ruby is installed, see section below.
- Run `./setup.sh` or see [setup.sh](setup.sh) and only run what is needed.
  - Runs `brew bundle` to install or update basic build tools including [Carthage](https://github.com/Carthage/Carthage) (see [Brewfile](Brewfile)).
  - Runs `bundle install` to install or update cocoapods and jazzy (see [Gemfile](Gemfile)).

Open the Xcode project in `ios-framework/ObjectBox.xcodeproj`.

Then some typical commands to use:

```shell
# Enter the framework directory
cd ios-framework/

# Download the ObjectBox database libraries
make fetch_dependencies

# Build the framework
make build_framework
# Run unit tests
make u_tests

# Build a debug version of the generator
make build_generator_debug
# Run generator tests
make g_tests
```

**To run a specific unit test** change the last argument to specify your test. You can also run a group/class by removing the last one/two parts of the filter.
Note: `xcpretty` cleans up the output so you won't see all the compiler calls but it also hides failed tests output. So once you see a failure, run without `xcpretty` to read the error.

```shell
xcodebuild -derivedDataPath ./DerivedData test -project ObjectBox.xcodeproj -scheme ObjectBox-macOS -destination 'platform=OS X,arch=x86_64' -only-testing ObjectBoxTests-macOS/StoreTests/test32vs64BitForOs | xcpretty
xcodebuild -derivedDataPath ./DerivedData test -project ObjectBox.xcodeproj -scheme ObjectBox-iOS -destination 'platform=iOS Simulator,name=iPhone 11' -only-testing ObjectBoxTests-iOS/StoreTests/test32vs64BitForOs | xcpretty
```

**To run a specific generator test** comment out other tests in [the run script](ios-framework/CodeGenTests/RunToolTests.sh).

**To run unit tests with an in-memory database** set the following environment variable before running an xcodebuild command:

```shell
export OBX_IN_MEMORY=true
make u_tests
```

In Xcode, set this by editing the scheme: under Test look for Arguments.

### Generate the Documentation

Inside `ios-framework/` jazzy is configured inside [Makefile](ios-framework/Makefile):

```shell
cd ios-framework/
make generate_docs
```

Jazzy uses the [README.md](ios-framework/README.md) as a front page.

The result is stored inside `ios-framework/docs/swift_output/`.

### Ruby version

The Ruby version on macOS is outdated, e.g. Cocoapods may have a problem.
Use [rbenv](https://github.com/rbenv/rbenv) to install the required version:

```shell
# Print current version
ruby -v
# Install rbenv and build plugin to install ruby versions
brew update && brew install rbenv ruby-build
# Print the version configured in .ruby-version
rbenv local
# Install that version, e.g.
rbenv install 3.0.5
# Ensure it is the expected version
ruby -v
```

To change the required ruby version, see https://www.ruby-lang.org/en/downloads/releases/ and set
it with e.g. `rbenv local 3.0.5`. This will update the `.ruby-version` file. Then install
it with rbenv like above.

### Updating gems: CocoaPods, Jazzy

If needed, change the allowed version in [Gemfile](Gemfile).

Run `bundle update` and commit the changed [lock file](Gemfile.lock).

### Build notes

- SwiftLint: target `ObjectBox-macOS` has a build phase that runs `swiftlint lint --config .swiftlint.yml`
  - Edit `.swiftlint.yml` file to customize

## Caveats

To make to-one relations and their backlinks work, the `Entity` protocol was extended to require (1) an `EntityType` typealias, and (2) an `_id` property. The former was needed to disambiguate which concrete entity we're talking about when all we have is the protocol type, and this in turn is needed to specify the generic type requirement of `Id<T>`. Since the `Entity` protocol itself is intended to be no more than a convenient code annotation (which Sourcery can filter on), it's advised to get rid of this as soon as possible and find a different way to get the data needed for associations in Swift, for example using an `IdGetter<T>` like we do in Java and injecting it into `EntityInfo` from generated code.
