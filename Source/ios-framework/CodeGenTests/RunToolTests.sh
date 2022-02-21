#!/bin/bash

#  Run this script from Xcode (target & scheme "CodeGenTests"):
#  it has a dependency and also relies on variables set by Xcode

echo -n "note: Starting tests at $(date)"

if [ -z ${PROJECT_DIR} ]; then
  echo "PROJECT_DIR unavailable; please run from Xcode"

  # TODO: In the future we could also setup the vars for derived data etc. to make it work; until then exit...

  # macOS does not have realpath and readlink does not have -f option, so do this instead:
  script_dir=$( cd "$(dirname "$0")" ; pwd -P )

  PROJECT_DIR="${script_dir}/../"

  exit 1
fi

MYDIR="${PROJECT_DIR}/CodeGenTests/" # Xcode copies our script into DerivedData before running it, so hard-code our path.

SOURCERY_APP="${PROJECT_DIR}/../external/objectbox-swift-generator/bin/Sourcery.app"
SOURCERY="${SOURCERY_APP}/Contents/MacOS/Sourcery"

EXPECTED_DIR="${MYDIR}/expected"
TESTPROJECT="${MYDIR}/ToolTestProject.xcodeproj"
MYOUTPUTDIR="${MYDIR}/generated/"

mkdir -p $MYOUTPUTDIR

cd ${BUILT_PRODUCTS_DIR}

