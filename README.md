<h1 align="center">bloodborne-mac</h1>

<p align="center">
  <strong>Bloodborne, running natively on Apple Silicon.</strong><br>
  A macOS port of the PS4 game, with a launcher app and an in-game settings menu. No Rosetta 2.
</p>

<p align="center">
  <sub>Built on <a href="https://github.com/deadinside28/bloodborne_pc"><strong>bbport</strong></a> by deadinside28, the native Linux port it started from, and on <a href="https://github.com/shadps4-emu/shadPS4">shadPS4</a>.</sub>
</p>

<p align="center">
  <a href="https://github.com/bloodborne-native/bloodborne-mac/releases/latest"><strong>Download</strong></a>
  ·
  <a href="docs/guide/installation.md">Installation</a>
  ·
  <a href="docs/README.md">Documentation</a>
  ·
  <a href="https://github.com/bloodborne-native/bloodborne-mac/issues">Report a problem</a>
</p>

<p align="center">
  <img src="docs/screenshots/title.jpg" alt="Bloodborne's title screen on a Mac" width="98%">
</p>
<p align="center">
  <img src="docs/screenshots/hunters-dream.jpg" alt="The Hunter's Dream at 60 FPS with FSR 3.1 on an Apple M3 Pro" width="49%">
  <img src="docs/screenshots/game.jpg" alt="Bloodborne running on an Apple M3 Pro" width="49%">
</p>
<p align="center">
  <img src="docs/screenshots/game-menu.jpg" alt="The in-game settings menu" width="49%">
  <img src="docs/screenshots/launcher-home.png" alt="The launcher's home tab" width="49%">
</p>
<p align="center">
  <img src="docs/screenshots/launcher-graphics.png" alt="The launcher's graphics settings" width="49%">
  <img src="docs/screenshots/launcher-controls.png" alt="The launcher's controls tab" width="49%">
</p>

> [!IMPORTANT]
> **No game files are included.** You need your own dump of Bloodborne with the 1.09 update.
> See [Game files](docs/guide/game-files.md).

## Features

- **Native on Apple Silicon:** the game's x86-64 code is translated to arm64 as it runs.
- **One app, nothing else to install:** download, open, choose your game folder, play.
- **A launcher** with graphics, controls, game options, mods, patches and the game's log.
- **AMD FSR 3.1 upscaling,** the biggest performance gain on Apple GPUs.
- **An in-game settings menu** (F1, or L3 + R3 on a controller).
- **Controllers and keyboard,** with button mapping for both.
- **Mods and patches,** with load order. The game folder is never changed.
- **20 languages** for the launcher and the menu, the same as the PS4 game.

## Getting started

1. [Download the latest release](https://github.com/bloodborne-native/bloodborne-mac/releases/latest)
   and drag **Bloodborne** to Applications.
2. The first time, right-click the app and choose **Open** (the app is not signed with an Apple
   Developer ID).
3. Choose your game folder and press **Play**.

The [installation guide](docs/guide/installation.md) has the details.

### AMD FSR 4 / 4.1.1 (Metal) Requirements

The app includes native Apple Silicon Metal support for AMD FSR 4 and FSR 4.1.1 (neural upscaling). To use FSR 4 / 4.1.1 on macOS:

- **Apple Silicon Mac** (M1 or newer; M5 features native matrix acceleration, M1–M4 use the SIMD FP16 fallback).
- **Metal Toolchain component**: Xcode 26+ with the Metal Toolchain installed. In Terminal, run:
  ```sh
  xcodebuild -downloadComponent MetalToolchain
  ```
- **Python 3** available on your system.

Select **AMD FSR 4.1.1 (Metal)** or **AMD FSR 4.0** in the launcher's **Graphics** tab or in the in-game settings menu.

## Status

**Experimental, playable.** The game boots, loads saves and plays with sound, controllers and
saving. On an Apple M3 Pro at 1080p with FSR 3.1 it runs at about **60 FPS** in the Hunter's Dream
and about **44 FPS** in the clinic at the start of the game
([performance](docs/guide/performance.md)). Only one machine has been tested so far: results on
other Macs are welcome.

**New in 0.5.1:** the crash while loading (a save, a lantern back to the Hunter's Dream, a death)
is fixed; the launcher window can be dragged, and *Graphics → Monitor* chooses the screen the game
opens on. From bbport 0.51: every retail release of the game is recognized, an `eboot.bin` with a
built-in 60 FPS patch is reported (it crashes the gestures menu), and the in-game menu (F1 or
L3+R3) has *Quit game*.

**Known issues:** in Yharnam the sky behind some gates can be black, with objects popping in; a
few more in [Troubleshooting](docs/guide/troubleshooting.md#known-issues).

## Documentation

| | |
|---|---|
| [Installation](docs/guide/installation.md) | Download, first start, where your data lives |
| [Game files](docs/guide/game-files.md) | Preparing your dump, supported editions, The Old Hunters |
| [Settings](docs/guide/settings.md) | The launcher, the in-game menu, languages, controllers |
| [Mods and patches](docs/guide/mods-and-patches.md) | Installing mods and third-party patches |
| [Performance](docs/guide/performance.md) | What to expect, and the settings that matter |
| [Troubleshooting](docs/guide/troubleshooting.md) | Common problems and known issues |

## Under the hood

The app is three repositories:

| Repository | |
|---|---|
| **bloodborne-mac** (this one) | The macOS app: launcher, packaging, releases, player guides |
| [bloodborne-runtime](https://github.com/bloodborne-native/bloodborne-runtime) | Loads the game: the PS4 system libraries and the Vulkan renderer (MoltenVK), here as `runtime/` |
| [bloodborne-recomp](https://github.com/bloodborne-native/bloodborne-recomp) | bbcpu, which translates the game's x86-64 code to arm64 as it runs, and the recompiler (`runtime/recomp/`) |

**The recompiler** turns the game's code, from the player's own copy, into native code ahead of
time, checked against calls recorded from the original. Every one of the game's functions is
generated and the game runs on them; the work now is making that faster than the translator.
Only the tool is published, never the game's code
([status](https://github.com/bloodborne-native/bloodborne-recomp/wiki/Recompilation-status)). The
recompiler and its CPU layer don't depend on macOS: other platforms can build on them.

[Building from source](docs/guide/building.md) · [How it works](docs/guide/how-it-works.md)

## Credits

Built on [**bbport**](https://github.com/deadinside28/bloodborne_pc) by deadinside28, the native
Linux port this project started from as a fork, and on [**shadPS4**](https://github.com/shadps4-emu/shadPS4):
the loader, the PS4 runtime, the renderer and its extensions, the upscalers and the game patches
come from them, and bbport's releases keep being merged (now 0.51). Native Apple Metal FSR 4 / 4.1.1
upscaling is based on [**fsr4-native-macos**](https://github.com/UzenUPoZiTiV4ik/fsr4-native-macos) by UzenUPoZiTiV4ik.
This work adds the macOS platform layer, the arm64 translator, the app and the recompiler. None of it would exist without
the projects it is built on. Full list: [Credits and licenses](docs/CREDITS.md).

Licensed under the [GNU GPL v2 or later](LICENSE).

<sub>Not affiliated with shadPS4, Sony Interactive Entertainment, FromSoftware or AMD. Please do
not report problems with this project to shadPS4 or to bbport.</sub>
