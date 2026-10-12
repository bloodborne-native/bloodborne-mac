#!/usr/bin/env bash
# macOS: packages the current build (bash runtime/build.sh first) as Bloodborne.app in
# dist/bloodborne_mac-<version>-<arch>.dmg. No game files are included. The app needs nothing
# installed: the Tauri launcher (launcher/app, built here with npm and cargo) carries the game,
# bash, Python and the libraries.
#   Contents/MacOS/             bloodborne-launcher, bb-probe, bb-gpu-capabilities, bash
#   Contents/Frameworks/        libbbgpu, MoltenVK, Vulkan loader, SDL3, FFmpeg
#   Contents/Resources/game/    run.sh, scripts/, patches/, share/vulkan/icd.d/
#   Contents/Resources/python/  standalone Python 3
# Library references become @rpath ones and everything is signed again ad hoc (no Developer
# ID: macOS asks the user to allow the app once). Version: $BB_VERSION, else `git describe`.
#   bash packaging/macos.sh
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
[[ $(uname -s) == Darwin ]] || { echo 'macOS only' >&2; exit 1; }
arch=${BB_ARCH:-$( [[ $(sysctl -n hw.optional.arm64 2>/dev/null) == 1 ]] && echo arm64 || echo x86_64 )}
[[ $arch == arm64 ]] || { echo 'The app is built for Apple Silicon (arm64) only' >&2; exit 1; }
# The game itself comes from the runtime/ submodule (bloodborne-runtime) and its build.
runtime=$PWD/runtime
deps=$runtime/deps/macos-$arch
gpudir=$runtime/out/gpu-arm64
# The app's own bash and Python (the runtime's scripts/macos/build-deps.sh builds what is missing).
[[ -x $deps/app-runtime/bin/bash && -x $deps/app-runtime/python/bin/python3 ]] ||
    (cd "$runtime" && BB_ARCH=$arch bash scripts/macos/build-deps.sh)
for f in "$runtime/out/bb-probe" "$runtime/out/bb-gpu-capabilities" "$gpudir/libbbgpu.dylib" "$deps/lib/libMoltenVK.dylib"; do
    [[ -f $f ]] || { echo "Missing $f: build first (BB_ARCH=$arch bash runtime/build.sh)" >&2; exit 1; }
done
# The real path: the libraries are referenced by it when deps/ is a symbolic link.
deps=$(cd "$deps" && pwd -P)
version=${BB_VERSION:-$(git describe --tags --always --dirty 2>/dev/null || echo dev)}
short_version=$(sed -E 's/^v//; s/[^0-9.].*$//' <<< "$version"); [[ -n $short_version ]] || short_version=0.0.0
name=bloodborne_mac-$version-$arch
work=dist/$name
app=$work/Bloodborne.app
rm -rf "$work" "dist/$name.dmg"
mkdir -p "$work"
macos=$app/Contents/MacOS
frameworks=$app/Contents/Frameworks
game=$app/Contents/Resources/game

