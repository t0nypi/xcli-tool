#!/bin/bash

currentDir="$(dirname "${BASH_SOURCE[0]}")"
source "$currentDir"/parseDestination.sh

runCommand() {
	# Check if the selected device is a simulator (ends with '(Simulator)')
	isDeviceSimulator=$([[ $(cat $XCLI_FOLDER/selectedDevice) =~ \(Simulator\)$ ]] && echo 1 || echo 0)
	echo "device is simulator $isDeviceSimulator"

	XCODE_PROJECT=$(cat $XCLI_FOLDER/selectedProject)
	XCODE_SCHEME=$(cat $XCLI_FOLDER/selectedScheme)
	XCODE_DESTINATION=$(parseDestination "$(cat $XCLI_FOLDER/selectedDevice)")

	echo "Getting target information before installing app on device"
	echo $XCODE_DESTINATION

	# Get derived data folder for current project-branch
	currentDir="$(dirname "${BASH_SOURCE[0]}")"
	source "$currentDir"/getDerivedDataPath.sh

	derivedDataFolder=$(getDerivedDataPath)
	deviceIdentifier=$(cat $XCLI_FOLDER/selectedDevice | awk '{print $2}')

	declare -A builtTargetInfo

	# AI: Use process substitution (< <(...)) so the while loop runs in the
	# current shell. A pipe creates a subshell, and associative array
	# assignments inside it are lost when the subshell exits.
	while IFS=' = ' read -r key value; do
		builtTargetInfo[$key]="$value"
	done < <(xcodebuild \
		-project "$XCODE_PROJECT" \
		-scheme "$XCODE_SCHEME" \
		-destination "$XCODE_DESTINATION" \
		-derivedDataPath "$derivedDataFolder" \
		-showBuildSettings \
		build 2>/dev/null | grep -e "TARGET_BUILD_DIR =" -e "EXECUTABLE_FOLDER_PATH =" -e "PRODUCT_BUNDLE_IDENTIFIER =")

	echo ${builtTargetInfo[@]}
	echo $isDeviceSimulator

	if [[ $isDeviceSimulator == 1 ]]; then
		echo "Installing on simulator"
		xcrun simctl boot "$deviceIdentifier"
		xcrun simctl install "$deviceIdentifier" "${builtTargetInfo[TARGET_BUILD_DIR]}/${builtTargetInfo[EXECUTABLE_FOLDER_PATH]}"
		xcrun simctl launch "$deviceIdentifier" "${builtTargetInfo[PRODUCT_BUNDLE_IDENTIFIER]}"
	else
		echo "Installing on physical device"
		devicectl device install app --device "$deviceIdentifier" "${builtTargetInfo[TARGET_BUILD_DIR]}/${builtTargetInfo[EXECUTABLE_FOLDER_PATH]}"
		devicectl device process launch -v --console --device "$deviceIdentifier" "${builtTargetInfo[PRODUCT_BUNDLE_IDENTIFIER]}" 
	fi
}
