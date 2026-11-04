# Troubleshooting

[← Documentation](../README.md)

## "Bloodborne can't be opened"

The app is not signed with an Apple Developer ID. Right-click it in Applications and choose
**Open**, or allow it in **System Settings → Privacy & Security**
([Installation](installation.md#the-first-time-you-open-it)).

## The launcher says the game folder has a problem

The message says what is wrong; the usual cases (update not merged, an old `eboot.bin`, another
edition) are in [Game files](game-files.md#when-the-launcher-reports-a-problem).

## The first start takes a long time

The first start compiles the game's shaders: a few minutes. It happens again after an update that
changes the shader cache.

## The game stops or crashes

1. Look at the launcher's **Log** tab, or `~/Library/Application Support/bloodborne_mac/logs/last.log`.
2. Start the game again: some rare crashes do not repeat.
3. If it keeps happening, [open an issue](https://github.com/bloodborne-native/bloodborne-mac/issues)
   with the log, your Mac model and macOS version.

Please do not report problems with this port to shadPS4 or to bbport.

## Known issues

- **Blood on already killed enemies** can look pale with bright edges after reloading a save.

## Good to know

- **The Metal renderer is new** (the default since 0.9.0 RC 1). If the picture or stability is
  wrong with it, switch to MoltenVK (Advanced → Renderer) and report what you saw.
- **Online play** (Seamless Hunt and The Hunter's Dream) is in 0.9.0. A save changed with the
  save editor plays offline only.
- *The Old Hunters*: the Game of the Year editions include it; add-on packages in
  `user/addcont/` are not tested on macOS.

## Fixed

| Problem | Fixed in |
|---|---|
| With Online mode on, the title screen skipped its Play Online / Play Offline choice | 0.9.7 |
| Pressing ⌘ while holding a key (W, Q or H) closed or hid the game | 0.9.6 |
| The game stopped after long play with "GPU library assertion failed" (`Unknown data_format=15`, exit code 23) | 0.9.5 |
| Keyboard keys could not be assigned in Controls on macOS 14 and later | 0.9.5 |
| Building the recompiled code stayed on "Checking your game" and Cancel did nothing; leaving the page could show the build as cancelled | 0.9.2 |
| Cloth fluttering and the play time counted slow above 30 FPS | 0.9.2 |
| A rare crash after long sessions (exit code 139, the render thread at `0x2169edc`) | 0.9.2 |
| Walls and scenery black on every start after a long session, until the shader cache was deleted | 0.9.1 |
| Closing the on-screen keyboard after typing a name opened it again at once, several times in a row | 0.9.0 |
| Opening the game's status page in the Lecture Building, or quitting, could stop the game with the Metal renderer | 0.9.0 RC 2 |
| The Mods and Patches pages kept loading and found no mods or patches | 0.8.3 |
| Character clothing lost its lighting at native 1440p after texture collection | 0.8.2 |
| A GX worker crash during loading or turning in the level, on Metal or MoltenVK | 0.8.1 |
| The shader cache rebuilt at every launch after a tessellation shader failed | 0.8.1 |
| The game stopped with "Lost VkDevice ... Invalid Resource" (`VK_ERROR_OUT_OF_DEVICE_MEMORY`), mostly with character motion vectors on | 0.8.0 |
| 1440p and 4K stopped at the loading screen | 0.8.0 |
| Stretched scenery, missing walls, objects popping in and a black sky with streaks after visiting a few areas | 0.7.0 |
| A crash or freeze in the opening video before character creation | 0.6.0 |
| A GPU error while loading (`Unimplemented PM4 type 0`), most often in Brazilian Portuguese | 0.5.1 |

If one of these comes back on a later version, please report it with what you were doing. The
causes are explained in the runtime's
[stability notes](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/STABILITY.md).
