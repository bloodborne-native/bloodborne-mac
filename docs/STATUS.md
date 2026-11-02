# Status

[← Documentation](README.md)

Where the whole project stands: what is released, what is on main, what is being worked on and
what comes next. Updated 2026-11-02. The plan in order: [Roadmap](ROADMAP.md). Each repository's
own status: [runtime](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/NATIVE_RENDERER.md#the-layers),
[recompiler](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/RECOMPILATION.md#milestones),
[launcher](https://github.com/bloodborne-native/bloodborne-launcher/blob/main/README.md#status).

## At a glance

- **Released:** 0.9.4, on 2026-11-02: The Hunter's Dream sign-in from the launcher, its connection
  crash fixed and GPU-only textures kept ([notes](releases/v0.9.4.md)). 0.9.3, on 2026-10-30: about a third faster on the Metal renderer (lossless
  texture compression), less processor time, and a recompiled library that survives updates and
  is updated in seconds to minutes instead of rebuilt ([notes](releases/v0.9.3.md)). 0.9.0 brought the native Metal
  renderer, online play, the save editor and the recompiled code page ([notes](releases/v0.9.0.md)).
- **Playable** on Apple Silicon: 48.0–49.2 FPS standing in Iosefka's Clinic at native 1080p on an
  M3 Pro with the Metal renderer in 0.9.3, against 36.3–36.7 before lossless texture compression
  (adapted from [MojahedAbushawish](https://github.com/MojahedAbushawish)'s lazy texture usages for
  Wooloomooloo2's [bloodborne_mac_port](https://github.com/Wooloomooloo2/bloodborne_mac_port), #33)
  ([performance](guide/performance.md)).
- **Now:** the native renderer (the maintainer's focus from 2026-10-29): the draw-state work, draws taken from
  the engine's draw state instead of the PS4 user data (a developer switch today), then the game's
  shaders built ahead of time, converted for each platform. The Metal renderer (the Metal backend) is accepted (2026-10-29).
- **Memory for smaller Macs:** the game's peak footprint
  in Iosefka's Clinic is down from 7.8 GB to 5.7 GB on main (the recompiled library no longer keeps
  the whole game decoded); next, the iPhone's compact memory layout as a Mac mode, toward 8 GB Macs.
- **The recompiler's CPU work:** calls left to the translator down from 69,600 a second to 9,400;
  what is left (memory ordering) waits for the maintainer's conditions.
- **Understanding the game's code:** about 19,800 of the about 56,000 functions to understand have a name
  or a known role, much of it compiler and template code, and 48,378 are placed in a class or a source
  file. Class names, the game's method registry, state machine steps and source file boundaries came from
  the executable, and EzState's opcodes are mostly named. What is left is read by hand, a few at a time
  ([where it stands](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/RECOMPILATION.md#annotations)).
- **On main since 0.9.4:** the function scanner no longer takes read-only data for code: 62,122 of the
  241,821 functions were data, so a rebuilt library is 296 MB, built in 5.5 minutes in a test, and
  48.1 FPS in Iosefka's Clinic with it.

## The PS4 layers

How native the game is: [the roadmap's table](ROADMAP.md#the-ps4-layers), with a page for each layer,
and what to do first: [priorities](ROADMAP.md#priorities).

**Platforms.** macOS is released. iOS is a [proof of concept](https://github.com/bloodborne-native/bloodborne-ios), not the focus of
development, built and installed from the player's own Mac. Linux has the runtime only. The launcher
runs on macOS, Windows and Linux; game integration exists on macOS and on iOS.

## Releases

| Version | Highlights |
|---|---|
| 0.9.4 | The Hunter's Dream sign-in from the launcher; its connection crash fixed; GPU-only textures kept |
| 0.9.3 | About a third faster on the Metal renderer (lossless texture compression, MojahedAbushawish's work for bloodborne_mac_port); the frame-preparation threads on the fast cores; the recompiled library kept across updates and updated in place; the hooked functions compiled too; a damaged pipeline cache recovered from |
| 0.9.2 | The recompiled-code build fixed (it starts, survives leaving the page, counts as it compiles, Cancel stops it all); cloth at high frame rates and the play time (bbport 0.7); the `0x2169edc` crash guarded (bbport 0.7); about 2 GB less memory and fewer translator calls with the recompiled code |
| 0.9.1 | The shader cache no longer reuses a shader's slot, which drew walls and scenery black after long play; caches are rebuilt once; the draw-preparation threads about 10% less busy |
| 0.9.0 | The release candidates' changes; the recompiled code page (the library built on the player's Mac); a faster translator; the game's threads on the performance cores; the on-screen keyboard no longer reopens after a name is typed |
| 0.9.0 RC 2 | Online play; the save editor; the launcher's new look with Saves and Trophies tabs; in-game menus in its colours; a faster translator; macOS 15 |
| 0.9.0 RC 1 | The native Metal renderer by default (MoltenVK as the fallback); MetalFX on the native frame; button prompts for the device in use; keyboard and mouse in the in-game menu |
| 0.8.3 | Mods and Patches pages fixed; character editing in every language; optional FSR 4.1.1 on Metal; trophy notices drawn by the game |
| 0.8.2 | High-resolution character lighting fixed |
| 0.8.1 | GX worker crash fixed; MetalFX; the shader cache no longer rebuilds every launch |
| 0.8.0 | Motion-vector crash fixed; settings shared with the in-game menu; outputs above 1080p; the experimental Metal renderer |
| 0.7.0 | Stretched geometry fixed; local trophies |
| 0.6.0 | Profiles and saves; the opening-video crash fixed |

Release notes: [docs/releases](releases/). bbport compatibility: 0.51, plus parts of 0.6 and 0.7
ported by hand (the runtime's [Upstream](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/UPSTREAM.md)).

## On main

Main is 0.9.4, plus:

- **The executable and the patches prepared in C** (runtime `src/runtime_prepare.c`,
  `src/runtime_patches.c`): the game builds them at start, without Python; `bb-patches` checks the
  C against `scripts/patches.py` byte for byte.
- **Touch controls** (runtime): on-screen sticks and buttons on a touch screen without a gamepad,
  in the menu's colours (design after ducvd89/Bloodborne-Android); `BB_TOUCH_CONTROLS`, and on the
  iPhone the launcher's Controls page, turns them off or on.
- **Aspect ratio Auto** with the screen's own ratio at the usual heights.
- **The iPhone work** (above), from the same runtime and launcher.

## Areas

| Area | State |
|---|---|
| Graphics | Metal by default, translated from the game's PS4 commands, without Vulkan or MoltenVK; MoltenVK selectable as a fallback; Vulkan on Linux. Upscalers: MetalFX with the Metal renderer; FSR 3.1 and FSR 4.1.1 (run on the Mac's GPU) with MoltenVK ([native renderer](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/NATIVE_RENDERER.md)) |
| Game features | bbport 0.6's frame rate through hooks (F3 for 30 FPS), live effects, aspect ratios, keyboard and mouse, Laurence's cinematic above 30 FPS |
| Online | Seamless Hunt and The Hunter's Dream (the runtime's `bbnet20`, GPL-3.0-or-later); tested here without an account, players are testing both pools with 0.9.0 |
| Launcher | Profiles and saves with backups; trophies; the save editor (attributes, items, weapons, armor, gems; an edited save earns no trophies and plays offline only); settings shared with the in-game menu; mods and patches; 20 languages; platform-neutral code with CI on macOS, Linux and Windows ([launcher docs](https://github.com/bloodborne-native/bloodborne-launcher/tree/main/docs)) |

## Open issues

- **Known bug:** blood on already killed enemies can look pale after a save reload. Cause not
  isolated.
- **The GXRenderThread crash** at `0x2169edc`
  ([#7](https://github.com/bloodborne-native/bloodborne-mac/issues/7)): guarded on main, kept open
  until a long session passes without it.
- **Watch list:** a short white flash in the opening video and an enemy drawn as colour noise
  have not recurred, without a confirmed fix. A crash on death in Central Yharnam
  ([#5](https://github.com/bloodborne-native/bloodborne-mac/issues/5)) could not be reproduced and
  is closed until it happens again. Older rare assertions: the runtime's
  [stability notes](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/STABILITY.md).
- **Only one Mac measured** (M3 Pro); results from M1, M2 and M4 Macs are welcome.
- **Tests:** five GPU tests no longer compile and are not run (roadmap, Later).