test_target_num () {
    local FAIL=0  # yuck, FAIL is also a global var

    echo "note: ******************** $2: $1 ********************"

    MODEL_FILE_BEFORE="${EXPECTED_DIR}/model/model${2}.before.json"
    MODEL_FILE_EXPECTED="${EXPECTED_DIR}/model/model${2}.json"
    MODEL_FILE_ACTUAL="${BUILT_PRODUCTS_DIR}/model${2}.json"
    
    DUMP_FILE_EXPECTED="${EXPECTED_DIR}/schema-dump/schemaDump${2}.txt"
    DUMP_FILE_ACTUAL="${MYOUTPUTDIR}/schemaDump${2}.txt"
    
    ENTITY_INFO_FILE_EXPECTED="${EXPECTED_DIR}/entity-info/EntityInfo.generated${2}.swift"
    ENTITY_INFO_FILE_ACTUAL="${MYOUTPUTDIR}/EntityInfo.generated${2}.swift"

    if [[ -f "$MODEL_FILE_BEFORE" ]]; then
        cp "$MODEL_FILE_BEFORE" "$MODEL_FILE_ACTUAL"
    elif [[ -f "$MODEL_FILE_EXPECTED" ]]; then
        cp "$MODEL_FILE_EXPECTED" "$MODEL_FILE_ACTUAL"
    elif [[ -f "$MODEL_FILE_ACTUAL" ]]; then
        rm "$MODEL_FILE_ACTUAL" # Make sure we get a fresh one even after failed tests.
    fi

    echo "// Ensure there's no leftover code from previous tests." > "$ENTITY_INFO_FILE_ACTUAL"

    echo "$SOURCERY --xcode-project \"$TESTPROJECT\" --xcode-target \"ToolTestProject${2}\" --model-json \"$MODEL_FILE_ACTUAL\" --debug-parsetree \"$DUMP_FILE_ACTUAL\" --output \"${ENTITY_INFO_FILE_ACTUAL}\" --disableCache"
    $SOURCERY --xcode-project "$TESTPROJECT" --xcode-target "ToolTestProject${2}" --model-json "$MODEL_FILE_ACTUAL" --debug-parsetree "$DUMP_FILE_ACTUAL" --output "${ENTITY_INFO_FILE_ACTUAL}" --disableCache

    if [ -f "$MODEL_FILE_EXPECTED" ]; then
        cmp --silent "$MODEL_FILE_ACTUAL" "$MODEL_FILE_EXPECTED"
        if [ $? -eq 0 ]; then
            echo "note: $2: $1: Model files match."
        else
            echo "error: $2: $1: Model files DIFFERENT!"

            echo "====="
            diff "$MODEL_FILE_ACTUAL" "$MODEL_FILE_EXPECTED"
            echo "opendiff \"$MODEL_FILE_ACTUAL\" \"$MODEL_FILE_EXPECTED\" -merge \"$MODEL_FILE_EXPECTED\""
#             echo "===== $MODEL_FILE_ACTUAL ====="
#             cat "$MODEL_FILE_ACTUAL"
#             echo "===== $MODEL_FILE_EXPECTED ====="
#             cat "$MODEL_FILE_EXPECTED"
            echo "====="
            FAIL=1
        fi
    fi

    if [ -e "$ENTITY_INFO_FILE_EXPECTED" ]; then
        cmp --silent "$ENTITY_INFO_FILE_ACTUAL" "$ENTITY_INFO_FILE_EXPECTED"
        if [ $? -eq 0 ]; then
            echo "note: $2: $1: Output files match."
        else
            echo "error: $2: $1: Output files DIFFERENT!"

            echo "====="
            diff "$ENTITY_INFO_FILE_ACTUAL" "$ENTITY_INFO_FILE_EXPECTED"
#            echo "opendiff \"$ENTITY_INFO_FILE_ACTUAL\" \"$ENTITY_INFO_FILE_EXPECTED\" -merge \"$ENTITY_INFO_FILE_EXPECTED\""
#             echo "===== $ENTITY_INFO_FILE_ACTUAL ====="
#             cat "$ENTITY_INFO_FILE_ACTUAL"
#             echo "===== $ENTITY_INFO_FILE_EXPECTED ====="
#             cat "$ENTITY_INFO_FILE_EXPECTED"
            echo "====="
            FAIL=1
        fi
    fi

    if [ -e "$DUMP_FILE_EXPECTED" ]; then
        cmp --silent "$DUMP_FILE_ACTUAL" "$DUMP_FILE_EXPECTED"
        if [ $? -eq 0 ]; then
            echo "note: $2: $1: Schema dumps match."
        else
            echo "error: $2: $1: Schema dumps DIFFERENT!"

            echo "====="
            echo "opendiff \"$DUMP_FILE_ACTUAL\" \"$DUMP_FILE_EXPECTED\" -merge \"$DUMP_FILE_EXPECTED\""
#             echo "===== $DUMP_FILE_ACTUAL ====="
#             cat "$DUMP_FILE_ACTUAL"
#             echo "===== $DUMP_FILE_EXPECTED ====="
#             cat "$DUMP_FILE_EXPECTED"
            echo "====="
            FAIL=1
        fi
    fi

    if [ $FAIL -eq 0 ]; then
        xcodebuild FRAMEWORK_SEARCH_PATHS="${BUILT_PRODUCTS_DIR}" -quiet -project "$TESTPROJECT" -target "ToolTestProject${2}" CONFIGURATION_BUILD_DIR="${BUILT_PRODUCTS_DIR}"
        if [ $? -eq 0 ]; then
            echo "note: $2: $1: Built test target."
        else
            echo "error: $2: $1: Build failed."
            FAIL=1
        fi
    else
        echo "error: $2: $1: Skipping build."
    fi

    TEST_EXECUTABLE="${BUILT_PRODUCTS_DIR}/ToolTestProject${2}"

    if [ $FAIL -eq 0 ]; then
        if [[ ! -f "${TEST_EXECUTABLE}" ]]; then
            echo "error: $2: $1: Can't find executable '${TEST_EXECUTABLE}'."
            FAIL=1
        else
            echo "DYLD_FRAMEWORK_PATH=\"${BUILT_PRODUCTS_DIR}\" \"${TEST_EXECUTABLE}\" \"$1\""
            DYLD_FRAMEWORK_PATH="${BUILT_PRODUCTS_DIR}" "${TEST_EXECUTABLE}" "$1"
            RESULT=$?
            if [ $RESULT -eq 0 ]; then
                echo "note: $2: $1: Ran test executable."
            else
                echo "error: $2: $1: Running test failed with $RESULT ."
                FAIL=1
            fi
        fi
    else
        echo "error: $2: $1: Skipping execution, build already failed."
    fi

    if [ $FAIL == 0 ]; then
        rm -f "$MODEL_FILE_ACTUAL"
        rm -f "${MODEL_FILE_ACTUAL}.bak"
        rm -f "$ENTITY_INFO_FILE_ACTUAL"
        rm -f "$DUMP_FILE_ACTUAL"
        
        echo "note: $2: $1: Cleaning up."
    else
        echo "note: $2: $1: Failed with result $FAIL ."
    fi

    return $FAIL
}

