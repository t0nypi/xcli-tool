#!/bin/bash
# Initialize some globals

XCLI_FOLDER=".xcli"
mkdir -p $XCLI_FOLDER

# Get derived data folder for current project-branch
source ./getDerivedDataPath.sh

$derivedDataFolder=$(getDerivedDataPath)

# Get current build configuration
XCODE_PROJECT=${XCODE_PROJECT:-"KeylessSDK.xcodeproj"}
XCODE_SCHEME=${XCODE_SCHEME:-"KeylessSDK iOS"}
XCODE_DESTINATION=${XCODE_DESTINATION:-"generic/platform=iOS Simulator"}

echo "Building Project $XCODE_PROJECT with scheme $XCODE_SCHEME for $XCODE_DESTINATION"
xcodebuild\
	-project "$XCODE_PROJECT"\
	-scheme "$XCODE_SCHEME"\
	-destination "$XCODE_DESTINATION"\
	-derivedDataPath "$derivedDataFolder"
	build | tee .build/build.log | xcpretty

grep "error:" .build/build.log > .build/errors.log

xcode-build-server parse -a .build/build.log && echo "parsed logs correctly" || echo "failed to parse logs"
