GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m # No color
VERSION?="1.0.0"
XCOPTIONS=-derivedDataPath ./DerivedData
CARTOPTIONS=--derived-data ./DerivedData
ARCH=$(shell uname -m)

all: build_framework

ci: build_framework

test: unit_tests generator_tests
	@echo "$(GREEN)Tests done.$(NC)"

unit_tests: fetch_dependencies u_tests

# Note: not using xcpretty as it swallows test stdout output, not using -quiet for the same reason
u_tests:
	@echo "$(GREEN)Running Unit Tests...$(NC)"
	xcodebuild $(XCOPTIONS) test -project ObjectBox.xcodeproj -scheme ObjectBox-macOS -destination 'platform=macOS,arch=$(ARCH)'
	# TODO FIXME simulator tests are currently broken; reenable:
	#xcodebuild $(XCOPTIONS) build test -project ObjectBox.xcodeproj -scheme ObjectBox-iOS -destination 'platform=iOS Simulator,name=iPhone 11'

generator_tests: fetch_dependencies g_tests

g_tests: build_generator g_tests_run

# This may be useful for iterating on the Generator directly from the main project
g_tests_dirty: build_generator_dirty g_tests_run

build_generator:
	@echo "$(GREEN)Building generator...$(NC)"
	../external/objectbox-swift-generator/_build.command
	@echo "$(GREEN)Generator version:$(NC)"
	../external/objectbox-swift-generator/bin/sourcery --version

build_generator_dirty:
	@echo "$(GREEN)Building generator (dirty)...$(NC)"
	../external/objectbox-swift-generator/_build.command --dirty

g_tests_run:
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
