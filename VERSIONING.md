# Versioning

Hermes uses [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`.

- **MAJOR** — incompatible/breaking changes (protocol, config, behavior).
- **MINOR** — new functionality, backwards-compatible.
- **PATCH** — backwards-compatible bug fixes only.

While Hermes is pre-1.0 (`0.x.y`), minor bumps may still include breaking
changes; treat `0.x` as "fast-moving".

## Single source of truth

The top-level [`VERSION`](VERSION) file holds the current version and nothing
else (e.g. `0.1.0`). Everything derives from it:

| Consumer            | How it reads the version                                  |
|---------------------|-----------------------------------------------------------|
| CMake / C++ build   | `CMakeLists.txt` reads `VERSION` into `project(... VERSION)`; exposed to C++ as the `PROJECT_VERSION` macro (boot log + WebUI/API). |
| WebUI               | `package.json` `version` field (kept in sync by the bump script). |
| `.deb` / `.rpm`     | The CI packaging steps run `VERSION="$(cat VERSION)"`.    |
| Nightly release     | The `nightly` job reads `VERSION` for the release title.  |

Because of this, you never edit the version in more than one place.

## Day-to-day: the changelog

As you make changes, add a bullet under **[Unreleased]** in
[`CHANGELOG.md`](CHANGELOG.md) (under `Added` / `Changed` / `Fixed` /
`Removed`). This is the only per-commit habit needed — it keeps the release
notes ready at all times.

## Cutting a release

Run the bump script with the part to increment:

```bash
scripts/bump-version.sh patch    # 0.1.0 -> 0.1.1
scripts/bump-version.sh minor    # 0.1.1 -> 0.2.0
scripts/bump-version.sh major    # 0.2.0 -> 1.0.0
scripts/bump-version.sh 1.4.2    # or set it explicitly
```

The script:

1. updates `VERSION` and `package.json`,
2. moves the `[Unreleased]` changelog entries into a new dated
   `## [X.Y.Z] - YYYY-MM-DD` section,
3. commits as `Release vX.Y.Z`, and
4. creates the annotated tag `vX.Y.Z`.

Then push:

```bash
git push origin HEAD
git push origin vX.Y.Z
```

Pushing the `vX.Y.Z` tag triggers the **release** job in
[`.github/workflows/build.yml`](.github/workflows/build.yml), which builds the
Linux artifacts and publishes a normal (non-prerelease) GitHub Release.

Flags: `--no-tag` (commit but don't tag), `--no-commit` (edit files only).

## Nightly builds

Every push to `main` that builds successfully refreshes a single rolling
`nightly` prerelease on GitHub Releases, with the latest Linux artifacts. The
`nightly` tag is force-moved to the newest commit each time, so it always
reflects the tip of `main`. Nightlies are marked **pre-release** and are not
meant to be stable.