fail_codegen_target_num () {
    local FAIL=0  # yuck, FAIL is also a global var

    echo "note: ******************** $2: $1 ********************"

    MODEL_FILE_EXPECTED="${EXPECTED_DIR}/model/model${2}.json"
    ORIGINALMESSAGESFILE="${EXPECTED_DIR}/model/messages${2}.log"
    MODEL_FILE_BEFORE="${EXPECTED_DIR}/model/model${2}.before.json"
    MODEL_FILE_ACTUAL="${BUILT_PRODUCTS_DIR}/model${2}.json"
    TESTMESSAGESFILE="${BUILT_PRODUCTS_DIR}/messages${2}.log"
    DUMP_FILE_EXPECTED="${EXPECTED_DIR}/schema-dump/schemaDump${2}.txt"
    DUMP_FILE_ACTUAL="${MYOUTPUTDIR}/schemaDump${2}.txt"
    ENTITY_INFO_FILE_ACTUAL="${MYOUTPUTDIR}/EntityInfo.generated${2}.swift"
    ORIGINALXCODELOGFILE="${MYDIR}/xcode${2}.log"
    TESTXCODELOGFILE="${BUILT_PRODUCTS_DIR}/xcode${2}.log"

    if [[ -f "$MODEL_FILE_BEFORE" ]]; then
        cp "$MODEL_FILE_BEFORE" "$MODEL_FILE_ACTUAL"
    elif [[ -f "$MODEL_FILE_EXPECTED" ]]; then
        cp "$MODEL_FILE_EXPECTED" "$MODEL_FILE_ACTUAL"
    elif [[ -f "$MODEL_FILE_ACTUAL" ]]; then
        rm "$MODEL_FILE_ACTUAL" # Make sure we get a fresh one even after failed tests.
    fi

    echo "// Ensure there's no leftover code from previous tests." > "$ENTITY_INFO_FILE_ACTUAL"

    echo "$SOURCERY --xcode-project \"$TESTPROJECT\" --xcode-target \"ToolTestProject${2}\" --model-json \"$MODEL_FILE_ACTUAL\" --debug-parsetree \"$DUMP_FILE_ACTUAL\" --output \"${ENTITY_INFO_FILE_ACTUAL}\" --disableCache"
    $SOURCERY --xcode-project "$TESTPROJECT" --xcode-target "ToolTestProject${2}" --model-json "$MODEL_FILE_ACTUAL" --debug-parsetree "$DUMP_FILE_ACTUAL" --output "${ENTITY_INFO_FILE_ACTUAL}" --disableCache > "$TESTMESSAGESFILE" 2>&1

    if [ -e "$ORIGINALMESSAGESFILE" ]; then
        cmp --silent "$TESTMESSAGESFILE" "$ORIGINALMESSAGESFILE"
        if [ $? -eq 0 ]; then
            echo "note: $2: $1: Output as expected."
        else
            echo "error: $2: $1: Output DIFFERENT!"

            echo "====="
            echo "opendiff \"$TESTMESSAGESFILE\" \"$ORIGINALMESSAGESFILE\" -merge \"$ORIGINALMESSAGESFILE\""
#             echo "===== $TESTMESSAGESFILE ====="
#             cat "$TESTMESSAGESFILE"
#             echo "===== $ORIGINALMESSAGESFILE ====="
#             cat "$ORIGINALMESSAGESFILE"
            echo "====="
            FAIL=1
        fi
    fi

    if [[ -f "$MODEL_FILE_BEFORE" ]]; then
        cmp --silent "$MODEL_FILE_ACTUAL" "$MODEL_FILE_EXPECTED"
        if [ $? -eq 0 ]; then
            echo "note: $2: $1: Model files match."
        else
            echo "error: $2: $1: Model files DIFFERENT!"

            echo "====="
            echo "opendiff \"$MODEL_FILE_ACTUAL\" \"$MODEL_FILE_EXPECTED\" -merge \"$MODEL_FILE_EXPECTED\""
#             echo "===== $MODEL_FILE_ACTUAL ====="
#             cat "$MODEL_FILE_ACTUAL"
#             echo "===== $MODEL_FILE_EXPECTED ====="
#             cat "$MODEL_FILE_EXPECTED"
            echo "====="
            FAIL=1
        fi
    fi
    
    if [ $FAIL -eq 0 ]; then
        if [ -e "$ORIGINALXCODELOGFILE" ]; then
            xcodebuild FRAMEWORK_SEARCH_PATHS="${BUILT_PRODUCTS_DIR}" -quiet -project "$TESTPROJECT" -target "ToolTestProject${2}" CONFIGURATION_BUILD_DIR="${BUILT_PRODUCTS_DIR}" > "$TESTXCODELOGFILE"
        
            OLDPWD="`pwd`"
            cd "$MYDIR"
            GITROOT=`git rev-parse --show-toplevel`
            cd "$OLDPWD"
            #sed -i "$TESTXCODELOGFILE" 's:$GITROOT:ROOT:'
        
            cmp --silent "$TESTXCODELOGFILE" "$ORIGINALXCODELOGFILE"
            if [ $? -eq 0 ]; then
                echo "note: $2: $1: Xcode log files match."
            else
                echo "error: $2: $1: Xcode log files DIFFERENT!"

                echo "====="
                echo "opendiff \"$TESTXCODELOGFILE\" \"$ORIGINALXCODELOGFILE\" -merge \"$ORIGINALXCODELOGFILE\""
#                 echo "===== $TESTXCODELOGFILE ====="
#                 cat "$TESTXCODELOGFILE"
#                 echo "===== $ORIGINALXCODELOGFILE ====="
#                 cat "$ORIGINALXCODELOGFILE"
                echo "====="
                FAIL=1
            fi
        else
            echo "note: $2: $1: Skipping build. No file at $ORIGINALXCODELOGFILE."
        fi
    else
        echo "note: $2: $1: Skipping build. Failed previously"
    fi

    if [ $FAIL == 0 ]; then
        rm -f "$MODEL_FILE_ACTUAL"
        rm -f "$ENTITY_INFO_FILE_ACTUAL"
        rm -f "$DUMP_FILE_ACTUAL"
        rm -f "$TESTMESSAGESFILE"
        rm -f "$TESTXCODELOGFILE"
        
        echo "note: $2: $1: Cleaning up."
    else
        echo "note: $2: $1: Failed with result $FAIL ."
    fi

    return $FAIL
}


