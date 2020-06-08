#!/bin/bash

echo -n "note: Starting tests at "
date

# macOS does not have realpath and readlink does not have -f option, so do this instead:
mydir=$( cd "$(dirname "$0")" ; pwd -P )
cd "${mydir}"

itestdir="$mydir/../IntegrationTests/"

test_target_num () {
    testname="$1"
    testname="${testname//[ \/]/_}"
    testdir="$itestdir/$2_$testname"
    mkdir "$testdir"
    if [ -f "EntityInfo.generated$2.swift" ]; then
        cp "EntityInfo.generated$2.swift" "$testdir/EntityInfo.generated.expected.swift"
    fi
    if [ -f "EntityInfo.generated$2_original.swift" ]; then
        cp "EntityInfo.generated$2_original.swift" "$testdir/EntityInfo.generated.initial.swift"
    fi
    if [ -f "messages$2.log" ]; then
        cp "messages$2.log" "$testdir/messages.expected.log"
    fi
    if [ -f "model$2.json" ]; then
        cp "model$2.json" "$testdir/model.expected.json"
        cp "model$2.json" "$testdir/model.initial.json"
    fi
    if [ -f "model$2_before.json" ]; then
        cp "model$2_before.json" "$testdir/model.initial.json"
    fi
    if [ -f "schemaDump$2.txt" ]; then
        cp "schemaDump$2.txt" "$testdir/schemaDump.expected.txt"
    fi
    if [ -f "schemaDump$2_original.txt" ]; then
        cp "schemaDump$2_original.txt" "$testdir/schemaDump_original.txt"
    fi
    if [ -f "ToolTestProject$2.swift" ]; then
        cp "ToolTestProject$2.swift" "$testdir/test.swift"
    fi
    if [ -f "ToolTestProject$2_original.swift" ]; then
        cp "ToolTestProject$2_original.swift" "$testdir/test_original.swift"
    fi
    if [ -f "xcode$2.log" ]; then
        cp "xcode$2.log" "$testdir/xcode.expected.log"
    fi
    cp -R "$itestdir/8_Empty_Entity/Project.xcodeproj" "$testdir/Project.xcodeproj"
}

fail_codegen_target_num () {
    testname="$1"
    testname="${testname//[ \/]/_}"
    testdir="$itestdir/$2_$testname"
    mkdir "$testdir"
    if [ -f "EntityInfo.generated$2.swift" ]; then
        cp "EntityInfo.generated$2.swift" "$testdir/EntityInfo.generated.expected.swift"
    fi
    if [ -f "EntityInfo.generated$2_original.swift" ]; then
        cp "EntityInfo.generated$2_original.swift" "$testdir/EntityInfo.generated.initial.swift"
    fi
    if [ -f "messages$2.log" ]; then
        cp "messages$2.log" "$testdir/messages.fail.log"
    fi
    if [ -f "model$2.json" ]; then
        cp "model$2.json" "$testdir/model.initial.json"
    fi
    if [ -f "model$2.before.json" ]; then
        if [ -f "$testdir/model.initial.json" ]; then
            echo "warning: model.before.json AND model.json found in ${2}_$testname"
            cp "model$2.before.json" "$testdir/model.initial2.json"
        else
            cp "model$2.json" "$testdir/model.expected.json"
        fi
    fi
    if [ -f "schemaDump$2.txt" ]; then
        cp "schemaDump$2.txt" "$testdir/schemaDump.initial.txt"
    fi
    if [ -f "schemaDump$2_original.txt" ]; then
        if [ -f "$testdir/schemaDump.initial.txt" ]; then
            echo "warning: schemaDump_before.txt AND schemaDump.txt found in ${2}_$testname"
            cp "schemaDump$2_original.txt" "$testdir/schemaDump.initial2.txt"
        else
            cp "schemaDump$2_original.txt" "$testdir/model.initial.txt"
        fi
        cp "schemaDump$2_original.txt" "$testdir/schemaDump_original.txt"
    fi
    if [ -f "ToolTestProject$2.swift" ]; then
        cp "ToolTestProject$2.swift" "$testdir/test.swift"
    fi
    if [ -f "ToolTestProject$2_original.swift" ]; then
        cp "ToolTestProject$2_original.swift" "$testdir/test_original.swift"
    fi
    if [ -f "xcode$2.log" ]; then
        cp "xcode$2.log" "$testdir/xcode.expected.log"
    fi
    cp -R "$itestdir/8_Empty_Entity/Project.xcodeproj" "$testdir/Project.xcodeproj"
}


