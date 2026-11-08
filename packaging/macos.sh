#!/usr/bin/env bash
# macOS: packages the current build (bash runtime/build.sh first) as Bloodborne.app in
# dist/bloodborne_mac-<version>-<arch>.dmg. No game files are included. The app needs nothing
# installed: the Tauri launcher (launcher/, built here with npm and cargo) carries the game,
# bash, Python and the libraries.
#   Contents/MacOS/             bloodborne-launcher, bb-probe, bb-gpu-capabilities, bash
#   Contents/Frameworks/        libbbgpu, MoltenVK, Vulkan loader, SDL3, FFmpeg
#   Contents/Resources/game/    run.sh, scripts/, patches/, share/vulkan/icd.d/
#   Contents/Resources/python/  standalone Python 3
# The game's half of that layout is runtime/CMakeLists.txt's install rules (`cmake --install`), which
# also rewrites the libraries' references to @rpath; this script adds the launcher, signs everything
# ad hoc (no Developer ID: macOS asks the user to allow the app once) and builds the DMG.
# Version: $BB_VERSION, else `git describe`.
#   bash packaging/macos.sh
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
[[ $(uname -s) == Darwin ]] || { echo 'macOS only' >&2; exit 1; }
arch=${BB_ARCH:-$( [[ $(sysctl -n hw.optional.arm64 2>/dev/null) == 1 ]] && echo arm64 || echo x86_64 )}
[[ $arch == arm64 ]] || { echo 'The app is built for Apple Silicon (arm64) only' >&2; exit 1; }
runtime=$PWD/runtime
build=$runtime/build/macos-$arch
[[ -f $build/bb-probe ]] || { echo "Missing $build/bb-probe: run bash runtime/build.sh" >&2; exit 1; }
# The build the bundle carries: configured and up to date (a no-op once build.sh has run), so the
# install rules and the binaries are the same version.
(cd "$runtime" && cmake --build --preset macos-$arch >/dev/null)
version=${BB_VERSION:-$(git describe --tags --always --dirty 2>/dev/null || echo dev)}
short_version=$(sed -E 's/^v//; s/[^0-9.].*$//' <<< "$version"); [[ -n $short_version ]] || short_version=0.0.0
name=bloodborne_mac-$version-$arch
work=dist/$name
app=$work/Bloodborne.app
# Limit cleanup to direct children of dist; unlink symlinks rather than following them.
python3 - "$work" "dist/$name.dmg" <<'CLEANUP'
from pathlib import Path
import shutil, sys
root = Path("dist").resolve()
for value in sys.argv[1:]:
    path = Path(value)
    if path.parent.resolve() != root or not path.name.startswith("bloodborne_mac-"):
        raise SystemExit("Invalid packaging output path")
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.exists():
        shutil.rmtree(path)
CLEANUP
mkdir -p "$work"

# The launcher (Tauri: React interface, Rust backend) makes the bundle the game goes into.
cmp runtime/gpu/shim/trophy_catalog.json launcher/src/lib/trophy-text/trophy_catalog.json
# A release tag (BB_VERSION, set by the workflow only for v* tags) goes into the launcher, so a
# candidate's update check knows it is one; git describe's versions are not passed.
(cd launcher && { [[ -d node_modules ]] || npm ci; } &&
    BB_RELEASE_TAG=${BB_VERSION:-} npx tauri build --bundles app)
cp -R launcher/src-tauri/target/release/bundle/macos/Bloodborne.app "$app"
plutil -replace CFBundleShortVersionString -string "$short_version" "$app/Contents/Info.plist"
plutil -replace CFBundleVersion -string "$version" "$app/Contents/Info.plist"

# The game: the executables, the libraries they link (their @rpath fixups included), the scripts and
# the assets, and Python — runtime/CMakeLists.txt's install rules.
cmake --install "$build" --prefix "$app"

# Symbols and signatures: stripped, then signed from the inside out (ad hoc, this app has no
# Developer ID).
strip -x "$app/Contents/MacOS/bb-probe" "$app/Contents/MacOS/bb-gpu-capabilities" \
    "$app/Contents/Frameworks/"*.dylib
codesign --force --sign - "$app/Contents/Frameworks/"*.dylib
codesign --force --sign - "$app/Contents/MacOS/"bb-probe "$app/Contents/MacOS/"bb-gpu-capabilities \
    "$app/Contents/MacOS/"bash "$app/Contents/MacOS/"bloodborne-launcher
find "$app/Contents/Resources/python" -type f \( -perm -u+x -o -name '*.so' -o -name '*.dylib' \) \
    -exec sh -c 'file -b "$1" | grep -q Mach-O && codesign --force --sign - "$1"' _ {} \;
codesign --force --sign - "$app"
# --deep is deprecated and cannot be trusted for shipping: every binary is checked on its own, and
# the bundle as a whole.
codesign --verify --strict "$app"
for f in "$app/Contents/MacOS/"* "$app/Contents/Frameworks/"*.dylib; do
    codesign --verify --strict "$f"
done
# Nothing may point at the checkout, and nothing may be missing: the app has to run on a Mac that
# has never seen this directory.
if leftovers=$(for f in "$app/Contents/MacOS/"* "$app/Contents/Frameworks/"*.dylib; do
                   otool -L "$f" | awk '!/:$/ {print $1}'; done |
               grep -v '^@\|^/usr/lib/\|^/System/' | sort -u) && [[ -n $leftovers ]]; then
    echo "References into the build tree remain:" >&2; echo "$leftovers" >&2; exit 1
fi
if missing=$(for f in "$app/Contents/MacOS/"* "$app/Contents/Frameworks/"*.dylib; do
                  refs=$(otool -L "$f" | awk '!/:$/ {print $1}' | grep '^@rpath/')
                  # An @rpath reference needs a search path to resolve against (app issue #19:
                  # bb-gpu-capabilities had none and could not load SDL3 on any Mac).
                  [[ -z $refs || $f == *.dylib || $(otool -l "$f") == *'cmd LC_RPATH'* ]] ||
                      echo "$f: no LC_RPATH for its @rpath libraries"
                  for ref in $refs; do
                      [[ -f $app/Contents/Frameworks/${ref#@rpath/} ]] || echo "$f: $ref"
                  done; done) && [[ -n $missing ]]; then
    echo "Libraries the bundle does not carry:" >&2; echo "$missing" >&2; exit 1
fi

ln -s /Applications "$work/Applications"
cat > "$work/First start.txt" <<EOF
Bloodborne for Apple Silicon ($version)

1. Drag Bloodborne to Applications.
2. The first time, right-click Bloodborne and choose Open, then Open again (the app is not
   signed with an Apple Developer ID). If macOS still refuses: System Settings → Privacy &
   Security → Open Anyway. Or, in Terminal: xattr -dr com.apple.quarantine /Applications/Bloodborne.app
3. Create your first profile when prompted. Updates adopt existing saves into that profile;
   additional profiles start with new saves.
4. Choose your Bloodborne dump (version 1.09; any edition with the same executable) and press Play.
   Graphics, controls (controller choice and button mapping), mods and patches are in the
   launcher's tabs.
   The first start compiles the game's shaders and takes a few minutes.

No game files are included. Saves, settings and logs:
~/Library/Application Support/bloodborne_mac

https://github.com/bloodborne-native/bloodborne-mac
EOF
hdiutil create -quiet -volname "Bloodborne" -srcfolder "$work" -ov -format UDZO "dist/$name.dmg"
ls -lh "dist/$name.dmg"
