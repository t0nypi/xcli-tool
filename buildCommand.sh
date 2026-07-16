#!/bin/bash

currentDir="$(dirname "${BASH_SOURCE[0]}")"
source "$currentDir"/parseDestination.sh
# This command builds the project and writes possible compilation errors in 
# a buffer that can be parsed later.
buildCommand() {
	buildOption="$(cat $XCLI_FOLDER/selectedBuildOption)"

	[[ -s $XCLI_FOLDER/selectedProject ]] || fail "No project selected"
	[[ -s $XCLI_FOLDER/selectedScheme ]] || fail "No scheme selected"
	[[ -s $XCLI_FOLDER/selectedDevice ]] || fail "No destination selected"

	# Get current build configuration
	XCODE_PROJECT=$(cat $XCLI_FOLDER/selectedProject)
	XCODE_SCHEME=$(cat $XCLI_FOLDER/selectedScheme)
	XCODE_DESTINATION=$(parseDestination "$(cat $XCLI_FOLDER/selectedDevice)")

	if [[ ! -e $XCODE_PROJECT ]]; then 
		echo "Project file is not present in this folder. Check CWD"
		exit -1
	fi

	# Get derived data folder for current project-branch
	currentDir="$(dirname "${BASH_SOURCE[0]}")"
	source "$currentDir"/getDerivedDataPath.sh

	derivedDataFolder=$(getDerivedDataPath)

	mkdir -p $XCLI_FOLDER
	mkdir -p .build

	echo "Building Project $XCODE_PROJECT with scheme $XCODE_SCHEME for $XCODE_DESTINATION"

	xcodebuild \
		-project "$XCODE_PROJECT" \
		-scheme "$XCODE_SCHEME" \
		-destination "$XCODE_DESTINATION" \
		-derivedDataPath "$derivedDataFolder" \
		$buildOption | tee .build/build.log | xcpretty

	grep "error:" .build/build.log > .build/errors.log || true

	xcode-build-server parse -a .build/build.log && echo "parsed logs correctly" || echo "failed to parse logs"
}
