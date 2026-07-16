#!/bin/bash

# This command scans the current directory for 
# project files and collects all the schemes
setupCommand() {
	# Save all project files in a cache
	currentDir="$(dirname "${BASH_SOURCE[0]}")"
	source "$currentDir"/findProjectFiles.sh
	echo "Found $(cat $XCLI_FOLDER/projects | wc -l | cut -f 1) projects/workspaces"

	# Save all schemes in a cache
	source "$currentDir"/findSchemes.sh
	echo "Found $(cat $XCLI_FOLDER/schemes | wc -l | cut -f 1) schemes"
}
