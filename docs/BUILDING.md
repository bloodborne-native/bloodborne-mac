# Building and releasing

[← Documentation](README.md)

## Requirements

- A Mac with Apple Silicon (macOS 15 or newer: the minimum the app declares and is built for).
- Xcode Command Line Tools and [Homebrew](https://brew.sh):

  ```bash
  brew install bash pkgconf glslang nasm cmake ninja
  ```

- Node 22+ and Rust (for the launcher).
- A game folder prepared as in [Game files](guide/game-files.md).

## Build

```bash
git clone --recursive https://github.com/bloodborne-native/bloodborne-mac.git
cd bloodborne-mac
bash runtime/build.sh                 # the game; the first run builds runtime/deps/ (about an hour)
bash packaging/macos.sh               # Bloodborne.app and its DMG in dist/
cd launcher && npm run tauri dev      # the launcher against runtime/ (npm run dev: browser preview)
```

- Run the game without the app, after building: `BB_GAME_DIR=/path/to/game bash runtime/run.sh`. The runtime's
  [building guide](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/BUILDING.md)
  has the environment, the test runners and how to measure.
- The launcher's [README](../launcher/README.md) has its stack, conventions and checks.
- The libraries in `runtime/deps/macos-arm64` are `@rpath` ones: moving the checkout needs no
  rebuild of them, only `bash runtime/build.sh` again for the game's own binaries. Never move or
  reset the player's data folder to fix a build. Packaged apps do not depend on the checkout's
  location.

## Working across the repositories

`launcher/`, `runtime/` and `runtime/recomp/` are submodules, checked out at a commit. Before
editing one, `git checkout main && git pull` inside it. Commit and push there first, then commit
the new pointer in its parent (recomp → runtime → app; launcher → app) and push that.

`main` in each repository has a ruleset: it cannot be deleted or force-pushed, and changes reach it
through a pull request with one approval and the CI checks passed (runtime: `build`; recomp:
`test`; launcher: `frontend` and `native (macos-15)`). Repository admins bypass it, so the
maintainer pushes to `main` directly. Release tags (`v*` here, `toolchain-*` in recomp) cannot be
moved or deleted. Merged branches are deleted.

## Things that change together

- **Memory:** `run.sh` sizes the game's memory; the launcher (`src/lib/data/memory.ts`) and the
  in-game menu (`MemoryEstimate` in `bbport_overlay.cpp`) estimate it the same way.
- **Settings the menu shows:** the runtime's `bbport_settings.cpp` and the launcher's
  `settings_store.rs` (`GAME_SYNCED`).
- **Colours:** the launcher's `src/index.css` tokens and the overlay's `Theme` in
  `bbport_overlay.cpp` (the settings menu, keyboard, FPS counter, banners and trophy notices).
- **Versions:** the app and the launcher, and a release's tag (`packaging/version.sh`, below).

## Tests

- `bash runtime/build.sh --test` runs the runtime's tests through `ctest`; the launcher's checks
  are in its README; bbcpu's CI runs its CPU tests on Apple Silicon.
- Game tests copy the player's save (`runtime/tools/test_run.sh`, the runtime's
  [building guide](https://github.com/bloodborne-native/bloodborne-runtime/blob/main/docs/BUILDING.md)).
  Test games are background-only apps (`SDL_MAC_BACKGROUND_APP=1`): they never become the active
  app, so focus and Cmd+Q behave unlike a launcher game; `BB_BENCH_FOREGROUND=1` for a test the
  maintainer plays in.
- The runtime's macOS CI runs on every push and cancels older runs: wait for a run whose result
  matters before pushing again. With its caches warm (the built dependencies and ccache, 99.7% of
  compiles from the cache) a run takes about 14 minutes instead of 36; most of what remains is the
  GPU library's link-time optimization and the tests. Its Linux CI is started by hand.
- Five GPU tests (motion-shader, scene-resolution, taa-shader, camera-motion, translation-memory)
  no longer compile and are listed in `runtime/gpu/CMakeLists.txt` instead of run.

## Docs and wikis

Each repository's wiki is generated from its docs, whole: one page per doc, Home from
`docs/README.md`, the sidebar, the app's release notes, and bloodborne-recomp's status page from
its RECOMPILATION.md. After changing docs, regenerate and push the wiki (never edit a page by
hand):

```bash
git clone https://github.com/bloodborne-native/bloodborne-recomp.wiki.git /tmp/recomp-wiki
python3 tools/wikigen.py recomp runtime/recomp /tmp/recomp-wiki   # app, runtime, bbcpu, recomp or launcher
```

Docs say what is true now: status, progress (20-block bars, one per 5%) and next steps in each
repository's status doc, conclusions instead of logs. Status and the plan for the whole project
are this repository's [Status](STATUS.md) and [Roadmap](ROADMAP.md).

## Releasing

App versions are this project's own; bbport's version only records imported compatibility. The
maintainer chooses the number. The app and the bundled launcher always have the same version, so
update checks compare correctly.

1. Bump the version: `bash packaging/version.sh X.Y.Z` writes it to the launcher's
   `package.json`, `package-lock.json` (two places), `src-tauri/Cargo.toml`, `src-tauri/Cargo.lock`
   and `src-tauri/tauri.conf.json`; `bash packaging/version.sh --check` reports whether they agree
   (the workflow does it against the tag).
2. Write `docs/releases/vX.Y.Z.md`: what changed for players, known issues, how to install.
3. Test this build: copied-save gameplay (`runtime/tools/test_run.sh`); the maintainer approves.
4. Commit and push `main`, run the workflow on it (`gh workflow run macos.yml --ref main`; pushes do
   not build) and check that it passes. The workflow keeps the built dependencies and a compiler
   cache between runs, so a run recompiles only what changed; with empty caches (or after a
   dependency changed) it builds everything, about an hour. The launcher's checks run in its own
   CI, and here only in the weekly build.
5. `git tag -a vX.Y.Z -m "..."` (a release candidate: `vX.Y.Z-rc.N`, published as a GitHub
   pre-release: release builds' update check skips it, candidate builds are told about it; its
   notes say it is a candidate and what feedback is wanted) and push the tag: `.github/workflows/macos.yml` builds the DMG and
   publishes the release with the notes, then posts it to the Discord server's `#releases`
   (`packaging/discord_release.py`: the notes' summary, "What's new" list and known issues;
   the `DISCORD_RELEASES_WEBHOOK` secret). Check the run (`gh run list`), the release's asset and
   the post. `DRY_RUN=1 python3 packaging/discord_release.py vX.Y.Z` shows the post beforehand;
   `gh workflow run discord-release.yml -f tag=vX.Y.Z` posts it again from main's notes.

README screenshots come from the game (`runtime/tools/grab.sh`, in English), never from the
screen; launcher screenshots from its browser preview with mock data.
