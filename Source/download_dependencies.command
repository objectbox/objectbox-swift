#!/usr/bin/env bash

# Script that is used by CI to build the static libs, or by external users to download a build from
# Github. Will do nothing if there already is a copy of the static libs in external.
#
# Adjust the 'version' variable as needed to get the right version for the current code.
#

set -e

version=1.0
core_version=0.7.0

my_dir=`dirname "$0"`
my_dir=`realpath "${my_dir}"`

cd $my_dir
code_dir="${my_dir}/external/objectbox/"
dest_dir="../../../objectbox-static/"
archive_path="${my_dir}/external/objectbox-static.zip"
OBXLIB_URL_apple_static="https://github.com/objectbox/objectbox-swift/releases/download/v${version}/ObjectBoxCore-static-${core_version}.zip"

if [ -d "$code_dir" ]; then
    echo "Have repository, building."
    "$code_dir/xcode/build_objectbox_core.command" "$dest_dir" release 
    exit
fi
    
if [ ! -d "${dest_dir}" ] || [ ! -e "${dest_dir}/libObjectBoxCore-iOS.a" ]; then
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
