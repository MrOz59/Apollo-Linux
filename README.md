# Hermes

Hermes is an Apollo-derived Linux game-streaming host focused on making
Moonlight/Hestia streaming less manual and more reliable on CachyOS/Arch,
especially with real virtual displays through EVDI.

Hermes keeps compatibility with Apollo, Sunshine, Moonlight, and Hestia. The
normal GameStream/Sunshine flow remains the fallback path, while Hestia can use
Hermes protocol extensions when the host reports support for them.

## Current focus

- Create and activate a real virtual display first, using EVDI or another
  compatible virtual-display backend.
- Use KDE/KScreen or Wayland output-management integration to make the
  compositor actually render into the virtual display.
- Avoid falling back silently to the physical monitor when EVDI setup fails.
- Report missing host dependencies and diagnostics clearly.
- Keep Gamescope optional. Gamescope is useful for a SteamOS-like session, but
  Hermes should only use it when enabled by app configuration, settings, or an
  explicit Hestia request.

## Hestia protocol support

Hermes exposes Hestia protocol v1 endpoints under:

```http
/api/hestia/v1
```

Important endpoints include:

- `GET /api/hestia/v1/capabilities`
- `POST /api/hestia/v1/session/prepare`
- `POST /api/hestia/v1/session/stop`
- `GET /api/hestia/v1/diagnostics`
- `GET /api/hestia/v1/clipboard`
- `POST /api/hestia/v1/clipboard`

Clients should gate enhanced behavior on the capabilities response. If the
Hestia API is unavailable, clients should continue through the normal
Moonlight/Apollo/Sunshine flow.

## Virtual display behavior

Hermes tries to create and connect a virtual display for virtual-display
sessions before launching the configured app. On Linux/KDE Wayland, this depends
on:

- `evdi` / `evdi-dkms`
- `libevdi`
- `kscreen-doctor`
- a session where the Hermes process can access the user compositor environment

Gamescope is not required for the normal EVDI virtual-display path. If installed,
Hermes exposes an optional `Gamescope Steam Session` app entry that runs Steam
Big Picture inside Gamescope on top of the virtual display.

## CachyOS/Arch package build

From the repository root:

```bash
makepkg -sf
```

If the host already has all build dependencies installed and `makepkg -s` is
blocked by local dependency metadata, a local developer build can use:

```bash
makepkg --nodeps -sf
```

Install the generated package with:

```bash
sudo pacman -U ./apollo-*.pkg.tar.zst
```

The package is still named `apollo` for compatibility with the existing Apollo
service/config paths. Renaming package IDs, binary names, and config paths is a
separate compatibility decision.

## Credits

Hermes builds on work from:

- ClassicOldSong's Apollo project, which established the Apollo host direction
  and Moonlight compatibility model.
- Sgtmetalmex's Apollo-CachyOS fork, whose EVDI/KDE/Gamescope patch series
  identified and fixed several Linux virtual-display issues that are important
  for Hermes stability:
  - EVDI device-index discovery.
  - KScreen/KWin virtual-output activation.
  - avoiding DRM master conflicts on EVDI cards.
  - hotplugged EVDI capture fallback.
  - EVDI CPU-buffer capture and event pumping.
  - physical-monitor recovery safety work.
  - optional Gamescope Steam Session integration.

Reference fork:

- https://github.com/Sgtmetalmex/Apollo-CachyOS
