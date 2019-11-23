#!/bin/bash

PRODUCTS_PATH="Carthage"
MAKE_TARGET_NAME="build_framework_verbose"
SOURCE_GITHUB="https://github.com/objectbox/objectbox-swift"
LICENSES="Apache 2.0, ObjectBox Binary License"

# Detect which version of Swift (well, Xcode) has been selected using
# sudo xcode-select --switch /Applications/Xcode10.app or whatever:

if [ "`xcrun swift --version | grep -o '5.0.1'`" == "5.0.1" ]; then
    SWIFT_VERSION="5.0.1"
    POD_NAME="ObjectBox501"
else
    SWIFT_VERSION="5.1"
    POD_NAME="ObjectBox"
fi

# macOS does not have realpath and readlink does not have -f option, so do this instead:
my_dir=$( cd "$(dirname "$0")" ; pwd -P )

if [ "$TERM" == "" ] || [ "$TERM" == "dumb" ]; then
    SMSO=""
    RMSO=""
    BEL=""
    GREEN=""
    RMGREEN=""
    GRAY=""
    RMGRAY=""
    RED=""
    RMRED=""
else
    SMSO="$(tput smso)"
    RMSO="$(tput rmso)"
    BEL="$(tput bel)"
    GREEN="$(tput smso; tput setaf 2)"
    RMGREEN="$(tput rmso; tput sgr0)"
    GRAY="$(tput smso; tput setaf 7)"
    RMGRAY="$(tput rmso; tput sgr0)"
    RED="$(tput setaf 9; tput smso)"
    RMRED="$(tput rmso; tput sgr0)"
fi

DEFAULT_VERSION=`defaults read io.objectbox.make-podspec-script ReleaseVersion 2> /dev/null`
if [ -z "$DEFAULT_VERSION" ]; then
    DEFAULT_VERSION="1.0.0"
fi


if [[ -z "$1" ]]; then
    echo "Please enter a version number for this release (like 1.0 or 1.2rc.5): [${DEFAULT_VERSION}]"
    echo -n "> $BEL"
    read VERSION
    echo ""
else
    VERSION="$1"
fi

if [ -z "$VERSION" ]; then
    VERSION="$DEFAULT_VERSION"
else
    defaults write io.objectbox.make-podspec-script ReleaseVersion -string "$VERSION"
fi

rm -rf "$my_dir/../Carthage/Build/"
rm -rf "$my_dir/../build/"
if [ -d "$my_dir/../../external/objectbox/cbuild" ]; then
    rm -rf "$my_dir/../../external/objectbox/cbuild"
fi

SOURCERY_DIR="`dirname $0`/../../external/objectbox-swift-generator/"
SOURCERY_PATH="$SOURCERY_DIR/bin/Sourcery.app"

echo "Building Sourcery..."
$SOURCERY_DIR/_build.command

DOWNLOAD_BASENAME="${POD_NAME}-framework-${VERSION}"
DOWNLOAD_NAME="${DOWNLOAD_BASENAME}.zip"
CARTHAGE_NAME="${POD_NAME}-${VERSION}-Carthage.framework.zip"
HELPER_FILES_DIR="`dirname $0`/../cocoapod"

BUILD_DIR="$my_dir/../build"

cd `dirname $0`/..

mkdir -p "${BUILD_DIR}" 2>&1 >/dev/null

echo ""
echo "$SMSO Build $RMSO"
echo ""

make "$MAKE_TARGET_NAME"
if [[ $? -ne 0 ]]; then
    echo "$RED Build failed.$RMRED$BEL"
    exit 1
fi

echo ""
echo "$SMSO Generate Zip file $RMSO"
echo ""

xcodebuild -derivedDataPath "${BUILD_DIR}/DerivedData" archive -project ObjectBox.xcodeproj -scheme OBXCodeGen -destination 'platform=OS X,arch=x86_64' -archivePath "${BUILD_DIR}/OBXCodeGen"

cd `dirname $0`/.. # just in case the makefile changed the current directory.

"${my_dir}/../regenerate_empty_generated_file.command"


cd `dirname $0`/.. # just in case the makefile changed the current directory.

echo ""
echo "$SMSO Generate Zip file $RMSO"
echo ""

PRODUCT_RESOURCES_DIR="${BUILD_DIR}/${DOWNLOAD_BASENAME}/Carthage/Build/Mac/OBXCodeGen.framework/Versions/A/Resources/"

# Copy the frameworks and support files:
rm "${BUILD_DIR}"/${DOWNLOAD_NAME} 2>&1 >/dev/null
rm -r "${BUILD_DIR}/"${DOWNLOAD_BASENAME} 2>&1 >/dev/null
mkdir -p "${BUILD_DIR}/"${DOWNLOAD_BASENAME}
rsync -av --exclude='*.dSYM' --exclude='*.bcsymbolmap' "${PRODUCTS_PATH}" "${BUILD_DIR}/"${DOWNLOAD_BASENAME}
cp -R "${BUILD_DIR}/OBXCodeGen.xcarchive/Products/Library/Frameworks/OBXCodeGen.framework" "${BUILD_DIR}/${DOWNLOAD_BASENAME}/Carthage/Build/Mac/"
rsync -av --exclude='*.md' --exclude='*.rb' --include='*.generated.swift' --exclude="*" "${HELPER_FILES_DIR}/" "${PRODUCT_RESOURCES_DIR}"
rsync -av --include='*.md' --exclude="*" "${HELPER_FILES_DIR}/" "${BUILD_DIR}/${DOWNLOAD_BASENAME}/"
cp -R "${HELPER_FILES_DIR}/generate_sources.sh" "${PRODUCT_RESOURCES_DIR}"
cp -R "${HELPER_FILES_DIR}/setup.rb" "${PRODUCT_RESOURCES_DIR}"
cp -R "$SOURCERY_PATH" "${PRODUCT_RESOURCES_DIR}"

