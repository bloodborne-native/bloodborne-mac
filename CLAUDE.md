# bloodborne-mac

The macOS app of Bloodborne (PS4, CUSA03173 1.09) on Apple Silicon: the packaging, the releases,
the player guides and the plan. The game itself is the `runtime/` submodule (bloodborne-runtime),
with the CPU layer in `runtime/bbcpu/` (bbcpu) and the recompiler in `runtime/recomp/` (bloodborne-recomp); the launcher is
`launcher/` (bloodborne-launcher). Clone with `--recursive`.

## Read first

- `docs/STATUS.md`: what main has, what is open, where to continue.
- `docs/ROADMAP.md`: the plan (the PS4 layers, Priorities, Now, Later, Not taken, Done); an item moves to Done, with
  where it landed, when the work lands.
- `docs/ARCHITECTURE.md`, `docs/BUILDING.md` (build, working across submodules, releasing).
- Each submodule's CLAUDE.md and docs for its own work.

## Layout

- `launcher/`, `runtime/`: submodules (see above).
- `packaging/macos.sh`: `Bloodborne.app` and its DMG in `dist/`, from `runtime/`'s build.
- `tools/wikigen.py`: every repository's wiki generated from its docs (`docs/BUILDING.md`).
- `.github/workflows/macos.yml`: a `v*` tag builds and publishes a release; manual runs build a
  test package.
- `docs/guide/`: player guides (the only copy; the launcher's docs are for developers).
  `docs/releases/`: release notes. `docs/screenshots/`: README pictures.

## Build

```sh
bash runtime/build.sh            # the game (runtime/deps/ the first time: ~1 h)
bash packaging/macos.sh          # the app and the DMG
cd launcher && npm run tauri dev # the launcher against runtime/ (npm run dev: browser preview)
```

## Releases

The maintainer chooses the number and approves the tests; ask before tagging. Steps in
`docs/BUILDING.md#releasing`. Release notes say what changed for players. README screenshots
come from the game (`runtime/tools/grab.sh`), in English, never from the user's screen.

## This machine (the user's Mac)

- The game dump: `~/Downloads/PS4/Bloodborne/CUSA03173` (1.09 merged). The player's data:
  `~/Library/Application Support/bloodborne_mac/` (never written by tests).
- The clone is `~/projects/bloodborne/bloodborne-mac` (VS Code workspace:
  `~/projects/bloodborne/bloodborne.code-workspace`). `runtime/deps/` records absolute paths.
  The iOS app is `~/projects/bloodborne/bloodborne-ios` (public since 2026-10-30, a proof of concept; in the same workspace); its
  `runtime/deps` and `runtime/recomp/out` link to this clone's.
- Metal System Traces need `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.
- **REA** (https://github.com/morluto/rea) is an MCP server here with the Ghidra provider
  (Ghidra 12.1.4, Java 21; `JAVA_HOME` and `GHIDRA_INSTALL_DIR` in `~/.zshrc`): decompiling,
  cross-references and call graphs of the game's executable (open
  `runtime/recomp/out/recomp/eboot_ghidra.elf`; its MCP entry in `~/.claude.json` sets a 6 GB
  heap and a longer startup deadline; recomp's CLAUDE.md has the details). Its output is game
  code: use it to understand, never commit it or paste it into docs, issues or wikis.
- An Apple M3 Pro (18 GB): a healthy run with the defaults (Metal renderer, native 1080p, no
  upscaler) reads 48.0–49.2 FPS standing in Iosefka's Clinic (the runtime's `docs/BUILDING.md`; with
  lossless texture compression, adapted from MojahedAbushawish's work for bloodborne_mac_port).
- The old `PabloVSouza/bloodborne_mac` repository only points to the project's repositories.

## Working rules (all five repositories)

- **The project is five repositories**, nested as submodules:
  [bloodborne-mac](https://github.com/bloodborne-native/bloodborne-mac) (the app) ⊃ `runtime/` =
  [bloodborne-runtime](https://github.com/bloodborne-native/bloodborne-runtime) ⊃ `bbcpu/` =
  [bbcpu](https://github.com/bloodborne-native/bbcpu) and `recomp/` =
  [bloodborne-recomp](https://github.com/bloodborne-native/bloodborne-recomp); the app also has
  `launcher/` = [bloodborne-launcher](https://github.com/bloodborne-native/bloodborne-launcher).
  Commit in the repository that owns the file, push it, then bump the submodule pointer in the
  parent and push that too. Submodules are checked out at a commit: run `git checkout main` (and
  `git pull`) there before editing.
- **Before any push, check `git remote get-url origin`.** Push to `main`; ask before
  force-pushing anything that existed before this session.
- **Commits:** a short subject, a body that says what changed and why (numbers when measured),
  and the trailer the session asks for.
- **Credits:** built on [bbport](https://github.com/deadinside28/bloodborne_pc) by deadinside28
  and on [shadPS4](https://github.com/shadps4-emu/shadPS4); keep them credited. Code taken from
  another project or fork is credited in the same commit: CREDITS.md, the wiki's credits page,
  the commit message and a short code comment.
- **No game code, ever:** no decompiled or generated game code, no game files, no records of game
  memory in any repository or wiki.
- **Test language:** English for game, launcher and overlay tests (`BB_LANGUAGE=1
  BB_UI_LANGUAGE=en`), unless the maintainer asks for a language-specific investigation.
- **Testing the game:** `runtime/tools/test_run.sh NAME [VAR=...]` (a copy of the save; the real
  one is never written), one game at a time (`pgrep -x bb-probe` first). Test windows open on the
  user's screen: say so before long batches, and stop when asked.
- **Every test run says what it tests, on screen:** `TEST_TITLE="..." TEST_DETAIL="..."
  runtime/tools/test_run.sh NAME ...` puts a banner at the top of the game's window (the title defaults to
  NAME). The title names the test and the build (e.g. "M2 skeleton: new build"); the detail
  says the settings and what is being checked. Never start a test window without them.
- **Never capture the user's screen.** Pictures come from the game: `tools/grab.sh`.
- **Shell:** no `rm -rf` on variable paths; no `xargs ... sh -c '...'`.
- **Docs:** plain, precise English; numbers measured, not guessed. Docs say what is true now;
  investigation logs do not go in docs (conclusions do). The wiki mirrors the docs; update both.
  Progress bars: 20 blocks, one per 5%.
