#!/bin/bash

source "$(dirname "$0")/helpers.sh"

test_buildFailsWithoutDerivedDataEnv() {
	# Run setup so projects/schemes are cached
	xcli-tool setup &> /dev/null

	# Populate selected* files directly (config --device has no non-interactive mode)
	printf "TestProject.xcodeproj" > .xcli/selectedProject
	xcli-tool config --scheme "TestProject" &> /dev/null
	mock_fzf "iPhone 16"
	xcli-tool config --device &> /dev/null
	xcli-tool config --build-option build &> /dev/null

	# Verify selected files are populated
	[[ -s .xcli/selectedProject ]] || fail "selectedProject should be populated"
	[[ -s .xcli/selectedScheme ]] || fail "selectedScheme should be populated"
	[[ -s .xcli/selectedDevice ]] || fail "selectedDevice should be populated"

	# Explicitly unset XCODE_CUSTOM_DERIVED_DATA
	unset XCODE_CUSTOM_DERIVED_DATA

	local output
	output=$(xcli-tool build 2>&1)
	local rc=$?

	# Should not return success
	[[ $rc -ne 0 ]] || fail "build should fail when XCODE_CUSTOM_DERIVED_DATA is not set, but exited with code $rc"

	# Should print error about missing env variable
	echo "$output" | grep "XCODE_CUSTOM_DERIVED_DATA" || fail "build should mention XCODE_CUSTOM_DERIVED_DATA not set, got: $output"

	# No .build directory should be created
	[[ ! -d .build ]] || fail ".build folder should not be created when build fails early"
}

test_buildFailsWithoutConfig() {
	[[ ! -f .xcli/selectedProject ]] || fail "selectedProject should not exist"
	[[ ! -f .xcli/selectedScheme ]] || fail "selectedScheme should not exist"
	[[ ! -f .xcli/selectedDevice ]] || fail "selectedDevice should not exist"

	# Mock XCODE_CUSTOM_DERIVED_DATA so DerivedData path is well-formed
	export XCODE_CUSTOM_DERIVED_DATA="DerivedData"

	local output
	output=$(xcli-tool build 2>&1)
	local rc=$?

	# Should not return success
	[[ $rc -ne 0 ]] || fail "build should fail when config is not run, but exited with code $rc"

	# Should print error about missing config
	echo "$output" | grep "No project selected" || fail "build should mention missing project, got: $output"

	# No build.log should be produced
	[[ ! -f .build/build.log ]] || fail "build.log should not exist when build fails early"

	# No DerivedData folder should be populated
	[[ ! -d DerivedData ]] || fail "DerivedData folder should not be created when build fails early"

	# Clean up mocked env var
	unset XCODE_CUSTOM_DERIVED_DATA
}
