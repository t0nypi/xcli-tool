#!/bin/bash

# Helper: fail with an error message and exit with -1
fail() {
	echo "❌ ERROR: $1" >&2
	exit -1
}

selectProject() {
	if [[ -z "$1" ]]; then 
		fail "Expected to receive the name of the project, but received nothing"
	fi

	grep -e $1 $XCLI_FOLDER/projects || fail "Project not found"

	echo "$1" > $XCLI_FOLDER/selectedProject 
}

selectScheme() {
	if [[ -z "$1" ]]; then 
		fail "Expected to receive the name of the scheme, but received nothing"
	fi

	grep -e $1 $XCLI_FOLDER/schemes || fail "Scheme not found"

	echo "$1" > $XCLI_FOLDER/selectedScheme 
}

openProjectSelector() {
	echo $(cat $XCLI_FOLDER/projects | fzf) > $XCLI_FOLDER/selectedProject
}

openSchemeSelector() {
	echo $(cat $XCLI_FOLDER/schemes | fzf) > $XCLI_FOLDER/selectedScheme
}
