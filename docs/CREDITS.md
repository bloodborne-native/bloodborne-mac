# Credits and licenses

[← Documentation](README.md)

This project is licensed under the **GNU GPL v2 or later** ([LICENSE](../LICENSE)), like the
project it is based on.

## Based on

- [**deadinside28/bloodborne_pc**](https://github.com/deadinside28/bloodborne_pc) (bbport) by
  deadinside28: the native Linux port this project started from as a fork, and a separate
  repository since October 2026. Its releases up to **0.51** are merged with their history, and parts
  of 0.6 and 0.7 are ported by hand (the runtime's [Upstream](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/UPSTREAM.md)
  page says what came from where). It provides the loader, the PS4 runtime, the
  renderer extensions, the upscalers, the game-specific fixes and the original launcher. Code
  taken from it keeps its authorship in the git history.
- [**shadPS4**](https://github.com/shadps4-emu/shadPS4): the video core and shader recompiler
  (GPL-2.0+), and [sirit](https://github.com/shadps4-emu/sirit).
- **shadp2p** (a shadPS4 fork, GPL-2.0): the network and PSN libraries of the Linux online module
  (bloodborne-runtime's `gpu/bbnet`, shadNet), from bbport 0.51.
- **shadPS4 v0.20.0's network code** ([`529ceb3`](https://github.com/shadps4-emu/shadPS4/tree/529ceb32f5546b820588f194b903cc39d08015fe),
  GPL-2.0-or-later): the network, NP and shadNet libraries of the macOS online module
  (bloodborne-runtime's `gpu/bbnet20`), unchanged but for three marked changes.
- [**droogie/bbhost**](https://github.com/droogie/bbhost/tree/566184a74f071166299bb656c4af479e5bbe2771)
  (GPL-3.0-or-later): the network side of its emulator, adapted as the online module's backend for
  The Hunter's Dream pool (`gpu/bbnet20/thd`). Its license makes the online module
  GPL-3.0-or-later (`gpu/bbnet20/LICENSE.GPL-3.0`, also in the app).
- [**Supermedo/bloodborne_pc**](https://github.com/Supermedo/bloodborne_pc/releases/tag/windows-v1.8.1)
  (Windows 1.8 and 1.8.1, "Awaken", 2026-10-15): the first to put shadPS4 0.20's network code and
  bbhost's backend together in a bbport build, which the online module follows.

## From other forks

Changes taken from other ports of bbport, with thanks (details and commits in the runtime's
[credits](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/CREDITS.md)):

- [**Huax-1839/bloodborne-macos**](https://github.com/Huax-1839/bloodborne-macos/commit/0f0cf54):
  the direct Metal renderer's shader compiler and rewrites, pipeline-state cache and
  Vulkan-to-Metal format/state tables, adapted here through Wooloomooloo2's port.
- [**Wooloomooloo2/bloodborne_mac_port**](https://github.com/Wooloomooloo2/bloodborne_mac_port):
  further Metal integration and development, including the command layer and frame encoder; and
  lossless texture compression, from [**MojahedAbushawish**](https://github.com/MojahedAbushawish)'s
  lazy texture usages there (#33, merged by Mark Hall): +33% FPS on an M3 Pro.
- [**Supermedo/bloodborne_pc**](https://github.com/Supermedo/bloodborne_pc): trophy event
  persistence and robustness fixes.
- [**MaSieS4Fun/ARM_bloodborne_pc**](https://github.com/MaSieS4Fun/ARM_bloodborne_pc) and
  [**ducvd89/Bloodborne-Android**](https://github.com/ducvd89/Bloodborne-Android): the portable
  shader-resource walker for arm64; and the design the touch controls follow (Bloodborne-Android's
  on-screen controller: the camera turned from where the finger lands).
- [**maze1377**](https://github.com/maze1377), porting our texture-collector fix to
  [**SpartanPort**](https://github.com/FelipePrado0/SpartanPort/pull/1124) (PR #1124): a
  correction to it, so images whose data a later GPU write already holds are not kept.

- [**bmy/bbport-mac**](https://github.com/bmy/bbport-mac) (Rosetta 2 port of bbport to macOS):
  - the Retina-resolution window (bloodborne-runtime's `gpu/shim/window.cpp`, `BB_RETINA`);
  - the texture cache hashing whole images when checking a possibly changed one (the item
    picture on the loading screen).

## Libraries

- [MoltenVK](https://github.com/KhronosGroup/MoltenVK) (Apache-2.0)
- [LLVM](https://llvm.org) (Apache-2.0 with LLVM exception): not shipped in the app; the
  launcher downloads clang and `ld64.lld` from bloodborne-recomp's `toolchain-llvm-23.1.4` release
  (trimmed from LLVM's official release, with its licence) to build the recompiled library
- [Zydis](https://github.com/zyantific/zydis) (MIT), the x86 decoder of [bbcpu](https://github.com/bloodborne-native/bbcpu)
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

## Launcher profile database

The independent launcher adapts the Drizzle/Tauri SQL adapter from [leari-mail/leari at 5876482](https://github.com/leari-mail/leari/tree/5876482), by Pablo Souza (MIT). The original notice and detailed credits are retained in [bloodborne-launcher](https://github.com/bloodborne-native/bloodborne-launcher/blob/main/docs/CREDITS.md).

The launcher’s shared Dialog and AlertDialog components were generated with shadcn CLI 4.21.4
from the base-nova registry ([shadcn-ui/ui, base-component reference 30a58d4](https://github.com/shadcn-ui/ui/tree/30a58d4498f270af1c1e981a7d78a15cf5740841/apps/v4/registry/bases/base/ui)).
The launcher retains the upstream MIT notice in `docs/licenses/shadcn-ui-MIT.txt`.

The launcher’s menu-bar/window restoration and Dock/taskbar handling follow
[leari-mail/leari 5876482](https://github.com/leari-mail/leari/tree/5876482/src-tauri/src)
(MIT, Pablo Souza). The launcher retains the original MIT notice; its hunter’s-sigil tray
artwork is original and does not copy Leari or game assets.

The launcher's character save format locations were checked against
[Noxde/Bloodborne-save-editor at d8d0365](https://github.com/Noxde/Bloodborne-save-editor/tree/d8d03658f288fe747f819d0dc9a09c5f9d2e1668)
(GPL-3.0). No source from that editor was copied; the launcher's parser and save workflow are
independent. See the [launcher credits](https://github.com/bloodborne-native/bloodborne-launcher/blob/main/docs/CREDITS.md).
The base HP and stamina progression values were checked against the public
[Bloodborne Wiki Vitality](https://www.bloodborne-wiki.com/2015/05/vitality.html) and
[Endurance](https://www.bloodborne-wiki.com/2015/05/endurance.html) tables
([CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/)).
