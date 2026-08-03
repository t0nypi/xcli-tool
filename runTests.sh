#!/bin/bash

source tests/helpers.sh

declare -a tests
cd tests

for file in $(find . -name "*_tests.sh" -type f); do
	source "$file";
	tests+=($(grep -E "test_.*\(\)" "$file" | sed "s|().*{||"))
done;

total=${#tests[@]}
echo "Running $total tests..."

success=0
failures=0
for test in ${tests[@]}; do
	if run_test "$test"; then
		((success++))
	else
		((failures++))
	fi
done

echo "Results: $success succeeded, $failures failed out of $total tests"


