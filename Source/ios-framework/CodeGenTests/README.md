# ObjectBox Swift Code generator tests (CodeGenTests)

## What is it?

This project is used to test code generation in ObjectBox's Sourcery-descended code generator.
It will run the codegen over a given target in the project, then build and run the product. You can do
whatever testing you need to do in the actual Swift code.

**Important note**: by passing the `--debug-parsetree` option to the generator in `RunToolTests.sh`
it generates **non-random, stable UIDs**. See `runCLI()` of `objectbox-swift-generator/Sourcery/main.swift`.
These are unlike (notably shorter) UIDs than are generated for a user project.

## Running these tests

These tests require a copy of ObjectBox Swift Code Generator in a known location. To get that all set up, do the following:

1. Locate the objectbox-swift-generator submodule in this repository's `external` folder.
2. Run the `_build.command` script to get a `Sourcery.app`.
3. Build the `CodeGenTests` target in the ObjectBox Xcode project (this step runs the tests using the built code generator)

## Adding New Test Cases

Adding a test case requires the following steps:

1. Open `ToolTestProject.xcodeproj` in Xcode.
2. Duplicate one of the `ToolTestProjectN` command line tool targets and increase to next highest number `N`.
3. In `RunToolTests.sh` at the bottom add a command to run the test (replace `<N>` with the chosen number):
   ```bash
   # If the code generator should succeed
   test_target_num "Test Name" <N> || ((FAIL++))
   # If the code generator should fail
   fail_codegen_target_num "Test Name" <N> || ((FAIL++))
   ```
4. Add a `ToolTestProjectN.swift` source file (replace `N` again) to the command line tool target. It should look like:
    ```swift
    import ObjectBox

    // TODO Add entity classes

    func main(_ args: [String]) throws -> Int32 {
        // TODO Add test code, may print on error or throw

        return 0 // on success
        return 1 // or any value > 0 on failure (make sure to print error details)
    }
    ```
5. If the code generator should succeed, add the generated `EntityInfo.generatedN.swift` to the `ToolTestProjectN` 
  command line tool target as well (so it's verified it compiles).

The `RunToolTests.sh` script will run the code generator and pass the "Test Name" as the first parameter. It will also check the code generator output against a file named `Entity.generatedN.swift`, the model file against a `modelN.json` and such.

### Command line tool target settings
For reference, all of the command line targets have these settings:
- Add `-framework ObjectBox` to the "Other Linker Flags"
- Add `@executable_path/../../../` and `$(TOOLCHAIN_DIR)/usr/lib/swift/macosx` to the "Runpath Search Paths"
- Add the `main.swift` file to the Compile sources build phase, it calls the main() function of the `ToolTestProjectN.swift` file.
