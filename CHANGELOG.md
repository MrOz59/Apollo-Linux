# Changelog

All notable changes to Hermes are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Add new entries under **[Unreleased]** as you work. When you cut a release,
run `scripts/bump-version.sh <major|minor|patch>` — it moves everything under
[Unreleased] into a new dated, versioned section automatically.

## [Unreleased]

### Added
- Single-source version scheme: the top-level `VERSION` file drives the
  CMake project version, packaging, and the version shown in the WebUI/logs.
- `scripts/bump-version.sh` to bump the version and tag a release in one step.
- Rolling `nightly` prerelease published from `main` on every successful build.

### Changed
- `package.json` renamed from `sunshine` to `hermes` and versioned at 0.1.0.
- Debian and RPM packaging now read the version from the `VERSION` file
  instead of a hardcoded value.
- The git-fallback versioning treats `main` as a release branch (no commit
  hash suffix), matching `master`.

### Fixed
- CI: install GBM (`libgbm-dev` / `mesa-libgbm-devel`) so the Linux builds
  compile `src/platform/linux/wayland.cpp`.
- CI: correct the Windows MinHook package name and add Node.js/npm to MSYS2.
- CI: stop the Debian job failing on a redundant self-`mv` of the `.deb`.

## [0.1.0] - 2026-06-29

### Added
- Initial versioned baseline of Hermes: an Apollo-derived Linux game-streaming
  host with low-latency virtual displays via Hermes-KMS (zero-copy DRM/KMS),
  EVDI still supported, and Hestia/Moonlight/Artemis protocol compatibility.

[Unreleased]: https://github.com/MrOz59/Hermes/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/MrOz59/Hermes/releases/tag/v0.1.0
