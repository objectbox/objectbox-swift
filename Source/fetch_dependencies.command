#!/usr/bin/env bash

# Script that is used by CI to build the static libs, or by external users to download a build from
# Github. Will do nothing if there already is a copy of the static libs in external.
#
# Adjust the 'version' variable as needed to get the right version for the current code.
#

set -e

if [ "${1:-}" == "--verify-only" ]; then
    verify_only=true
    shift
else
    verify_only=false
fi

# macOS does not have realpath and readlink does not have -f option, so do this instead:
my_dir=$( cd "$(dirname "$0")" ; pwd -P )

cd "$my_dir"
code_dir="${my_dir}/external/objectbox"
dest_dir="${my_dir}/external/objectbox-static"

if [ "$verify_only" = true ]; then
  echo "Skipping fetch, only verifying"
else

if [ -d "$code_dir" ]; then # Do we have an existing code repo?
    pushd "$code_dir"  # todo fix this workaround for building into cbuild dir in "our" objectbox-swift dir
    echo "Have repository, building."
    "$code_dir/scripts/apple-build-static-libs.sh" "$dest_dir" release
    popd
else # Download static public release and unzip into $dest
    if [ ! -d "${dest_dir}" ] || [ ! -e "${dest_dir}/libObjectBoxCore-iOS.a" ]; then
        version=1.4.1
        c_version=0.11.0
        archive_path="${my_dir}/external/objectbox-static.zip"
        OBXLIB_URL_apple_static="https://github.com/objectbox/objectbox-swift/releases/download/v${version}/ObjectBoxCore-static-${c_version}.zip"

        mkdir -p "${dest_dir}"

        curl -L --fail "${OBXLIB_URL_apple_static}" --output "${archive_path}"

        pushd "${dest_dir}"
        unzip "${archive_path}"
        popd

        if [ -d "${dest_dir}/build-artifacts/" ]; then
            mv "${dest_dir}/build-artifacts/"* "${dest_dir}/"
            rm -r "${dest_dir}/build-artifacts/"
        fi

        rm "${archive_path}"
    fi
fi
fi # verify_only

# Update the header file actually used by our Swift sources
cp "$dest_dir/objectbox.h" "ios-framework/CommonSource/Internal/objectbox-c.h"

# Print versions for allow verification of built libs (is it the one we expect?)
echo "============================================================================================"
echo "Please check that the found libs are available (macOS, iOS) and contain the expected symbols"
echo "Available libs in '$dest_dir':"
cd ${dest_dir}
for filename in ./*.a; do
  echo ""
  ls -lha "$filename"
  # Match our version/date pattern like "2.6.1-2020-06-09"
  obx_version=$(strings "$filename" | grep "[0-9]\.[0-9]\.[0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]")
  echo "  >> Version found: $obx_version"
  obx_symbols=$(nm -gj "$filename" | grep -c obx_  || true)
  obx_sync_symbols=$(nm -gj "$filename" | grep -c obx_sync_ || true)
  echo "  >> Symbols found: $obx_symbols obx, $obx_sync_symbols obx_sync"
done