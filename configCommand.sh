#!/bin/bash

configCommand() {
	currentDir="$(dirname "${BASH_SOURCE[0]}")"
	source "$currentDir"/configureProject.sh

	# Check that setup has been run (projects and schemes files must exist)
	if [[ ! -f "$XCLI_FOLDER/projects" ]] || [[ ! -f "$XCLI_FOLDER/schemes" ]]; then
		echo "ERROR: you must run 'setup' before 'config'"
		exit 1
	fi

	case "$1" in
		--project)
			if [[ -n "$2" ]]; then
				selectProject $2
			else
				openProjectSelector 
			fi

			;;
		--scheme)
			if [[ -n "$2" ]]; then
				selectScheme "$2"
			else
				openSchemeSelector 
			fi
			;;

		--device)
			openDeviceSelector 
			;;

		--build-option)
			if [[ -z "$2" ]]; then
				echo "Valid build options are:"
				echo "- 'build'"
				echo "- 'buildForTest'"
				fail "Provide one of the options above"
			fi

			switchBuildOption "$2"
			;;

		--show)
			showConfiguration
			;;

		*)
			fail "Unknown config option: $1"
			;;
	esac
}
