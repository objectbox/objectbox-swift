#!/usr/bin/env bash

# Script that is used by CI to build the static libs, or by external users to download a build from
# Github. Will do nothing if there already is a copy of the static libs in external.
#
# Adjust the 'version' variable as needed to get the right version for the current code.
#

set -e

# macOS does not have realpath and readlink does not have -f option, so do this instead:
my_dir=$( cd "$(dirname "$0")" ; pwd -P )

cd "$my_dir"
code_dir="${my_dir}/external/objectbox/"
dest_dir="${my_dir}/external/objectbox-static/"

# Build?
if [ -d "$code_dir" ]; then
    echo "Have repository, building."
    "$code_dir/xcode/build_objectbox_core.command" "$dest_dir" release 
    exit
fi
    
# Nothing to build, so download instead
if [ ! -d "${dest_dir}" ] || [ ! -e "${dest_dir}/libObjectBoxCore-iOS.a" ]; then
    version=1.3.1
    core_version=0.9.1
    archive_path="${my_dir}/external/objectbox-static.zip"
    OBXLIB_URL_apple_static="https://github.com/objectbox/objectbox-swift/releases/download/v${version}/ObjectBoxCore-static-${core_version}.zip"

    mkdir -p "${dest_dir}"
    
    curl -L --fail "${OBXLIB_URL_apple_static}" --output "${archive_path}"
    
    cd "${dest_dir}"
    unzip "${archive_path}"
    
    if [ -d "${dest_dir}/build-artifacts/" ]; then
        mv "${dest_dir}/build-artifacts/"* "${dest_dir}/"
        rm -r "${dest_dir}/build-artifacts/"
    fi
    
    rm "${archive_path}"
fi
