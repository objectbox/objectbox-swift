#!/bin/zsh

# Creates an empty ObjectBox model so that we users have the proper Store constructor

# macOS does not have realpath and readlink does not have -f option, so do this instead:
my_dir=$( cd "$(dirname "$0")" ; pwd -P )

dummy_source_file="${my_dir}/cocoapod/dummy.swift"
model_json_file="${my_dir}/cocoapod/model.json"
output_file="${my_dir}/cocoapod/empty.generated.swift"

## Pre-check: ensure we do not overwrite any existing file

files_to_check=("$dummy_source_file" "$model_json_file")
for file_to_check in $files_to_check; do # ShellCheck SC2128 warning: bash only? seems to work in zsh!?
  if [ -f "$file_to_check" ]; then
      echo "Will not generate empty ObjectBox model; file already exists: $file_to_check"
      exit 0
  fi
done

## Create dummy file to trigger codegen and clean up temp files afterwards
echo "// Temporary dummy source file used to generate code if there are no ObjectBox entity objects" > "$dummy_source_file"

sourcery_binary="${my_dir}/../external/objectbox-swift-generator/bin/Sourcery.app/Contents/MacOS/Sourcery"
"${sourcery_binary}" --output "$output_file" --model-json "$model_json_file" --xcode-module "MyApp" --sources "$dummy_source_file"

rm "$dummy_source_file"
rm "$model_json_file"