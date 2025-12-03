#!/usr/bin/env bash

set -e

# Runs the generator for Entities.swift and RelatedEntities.swift to (re)generate
# the EntityInfo.generated.swift file and the model.json file.

# Get and change to the directory of this script, regardless of the working directory
CURR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_PATH="$CURR_PATH"
GENERATOR_PATH="$CURR_PATH/../../../external/objectbox-swift-generator"
GENERATED_PATH="$CURR_PATH"
SOURCERY_PATH="$GENERATOR_PATH/bin/Sourcery.app/Contents/MacOS/Sourcery"

echo "Using generator version $("$SOURCERY_PATH" --version)"

"$SOURCERY_PATH" --verbose --no-statistics --disableCache --prune --sources "$CURR_PATH/Entities.swift" --sources "$CURR_PATH/RelatedEntities.swift" --model-json "$CURR_PATH/model.json" --output "$GENERATED_PATH"

echo ""
echo "ℹ️  Review EntityInfo.generated.swift and restore changes required for testing!"