FAIL=0

cd "${MYOUTPUTDIR}"

test_target_num "Simple Model" 1 || ((FAIL++))
test_target_num "Subclassed Model" 2 || ((FAIL++))
test_target_num "Annotated minimal entity" 3 || ((FAIL++))
test_target_num "Un-annotated minimal entity" 4 || ((FAIL++))
test_target_num "Two IDs one annotated" 5 || ((FAIL++))
fail_codegen_target_num "Two IDs both annotated" 6 || ((FAIL++))
fail_codegen_target_num "Two IDs none annotated" 7 || ((FAIL++))
fail_codegen_target_num "Empty Entity" 8 || ((FAIL++))
test_target_num "ID and 2 strings entity" 9 || ((FAIL++))
fail_codegen_target_num "NameInDb collision with other property" 10 || ((FAIL++))
fail_codegen_target_num "Entity with string but no ID" 11 || ((FAIL++))
test_target_num "Remove A Property" 12 || ((FAIL++))
test_target_num "Remove A Property and add one at same time" 13 || ((FAIL++))
test_target_num "Add a Property after having removed one" 14 || ((FAIL++))
test_target_num "Remove an index from a property" 15 || ((FAIL++))
test_target_num "Add and remove an index in one go" 16 || ((FAIL++))
test_target_num "Add an index after having removed one" 17 || ((FAIL++))
test_target_num "Rename an entity" 18 || ((FAIL++))
fail_codegen_target_num "Entity UID printing" 19 || ((FAIL++))
fail_codegen_target_num "New Entity with empty UID" 20 || ((FAIL++))
test_target_num "Rename a property" 21 || ((FAIL++))
fail_codegen_target_num "Property UID printing" 22 || ((FAIL++))
fail_codegen_target_num "New Property with empty UID" 23 || ((FAIL++))
fail_codegen_target_num "New Property with UID" 24 || ((FAIL++))
test_target_num "Read/write all our data types" 25 || ((FAIL++))
test_target_num "Ensure running codegen on unchanged file changes nothing" 26 || ((FAIL++))
test_target_num "Ensure assigning a previously proposed UID works [Change/Reset]" 27 || ((FAIL++))
test_target_num "Ensure moving properties changes nothing" 28 || ((FAIL++))
test_target_num "Ensure moving entities changes nothing" 29 || ((FAIL++))
test_target_num "Unique Entity Exception Test" 30 || ((FAIL++))
test_target_num "Struct Entity Test" 31 || ((FAIL++))
test_target_num "UInt64 as ID Test" 32 || ((FAIL++))
test_target_num "Data and [UInt8] Test" 33 || ((FAIL++))

