#!/bin/bash

# Helper: fail with an error message and exit with -1
fail() {
	echo "❌ ERROR: $1" >&2
	exit ${2:-42}
}

selectProject() {
	if [[ -z "$1" ]]; then 
		fail "Expected to receive the name of the project, but received nothing"
	fi

	grep -e "$1" "$XCLI_FOLDER/projects" || fail "Project not found"

	echo "$1" > $XCLI_FOLDER/selectedProject 
}

selectScheme() {
	local scheme=$1
	if [[ -z "$scheme" ]]; then 
		fail "Expected to receive the name of the scheme, but received nothing"
	fi

	grep -e "$scheme" "$XCLI_FOLDER/schemes" || fail "Scheme not found"

	echo "$scheme" > $XCLI_FOLDER/selectedScheme 
}

selectDeviceByName() {
	if [[ -z "$1" ]]; then 
		fail "Expected to receive the name of the device, but received nothing"
	fi

	echo "Name: $1" > $XCLI_FOLDER/selectedDevice 
}

selectDeviceByIdentifier() {
	if [[ -z "$1" ]]; then 
		fail "Expected to receive the identifier of the device, but received nothing"
	fi

	echo "Identifier: $1" > $XCLI_FOLDER/selectedDevice 
}

openDeviceSelector() {
	currentDir="$(dirname "${BASH_SOURCE[0]}")"
	source "$currentDir"/listDevices.sh

	listDevices | fzf | \
		awk '{ printf("Identifier: %s %s\n", substr($(NF-1), 1, length($(NF-1))), $NF) }'  > $XCLI_FOLDER/selectedDevice
}

openProjectSelector() {
	echo $(cat $XCLI_FOLDER/projects | fzf) > $XCLI_FOLDER/selectedProject
}

openSchemeSelector() {
	echo $(cat $XCLI_FOLDER/schemes | fzf) > $XCLI_FOLDER/selectedScheme
}

switchBuildOption() {
	if [[ -z "$1" ]]; then
		fail "Expected to receive build option argument. Received nothing"
	fi

	case "$1" in
		build)
			echo "build" > $XCLI_FOLDER/selectedBuildOption
			;;
		buildForTest)
			echo "build-for-testing" > $XCLI_FOLDER/selectedBuildOption
			;;
		*)
			fail "Unsupported build option"
			;;
	esac
}

showConfiguration() {
	[[ -f "$XCLI_FOLDER/selectedProject" ]] || fail "You need to set selectedProject before showing all configs" 1
	[[ -f "$XCLI_FOLDER/selectedScheme" ]] || fail "You need to set selectedScheme before showing all configs"  2
	[[ -f "$XCLI_FOLDER/selectedDevice" ]] || fail "You need to set selectedDevice before showing all configs"  3
	[[ -f "$XCLI_FOLDER/selectedBuildOption" ]] || fail "You need to set selectedBuildOption before showing all configs" 4

	echo "Selected project: $(cat $XCLI_FOLDER/selectedProject)"
	echo "Selected scheme: $(cat $XCLI_FOLDER/selectedScheme)"
	echo "Selected device: $(cat $XCLI_FOLDER/selectedDevice)"
	echo "Selected build option: $(cat $XCLI_FOLDER/selectedBuildOption)"
}
