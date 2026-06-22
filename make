#!/bin/bash
# Initialize some globals

XCLI_FOLDER=".xcli"

buildCommand() {
	# Get current build configuration
	XCODE_PROJECT=${XCODE_PROJECT:-"KeylessSDK.xcodeproj"}
	XCODE_SCHEME=${XCODE_SCHEME:-"KeylessSDK iOS"}
	XCODE_DESTINATION=${XCODE_DESTINATION:-"generic/platform=iOS Simulator"}

	if [[ ! -e $XCODE_PROJECT ]]; then 
		echo "Project file is not present in this folder. Check CWD"
		exit -1
	fi

	# Get derived data folder for current project-branch
	source ./getDerivedDataPath.sh

	$derivedDataFolder=$(getDerivedDataPath)

	mkdir -p $XCLI_FOLDER

	echo "Building Project $XCODE_PROJECT with scheme $XCODE_SCHEME for $XCODE_DESTINATION"
	xcodebuild\
		-project "$XCODE_PROJECT"\
		-scheme "$XCODE_SCHEME"\
		-destination "$XCODE_DESTINATION"\
		-derivedDataPath "$derivedDataFolder"
		build | tee .build/build.log | xcpretty

	grep "error:" .build/build.log > .build/errors.log

	xcode-build-server parse -a .build/build.log && echo "parsed logs correctly" || echo "failed to parse logs"
}

# Dispatch based on first argument
case "$1" in
    build)
        buildCommand
        ;;
    *)
        echo "Unknown command: $1"
        echo "Usage: $0 [build]"
        exit 1
        ;;
esac
