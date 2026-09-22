#!/bin/bash

source "$(dirname "$0")/helpers.sh"

test_config_failsIfSetupIsNotRun() {
	mock_fzf "TestProjectScheme2"

	[[ ! -f .xcli/schemes ]] || fail "There should not be any scheme file here"

	xcli-tool config --scheme | grep "ERROR: you must run 'setup' before 'config'" \
	|| fail "Config should fail if setup is not run before"
}

test_configInteractive_selectsSchemeCorrectly() {
	mock_fzf "TestProjectScheme2"

	xcli-tool setup &> /dev/null
	xcli-tool config --scheme &> /dev/null

	[[ $(cat .xcli/selectedScheme) == "TestProjectScheme2" ]] || fail "Should have selected correctly the scheme"
}

test_configNonInteractive_selectsSchemeCorrectly() {
	xcli-tool setup &> /dev/null
	xcli-tool config --scheme "TestProjectScheme2" &> /dev/null

	[[ $(cat .xcli/selectedScheme) == "TestProjectScheme2" ]] || fail "Should have selected correctly the scheme"
}

test_configNonInteractiveWithNonExistingScheme_failsWithoutSelectingAnything() {
	xcli-tool setup &> /dev/null
	xcli-tool config --scheme "NonExistingScheme" &> /dev/null && fail "Should not succeed since the scheme is invalid"

	[[ ! -f .xcli/selectedScheme ]] || fail "Should not have selected any scheme" 
}

# === --project tests ===

test_configProjectInteractive_selectsProjectCorrectly() {
	mock_fzf "TestProject.xcodeproj"

	xcli-tool setup &> /dev/null
	xcli-tool config --project &> /dev/null

	[[ $(cat .xcli/selectedProject) == "TestProject.xcodeproj" ]] || fail "Should have selected correctly the project"
}

test_configProjectNonInteractive_selectsProjectCorrectly() {
	xcli-tool setup &> /dev/null
	xcli-tool config --project "TestProject.xcodeproj" &> /dev/null

	[[ $(cat .xcli/selectedProject) == "TestProject.xcodeproj" ]] || fail "Should have selected correctly the project"
}

test_configProjectNonInteractiveWithNonExistingProject_failsWithoutSelectingAnything() {
	xcli-tool setup &> /dev/null
	xcli-tool config --project "NonExistingProject" &> /dev/null && fail "Should not succeed since the project is invalid"

	[[ ! -f .xcli/selectedProject ]] || fail "Should not have created selectedProject for invalid project" || return 0
}

# === --build-option tests ===

test_configBuildOptionNonInteractive_selectsBuildCorrectly() {
	xcli-tool setup &> /dev/null
	xcli-tool config --build-option "build" &> /dev/null

	[[ $(cat .xcli/selectedBuildOption) == "build" ]] || fail "Should have selected 'build' correctly"
}

test_configBuildOptionNonInteractive_selectsBuildForTestCorrectly() {
	xcli-tool setup &> /dev/null
	xcli-tool config --build-option "buildForTest" &> /dev/null

	[[ $(cat .xcli/selectedBuildOption) == "build-for-testing" ]] || fail "Should have selected 'build-for-testing' correctly"
}

test_configBuildOptionNonInteractiveWithInvalidOption_failsWithoutSelectingAnything() {
	xcli-tool setup &> /dev/null
	xcli-tool config --build-option "invalidOption" &> /dev/null && fail "Should not succeed since the build option is invalid"

	[[ ! -f .xcli/selectedBuildOption ]] || fail "Should not have created selectedBuildOption for invalid option" 
}

# === --show tests ===

test_configShowRunBeforeSettingProject_commandFails() {
	xcli-tool setup &> /dev/null
	xcli-tool config --scheme "TestProjectScheme2" &> /dev/null 
	xcli-tool config --build-option "build" &> /dev/null 
	mock_fzf "iPhone 16"
	xcli-tool config --device &> /dev/null

	xcli-tool config --show &> /dev/null 
	if [[ $? == 0 ]]; then
	 fail "Should not succeed if 'project' is not set" 
	else
		exit 0
	fi
}

test_configShowRunBeforeSettingScheme_commandFails() {
	xcli-tool setup &> /dev/null
	xcli-tool config --project "TestProject.xcodeproj" &> /dev/null
	xcli-tool config --build-option "build" &> /dev/null 
	mock_fzf "iPhone 16"
	xcli-tool config --device &> /dev/null

	xcli-tool config --show &> /dev/null 
	if [[ $? == 0 ]]; then
	 fail "Should not succeed if 'scheme' is not set" 
	else
		exit 0
	fi
}

test_configShowRunBeforeSettingBuildOption_commandFails() {
	xcli-tool setup &> /dev/null
	xcli-tool config --project "TestProject.xcodeproj" &> /dev/null
	xcli-tool config --scheme "TestProjectScheme2" &> /dev/null 
	mock_fzf "iPhone 16"
	xcli-tool config --device &> /dev/null

	xcli-tool config --show &> /dev/null 
	if [[ $? == 0 ]]; then
	 fail "Should not succeed if 'build-option' is not set" 
	else
		exit 0
	fi
}

test_configShowRunBeforeSettingDevice_commandFails() {
	xcli-tool setup &> /dev/null && \
	xcli-tool config --project "TestProject.xcodeproj" &> /dev/null && \
	xcli-tool config --scheme "TestProjectScheme2" &> /dev/null  && \
	xcli-tool config --build-option "build" &> /dev/null  && \

	xcli-tool config --show &> /dev/null 
	if [[ $? == 0 ]]; then
	 fail "Should not succeed if 'device' is not set" 
	else
		exit 0
	fi
}

test_configShowPrintsAllCurrentConfigurations() {
	xcli-tool setup &> /dev/null
	xcli-tool config --project "TestProject.xcodeproj" &> /dev/null 
	xcli-tool config --scheme "TestProjectScheme2" &> /dev/null 
	xcli-tool config --build-option "build" &> /dev/null 
	mock_fzf "iPhone 16"
	xcli-tool config --device &> /dev/null

	local output
	output=$(xcli-tool config --show 2>&1)
	local rc=$?

	# Should return success
	[[ $rc == 0 ]] || fail "Should be able to show all configs, but returned code $rc"

	# Should print error about missing env variable
	# Check each expected line individually (all must be present)
	echo "$output" | grep -q "Selected project: TestProject.xcodeproj" \
		|| fail "Missing 'Selected project:' line in config --show output"
	echo "$output" | grep -q "Selected scheme: TestProjectScheme2" \
		|| fail "Missing 'Selected scheme:' line in config --show output"
	echo "$output" | grep -q "Selected device:" \
		|| fail "Missing 'Selected device:' line in config --show output"
	echo "$output" | grep -q "Selected build option: build" \
		|| fail "Missing 'Selected build option:' line in config --show output"
}
