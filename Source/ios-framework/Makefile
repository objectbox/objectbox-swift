GREEN=\033[0;32m
RED=\033[0;31m
BLUE=\033[1;34m
NC=\033[0m # No color
VERSION?="1.0.0"
XCOPTIONS=-derivedDataPath ./DerivedData
CARTOPTIONS=--derived-data ./DerivedData

all: build_framework

ci: build_framework

test: unit_tests integration_tests
	@echo "$(BLUE)Tests done.$(NC)"

unit_tests: fetch_dependencies u_tests

u_tests:
	@echo "$(BLUE)Running Unit Tests...$(NC)"
	xcodebuild $(XCOPTIONS) test -project ObjectBox.xcodeproj -scheme ObjectBox-macOS -destination 'platform=macOS,arch=x86_64'
	# TODO FIXME simulator tests are currently broken; reenable:
	#xcodebuild $(XCOPTIONS) build test -project ObjectBox.xcodeproj -scheme ObjectBox-iOS -destination 'platform=iOS Simulator,name=iPhone 11'

integration_tests: fetch_dependencies i_tests

i_tests: build_generator i_tests_run

# This may be useful for iterating on the Generator directly from the main project
i_tests_dirty: build_generator_dirty i_tests_run

build_generator:
	@echo "$(BLUE)Building generator...$(NC)"
	../external/objectbox-swift-generator/_build.command
	@echo "$(BLUE)Generator version:$(NC)"
	../external/objectbox-swift-generator/bin/sourcery --version

build_generator_dirty:
	@echo "$(BLUE)Building generator (dirty)...$(NC)"
	../external/objectbox-swift-generator/_build.command --dirty

i_tests_run:
	@echo "$(BLUE)Integration Tests...$(NC)"
	xcodebuild $(XCOPTIONS) build -project ObjectBox.xcodeproj -scheme CodeGenTests -destination 'platform=macOS,arch=x86_64'

# Note: If ObjectBox core repo is present, it will build; otherwise it will download static libs
fetch_dependencies:
	@echo "$(BLUE)Building/Downloading static libraries...$(NC)"
	@../fetch_dependencies.command

# Carthage by default uses a gibberish name for the log file; but we can adjust it via --log-path
build_framework_log_file: fetch_dependencies
	@echo "$(BLUE)Building Frameworks with Carthage...$(NC)"
	@carthage build $(CARTOPTIONS) --no-skip-current --use-xcframeworks --log-path ./xcodelog.txt

# Carthage calls it "verbose" to have xcode output go to the log, which is what we want in most cases though...
# (E.g. compilation errors should be simple to find without involving another file.)
build_framework: fetch_dependencies
	@echo "$(BLUE)Building Frameworks with Carthage...$(NC)"
	@carthage build $(CARTOPTIONS) --no-skip-current --use-xcframeworks --verbose

# Consider to pass in VERSION as a parameter here instead of in the jazzy configuration.
# Version used in jazzy for the Dash.app documentation XML feed.
generate_docs:
	@echo "$(BLUE)Generating Swift Docs ...$(NC)"
	@echo ""
	@bundle exec jazzy --clean --config ./docs/jazzy.yaml
