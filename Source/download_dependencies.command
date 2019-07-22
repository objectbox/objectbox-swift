#!/usr/bin/env bash

# Script that is used by CI to download a recent build of the static libs, or by external users to download a build from
# Github. Will do nothing if there already is a copy of the static libs in external.
#
# Set the CI_API_TOKEN and OBXLIB_URL_apple_static environment variables to have it download from CI instead of Github. 
#
# Adjust the 'version' variable as needed to get the right version for the current code.
#

set -e

version=0.9.0
core_version=0.6.0

my_dir=$(realpath `dirname "$0"`)

cd $my_dir
dest_dir="${my_dir}/external/objectbox-static/"
archive_path="${my_dir}/external/objectbox-static.zip"

#if [ "${OBXLIB_URL_apple_static}" == "" ]; then
    OBXLIB_URL_apple_static="https://github.com/objectbox/objectbox-swift/releases/download/v${version}/ObjectBoxCore-static-${core_version}.zip"
    CI_API_TOKEN=""
    extra_header=""
#else
#    extra_header="-H 'PRIVATE-TOKEN: ${CI_API_TOKEN}'"
#fi
    
if [ ! -d "${dest_dir}" ] || [ ! -e "${dest_dir}/libObjectBoxCore-iOS.a" ]; then
    mkdir -p "${dest_dir}"
    
    curl -L ${extra_header} --fail "${OBXLIB_URL_apple_static}" --output "${archive_path}"
    
    cd "${dest_dir}"
    unzip "${archive_path}"
    
    if [ -d "${dest_dir}/build-artifacts/" ]; then
        mv "${dest_dir}/build-artifacts/"* "${dest_dir}/"
        rm -r "${dest_dir}/build-artifacts/"
    fi
    
    rm "${archive_path}"
fi
