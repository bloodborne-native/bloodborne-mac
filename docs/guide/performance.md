# Performance

[← Documentation](../README.md)

Measured on an Apple M3 Pro (18-core GPU, 18 GB) with a 1080p output, on the current code
(2026-10-24 and 25; the Metal renderer's native row 2026-10-30, with lossless texture
compression):

| Where | Renderer | Setting | FPS |
|---|---|---|---|
| Iosefka's Clinic, standing (about 1,660 draws a frame) | MoltenVK | Native 1080p, no upscaler | 30.6 |
| The same | MoltenVK | FSR 3.1 *Balanced* | 27.6 |
| The same | Metal | Native 1080p, no upscaler | 48.0–49.2 |
| The same | Metal | MetalFX *Quality* / *Balanced* | 31.7 / 33.5 |
| A new game, 3 h 26 min of play | Metal | Native 1080p, no upscaler | median 42.2 (37 or more 90% of the time) |

- The upscalers do not make the game faster at 1080p any more: native rendering got faster with
  the renderer and memory work, and FSR 3.1 now costs more than it saves. Use them above 1080p
  output, where native resolution would need too much memory
  ([recommended settings](settings.md#recommended-settings)).
- The Metal renderer is about 60% faster than MoltenVK at native 1080p. A third of that is
  lossless texture compression (from 36.3–36.7 to 48.0–49.2 FPS), adapted from [MojahedAbushawish](https://github.com/MojahedAbushawish)'s work for
  Wooloomooloo2's [bloodborne_mac_port](https://github.com/Wooloomooloo2/bloodborne_mac_port): textures are made so that Apple GPUs can compress them.
- The Metal renderer's upscaler is MetalFX; FSR 3.1 and FSR 4.1.1 are offered with the MoltenVK
  renderer ([settings](settings.md)).
- Character motion vectors cost a few FPS with an upscaler.
- The frame rate is uncapped by default; set a limit on the Graphics tab, or press **F3** for 30
  FPS while playing.
- Only one Mac has been measured; results on other Macs are welcome in the
  [issues](https://github.com/bloodborne-native/bloodborne-mac/issues).

## Compile shaders ahead of time

**Compile shaders ahead of time** (on the **Recompiled code** page) has the game prepare its
shaders the next time it starts, with progress on screen. It takes a few minutes, once, and you
can stop and continue later. New effects then stop pausing the game the first time they appear.

The game also notes how it draws as you play, and uses that to prepare more the next time it
starts, which takes less time than the first run and shortens pauses while loading. So the second
start after you turn this on does the most good. It runs again now and then as you reach new
places, with progress on screen. After a macOS update, or on another Mac, it runs again once,
because macOS discards the compiled pipelines.

## Recompiled code

**Recompiled code** (in the launcher's menu, under Settings) compiles the game's code for your
Mac once, from your own copy, instead of translating it while you play. The game then uses less
processor time: about 14% less in our tests (344% of one core against 402% at the 1st Floor
Sickroom lamp). The frame rate stays about the same, because the graphics set the pace on a Mac.

- **Build the library** downloads a 70 MB compiler (LLVM), builds the library (about 14 minutes
  on an M3 Pro; longer with fewer cores) and deletes the compiler. It needs about 3 GB free while
  it runs; the library then takes about 330 MB. The page shows the step, the files compiled and
  the time left. **Cancel** stops it; building again continues where it stopped.
- Then choose **Recompiled** under *How the game's code runs*. **Translated while playing**
  stays the default.
- The library is built from your copy and stays on your Mac. It is used only while it matches
  your game and the app's recompiler: after you change the game folder or update the app, the
  page asks you to build it again, and until then the game's code is translated (the log's first
  line says so).
- The compiled code still behaves like the PS4's processor: it is not a native version of the
  game.

Where a frame's time goes and what has been tried: the runtime's
[performance notes](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/PERFORMANCE.md).
