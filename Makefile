SHELL := /bin/bash

# Read version from pubspec.yaml (e.g. "1.1.1+3" -> "1.1.1+3").
VERSION := $(shell awk '/^version:/ { print $$2; exit }' pubspec.yaml)
SYMBOLS_DIR := build/symbols/$(VERSION)
ARTIFACTS_DIR := release-artifacts/$(VERSION)

.PHONY: help release arm64 install clean

help:
	@echo "Available targets:"
	@echo "  make release  Build obfuscated, per-ABI release APKs into $(ARTIFACTS_DIR)/"
	@echo "  make arm64    Same as release, but only keep the arm64-v8a APK"
	@echo "  make install  Install arm64-v8a release APK to the connected device"
	@echo "  make clean    flutter clean + remove release-artifacts/"

release:
	@echo "==> Building release APKs for v$(VERSION)"
	flutter build apk --release \
		--split-per-abi \
		--obfuscate --split-debug-info=$(SYMBOLS_DIR)
	@mkdir -p "$(ARTIFACTS_DIR)"
	@cp build/app/outputs/flutter-apk/app-*-release.apk "$(ARTIFACTS_DIR)/"
	@echo
	@echo "==> Artifacts in $(ARTIFACTS_DIR)/"
	@ls -lh "$(ARTIFACTS_DIR)" | awk 'NR>1 {print "    " $$NF "  " $$5}'
	@echo
	@echo "==> Debug symbols in $(SYMBOLS_DIR)/ (keep these to decode release crashes)"

arm64: release
	@find "$(ARTIFACTS_DIR)" -maxdepth 1 -type f -name 'app-*-release.apk' \
		! -name 'app-arm64-v8a-release.apk' -delete
	@echo "==> Kept only $(ARTIFACTS_DIR)/app-arm64-v8a-release.apk"

install:
	flutter install --release --use-application-binary \
		"$(ARTIFACTS_DIR)/app-arm64-v8a-release.apk"

clean:
	flutter clean
	rm -rf release-artifacts
