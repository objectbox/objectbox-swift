#!/usr/bin/env bash
set -e

# macOS does not have realpath and readlink does not have -f option, so do this instead:
myDir=$( cd "$(dirname "$0")" ; pwd -P )

cd "${myDir}/ios-framework"
dir_build="${myDir}/build-deploy"
mkdir -p "$dir_build"

function build_archive() {
  echo "************* Building archive for $1 $2 (${3:-$1}) *************"
  xcodebuild archive -scheme "$1" -destination "$2" -archivePath "$dir_build/${3:-$1}" \
    SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
}

build_archive "ObjectBox-macOS" "platform=macOS"
build_archive "ObjectBox-iOS" "generic/platform=iOS"
build_archive "ObjectBox-iOS" "generic/platform=iOS Simulator" "ObjectBox-iOS-Sim"

echo "************* Building XCFramework *************"
path_in_xcarchive="Products/Library/Frameworks/ObjectBox.framework"
dir_xcframework="$dir_build/ObjectBox.xcframework"
rm -rf "$dir_xcframework"
xcodebuild -create-xcframework -output "$dir_xcframework" \
 -framework "$dir_build/ObjectBox-macOS.xcarchive/$path_in_xcarchive" \
 -framework "$dir_build/ObjectBox-iOS.xcarchive/$path_in_xcarchive" \
 -framework "$dir_build/ObjectBox-iOS-Sim.xcarchive/$path_in_xcarchive"

zip -r "$dir_xcframework.zip" "$dir_xcframework"

ls -lh "$dir_xcframework.zip"