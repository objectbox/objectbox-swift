#!/usr/bin/env bash
set -eu

if [ "${1:-}" == "brew" ]; then
  echo "Updating brew..."
  brew update
  brew upgrade
  shift
fi

# Install dependencies via homebrew, including carthage (see Brewfile)
brew bundle

# Initialize git submodules
# macOS does not have realpath and readlink does not have -f option, so do this instead:
myDir=$( cd "$(dirname "$0")" ; pwd -P )
cd "${myDir}"

core_dir="external/objectbox"

if [ ! -d "../objectbox.git" ]; then
  if [ -d "${core_dir}" ]; then
    rm -d "${core_dir}"
  fi
  
  echo "Updating git submodules..."
  git submodule update --init --recursive external/SwiftLint external/objectbox-swift-generator
else
  echo "Updating git submodules..."
  git submodule update --init --recursive

  echo "Core submodule status and version string from ObjectStore.cpp:"
  git submodule status "$core_dir"
  grep 'ObjectStore_VERSION = ' "$core_dir/objectbox/src/main/cpp/ObjectStore.cpp"
fi

# Install Xcode command line tools (installed by default with newer versions)
xcode_cli_tools=$(xcode-select 2>&1 --install || true)
if [[ $xcode_cli_tools != *"already installed"* ]]; then
  echo "Trying to install Xcode command line tools returned this message:"
  echo "$xcode_cli_tools"
  exit 1
fi

# Build SwiftLint from source into its `external/SwiftLint/.build` directory.
make build_swiftlint

# Build the code generator binary (including Sourcery)
cd ios-framework
make build_generator
cd ..

# Print Carthage version
cartage_version=$(carthage version || true)
echo "Carthage version: $cartage_version"

# Install gems, including CocoaPods (see Gemfile)
bundle install

# Update CocoaPods repo
cocoapods_version=$(pod --version || true)
echo "Cocoapods version: $cocoapods_version"
pod repo update

# Print CMake version
echo "CMake: $(cmake --version)"

echo "Seems like setup was successful. So, what's next? See the Development section of the README."
