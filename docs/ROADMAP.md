# Roadmap

[← Documentation](README.md)

The plan, in order. Where things stand now: [Status](STATUS.md). When an item lands it moves to
**Done** with where it landed; release notes say what changed for players.

Changes taken from other ports and forks (bbport, Supermedo's Windows fork, the Huax-1839 and
Wooloomooloo2 macOS ports, DiAvisoo) are adopted only after an A/B on our build (same save, route
and settings, alternating runs), and are credited in the same commit (CREDITS, the wiki, the
commit message, a code comment; the runtime's `docs/UPSTREAM.md` records them).

## The PS4 layers

The goal is a game that is truly native: nothing between it and the platform pretends to be a PS4.
These are the layers that do that today, and how much of each has been replaced. A layer counts as
native only when nothing in it is translated any more: replacing part of a translation does not
make it native. Each row says what its percentage counts, and bars have 20 blocks, one per 5%. The
rows measure different things, so they are not averaged into one number.

| Layer | What it does | Native | What the number counts | What is left |
|---|---|---|---|---|
| **[The game's code](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/layers/game-code.md)** | PS4 x86-64 code translated while the game runs | 96% `███████████████████░` | 10,284,725 of 10,691,122 instructions recompiled; opt-in, the translator is still the default | The default; import stubs and code rewritten while running |
| **[The PS4's C and file libraries](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/c-libraries.md)** | `libc.prx` and `libSceFios2.prx` run as game code | 94% `██████████████████░░` | 4,453 of 4,759 functions recompiled; opt-in with the library, and short tests so far | Long play; what stays translated on purpose |
| **[The PS4's system](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/system.md)** | Threads, memory, files, saves, input, audio, network, trophies | 0% `░░░░░░░░░░░░░░░░░░░░` | The game still makes PS4 system calls, and the runtime translates each one. No PS4 firmware runs: all of the answers are our code | Recompiled code calling the platform directly |
| **[The renderer](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/renderer.md)** | PS4 commands and shaders translated into Metal calls every frame | 0% `░░░░░░░░░░░░░░░░░░░░` | Every frame is still translated. One translation is gone: on macOS the renderer reaches Metal directly, without Vulkan or MoltenVK | The renderer working from the engine, not from PS4 commands: the rows below |
| **[PS4 GPU commands](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/gpu-commands.md)** | The game writes PS4 command buffers, decoded each frame | 0% `░░░░░░░░░░░░░░░░░░░░` | Every draw and dispatch is still decoded, with every switch. The engine's draws are found (the render boundary, 99.94% matched), behind `BB_RENDER_BOUNDARY`, which no player build sets | Draws taken from the engine, then no decoding |
| **[PS4 user data](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/user-data.md)** | A walker reads each shader's resources the way the PS4 lays them out | 0% `░░░░░░░░░░░░░░░░░░░░` | The walker runs for every player. With `BB_RENDER_BOUNDARY=flat`, 92% of draw and 79% of dispatch shader stages skip it; the shaders themselves are unchanged and the walker still teaches the slots | On by default, and the rest of the draw kinds (the other draw kinds) |
| **[Shaders compiled during play](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/shaders.md)** | PS4 shaders converted and compiled at first use | 86% `█████████████████░░░` | 253 of 295 sources one Clinic session used were already built; opt-in in the launcher, one area, standing still. Shaders stay converted from GCN, ahead of time, by decision | The remaining forms, other areas, Vulkan's build path |
| **[PS4 textures and memory](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/textures-memory.md)** | The PS4's CPU and GPU share one memory, and the game is written around that: textures are inferred from it and held twice | 0% `░░░░░░░░░░░░░░░░░░░░` | Textures as objects not started | Textures as the objects the engine creates. Needed on every platform, and more on PCs with a separate GPU memory, where shared data has to be copied and kept in sync |
| **[x86 memory ordering](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/layers/memory-ordering.md)** | Every load and store keeps x86's ordering on arm64 | 0% `░░░░░░░░░░░░░░░░░░░░` | Not started. Only arm64 needs this layer: x86-64 keeps this ordering in hardware | Ordering kept only around the engine's synchronization |
| **[The PS4 executable](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/executable.md)** | The game starts from a PS4 executable, prepared and patched in memory | 0% `░░░░░░░░░░░░░░░░░░░░` | The game still starts from it, with the recompiled library loaded into it | A game that starts as a native program |

## Priorities

Ordered by what each layer would gain for the game: frame rate, stalls, CPU and memory. **Measure
first:** the game is limited by the GPU at 1080p on an M3 Pro, and no Metal System Trace of a frame
has been recorded, so the first two rows rest on MoltenVK's figures and on the memory they would
save. CPU savings do not raise the frame rate on an M3 Pro; they matter for heat, battery and weaker
CPUs. Figures are from an M3 Pro in Iosefka's Clinic unless they say otherwise.

| # | Layer | Frame rate | CPU | Memory | Why here |
|---|---|---|---|---|---|
| 1 | [PS4 textures and memory](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/textures-memory.md) | Some: copies about 2 ms of GPU on MoltenVK | Less tracking; not measured | **About 1–1.5 GB** | The largest memory saving, needed for 8 and 16 GB Macs and for PCs with a separate GPU memory |
| 2 | [The renderer](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/renderer.md) | **The largest:** 6–8 ms of GPU idle a frame on MoltenVK; not measured on Metal | Recording takes about 1.8 cores | Not measured | The only layer shown to bound the frame rate |
| 3 | [Shaders compiled during play](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/shaders.md) | **Stalls:** worst frame 561 ms; 258 ms with recorded states | None in play | None | Felt the most in play, but only at first use; no change to the average |
| 4 | [The game's code](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/layers/game-code.md) | None on an M3 Pro | **14% less game CPU** (0.4–0.6 core), already built | Not measured against the translator | Stays opt-in for now: the gain does not yet justify a build of about 14 minutes (the maintainer, 2026-11-02) |
| 5 | [PS4 GPU commands](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/gpu-commands.md) | None measured | About 0.6 core | Not measured | Needs draws taken from the engine first |
| 6 | [x86 memory ordering](https://github.com/bloodborne-native/bloodborne-recomp/blob/main/docs/layers/memory-ordering.md) | None on an M3 Pro | Not measured | None | Paid on every access on arm64, with the highest risk: the maintainer's conditions apply |
| 7 | [PS4 user data](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/user-data.md) | None | At most about 0.3 core, while the observer costs about 45 points today | None | A net cost until the observer is cheaper |
| 8 | [The PS4's C and file libraries](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/c-libraries.md) | None | Part of about 6% of the main thread's busy time | None | Recompiled in the library; what is left is small |
| 9 | [The PS4's system](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/system.md) | None | Not measured | None | Mostly needed for platforms, not speed |
| 10 | [The PS4 executable](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/executable.md) | None | None in play | None | Done for portability, last |

Other work: less memory for Macs with 8 and 16 GB through the iPhone's compact memory layout (the
game's memory as one file mapping, Metal's view of it, nothing pinned), each step measured in
footprint and FPS.

## Now

The shader compile step and its misses ([Shaders compiled during play](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/layers/shaders.md)), on `main` as
an opt-in setting.

## Later

**Checks owed** (no code expected):

- Physics in play with the frame-rate hooks: running above 90 FPS, cloth, corpses.
- Laurence's cinematic above 30 FPS (needs a save near it).
- Frame-rate A/B of the motion-vector crash fix (expected nil).
- Real occlusion queries counted at the game's resolution (bbport 0.6's memory model): check ours.

**Bugs** (causes not isolated):

- Blood on already killed enemies can be pale with bright edges after a save reload.
- Five GPU tests (motion-shader, scene-resolution, taa-shader, camera-motion, translation-memory)
  no longer compile; they are listed in `runtime/gpu/CMakeLists.txt` instead of run.

**From other forks** (each measured on our build first):

- bbport 0.7: cloth fluttering above 30 FPS (Havok's stiffness per substep) and the play time
  counted correctly above 30 FPS; the point-light shadow wedges and the HUD's item-icon grid
  (check on Metal first); the frame limiter, the FPS drop after loading another save, the hit
  collector's cap. The list: the runtime's `docs/UPSTREAM.md`.

- Mods: more folder layouts load, and folders that do not are named (Supermedo `dd2314e`).
- An external FPS patch replaces the built-in preset (Supermedo `8042500`).
- Field of view; mute in the background (Supermedo `b75e811`).
- MoltenVK without Metal argument buffers (+13–16% FPS there) and with prefilled command buffers
  (fewer late frames there): A/B on the MoltenVK fallback.
- Queue the game's compute work before waiting for the previous submission (a black loading screen
  there).
- A texture budget that does not count the game's memory pool (their #19): check Metal's
  working-set limit on 16–18 GB Macs.
- The draw-list task lock (a stuck loading screen there): check whether our command-buffer guard
  covers it.
- Character-name entry in fullscreen (the IME text box): check ours first.
- DiAvisoo/bbport-mac-optimized's ideas, reviewed separately.

**Launcher:**

- Import and export complete save sets; manage the backup history.

**Graphics:**

- Background shader compilation: a missing pipeline compiles on a worker and its draw is skipped
  until ready, behind a setting.

**iOS** (a proof of concept, not the focus of development: it gains from the Mac's work on the
shared runtime and launcher; [bloodborne-ios](https://github.com/bloodborne-native/bloodborne-ios),
public since 2026-10-30, its [findings](https://github.com/bloodborne-native/bloodborne-ios/blob/main/docs/FINDINGS.md);
the runtime's [write-up](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/IOS_POC.md);
how code is organized: [Architecture](ARCHITECTURE.md#where-code-lives)):

1. Done (2026-10-29): the proof of concept merged to `main`, its platform code behind
   `TARGET_OS_IPHONE` (the game's mutex as host code stays iOS-only: it costs on the Mac), its
   general fixes for every platform (hashing without the decode cache, no JIT on iOS, the UI
   scale).
2. Done (2026-10-30): one app. The launcher's iOS app runs the game in its own process (launcher
   `87e372d` to `b266315`), with its settings, the screen's own shape and touch controls (runtime
   `f7ddfe48`, `fbaaaae6`); the game prepared and patched on the phone.
3. Partly done: the runtime's Python moved into C. The executable, its linked modules, the content
   profile and the patches are built by the runtime at start (runtime `96173c7a` to `f104d743`);
   `game_check.py` and `mods.py` remain. Then the runtime as a library with a small C API,
   `bb-probe` a thin program around it.
4. The address space: the game should survive the system drawing over it (a texture budget that
   keeps room for the system without evicting GPU-only textures, then the runtime's largest
   tables).
5. The iOS platform code in the runtime's platform layer behind an `ios-arm64` CMake preset and a
   compile-only CI job: the compact memory layout as a named mode, the system call and Metal
   format differences.
6. Less CPU work for the same frames, since heat limits the frame rate (capped at 30 it holds 30;
   uncapped it falls from 38–42 FPS as the phone heats): the PS4's own libraries through the
   recompiler, other spinning waits.

## Not taken

- **Seamless co-op (BBSC):** not supported for now (maintainer, 2026-10-26). BBSC is built on the
  game's internals, which no repository here may carry. A separately built and hosted module the
  runtime loads through a plugin interface could be discussed with BBSC's developer.
- **shadPS4's public online server** (bbport 0.51's module): it accepts only shadPS4's own builds.
- **bbport 0.6's new memory model** and the Windows fork's VRAM budget fixes: we use the unified
  pool.
- **Discrete-GPU and other platforms' fixes** from bbport 0.6 and the Windows fork (NVIDIA, Intel,
  Polaris, Steam Deck, AppImage, Windows), DLSS, frame generation, bbport's FSR 4.1.1 Vulkan
  assets, `VK_EXT_device_fault` (MoltenVK lacks it). Our FSR 4.1.1 runs on the Mac's GPU (0.8.3).
- **The Windows fork's stretched-polygon fixes** (`9566a1d`, `5012c6f`): bugs of its newer shadPS4
  base that our push block and index binding do not have. Its barrier memo (`08cd804`): we have it.

## Done

Where each landed; the release notes say what changed for players.

**CPU and recompiler** (bbcpu and bloodborne-recomp):

- The first stages of the recompiler: every function recompiled and running in the game, with less CPU time than the translator
  (the speed work, 2026-10-25).
- The recompiled library built from the launcher with a downloaded LLVM toolchain (recomp
  `aa47a95`, runtime `8d2d469`, launcher `adec5ac`).
- The annotations: the engine's render code, synchronization and 20 busiest functions named and described
  (recomp `annotations/`, 2026-10-28).
- The function scanner stops at the end of code: 62,122 of 241,821 functions were read-only data
  (recomp `622e0f8`, 2026-11-02).
- Class names tied to their vtables, the method registry, step tables and object file boundaries read from
  the executable: about 31,100 functions identified and 48,690 placed
  (recomp `tools/recomp/names.py`, 2026-11-02).
- A faster translator (recomp #15, #16, #17, #18) and the runtime's own math and wide-string
  calls (runtime #7); the game's threads at user-interactive QoS (runtime #8).

**Graphics** (bloodborne-runtime):

- The native Metal renderer: every pipeline in Metal, the frame drawn through Metal, the render
  adapter (A0–A6, M1–M4), native startup without Vulkan or MoltenVK; the default since 0.9.0 RC 1,
  accepted as the Metal backend (the maintainer, 2026-10-29). MoltenVK stays selectable as a fallback until the
  maintainer decides whether it leaves the macOS app.
- Lossless texture compression (2026-10-30, runtime `316e0eb2`): textures made without the
  ShaderWrite and PixelFormatView usages until a view needs one, so Apple GPUs compress them; +33%
  FPS in Iosefka's Clinic on an M3 Pro (48.0–49.2 against 36.3–36.7). Adapted from [MojahedAbushawish](https://github.com/MojahedAbushawish)'s lazy
  texture usages for Wooloomooloo2's [bloodborne_mac_port](https://github.com/Wooloomooloo2/bloodborne_mac_port) (#33).
- MetalFX (runtime PR #2) on the native frame; FSR 4.1.1 on the Mac's GPU with the MoltenVK renderer
  (runtime #1, 0.8.3).
- The renderer's scope (scope), frame planning (frame planning: deferred clears).
- The render boundary, the engine's render boundary (2026-10-28, merged 2026-10-29: runtime `cf0ce17d`; mesh draws
  recognised with the recompiled library too, recomp `8c49bc7`): the engine's draws matched to
  their packets and observed; every buffer address and resource slot found from its draw state;
  mesh draws bind their resources from it (`BB_RENDER_BOUNDARY=observe|mesh`).
- Crashes fixed: character motion vectors (runtime `57fba4f`), the GX worker with live dynamic
  shadows (`e8e14a3`), outputs above 1080p (`74c556e`), character lighting above 3.5 million
  pixels (`b2ff9cd`, `ab31a4c`); the shader cache no longer rebuilds every launch (`e8e14a3`,
  PR #3, `0e940e9`).
- Small fixes from bbport 0.6 and the Windows fork: the blur-kernel assertion, the larger GX
  command heap, stale texture formats, garbage PM4 headers, null vertex-buffer tables, early flip
  IRQs (runtime `63f043a`).

**bbport 0.6, ported by hand** (runtime): the renderer fixes; the present's wait; the frame rate
through hooks (F3 for 30 FPS); Laurence's cinematic above 30 FPS; effects switched live; aspect
ratios; keyboard and mouse with a menu pointer; button prompts for the device in use; online
(Seamless Hunt and The Hunter's Dream, runtime `49e2d2c`).

**bbport 0.7, ported by hand** (runtime): the GX occlusion query guard, the crash at `0x2169edc`
(whp199's PR #343; runtime `994846bb`). Its occlusion intervals were measured without a gain on
Metal and not taken.

**Memory and the recompiled library** (2026-10-29): hashing without the decode cache, from the
iPhone work (recomp `da077b8`: the peak footprint 7.8 GB to 5.7 GB); 99 more jump tables and the C
library's character tables and busiest calls on the host (recomp `0f344f8`, runtime `540a91b1`:
translator calls 69,600 a second to 9,400).

**Release candidates learn of newer releases** (launcher `9466d2d`): a candidate build carries its
tag and checks candidates too, so it is told about the next candidate and the final release.

**Releases:** 0.9.3 (2026-10-30): lossless texture compression (about a third faster on Metal),
the frame-preparation threads on the fast cores, the recompiled library kept across updates and
updated in place. 0.9.2 (2026-10-29): the recompiled-code build fixed (app issue #9), bbport 0.7's cloth,
play time and `0x2169edc` guard, about 2 GB less memory with the recompiled code. 0.9.1 (2026-10-28): the shader cache fix for black walls after long play (app issue
#7). 0.9.0 (2026-10-28): the release candidates' changes, the recompiled code page, a
faster translator, game threads on the performance cores, the on-screen keyboard fix.

**Launcher:** profiles and saves; trophies, with notices drawn by the game; settings shared with
the in-game menu (runtime `8cbcf64`, launcher `1dc03d8`); the save editor (attributes, Blood
Echoes, Insight, items, weapons, armor, gems and their slots; launcher `6f6f64a` to `1d77932`); the
Online page; the Recompiled code page; the slate-and-gold look, mirrored in the game's menus.
