# Credits and licenses

[← Documentation](README.md)

This project is licensed under the **GNU GPL v2 or later** ([LICENSE](../LICENSE)), like the
project it is based on.

## Based on

- [**deadinside28/bloodborne_pc**](https://github.com/deadinside28/bloodborne_pc) (bbport) by
  deadinside28: the native Linux port this project started from as a fork, and a separate
  repository since October 2026. Its releases are merged here as they come out (now **0.51**), with
  their history; the merge commits name each one. It provides the loader, the PS4 runtime, the
  renderer extensions, the upscalers, the game-specific fixes and the original launcher. Code
  taken from it keeps its authorship in the git history.
- [**shadPS4**](https://github.com/shadps4-emu/shadPS4): the video core and shader recompiler
  (GPL-2.0+), and [sirit](https://github.com/shadps4-emu/sirit).
- **shadp2p** (a shadPS4 fork, GPL-2.0): the network and PSN libraries of the online module
  (bloodborne-runtime's `gpu/bbnet`, shadNet), from bbport 0.51.

## From other forks

Changes taken from other ports of bbport, with thanks:

- [**bmy/bbport-mac**](https://github.com/bmy/bbport-mac) (Rosetta 2 port of bbport to macOS):
  - the Retina-resolution window (bloodborne-runtime's `gpu/shim/window.cpp`, `BB_RETINA`);
  - the texture cache hashing whole images when checking a possibly changed one (the item
    picture on the loading screen).

## Libraries

- [MoltenVK](https://github.com/KhronosGroup/MoltenVK) (Apache-2.0)
- [Zydis](https://github.com/zyantific/zydis) (MIT), the translator's x86 decoder
- [SDL3](https://www.libsdl.org/) (zlib)
- [FFmpeg](https://ffmpeg.org/) (LGPL)
- [Mesa](https://www.mesa3d.org/) KosmicKrisp (MIT, optional)
- [FSR-Vulkan](https://github.com/FireBurn/FSR-Vulkan) by FireBurn and the AMD FidelityFX SDK (MIT)
- [fsr4-native-macos](https://github.com/UzenUPoZiTiV4ik/fsr4-native-macos) by UzenUPoZiTiV4ik (MIT), native Apple Metal FSR 4 / 4.1.1 upscaling pipeline
- [LibAtrac9](https://github.com/Thealexbarney/LibAtrac9) (MIT)
- [Dear ImGui](https://github.com/ocornut/imgui) (MIT)
- [cpp-httplib](https://github.com/yhirose/cpp-httplib) by Yuji Hirose (MIT), in the online module
- [half](https://half.sourceforge.net/) (MIT)
- DejaVu fonts
- The launcher: [Tauri](https://tauri.app), [React](https://react.dev),
  [shadcn/ui](https://ui.shadcn.com), [Tailwind CSS](https://tailwindcss.com),
  [i18next](https://www.i18next.com) (MIT)

## Game patches

By Kyo, Lance McDonald, auser1337, illusion, emoose and other community members
(bloodborne-runtime's `patches/Bloodborne.xml`).

## Disclaimer

This project is not affiliated with shadPS4, Sony Interactive Entertainment, FromSoftware or AMD.
*Bloodborne* is a trademark of Sony Interactive Entertainment. No game files are included.
