#  Tool Test Project

## What is it?

This project is used to test code generation in ObjectBox's Sourcery-descended code generator.
It will run the codegen over a given target in the project, then build and run the product. You can do
whatever testing you need to do in the actual Swift code.

## Running these tests

These tests require a copy of ObjectBox Swift Code Generator in a known location. To get that all set up, do the following:

1. Locate the objectbox-swift-generator submodule in this repository's `external` folder.
2. Run the `_build.command` script to get a `Sourcery.app`.
3. Build the `CodeGenTests` target in the ObjectBox Xcode project (this step runs the tests using the built code generator)

## Adding New Test Cases

Adding a test case requires the following steps:

1. Add a new command line tool target
2. Name it ToolTestProject`N` (where `N` is the next number)
3. Go to the bottom of `RunToolTests.sh` and add `test_target_num "Test Name" N || FAIL=1` where "Test Name" is the name you want to have used in the log messages for this test, and `N` is again, the number of the test target.
4. Add `-framework ObjectBox` to the "Other Linker Flags"
5. Add `@executable_path/../../../` and `$(TOOLCHAIN_DIR)/usr/lib/swift/macosx` to the "Runpath Search Paths"
6. Add a `ToolTestProjectN.swift` source file (`N` again is the number of the target) containing a `main(_ args: [String]) -> Int32` that does the actual test and returns 0 on success, something else > 0 on failure.
7. Add the `main.swift` file to your target, it calls the main() function for you.

The `RunToolTests.sh` script will run the code generator and pass you the "Test Name" as your first parameter. It will also check the code generator output against a file named `Entity.generatedN.swift`, the model file against a `modelN.json` and such.
