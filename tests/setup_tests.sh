#!/bin/bash

source helpers.sh

test_setupFindsProjectsAndSchemes() {
	xcli-tool setup &> /dev/null

	[[ -f .xcli/schemes ]] || fail "Schemes file not created"
	[[ -f .xcli/projects ]] || fail "Projects file not created"
}

test_setupCollectsAllAvailableSchemes() {
	xcli-tool setup &> /dev/null
	local scheme_file=".xcli/schemes"

	grep "^TestProject$" $scheme_file &> /dev/null || fail "Not all Schemes have been found" 
	grep "^TestProjectScheme2$" $scheme_file  &> /dev/null || fail "Not all Schemes have been found"
	grep "^TestProjectScheme3$" $scheme_file &> /dev/null || fail "Not all Schemes have been found"
}

test_setupCollectsAllAvailableProjects() {
	xcli-tool setup &> /dev/null
	local project_file=".xcli/projects"

	grep "^TestProject.xcodeproj$" $project_file &> /dev/null || fail "Not all Schemes have been found" 
}
