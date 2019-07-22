#!/bin/bash

PRODUCTS_PATH="Carthage"
MAKE_TARGET_NAME="build_framework_verbose"
SOURCE_GITHUB="https://github.com/objectbox/objectbox-swift"
LICENSES="Apache 2.0, ObjectBox Binary License"

DEFAULT_VERSION=`defaults read io.objectbox.make-podspec-script ReleaseVersion 2> /dev/null`
if [ -z "$DEFAULT_VERSION" ]; then
    DEFAULT_VERSION="1.0.0"
fi


if [[ -z "$1" ]]; then
    echo "Please enter a version number for this release (like 1.0): [${DEFAULT_VERSION}]"
    echo -n "> $(tput bel)"
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

SOURCERY_DIR="`dirname $0`/../../external/objectbox-swift-generator/"
SOURCERY_PATH="$SOURCERY_DIR/bin/Sourcery.app"

if [ ! -d "$SOURCERY_PATH" ]; then
    echo "Please run $(tput smso; tput setaf 7) $SOURCERY_DIR/_build.command $(tput sgr0) first, to build the code generator."
    exit 1
fi

DOWNLOAD_BASENAME="ObjectBox-framework-${VERSION}"
DOWNLOAD_NAME="${DOWNLOAD_BASENAME}.zip"
HELPER_FILES_DIR="`dirname $0`/../cocoapod"

BUILD_DIR="`dirname $0`/../build"

cd `dirname $0`/..

mkdir -p "${BUILD_DIR}" 2>&1 >/dev/null

echo ""
echo "$(tput smso) Build $(tput rmso)"
echo ""

make "$MAKE_TARGET_NAME"
if [[ $? -ne 0 ]]; then
    echo "$(tput setaf 9; tput smso) Build failed.$(tput rmso; tput sgr0; tput bel)"
    exit 1
fi

cd `dirname $0`/.. # just in case the makefile changed the current directory.

echo ""
echo "$(tput smso) Generate Zip file $(tput rmso)"
echo ""

rm "${BUILD_DIR}"/${DOWNLOAD_NAME} 2>&1 >/dev/null
rm -r "${BUILD_DIR}/"${DOWNLOAD_BASENAME} 2>&1 >/dev/null
mkdir -p "${BUILD_DIR}/"${DOWNLOAD_BASENAME}
rsync -av --exclude='*.dSYM' --exclude='*.bcsymbolmap' "${PRODUCTS_PATH}" "${BUILD_DIR}/"${DOWNLOAD_BASENAME}
rsync -av --include='*.md' --include='*.rb' --exclude="*" "${HELPER_FILES_DIR}/"  "${BUILD_DIR}/"${DOWNLOAD_BASENAME}
cp -R "${HELPER_FILES_DIR}/templates" "${BUILD_DIR}/"${DOWNLOAD_BASENAME}/
cp -R "${HELPER_FILES_DIR}/generate_sources.sh" "${BUILD_DIR}/"${DOWNLOAD_BASENAME}/
cp -R "$SOURCERY_PATH" "${BUILD_DIR}/"${DOWNLOAD_BASENAME}/

cd "${BUILD_DIR}/"${DOWNLOAD_BASENAME}
zip "${BUILD_DIR}/${DOWNLOAD_NAME}" -r --symlinks * # preserve the relative symlinks in Mac frameworks (avoids huge size and "bundle format is ambiguous (could be app or framework)" error message)

echo ""
echo "$(tput smso) Generate Podspec file $(tput rmso)"
echo ""

PODSPEC_PATH="${BUILD_DIR}/ObjectBox.podspec"
read -r -d '' POD_CONTENTS1 <<'EOF'
Pod::Spec.new do |spec|
  spec.name         = "ObjectBox"
EOF
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

  spec.swift_version = "5.0"
  spec.ios.deployment_target = "10.0"
  spec.osx.deployment_target = "10.10"

  # How to obtain the contents
  spec.source = {
EOF
POD_CONTENTS_SOURCE="    :http => '${SOURCE_GITHUB}/releases/download/v$VERSION/${DOWNLOAD_NAME}', "
read -r -d '' POD_CONTENTS4 <<'EOF'
  }
  spec.preserve_paths = '{templates,*.rb,*.sh,*.command,*.app}'
  spec.ios.vendored_frameworks = "Carthage/Build/iOS/ObjectBox.framework"
  spec.osx.vendored_frameworks = "Carthage/Build/Mac/ObjectBox.framework"
end
EOF
echo -e "$POD_CONTENTS1\n$POD_CONTENTS_VERSION\n  $POD_CONTENTS2\n$POD_CONTENTS_HOMEPAGE\n$POD_CONTENTS_LICENSE\n  $POD_CONTENTS3\n$POD_CONTENTS_SOURCE\n  $POD_CONTENTS4" > ${PODSPEC_PATH}

echo "Repository used: $(tput smso; tput setaf 7) ${SOURCE_GITHUB} $(tput sgr0)"
echo "Licenses mentioned: $(tput smso; tput setaf 7) ${LICENSES} $(tput sgr0)"
echo ""
echo "If you want to test this in a Spec Repo, place $(tput smso; tput setaf 7) $PODSPEC_PATH $(tput sgr0) in $(tput smso; tput setaf 7) Specs/ObjectBox/$VERSION/`basename "$PODSPEC_PATH"` $(tput sgr0)"

echo ""
echo "$(tput smso; tput setaf 2) Done. $(tput sgr0; tput bel)"
echo ""
