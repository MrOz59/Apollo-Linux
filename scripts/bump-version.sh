#!/usr/bin/env bash
#
# bump-version.sh — bump the Hermes version in one step.
#
# The top-level VERSION file is the single source of truth. This script
# bumps it, mirrors the value into package.json and the PKGBUILD (pkgver,
# resetting pkgrel to 1), rolls the CHANGELOG's [Unreleased] section into a
# dated release section, then creates a commit and an annotated git tag
# (vX.Y.Z).
#
# Usage:
#   scripts/bump-version.sh patch        # 0.1.0 -> 0.1.1
#   scripts/bump-version.sh minor        # 0.1.1 -> 0.2.0
#   scripts/bump-version.sh major        # 0.2.0 -> 1.0.0
#   scripts/bump-version.sh 1.4.2        # set an explicit version
#
# Options:
#   --no-tag      Update files and commit, but do not create the git tag.
#   --no-commit   Update files only (implies --no-tag); leaves them staged.
#   -h, --help    Show this help.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

VERSION_FILE="VERSION"
PKG_JSON="package.json"
CHANGELOG="CHANGELOG.md"
PKGBUILD="PKGBUILD"

do_commit=1
do_tag=1
bump=""

usage() { sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --no-tag) do_tag=0 ;;
    --no-commit) do_commit=0; do_tag=0 ;;
    major|minor|patch) bump="$arg" ;;
    [0-9]*.[0-9]*.[0-9]*) bump="$arg" ;;
    *) echo "error: unknown argument '$arg'" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$bump" ]]; then
  echo "error: specify major|minor|patch or an explicit X.Y.Z version" >&2
  usage
  exit 1
fi

current="$(tr -d '[:space:]' < "$VERSION_FILE")"
IFS='.' read -r major minor patch <<< "$current"

case "$bump" in
  major) new="$((major + 1)).0.0" ;;
  minor) new="${major}.$((minor + 1)).0" ;;
  patch) new="${major}.${minor}.$((patch + 1))" ;;
  *)     new="$bump" ;;
esac

if ! [[ "$new" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "error: resulting version '$new' is not valid SemVer (X.Y.Z)" >&2
  exit 1
fi

echo "Bumping version: $current -> $new"

# 1. VERSION (single source of truth)
printf '%s\n' "$new" > "$VERSION_FILE"

# 2. package.json (top-level "version" field)
if [[ -f "$PKG_JSON" ]]; then
  # Only touch the first top-level "version": "..." line.
  sed -i -E "0,/^([[:space:]]*\"version\":[[:space:]]*)\"[^\"]*\"/s//\1\"$new\"/" "$PKG_JSON"
fi

# 3. PKGBUILD — the Arch pkgver drives BUILD_VERSION, which the build embeds
#    into the binary and the web UI shows. Keep it in lockstep with VERSION and
#    reset pkgrel to 1 for the new upstream version.
if [[ -f "$PKGBUILD" ]]; then
  sed -i -E "0,/^pkgver=.*/s//pkgver=$new/" "$PKGBUILD"
  sed -i -E "0,/^pkgrel=.*/s//pkgrel=1/" "$PKGBUILD"
fi

# 4. CHANGELOG.md — turn [Unreleased] into a dated release section and
#    open a fresh [Unreleased] above it.
if [[ -f "$CHANGELOG" ]]; then
  today="$(date +%Y-%m-%d)"
  if grep -q "^## \[Unreleased\]" "$CHANGELOG"; then
    sed -i -E "s|^## \[Unreleased\].*$|## [Unreleased]\n\n## [$new] - $today|" "$CHANGELOG"
  else
    echo "warning: no '## [Unreleased]' heading in $CHANGELOG; skipping changelog roll" >&2
  fi
fi

git add "$VERSION_FILE" "$PKG_JSON" "$PKGBUILD" "$CHANGELOG" 2>/dev/null || true

if [[ "$do_commit" -eq 0 ]]; then
  echo "Files updated and staged (no commit). Done."
  exit 0
fi

git commit -m "Release v$new"
echo "Committed: Release v$new"

if [[ "$do_tag" -eq 1 ]]; then
  git tag -a "v$new" -m "Hermes v$new"
  echo "Tagged: v$new"
  echo
  echo "Next: git push origin HEAD && git push origin v$new"
else
  echo "Next: git push origin HEAD   (tag skipped)"
fi
