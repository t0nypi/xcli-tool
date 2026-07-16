#!/bin/bash

listCommand() {
	currentDir="$(dirname "${BASH_SOURCE[0]}")"
	source "$currentDir"/listDevices.sh

	case "$1" in
		--project)
			if [[ -n "$2" ]]; then
				grep -e $2 $XCLI_FOLDER/projects || fail "Project not found"
			else
				echo "Available projects:"
				cat $XCLI_FOLDER/projects
			fi
			;;
		--scheme)
			if [[ -n "$2" ]]; then
				grep -e $2 $XCLI_FOLDER/schemes || fail "Scheme not found"
			else
				echo "Available schemes:"
				cat $XCLI_FOLDER/schemes
			fi
			;;
		--device)
			echo "Available devices:"
			listDevices
			;;
		--build-option)
			echo "Available build options:"
			echo "- build"
			echo "- buildForTest"
			;;
		*)
			fail "Unknown list option: $1"
			;;
	esac
}