# Relative symlinks in old CocoaPods script locations (Carthage doesn't download these):
cd "${BUILD_DIR}/${DOWNLOAD_BASENAME}"
ln -s "Carthage/Build/Mac/OBXCodeGen.framework/Versions/A/Resources/setup.rb" "setup.rb"
ln -s "Carthage/Build/Mac/OBXCodeGen.framework/Versions/A/Resources/generate_sources.sh" "generate_sources.sh"

# Relative symlink at bottom of framework so Carthage users don't need to type the path to Resources:
cd "${BUILD_DIR}/${DOWNLOAD_BASENAME}/Carthage/Build/Mac/OBXCodeGen.framework/"
ln -s "Versions/A/Resources/setup.rb" "setup.rb"

# Zip it all up into a download:
cd "${BUILD_DIR}/"${DOWNLOAD_BASENAME}
zip "${BUILD_DIR}/${DOWNLOAD_NAME}" -r --symlinks * # preserve the relative symlinks in Mac frameworks (avoids huge size and "bundle format is ambiguous (could be app or framework)" error message)
cp "${BUILD_DIR}/${DOWNLOAD_NAME}" "${BUILD_DIR}/${CARTHAGE_NAME}" # Create copy with stupid suffix that Carthage requires.

echo ""
echo "$SMSO Generate Podspec file $RMSO"
echo ""

PODSPEC_PATH="${BUILD_DIR}/${POD_NAME}.podspec"
read -r -d '' POD_CONTENTS1 <<'EOF'
Pod::Spec.new do |spec|
EOF
POD_CONTENTS_NAME="  spec.name         = \"${POD_NAME}\""
POD_CONTENTS_VERSION="  spec.version      = \"$VERSION\""
read -r -d '' POD_CONTENTS2 <<'EOF'
  spec.summary      = "ObjectBox is a superfast, lightweight database for objects."

  spec.description  = <<-DESC
                      ObjectBox is a superfast object-oriented database with strong relation support. ObjectBox is embedded into your Android, Linux, iOS, macOS, or Windows app.
                      DESC
EOF
POD_CONTENTS_HOMEPAGE="  spec.homepage     = \"${SOURCE_GITHUB}\""
POD_CONTENTS_LICENSE="  spec.license      = \"$LICENSES\""
read -r -d '' POD_CONTENTS3 <<'EOF'
  spec.social_media_url   = "https://twitter.com/objectbox_io"

  spec.authors            = [ "ObjectBox" ]

EOF
POD_CONTENTS_SWIFT_VERSION="  spec.swift_version = \"${SWIFT_VERSION}\""
read -r -d '' POD_CONTENTS4 <<'EOF'
  spec.ios.deployment_target = "10.3"
  spec.osx.deployment_target = "10.10"

  # How to obtain the contents
  spec.source = {
EOF
POD_CONTENTS_SOURCE="    :http => '${SOURCE_GITHUB}/releases/download/v$VERSION/${DOWNLOAD_NAME}', "
read -r -d '' POD_CONTENTS5 <<'EOF'
  }
  spec.preserve_paths = '{templates,*.rb,*.sh,*.command,*.app,*.generated.swift,Carthage/Build/Mac/OBXCodeGen.framework}'
  spec.ios.vendored_frameworks = "Carthage/Build/iOS/ObjectBox.framework"
  spec.osx.vendored_frameworks = "Carthage/Build/Mac/ObjectBox.framework"
end
EOF
echo -e "$POD_CONTENTS1\n$POD_CONTENTS_NAME\n$POD_CONTENTS_VERSION\n  $POD_CONTENTS2\n$POD_CONTENTS_HOMEPAGE\n$POD_CONTENTS_LICENSE\n  $POD_CONTENTS3\n$POD_CONTENTS_SWIFT_VERSION\n  $POD_CONTENTS4\n$POD_CONTENTS_SOURCE\n  $POD_CONTENTS5" > ${PODSPEC_PATH}

echo "Repository used: $GRAY ${SOURCE_GITHUB} $RMGRAY"
echo "Licenses mentioned: $GRAY ${LICENSES} $RMGRAY"
echo ""
echo "If you want to test this in a Spec Repo, publish it using"
podspec_dir=`dirname "$PODSPEC_PATH"`
echo "$GRAY cd $podspec_dir $RMGRAY"
podspec_name=`basename "$PODSPEC_PATH"`
echo "$GRAY pod repo push objectbox-swift-spec-staging $podspec_name $RMGRAY"

echo ""
echo "$GREEN Done. $RMGREEN$BEL"
echo ""
