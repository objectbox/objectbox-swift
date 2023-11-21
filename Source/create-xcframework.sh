#!/usr/bin/env bash
set -e

myDir=$( readlink -f "$(dirname "$0")" )
cd "${myDir}/ios-framework"
dir_build="${myDir}/build-deploy"
mkdir -p "$dir_build"

# Since Xcode 15 xcodebuild expects canonical paths. 
# mktemp creates in /var which is actually /private/var on macOS.
derived_data_path=$( readlink -f $( mktemp -d ) )
mkdir -p $derived_data_path

echo "dir_build=$dir_build"
echo "derived_data_path=$derived_data_path"

xcodebuild -version

function build() {
  echo "************* Building archive for $1 $2 (${3:-$1}) *************"
  xcrun xcodebuild build \
    -project ObjectBox.xcodeproj \
    -scheme "$1" \
    -destination "$2" \
    -configuration Release \
    -skipUnavailableActions \
    -derivedDataPath "${derived_data_path}" \
    -quiet
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