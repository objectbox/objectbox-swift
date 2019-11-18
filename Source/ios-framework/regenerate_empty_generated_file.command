#!/bin/zsh

my_dir=`dirname "$0"`

sourcery_dir="${my_dir}/../external/objectbox-swift-generator/"
sourcery_binary="${sourcery_dir}/bin/Sourcery.app/Contents/MacOS/Sourcery"
dummy_source_file="${my_dir}/cocoapod/dummy.swift"
model_json_file="$my_dir/cocoapod/model.json"

echo "// dummy source file." > "$dummy_source_file"

"${sourcery_binary}" --output "$my_dir/cocoapod/empty.generated.swift" --model-json "$model_json_file" --xcode-module "MyApp" --sources "$dummy_source_file"

rm "$dummy_source_file"
rm "$model_json_file"