# The launcher (Tauri: React interface, Rust backend), the bundle the rest goes into.
(cd launcher/app && { [[ -d node_modules ]] || npm ci; } && npx tauri build --bundles app)
cp -R launcher/app/src-tauri/target/release/bundle/macos/Bloodborne.app "$app"
plutil -replace CFBundleShortVersionString -string "$short_version" "$app/Contents/Info.plist"
plutil -replace CFBundleVersion -string "$version" "$app/Contents/Info.plist"
mkdir -p "$frameworks" "$game/share/vulkan/icd.d"
install -m755 "$runtime/out/bb-probe" "$runtime/out/bb-gpu-capabilities" "$deps/app-runtime/bin/bash" "$macos/"
install -m755 "$gpudir/libbbgpu.dylib" "$frameworks/"
copy_deps() { # copy_deps FILE: the non-system libraries FILE links against, recursively
    local dep
    for dep in $(otool -L "$1" | awk 'NR > 1 {print $1}' | grep "^$deps/lib/"); do
        local base=${dep##*/}
        if [[ ! -f $frameworks/$base ]]; then
            install -m755 "$(realpath "$dep")" "$frameworks/$base"
            copy_deps "$frameworks/$base"
        fi
    done
}
for f in "$macos/bb-probe" "$macos/bb-gpu-capabilities" "$frameworks/libbbgpu.dylib"; do copy_deps "$f"; done
install -m755 "$(realpath "$deps/lib/libMoltenVK.dylib")" "$frameworks/libMoltenVK.dylib"
cat > "$game/share/vulkan/icd.d/MoltenVK_icd.json" <<'EOF'
{
    "file_format_version": "1.0.0",
    "ICD": {
        "library_path": "../../../../../Frameworks/libMoltenVK.dylib",
        "api_version": "1.4.0",
        "is_portability_driver": true
    }
}
EOF

relink() { # relink FILE RPATH: @rpath references, the build tree's search paths replaced
    local file=$1 dep old
    for dep in $(otool -L "$file" | awk 'NR > 1 {print $1}' | grep "^$deps/lib/"); do
        install_name_tool -change "$dep" "@rpath/${dep##*/}" "$file" 2>/dev/null
    done
    if [[ $file == *.dylib ]]; then install_name_tool -id "@rpath/${file##*/}" "$file" 2>/dev/null; fi
    for old in $(otool -l "$file" | awk '/LC_RPATH/ {getline; getline; print $2}'); do
        install_name_tool -delete_rpath "$old" "$file" 2>/dev/null
    done
    install_name_tool -add_rpath "$2" "$file" 2>/dev/null
}
relink "$macos/bb-probe" @executable_path/../Frameworks
relink "$macos/bb-gpu-capabilities" @executable_path/../Frameworks
for f in "$frameworks/"*.dylib; do relink "$f" @loader_path; done
if leftovers=$(for f in "$macos/"* "$frameworks/"*.dylib; do otool -L "$f" | awk '!/:$/ {print $1}'; done |
               grep -v '^@\|^/usr/lib/\|^/System/' | sort -u) && [[ -n $leftovers ]]; then
    echo "References into the build tree remain:" >&2; echo "$leftovers" >&2; exit 1
fi
strip -x "$macos/bb-probe" "$macos/bb-gpu-capabilities" "$frameworks/"*.dylib 2>/dev/null || true

cp "$runtime/run.sh" LICENSE README.md "$game/"
cp -R "$runtime/scripts" "$runtime/patches" "$game/"
cp -R "$runtime/gpu/fsr4_metal" "$game/"
if [[ -d /Users/vitao/Documents/GitHub/fsr4-native-macos ]]; then
    mkdir -p "$game/fsr4_metal/tools"
    cp -R /Users/vitao/Documents/GitHub/fsr4-native-macos/tools "$game/fsr4_metal/"
    cp -R /Users/vitao/Documents/GitHub/fsr4-native-macos/third_party "$game/fsr4_metal/"
fi
cp -R "$deps/app-runtime/python" "$app/Contents/Resources/python"
find "$app" -name __pycache__ -type d -prune -exec rm -rf {} +
# Ad-hoc signatures, inside out (libraries, helpers, Python's binaries, then the bundle).
codesign --force --sign - "$frameworks/"*.dylib
find "$app/Contents/Resources/python" -type f \( -perm -u+x -o -name '*.so' -o -name '*.dylib' \) \
    -exec sh -c 'file -b "$1" | grep -q Mach-O && codesign --force --sign - "$1"' _ {} \;
codesign --force --sign - "$macos/bb-probe" "$macos/bb-gpu-capabilities" "$macos/bash" "$macos/bloodborne-launcher"
codesign --force --sign - "$app"
codesign --verify --deep --strict "$app"

ln -s /Applications "$work/Applications"
cat > "$work/First start.txt" <<EOF
Bloodborne for Apple Silicon ($version)

1. Drag Bloodborne to Applications.
2. The first time, right-click Bloodborne and choose Open, then Open again (the app is not
   signed with an Apple Developer ID). If macOS still refuses: System Settings → Privacy &
   Security → Open Anyway. Or, in Terminal: xattr -dr com.apple.quarantine /Applications/Bloodborne.app
3. Choose your Bloodborne dump (version 1.09; any edition with the same executable) and press Play.
   Graphics, controls (controller choice and button mapping), mods and patches are in the
   launcher's tabs.
   The first start compiles the game's shaders and takes a few minutes.

No game files are included. Saves, settings and logs:
~/Library/Application Support/bloodborne_mac

https://github.com/bloodborne-native/bloodborne-mac
EOF
hdiutil create -quiet -volname "Bloodborne" -srcfolder "$work" -ov -format UDZO "dist/$name.dmg"
ls -lh "dist/$name.dmg"
