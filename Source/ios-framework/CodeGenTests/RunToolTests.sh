#!/bin/bash

#  RunToolTests.sh
#  ObjectBox Swift
#
#  Created by Uli Kusterer on 07.12.18.
#  

echo -n "note: Starting tests at "
date

MYDIR="${PROJECT_DIR}/CodeGenTests/" # Xcode copies our script into DerivedData before running it, so hard-code our path.

SOURCERY_APP="${PROJECT_DIR}/../external/objectbox-swift-generator/bin/Sourcery.app"
SOURCERY="${SOURCERY_APP}/Contents/MacOS/Sourcery"

TESTPROJECT="${MYDIR}/ToolTestProject.xcodeproj"
MYOUTPUTDIR="${MYDIR}/generated/"

mkdir -p $MYOUTPUTDIR

cd ${BUILT_PRODUCTS_DIR}

test_target_num () {
    FAIL=0

    echo "note: ******************** $2: $1 ********************"

    PREMODELFILE="${MYDIR}/model${2}.before.json"
    ORIGINALMODELFILE="${MYDIR}/model${2}.json"
    TESTMODELFILE="${BUILT_PRODUCTS_DIR}/model${2}.json"
    ORIGINALDUMPFILE="${MYDIR}/schemaDump${2}.txt"
    TESTDUMPFILE="${MYOUTPUTDIR}/schemaDump${2}.txt"
    ORIGINALSOURCEFILE="${MYDIR}/EntityInfo.generated${2}.swift"
    TESTSOURCEFILE="${MYOUTPUTDIR}/EntityInfo.generated${2}.swift"

    if [[ -f "$PREMODELFILE" ]]; then
        cp "$PREMODELFILE" "$TESTMODELFILE"
    elif [[ -f "$ORIGINALMODELFILE" ]]; then
        cp "$ORIGINALMODELFILE" "$TESTMODELFILE"
    fi

    echo "// Ensure there's no leftover code from previous tests." > "$TESTSOURCEFILE"

    echo "$SOURCERY --xcode-project \"$TESTPROJECT\" --xcode-target \"ToolTestProject${2}\" --model-json \"$TESTMODELFILE\" --debug-parsetree \"$TESTDUMPFILE\" --output \"${TESTSOURCEFILE}\" --disableCache"
    $SOURCERY --xcode-project "$TESTPROJECT" --xcode-target "ToolTestProject${2}" --model-json "$TESTMODELFILE" --debug-parsetree "$TESTDUMPFILE" --output "${TESTSOURCEFILE}" --disableCache

    if [ -e "$PREMODELFILE" ]; then
        cmp --silent "$TESTMODELFILE" "$ORIGINALMODELFILE"
        if [ $? -eq 0 ]; then
            echo "note: $1: Model files match."
        else
            echo "error: $1: Model files DIFFERENT!"

            echo "====="
            echo "opendiff \"$TESTMODELFILE\" \"$ORIGINALMODELFILE\" -merge \"$ORIGINALMODELFILE\""
            echo "===== $TESTMODELFILE ====="
            cat "$TESTMODELFILE"
            echo "===== $ORIGINALMODELFILE ====="
            cat "$ORIGINALMODELFILE"
            echo "====="
            FAIL=1
        fi
    fi

    if [ -e "$ORIGINALSOURCEFILE" ]; then
        cmp --silent "$TESTSOURCEFILE" "$ORIGINALSOURCEFILE"
        if [ $? -eq 0 ]; then
            echo "note: $1: Output files match."
        else
            echo "error: $1: Output files DIFFERENT!"

            echo "====="
            echo "opendiff \"$TESTSOURCEFILE\" \"$ORIGINALSOURCEFILE\" -merge \"$ORIGINALSOURCEFILE\""
            echo "===== $TESTSOURCEFILE ====="
            cat "$TESTSOURCEFILE"
            echo "===== $ORIGINALSOURCEFILE ====="
            cat "$ORIGINALSOURCEFILE"
            echo "====="
            FAIL=1
        fi
    fi

    if [ -e "$ORIGINALDUMPFILE" ]; then
        cmp --silent "$TESTDUMPFILE" "$ORIGINALDUMPFILE"
        if [ $? -eq 0 ]; then
            echo "note: $1: Schema dumps match."
        else
            echo "error: $1: Schema dumps DIFFERENT!"

            echo "====="
            echo "opendiff \"$TESTDUMPFILE\" \"$ORIGINALDUMPFILE\" -merge \"$ORIGINALDUMPFILE\""
            echo "===== $TESTDUMPFILE ====="
            cat "$TESTDUMPFILE"
            echo "===== $ORIGINALDUMPFILE ====="
            cat "$ORIGINALDUMPFILE"
            echo "====="
            FAIL=1
        fi
    fi

    if [ $FAIL -eq 0 ]; then
        xcodebuild FRAMEWORK_SEARCH_PATHS="${BUILT_PRODUCTS_DIR}" -quiet -project "$TESTPROJECT" -target "ToolTestProject${2}" CONFIGURATION_BUILD_DIR="${BUILT_PRODUCTS_DIR}"
        if [ $? -eq 0 ]; then
            echo "note: $1: Built test target."
        else
            echo "error: $1: Build failed."
            FAIL=1
        fi
    else
        echo "error: $1: Skipping build."
    fi

    TEST_EXECUTABLE="${BUILT_PRODUCTS_DIR}/ToolTestProject${2}"

    if [ $FAIL -eq 0 ]; then
        if [[ ! -f "${TEST_EXECUTABLE}" ]]; then
            echo "error: $1: Can't find executable '${TEST_EXECUTABLE}'."
            FAIL=1
        else
            echo "DYLD_FRAMEWORK_PATH=\"${BUILT_PRODUCTS_DIR}\" \"${TEST_EXECUTABLE}\" \"$1\""
            DYLD_FRAMEWORK_PATH="${BUILT_PRODUCTS_DIR}" "${TEST_EXECUTABLE}"
            RESULT=$?
            if [ $RESULT -eq 0 ]; then
                echo "note: $1: Ran test executable."
            else
                echo "error: $1: Running test failed with $RESULT ."
                FAIL=1
            fi
        fi
    else
        echo "error: $1: Skipping execution, build already failed."
    fi

    if [ $FAIL == 0 ]; then
        rm -f "$TESTMODELFILE"
        rm -f "${TESTMODELFILE}.bak"
        rm -f "$TESTSOURCEFILE"
        rm -f "$TESTDUMPFILE"
        
        echo "note: $1: Cleaning up."
    else
        echo "note: $1: Failed with result $FAIL ."
    fi

    return $FAIL
}