test_target_num "Converter Test" 34 || ((FAIL++))
test_target_num "Enum Test" 35 || ((FAIL++))
test_target_num "Standalone Relations" 36 || ((FAIL++))
test_target_num "Standalone Backlinks" 37 || ((FAIL++))
test_target_num "Edit ToOne Backlinks" 38 || ((FAIL++))
test_target_num "Edit ToOne Backlinks Structs" 39 || ((FAIL++))
test_target_num "Standalone Backlinks Structs" 40 || ((FAIL++))
fail_codegen_target_num "ToOne Backlink annotation wrong" 41 || ((FAIL++))
test_target_num "Standalone Relation Queries" 42 || ((FAIL++))
test_target_num "ToOne Relation Queries" 43 || ((FAIL++))
test_target_num "many-to-many reset" 44 || ((FAIL++))
test_target_num "many-to-many backlink reset" 45 || ((FAIL++))
test_target_num "Threaded ToOne backlink edit" 46 || ((FAIL++))
test_target_num "Threaded Many-to-many edit" 47 || ((FAIL++))
test_target_num "Threaded Many-to-many backlink edit" 48 || ((FAIL++))
test_target_num "Untyped IDs and queries 1" 49 || ((FAIL++))
test_target_num "Untyped IDs and queries 2" 50 || ((FAIL++))
#fail_codegen_target_num "Typed IDs still enforce type?" 51 || ((FAIL++))

fail_codegen_target_num "Ensure we don't write JSON before ID errors" 52 || ((FAIL++))
test_target_num "ToOne Backlink ensure applyToDb is needed" 53 || ((FAIL++))
test_target_num "ToMany ensure applyToDb is needed" 54 || ((FAIL++))
test_target_num "ToMany Backlink ensure applyToDb is needed" 55 || ((FAIL++))
test_target_num "Swift Property Wrappers are treated as wrapped type" 56 || ((FAIL++))
test_target_num "Optional Template Syntax recognized as optional" 57 || ((FAIL++))

echo "note: Finished tests with $FAIL failures"

exit $FAIL