cd "$mydir"

test_target_num "ID and 2 strings entity" 9 || FAIL=1
fail_codegen_target_num "NameInDb collision with other property" 10 || FAIL=1
fail_codegen_target_num "Entity with string but no ID" 11 || FAIL=1
test_target_num "Remove A Property" 12 || FAIL=1
test_target_num "Remove A Property and add one at same time" 13 || FAIL=1
test_target_num "Add a Property after having removed one" 14 || FAIL=1
test_target_num "Remove an index from a property" 15 || FAIL=1
test_target_num "Add and remove an index in one go" 16 || FAIL=1
test_target_num "Add an index after having removed one" 17 || FAIL=1
test_target_num "Rename an entity" 18 || FAIL=1
fail_codegen_target_num "Entity UID printing" 19 || FAIL=1
fail_codegen_target_num "New Entity with empty UID" 20 || FAIL=1
test_target_num "Rename a property" 21 || FAIL=1
fail_codegen_target_num "Property UID printing" 22 || FAIL=1
fail_codegen_target_num "New Property with empty UID" 23 || FAIL=1
fail_codegen_target_num "New Property with UID" 24 || FAIL=1
test_target_num "Read/write all our data types" 25 || FAIL=1
test_target_num "Ensure running codegen on unchanged file changes nothing" 26 || FAIL=1
test_target_num "Ensure assigning a previously proposed UID works [Change/Reset]" 27 || FAIL=1
test_target_num "Ensure moving properties changes nothing" 28 || FAIL=1
test_target_num "Ensure moving entities changes nothing" 29 || FAIL=1
test_target_num "Unique Entity Exception Test" 30 || FAIL=1
test_target_num "Struct Entity Test" 31 || FAIL=1
test_target_num "UInt64 as ID Test" 32 || FAIL=1
test_target_num "Data and [UInt8] Test" 33 || FAIL=1

test_target_num "Converter Test" 34 || FAIL=1
test_target_num "Enum Test" 35 || FAIL=1
test_target_num "Standalone Relations" 36 || FAIL=1
test_target_num "Standalone Backlinks" 37 || FAIL=1
test_target_num "Edit ToOne Backlinks" 38 || FAIL=1
test_target_num "Edit ToOne Backlinks Structs" 39 || FAIL=1
test_target_num "Standalone Backlinks Structs" 40 || FAIL=1
fail_codegen_target_num "ToOne Backlink annotation wrong" 41 || FAIL=1
test_target_num "Standalone Relation Queries" 42 || FAIL=1
test_target_num "ToOne Relation Queries" 43 || FAIL=1
test_target_num "many-to-many reset" 44 || FAIL=1
test_target_num "many-to-many backlink reset" 45 || FAIL=1
test_target_num "Threaded ToOne backlink edit" 46 || FAIL=1
test_target_num "Threaded Many-to-many edit" 47 || FAIL=1
test_target_num "Threaded Many-to-many backlink edit" 48 || FAIL=1
test_target_num "Untyped IDs and queries 1" 49 || FAIL=1
test_target_num "Untyped IDs and queries 2" 50 || FAIL=1
#fail_codegen_target_num "Typed IDs still enforce type?" 51 || FAIL=1

fail_codegen_target_num "Ensure we don't write JSON before ID errors" 52 || FAIL=1
test_target_num "ToOne Backlink ensure applyToDb is needed" 53 || FAIL=1
test_target_num "ToMany ensure applyToDb is needed" 54 || FAIL=1
test_target_num "ToMany Backlink ensure applyToDb is needed" 55 || FAIL=1
test_target_num "Swift Property Wrappers are treated as wrapped type" 56 || FAIL=1

echo "note: Finished tests..."

exit $FAIL
