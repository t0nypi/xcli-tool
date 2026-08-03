TEST_PROJECT_DIR="TestProject"

fail() {
	echo "❌ ERROR: $1" >&2
	exit -1
}

clean() {
	rm -rf .xcli
	rm -rf .build
}

setup() {
	cd "$TEST_PROJECT_DIR"
}

run_test() {
	(setup && $1 && echo "✅ SUCCESS: test $1 succeeded" && clean)
}