fail_codegen_target_num () {
    FAIL=0

    echo "note: ******************** $2: $1 ********************"

    ORIGINALMODELFILE="${MYDIR}/model${2}.json"
    ORIGINALMESSAGESFILE="${MYDIR}/messages${2}.log"
    PREMODELFILE="${MYDIR}/model${2}.before.json"
    TESTMODELFILE="${BUILT_PRODUCTS_DIR}/model${2}.json"
    TESTMESSAGESFILE="${BUILT_PRODUCTS_DIR}/messages${2}.log"
    ORIGINALDUMPFILE="${MYDIR}/schemaDump${2}.txt"
    TESTDUMPFILE="${MYOUTPUTDIR}/schemaDump${2}.txt"
    TESTSOURCEFILE="${MYOUTPUTDIR}/EntityInfo.generated${2}.swift"

    if [[ -f "$PREMODELFILE" ]]; then
        cp "$PREMODELFILE" "$TESTMODELFILE"
    elif [[ -f "$ORIGINALMODELFILE" ]]; then
        cp "$ORIGINALMODELFILE" "$TESTMODELFILE"
    fi

    echo "// Ensure there's no leftover code from previous tests." > "$TESTSOURCEFILE"

    echo "$SOURCERY --xcode-project \"$TESTPROJECT\" --xcode-target \"ToolTestProject${2}\" --model-json \"$TESTMODELFILE\" --debug-parsetree \"$TESTDUMPFILE\" --output \"${TESTSOURCEFILE}\" --disableCache"
    $SOURCERY --xcode-project "$TESTPROJECT" --xcode-target "ToolTestProject${2}" --model-json "$TESTMODELFILE" --debug-parsetree "$TESTDUMPFILE" --output "${TESTSOURCEFILE}" --disableCache > "$TESTMESSAGESFILE" 2>&1

    if [ -e "$ORIGINALMESSAGESFILE" ]; then
        cmp --silent "$TESTMESSAGESFILE" "$ORIGINALMESSAGESFILE"
        if [ $? -eq 0 ]; then
            echo "note: $1: Output as expected."
        else
            echo "error: $1: Output DIFFERENT!"

            echo "====="
            echo "opendiff \"$TESTMESSAGESFILE\" \"$ORIGINALMESSAGESFILE\" -merge \"$ORIGINALMESSAGESFILE\""
            echo "===== $TESTMESSAGESFILE ====="
            cat "$TESTMESSAGESFILE"
            echo "===== $ORIGINALMESSAGESFILE ====="
            cat "$ORIGINALMESSAGESFILE"
            echo "====="
            FAIL=1
        fi
    fi

    if [[ -f "$PREMODELFILE" ]]; then
        cmp --silent "$TESTMODELFILE" "$ORIGINALMODELFILE"
        if [ $? -eq 0 ]; then
            echo "note: $1: Model files match."
        else
            echo "error: $1: Model files DIFFERENT!"

            echo "====="
            echo "opendiff \"$TESTMODELFILE\" \"$ORIGINALMODELFILE\" -merge \"$ORIGINALMODELFILE\""
            echo "===== $TESTMODELFILE ====="
            cat "$TESTMODELFILE"
            echo "===== $ORIGINALMODELFILE ====="
            cat "$ORIGINALMODELFILE"
            echo "====="
            FAIL=1
        fi
    fi

    if [ $FAIL == 0 ]; then
        rm -f "$TESTMODELFILE"
        rm -f "$TESTSOURCEFILE"
        rm -f "$TESTDUMPFILE"
        rm -f "$TESTMESSAGESFILE"
        
        echo "note: $1: Cleaning up."
    else
        echo "note: $1: Failed with result $FAIL ."
    fi

    return $FAIL
}


FAIL=0

cd "${MYOUTPUTDIR}"

test_target_num "Simple Model" 1 || FAIL=1
test_target_num "Subclassed Model" 2 || FAIL=1
test_target_num "Annotated minimal entity" 3 || FAIL=1
test_target_num "Un-annotated minimal entity" 4 || FAIL=1
test_target_num "Two IDs one annotated" 5 || FAIL=1
fail_codegen_target_num "Two IDs both annotated" 6 || FAIL=1
fail_codegen_target_num "Two IDs none annotated" 7 || FAIL=1
fail_codegen_target_num "Empty Entity" 8 || FAIL=1
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

echo "note: Finished tests..."

exit $FAIL
