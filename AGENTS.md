# AGENTS.md

## Project Overview

**xcli-tool** is a lightweight Bash CLI that wraps `xcodebuild` with interactive project configuration, scheme selection, and device targeting for iOS development. It's designed to make iOS/iPadOS/macOS development smoother from the command line without opening Xcode.

## Architecture

```
xcli-tool          # Entrypoint — dispatches commands
├── setupCommand.sh       # Project/scheme scanning
├── buildCommand.sh       # Build orchestration
├── configCommand.sh      # Configuration CLI
├── listCommand.sh        # Listing/inspection
├── runCommand.sh         # Build + run on device
├── testCommand.sh        # Build + test on device
├── configureProject.sh   # Project/scheme/device selection helpers
├── findProjectFiles.sh   # Find .xcodeproj / .xcworkspace
├── findSchemes.sh        # Find .xcscheme files
├── listDevices.sh        # List Xcode devices & simulators
├── parseDestination.sh   # Resolve device name/ID → xcodebuild platform string
└── getDerivedDataPath.sh # Branch-aware DerivedData path resolution
```

All scripts are Bash. The entrypoint (`xcli-tool`) sources all command modules and dispatches based on `$1`.

## Commands

### `setup`

Scans the current directory recursively for `.xcodeproj` / `.xcworkspace` files and `.xcscheme` files, excluding `DerivedData` and `Build` directories. Results are cached in `.xcli/projects` and `.xcli/schemes`.

```bash
./xcli-tool setup
```

### `config <option> [value]`

Configure the build target. Without a value, shows an interactive `fzf` picker.

| Option           | Description                                   |
| ---------------- | --------------------------------------------- |
| `--project`      | Select a project or workspace                 |
| `--scheme`       | Select a build scheme                         |
| `--device`       | Select a device or simulator                  |
| `--build-option` | Set build action: `build` or `build-for-test` |
| `--show`         | Display all current configurations            |

```bash
# Interactive (uses fzf)
./xcli-tool config --project
./xcli-tool config --scheme
./xcli-tool config --device

# Non-interactive (pass value as $2)
./xcli-tool config --project MyProject.xcodeproj
./xcli-tool config --scheme MyScheme
./xcli-tool config --build-option build

# Show all current configurations
./xcli-tool config --show
```

### `list <option> [filter]`

List available options. Optionally filter by a keyword.

```bash
./xcli-tool list --project
./xcli-tool list --project MyProject
./xcli-tool list --scheme
./xcli-tool list --device
./xcli-tool list --build-option
```

### `build`

Builds the selected project/scheme on the configured device/simulator using `xcodebuild` + `xcpretty`. Build artifacts are stored in a branch-aware DerivedData folder (`$XCODE_CUSTOM_DERIVED_DATA/<project>/<branch>/`).

```bash
./xcli-tool build
```

**Prerequisites:** `selectedProject`, `selectedScheme`, and `selectedDevice` must all be set (run `setup` + `config` first).

### `run`

Builds and runs the configured application on the target device or simulator. Automatically detects simulator vs physical device and uses the appropriate launch command (`xcrun simctl` for simulators, `devicectl` for physical devices).

```bash
./xcli-tool run
```

### `test`

Builds and runs tests for the selected project/scheme. Uses `xcodebuild test` with `xcpretty` formatting. Build artifacts (full log + filtered errors log) are stored in `.build/`. Logs are parsed with `xcode-build-server` for structured diagnostics.

```bash
./xcli-tool test
```

## Configuration

All state is stored in `.xcli/`:

| File                        | Description                                  |
| --------------------------- | -------------------------------------------- |
| `.xcli/projects`            | Cached list of project/workspace paths       |
| `.xcli/schemes`             | Cached list of scheme names                  |
| `.xcli/selectedProject`     | Currently selected project                   |
| `.xcli/selectedScheme`      | Currently selected scheme                    |
| `.xcli/selectedDevice`      | Currently selected device/simulator          |
| `.xcli/selectedBuildOption` | Build action (`build` / `build-for-testing`) |

### Environment Variables

| Variable                     | Description                                                     |
| ---------------------------- | --------------------------------------------------------------- |
| `$XCODE_CUSTOM_DERIVED_DATA` | Base path for branch-aware DerivedData (required, no default) |

## Requirements

- **Bash** 4+ (associative arrays used in `runCommand.sh`)
- **`fzf`** — interactive selection pickers
- **`xcrun`** / **`xctrace`** — Xcode command-line tools
- **`xcpretty`** — build output formatting (optional but recommended)
- **`xcode-build-server`** — log parsing for `test` command

## Testing

Tests are plain Bash scripts in the `tests/` directory.

### Running tests

```bash
./runTests.sh
```

This script:
1. Sources `tests/helpers.sh`
2. Discovers all `*_tests.sh` files in `tests/`
3. Extracts function names matching the `test_*()` pattern
4. Runs each test via `run_test <name>` and reports success/failure counts

### Test structure

Tests follow a simple convention:
- Files named `*_tests.sh` (e.g., `setup_tests.sh`, `config_tests.sh`)
- Test functions named `test_<description>()`
- Use `fail "message"` to signal a failure (returns -1)
- Use `[[ condition ]] || fail "message"` for assertions

### Test helpers (`tests/helpers.sh`)

| Function   | Description                                                |
| ---------- | ---------------------------------------------------------- |
| `fail()`   | Prints an error message and returns -1                     |
| `clean()`  | Removes `.xcli/` and `.build/` directories                 |
| `run_test()` | Wraps a test function, captures output, prints ✅/❌      |
| `mock_fzf()` | Sets `FZF_DEFAULT_OPTS="--filter=..."` to simulate fzf selection |

### Test project

Tests run inside `tests/TestProject/`, a minimal Xcode project with 3 schemes (`TestProject`, `TestProjectScheme2`, `TestProjectScheme3`). Each test is run from within this directory and cleaned up afterward via `clean()`.

### Writing new tests

1. Create `tests/<name>_tests.sh`
2. Source helpers: `source "$(dirname "$0")/helpers.sh"`
3. Define `test_<description>()` functions
4. Each test should clean up after itself (or rely on `run_test` calling `clean()`)

Example:

```bash
#!/bin/bash
source "$(dirname "$0")/helpers.sh"

test_myFeature_works() {
    xcli-tool setup &> /dev/null
    xcli-tool config --scheme "MyScheme" &> /dev/null
    [[ $(cat .xcli/selectedScheme) == "MyScheme" ]] || fail "Scheme not selected"
}
```
