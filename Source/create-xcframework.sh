#!/usr/bin/env bash
set -e

# macOS does not have realpath and readlink does not have -f option, so do this instead:
myDir=$( cd "$(dirname "$0")" ; pwd -P )

cd "${myDir}/ios-framework"
dir_build="${myDir}/build-deploy"
mkdir -p "$dir_build"
derived_data_path=$( mktemp -d )

function build() {
  echo "************* Building archive for $1 $2 (${3:-$1}) *************"
  xcodebuild build \
    -scheme "$1" \
    -destination "$2" \
    -configuration Release \
    -derivedDataPath "${derived_data_path}" \
    -quiet \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
}

build "ObjectBox-macOS" "platform=macOS"
build "ObjectBox-iOS" "generic/platform=iOS"
build "ObjectBox-iOS Simulator" "generic/platform=iOS Simulator"

echo "************* Building XCFramework *************"
path_in_xcarchive="Products/Library/Frameworks/ObjectBox.framework"
dir_xcframework="$dir_build/ObjectBox.xcframework"
rm -rf "$dir_xcframework"

xcodebuild -create-xcframework \
  -output "$dir_xcframework" \
  -framework "${derived_data_path}/Build/Products/Release/ObjectBox.framework" \
  -framework "${derived_data_path}/Build/Products/Release-iphoneos/ObjectBox.framework" \
  -framework "${derived_data_path}/Build/Products/Release-iphonesimulator/ObjectBox.framework"

pushd "$dir_xcframework/.."
zip --symlinks -r -o "$dir_xcframework.zip" "ObjectBox.xcframework"
popd

rm -rf ${derived_data_path}

ls -lh "$dir_xcframework.zip"
xcrun swift package compute-checksum "$dir_xcframework.zip"