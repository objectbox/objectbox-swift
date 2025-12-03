GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m # No color
VERSION?="1.0.0"
# Since Xcode 26 xctest fails to run because it can't find the test bundle
# if the derived data path is on an external drive.
#XCOPTIONS=-derivedDataPath ./DerivedData
CARTOPTIONS=--derived-data ./DerivedData
ARCH=$(shell uname -m)

all: build_framework

test: unit_tests generator_tests
	@echo "$(GREEN)Tests done.$(NC)"

unit_tests: fetch_dependencies u_tests

# Expects an iOS simulator named "iPhone 11" to be configured on the host.
# Note: not using xcpretty as it swallows test stdout output, not using -quiet for the same reason.
# Note: for iOS Simulator always build first to avoid framework not found error (in the test iOS app, unclear why, even though it's built first).
# Since Xcode 26, using the default, shared, Derived Data folder, so at least clean up build artifacts afterwards to reduce disk usage.
u_tests:
	@echo "$(GREEN)Running Unit Tests on macOS...$(NC)"
	xcodebuild $(XCOPTIONS) -project ObjectBox.xcodeproj -scheme ObjectBox-macOS -destination 'platform=macOS,arch=$(ARCH)' test
	@echo "$(GREEN)Running Unit Tests on iOS Simulator...$(NC)"
	xcodebuild $(XCOPTIONS) -project ObjectBox.xcodeproj -scheme 'ObjectBox-iOS Simulator' -destination 'platform=iOS Simulator,name=iPhone 11' build test clean

generator_tests: fetch_dependencies build_generator g_tests

build_generator:
	@echo "$(GREEN)Building generator...$(NC)"
	../external/objectbox-swift-generator/_build.command

# Builds a debug version only for the architecture of this machine, does not clean cache for faster build time
build_generator_debug:
	@echo "$(GREEN)Building generator (debug)...$(NC)"
	../external/objectbox-swift-generator/_build.command --debug

# Runs generator tests. Requires built generator.
# For faster testing might want to comment out unrelated tests in RunToolTests.sh for even faster testing.
g_tests:
	@echo "$(GREEN)Generator version:$(NC)"
	../external/objectbox-swift-generator/bin/sourcery --version
	@echo "$(GREEN)Generator tests...$(NC)"
	xcodebuild $(XCOPTIONS) build -project ObjectBox.xcodeproj -scheme CodeGenTests -destination 'platform=macOS,arch=$(ARCH)'

# Note: If ObjectBox core repo is present, it will build; otherwise it will download static libs
fetch_dependencies:
	@echo "$(GREEN)Building/Downloading static libraries...$(NC)"
	@../fetch_dependencies.command

# Use --verbose to print xcodebuild log output (Note: can not pass through -quiet)
build_framework: fetch_dependencies
	@echo "$(GREEN)Building Frameworks with Carthage...$(NC)"
	@carthage build $(CARTOPTIONS) --no-skip-current --use-xcframeworks --verbose

# Consider to pass in VERSION as a parameter here instead of in the jazzy configuration.
# Version used in jazzy for the Dash.app documentation XML feed.
generate_docs:
	@echo "$(GREEN)Generating Swift Docs ...$(NC)"
	@echo ""
	@bundle exec jazzy --clean --config ./docs/jazzy.yaml
