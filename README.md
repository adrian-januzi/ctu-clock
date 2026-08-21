# CTU Clock

A 24-themed menu bar countdown timer for macOS.

## Requirements

- macOS 13 or later
- Xcode command line tools (for `swift build`)

## Install

```bash
git clone <this-repo-url>
cd ctu-clock
./build_app.sh
```

This builds a release binary and installs **CTU Clock.app** to `~/Applications`. Launch it from there or Spotlight.

## Uninstall

```bash
rm -rf ~/Applications/"CTU Clock.app"
```

## Troubleshooting

### `error: 'ctu-clock': Invalid manifest` / `Undefined symbols ... PackageDescription.Package.__allocating_init`

`swift build` is failing to compile `Package.swift` itself, before it ever gets to this project's code. This happens when the Swift compiler picks up a `libPackageDescription` from a different or mismatched toolchain than the one invoking it — usually because the Xcode Command Line Tools are stale (common right after a macOS upgrade) or a second Swift toolchain is present on the machine.

To fix:

```bash
xcode-select -p                 # should point to /Library/Developer/CommandLineTools
echo $TOOLCHAINS                # should be empty
which swift && swift --version  # should resolve under CommandLineTools, not a custom install

# most reliable fix: clean reinstall of the Command Line Tools
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```

If full Xcode.app is also installed, switching to it instead often avoids this entirely:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```
