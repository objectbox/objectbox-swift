SWIFT_LINT_PATH=$(shell pwd)/external/SwiftLint
SOURCERY_PATH=$(shell pwd)/external/objectbox-swift-generator
FRAMEWORK_PATH=$(shell pwd)/ios-framework

GREEN=\033[0;32m
RED=\033[0;31m
BLUE=\033[1;34m
NC=\033[0m # No color

all: build_swiftlint build_sourcery

build_swiftlint:
	@echo "$(BLUE)Building SwiftLint...$(NC)"
	@echo $(SWIFT_LINT_PATH)
	(cd "$(SWIFT_LINT_PATH)"; make build)

build_sourcery:
	@echo "$(BLUE)Building Sourcery...$(NC)"
	@echo $(SOURCERY_PATH)
	(cd "$(SOURCERY_PATH)"; rake build)

archive_framework:
	(cd "$(FRAMEWORK_PATH)"; make all)
