GREEN=\033[0;32m
RED=\033[0;31m
BLUE=\033[1;34m
NC=\033[0m # No color
VERSION?="1.0.0"

all: build_framework archive_framework

ci: build_framework

test: unit_tests integration_tests
	@echo "$(BLUE)Tests done.$(NC)"

unit_tests:
	@echo "$(BLUE)Running Unit Tests...$(NC)"
	xcodebuild test -project ObjectBox.xcodeproj -scheme ObjectBox-macOS -destination 'platform=OS X,arch=x86_64'
	xcodebuild build test -project ObjectBox.xcodeproj -scheme ObjectBox-iOS -destination 'platform=iOS Simulator,name=OBX iPhone'

integration_tests:
	@echo "$(BLUE)Integration Tests...$(NC)"
	../external/objectbox-swift-generator/_build.command
	xcodebuild build -project ObjectBox.xcodeproj -scheme CodeGenTests -destination 'platform=OS X,arch=x86_64'

download_statics:
	@echo "$(BLUE)Downloading static libraries...$(NC)"
	@../download_dependencies.command

build_framework: download_statics
	@echo "$(BLUE)Building Frameworks with Carthage...$(NC)"
	@carthage build --no-skip-current --log-path ./xcodelog.txt

build_framework_verbose: download_statics
	@echo "$(BLUE)Building Frameworks with Carthage...$(NC)"
	@carthage build --no-skip-current --verbose

archive_framework:
	@echo "$(BLUE)Archiving Carthage Frameworks...$(NC)"
	@carthage archive ObjectBox

# Consider to pass in VERSION as a parameter here instead of in the jazzy configuration.
# Version used in jazzy for the Dash.app documentation XML feed.
generate_docs:
	@echo "$(BLUE)Generating Swift Docs ...$(NC)"
	@echo ""
	@bundle exec jazzy --clean --config ./docs/jazzy.yaml
