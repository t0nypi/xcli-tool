#!/bin/bash

configCommand() {
	currentDir="$(dirname "${BASH_SOURCE[0]}")"
	source "$currentDir"/configureProject.sh

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
				selectScheme $2
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

		*)
			fail "Unknown config option: $1"
			;;
	esac
}
