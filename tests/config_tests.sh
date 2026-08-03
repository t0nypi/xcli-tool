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
