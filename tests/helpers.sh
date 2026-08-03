TEST_PROJECT_DIR="TestProject"

fail() {
	echo "	Underlying Error: $1" >&2
	return -1
}

clean() {
	rm -rf .xcli
	rm -rf .build
	unset FZF_DEFAULT_OPTS
}

run_test() {
	local output
	output=$(cd "$TEST_PROJECT_DIR" && $1 2>&1)
	rc=$?
	 if [[ $rc == 0 ]]; then 
		echo "✅ SUCCESS: test $1 succeeded"
		(cd "$TEST_PROJECT_DIR" && clean)
		return 0
	else
		echo "❌ FAILURE: test $1 failed"
		echo "$output"
		(cd "$TEST_PROJECT_DIR" && clean)
		return 1
	fi
}

# Always returns fixed result
mock_fzf() {
	export FZF_DEFAULT_OPTS="--filter="$1""
}
