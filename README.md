# Xcli Tool

**iOS / Xcode project automation toolkit**

A lightweight shell-based CLI that wraps `xcodebuild` with interactive project configuration, scheme selection, and device targeting — all from the command line.

## Motivations

I have created this tool to ease iOS development on command line.

Xcode has always been the editor of choice for its extensive tooling for mac and mobile development; one cannot really think to develop an iOS project without keeping Xcode open.
Even with the advent of AI agents, Xcode still has the upper-hand as editor of choice thanks to its new agent capabilities. Any other agent would have to resort to `xcodebuild`.
`xcodebuild` has a cumbersome interface that requires a lot of mnemonic load. Plus it's not easy to remember all projects/schemes/targets, and its output is quite verbose.

**`xcli-tool` re-invents the wheel**. I'm not saying that iOS development now does not require Xcode and we can all build iOS apps from Windows or Linux, but at least it makes
iOS/iPadOS/macOS development feel **smoother on cli**. I didn't like Xcode dev experience. I use neovim as my editor of choice and I like being already in the cli where I can readily
launch all my tools and scripts, while keeping an eye on my Swift sources.

### What I wanted from this project

- I wanted to have my `sourcekit-lsp` easily setup in neovim in a few steps
- I wanted to be able to build and run any scheme from cli with few guided commands
- I wanted to give my local LLM a lean tool to leverage to confidently assist me without consuming too much context/tokens

The tool is still in an embryonic stage, but the end goal is to really allow one to never have to open Xcode.

## Features

- **`setup`** — Scan the current directory for `.xcodeproj` / `.xcworkspace` files and collect all available schemes (cached locally). When in a workspace, it also adds the projects contained in that workspace
- **`build`** — Build the selected project/scheme on the selected target device or simulator using `xcodebuild` + `xcpretty`.
- **`config`** — Interactively (or non-interactively) select the project, scheme, device, and build option (`build` / `build-for-testing`). Use `--show` to display all current configurations.
- **`list`** — List available projects, schemes, devices, and build options.
- **`run`** — Build and run the configured application on the target device or simulator.
- **`test`** — Build and run tests for the selected project/scheme, capturing compilation errors and parsing logs with `xcode-build-server`.

## Quick Start

```bash
# 1. Scan for projects and schemes in the current directory
./xcli-tool setup

# 2. Configure your build target
./xcli-tool config --project          # interactive project picker (fzf)
./xcli-tool config --scheme           # interactive scheme picker (fzf)
./xcli-tool config --device           # interactive device/simulator picker (fzf)
./xcli-tool config --build-option build|build-for-test

# 3. Build
./xcli-tool build

# 4. Test
./xcli-tool test

# 5. Run on the configured target
./xcli-tool run
```

## Commands Reference

### `setup`

Scans the current directory (recursively) for Xcode project files (`.xcodeproj`, `.xcworkspace`) and Xcode schemes (`.xcscheme`), excluding `DerivedData` and `Build` directories. Results are cached in `.xcli/projects` and `.xcli/schemes`.

```bash
./xcli-tool setup
```

### `config <option> [value]`

Configure the build target. If no value is provided, an interactive `fzf` picker is shown.

| Option           | Description                                   |
| ---------------- | --------------------------------------------- |
| `--project`      | Select a project or workspace                 |
| `--scheme`       | Select a build scheme                         |
| `--device`       | Select a device or simulator                  |
| `--build-option` | Set build action: `build` or `build-for-test` |
| `--show`         | Display all current configurations            |

```bash
# Interactive
./xcli-tool config --project
./xcli-tool config --scheme
./xcli-tool config --device

# Non-interactive
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
./xcli-tool list --scheme
./xcli-tool list --device
./xcli-tool list --build-option
```

### `build`

Builds the selected project and scheme on the configured device/simulator. Uses `xcodebuild` with `xcpretty` for formatted output. Build artifacts are stored in a branch-aware DerivedData folder (`$XCODE_CUSTOM_DERIVED_DATA/<project>/<branch>/`).

```bash
./xcli-tool build
```

### `run`

Builds and runs the configured application on the target device or simulator. Automatically detects whether the target is a simulator or physical device and adjusts the `xcodebuild` destination and launch command accordingly.

```bash
./xcli-tool run
```

### `test`

Builds and runs tests for the selected project and scheme on the configured device/simulator. Uses `xcodebuild test` with `xcpretty` for formatted output. Build artifacts (including a full log and a filtered errors log) are stored in `.build/`. The log is also parsed with `xcode-build-server` for structured diagnostics.

```bash
./xcli-tool test
```

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

## Configuration

All state is stored in the `.xcli/` directory:

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
| `$XCODE_CUSTOM_DERIVED_DATA` | Base path for branch-aware DerivedData (default: `DerivedData`) |

## Requirements

- **Bash** 4+ (associative arrays used in `runCommand.sh`)
- **`fzf`** — for interactive selection pickers
- **`xcrun`** / **`xctrace`** — part of Xcode command-line tools
- **`xcpretty`** — for build output formatting (optional but recommended)

## Contributing

The tool is completely written in **bash** for now. Why bash? Because it was fast to iterate over to begin with.
Second, it easily adapts to any other language, in case I decide to rewrite or add modules in, say, Python or Swift.
An important way of contributing for me is to open an issue on Github and let me know of any problem or compelling
feature the tool should have. That is much appreciated!

For any direct contributions, feel free to open a PR.

## Future work

Some features I plan to add in the near future are:

- Automatically attach an **LLDB session to Simulators** when running (Physical devices require more work as we need to connect via a `debugproxy`)
- Watch file additions/removal/renaming to **automatically update Xcode project**. `Tuist`'s approach of removing completely `xcodeproj` folders is my favorite,
  but there are projects where migrating to Tuist may take time and effort.

More ambitious work that aims at making Xcode less and less compelling will be listed.

## License

MIT
