<h1 align="center">bloodborne-mac</h1>

<p align="center"><a href="https://discord.gg/QS6vHz45xA"><img src="https://img.shields.io/badge/Discord-join%20the%20server-5865F2?logo=discord&logoColor=white" alt="Discord"></a></p>

<p align="center">
  <strong>Bloodborne on Apple Silicon, on the way to truly native.</strong><br>
  A macOS port of the PS4 game, with a launcher app and an in-game settings menu. No Rosetta 2.
</p>

<p align="center">
  <sub>Built on <a href="https://github.com/deadinside28/bloodborne_pc"><strong>bbport</strong></a> by deadinside28, the native Linux port it started from, and on <a href="https://github.com/shadps4-emu/shadPS4">shadPS4</a>.</sub>
</p>

> [!IMPORTANT]
> **This is an experimental project. Expect bugs and regressions.**
>
> We are developing our own CPU recompiler and renderer, with many approaches and changes
> that diverge from the original bbport. These experiments can make this project less stable than
> other Bloodborne projects. Crashes, loading hangs and graphical corruption are known risks
> during development.
>
> **Our goal is to make Bloodborne truly native on any platform**, removing every layer that stands
> in for a PS4. This is an independent development effort beyond porting bbport to macOS.
>
> For other Bloodborne ports on the Mac, see
> **[Wooloomooloo2/bloodborne_mac_port](https://github.com/Wooloomooloo2/bloodborne_mac_port)**
> (actively maintained: the game's own code under Rosetta 2, rendered natively with Metal) and
> **[bmy/bbport-mac](https://github.com/bmy/bbport-mac)** (the dedicated macOS port of bbport). Both
> are separate projects and describe themselves as experimental or a work in progress. Please report
> problems with bloodborne-native [here](https://github.com/bloodborne-native/bloodborne-mac/issues).

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
  <img src="docs/screenshots/hunters-dream.jpg" alt="The Hunter's Dream on an Apple M3 Pro" width="49%">
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

- **Made for Apple Silicon:** the game's x86-64 code runs as arm64, translated as it runs or, on
  request, compiled ahead of time for your Mac from your own copy (no Rosetta 2). The renderer
  reaches Metal directly.
- **One app, nothing else to install:** download, open, choose your game folder, play.
- **A launcher** ([bloodborne-launcher](https://github.com/bloodborne-native/bloodborne-launcher)) with graphics, controls, game options, mods, patches and the game's log.
- **Upscalers,** optional: Apple MetalFX with the Metal renderer; AMD FSR 3.1 and FSR 4.1.1 with
  the MoltenVK renderer.
- **An in-game settings menu** (F1, or L3 + R3 on a controller).
- **Controllers, keyboard and mouse,** with mapping for all three; the mouse turns the camera and
  points in the game's menus.
- **Any aspect ratio:** 16:10, 21:9, 32:9 and 4:3 without stretching or black bars.
- **Mods and patches,** with load order. The game folder is never changed.
- **20 languages** for the launcher and the menu, the same as the PS4 game.

## Getting started

1. [Download the latest release](https://github.com/bloodborne-native/bloodborne-mac/releases/latest)
   and drag **Bloodborne** to Applications.
2. The first time, right-click the app and choose **Open** (the app is not signed with an Apple
   Developer ID).
3. Choose your game folder and press **Play**.

The [installation guide](docs/guide/installation.md) has the details.

## The goal

Bloodborne was written for the PS4, and today it still runs as a PS4 game: layers stand in for the
console around it. Each of them costs time and memory, and limits what can be done with the game.

**The goal is a game that is truly native:** nothing between it and the platform pretends to be a
PS4, whatever that platform is. A layer counts as native only when nothing in it is translated any
more, so this is where the project stands:

| Layer | Native | |
|---|---|---|
| [The game's code](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/layers/game-code.md) | `███████████████████░` 96% | Instructions recompiled; opt-in, the translator is the default |
| [Shaders compiled during play](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/shaders.md) | `█████████████████░░░` 86% | Sources built ahead in one area; opt-in |
| [The PS4's system](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/system.md) | `░░░░░░░░░░░░░░░░░░░░` 0% | No firmware runs, but the game's PS4 calls are still translated |
| [The renderer](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/renderer.md) | `░░░░░░░░░░░░░░░░░░░░` 0% | Metal directly, but every frame is translated from PS4 commands |
| [PS4 GPU commands](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/gpu-commands.md) | `░░░░░░░░░░░░░░░░░░░░` 0% | The engine's draws are found; all of them are still decoded |
| [PS4 user data](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/user-data.md) | `░░░░░░░░░░░░░░░░░░░░` 0% | Developer switch only |
| [PS4 textures and memory](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/textures-memory.md) | `░░░░░░░░░░░░░░░░░░░░` 0% | Not started |
| [The PS4's C and file libraries](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/c-libraries.md) | `██████████████████░░` 94% | Functions recompiled; opt-in with the library |
| [x86 memory ordering](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/layers/memory-ordering.md) | `░░░░░░░░░░░░░░░░░░░░` 0% | Not started; only arm64 needs this layer |
| [The PS4 executable](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/executable.md) | `░░░░░░░░░░░░░░░░░░░░` 0% | The game still starts from it |

What each number counts: [the PS4 layers](docs/ROADMAP.md#the-ps4-layers).

## Status

**Experimental, playable.** The latest release has the Metal renderer by default, online play, the
save editor and the game's code compiled for your Mac on request. On an Apple M3 Pro at 1080p it
reads 48–49 FPS standing in Iosefka's Clinic ([performance](docs/guide/performance.md)). Only one
Mac has been measured so far: results on other Macs are welcome.

**Next:** the renderer (taking draws from the engine, and the game's shaders built ahead of time),
and less memory for Macs with 8 and 16 GB. Details: [Status](docs/STATUS.md) and
[Roadmap](docs/ROADMAP.md).

**Known issues:** blood on already killed enemies can look pale after a save reload. See
[Troubleshooting](docs/guide/troubleshooting.md#known-issues).

## Documentation

| | |
|---|---|
| [Installation](docs/guide/installation.md) | Download, first start, where your data lives |
| [Game files](docs/guide/game-files.md) | Preparing your dump, supported editions, The Old Hunters |
| [Settings](docs/guide/settings.md) | The launcher, the in-game menu, languages, controllers |
| [Mods and patches](docs/guide/mods-and-patches.md) | Installing mods and third-party patches |
| [Performance](docs/guide/performance.md) | What to expect, and the settings that matter |
| [Profiles and saves](docs/guide/saves.md) | Profiles, backups, trophies |
| [Troubleshooting](docs/guide/troubleshooting.md) | Common problems and known issues |

## Under the hood

The app is built from five repositories; a sixth, [bloodborne-ios](https://github.com/bloodborne-native/bloodborne-ios), runs the game on the iPhone:

| Repository | |
|---|---|
| **bloodborne-mac** (this one) | The macOS app: packaging, releases, player guides |
| [bloodborne-launcher](https://github.com/bloodborne-native/bloodborne-launcher) | The independent launcher source, included here as `launcher/` |
| [bloodborne-runtime](https://github.com/bloodborne-native/bloodborne-runtime) | Loads the game, answers its PS4 system calls and renders it, with Metal by default on macOS, here as `runtime/` |
| [bbcpu](https://github.com/bloodborne-native/bbcpu) | Translates the game's x86-64 code to arm64 as it runs: a project of its own, usable by other PS4 ports |
| [bloodborne-recomp](https://github.com/bloodborne-native/bloodborne-recomp) | The recompiler (`runtime/recomp/`) |
| [bloodborne-ios](https://github.com/bloodborne-native/bloodborne-ios) | The iPhone app, a proof of concept built and installed from your own Mac: the launcher with the game inside |

**The recompiler** turns the game's code, from the player's own copy, into native code ahead of
time, checked against calls recorded from the original. It takes less CPU time than the translator,
and the launcher builds the library on the player's Mac. Only the tool is published, never the
game's code ([how it works](https://github.com/bloodborne-native/bloodborne-recomp)). It is how the game leaves the PS4 behind on
any platform, not only on arm64.

[Architecture](docs/ARCHITECTURE.md) · [Building and releasing](docs/BUILDING.md) · [Status](docs/STATUS.md)

## Credits

Built on [**bbport**](https://github.com/deadinside28/bloodborne_pc) by deadinside28, the native
Linux port this project started from as a fork, and on [**shadPS4**](https://github.com/shadps4-emu/shadPS4):
the loader, the PS4 runtime, the renderer and its extensions, the upscalers and the game patches
come from them; bbport's releases are merged up to 0.51 and ported in parts from 0.6 and 0.7. The
Metal renderer also uses shader and pipeline work first published by
[**Huax-1839/bloodborne-macos**](https://github.com/Huax-1839/bloodborne-macos), adapted through
[**Wooloomooloo2/bloodborne_mac_port**](https://github.com/Wooloomooloo2/bloodborne_mac_port).
Metal FSR 4.1.1 upscaling is based on [**fsr4-native-macos**](https://github.com/UzenUPoZiTiV4ik/fsr4-native-macos)
by UzenUPoZiTiV4ik. This work adds the macOS
platform layer, the arm64 translator, the app and the recompiler. None of it would exist without
the projects it is built on. Full list: [Credits and licenses](docs/CREDITS.md).

Licensed under the [GNU GPL v2 or later](LICENSE). The online module (the runtime's `gpu/bbnet20`) includes droogie/bbhost's
GPL-3.0-or-later code, so that module, and the app that ships it, are under the
[GNU GPL v3 or later](https://www.gnu.org/licenses/gpl-3.0.html).

<sub>Not affiliated with shadPS4, Sony Interactive Entertainment, FromSoftware or AMD. Please do
not report problems with this project to shadPS4 or to bbport.</sub>
