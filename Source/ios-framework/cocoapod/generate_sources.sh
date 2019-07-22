#!/bin/zsh

set -e

sourcery=`dirname "$0"`/Sourcery.app/Contents/MacOS/Sourcery

# if this script had parameters, we would look for them here.

## Swallow all arguments until a "--", and forward anything after that to Sourcery:
while [[ $1 != "--" && $1 != "" ]]; do
	shift
done
if [[ $1 == "--" ]]; then
	shift
fi

# Give a default module name if the user didn't specify one in the overrides:
if [[ "$@" != *"--xcode module"* ]]; then
    echo "note: using module name ${PRODUCT_MODULE_NAME}"
    MODULENAME1="--xcode-module"
    MODULENAME2="${PRODUCT_MODULE_NAME}"
else
    MODULENAME1=""
    MODULENAME2=""
fi

# Actually call Sourcery:
if [ -f "$sourcery" ]; then
  "$sourcery" --xcode-project "${PROJECT_FILE_PATH}" --xcode-target "${TARGETNAME}" $MODULENAME1 $MODULENAME2 $@
else
  echo "error: Cannot find Sourcery in the expected location at '$sourcery'"
  exit 1
fi
