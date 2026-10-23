# WiredDMS — a "Wired (Lain)" widget for DankMaterialShell

[English](README.md) · [Русский](README.ru.md)

A CRT panel with scrolling messages in the spirit of *Serial Experiments Lain*:
scanlines, character-by-character typing, glitches, a Japanese line above the
English one, a clock in the corner.

This is a desktop plugin for [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) (DMS),
written in [Quickshell](https://quickshell.org/).

```
┌────────────────────────────────────────────┐
│ LAYER 07                          01:26:30 │
│                                            │
│ 神はここにいる。                             │
│ God is here.▌                              │
└────────────────────────────────────────────┘
```

## Features

- Messages rotate on their own: typing, pause, fade out, next.
- Order is by layer (`LAYER 01`…`LAYER NN`) or random.
- A glitch flash whenever the message changes.
- The Japanese line is optional; the font falls back automatically.
- Palette: either its own CRT colors or the DMS theme colors.
- Draggable, resizable, font size via the mouse wheel. Position and size are
  stored **per monitor**.

## Requirements

| What | Version |
|---|---|
| DankMaterialShell | ≥ 1.2.0 |
| Quickshell | ≥ 0.3.2 |
| Font | `JetBrainsMono Nerd Font Mono` (Japanese falls back to `Noto Sans CJK JP`) |

The font is not mandatory, but the widget looks different without it — set your
own in `monoFont` inside `LainDesktopWidget.qml`.

## Installation

```bash
git clone https://github.com/Protectore/WiredDMS.git
cd WiredDMS
./install-dms-plugin.sh
```

The script copies `dms-plugin/*` into `~/.config/DankMaterialShell/plugins/lainWidget/`.

Then in DMS: **Settings → Desktop → add the "Wired (Lain)" widget**.

After installing or editing plugin files, reload it:

```bash
id=$(ls /run/user/1000/quickshell/by-id/ | head -1)
qs ipc -i "$id" call plugin-scan reload lainWidget
qs ipc -i "$id" call plugin-scan status lainWidget   # expect "loaded  desktop"
```

> **Do not confuse `reload` with `rescan`.** The `plugin-scan rescan` command
> unloads the plugin and does **not** bring it back — the widget disappears from
> the screen and `status` reads `unloaded`. Only `reload` brings it up.

## Controls

| Action | How |
|---|---|
| Move | **right mouse button** on the panel (the left one passes through — clickThrough) |
| Resize | **right mouse button** on the bottom-right corner of the panel |
| Font size | **mouse wheel** over the panel (works while clickThrough = false) |
| Settings | DMS Settings → Desktop → widgets → "Wired (Lain)" |

While the panel is being dragged, DMS raises it to the `Overlay` layer and puts it
back into `Bottom` afterwards. Position and size are written to
`~/.local/state/DankMaterialShell/session.json` → `desktopWidgetInstancePositions`.

## Settings

| Option | Default | Meaning |
|---|---|---|
| `cycleInterval` | `45` | pause between messages, s |
| `holdDuration` | `13` | how long a message stays on screen, s |
| `typeSpeed` | `32` | typing speed, ms per character |
| `randomOrder` | `false` | random order instead of layer order |
| `showJp` | `true` | show the Japanese line |
| `colorMode` | `custom` | `custom` — own palette, `theme` — DMS theme colors |
| `customInk` | `#dff3f5` | text color in `custom` mode |
| `backgroundOpacity` | `66` | background opacity, % |
| `fontPixelSize` | `17` | base font size (scales with the window size) |

## Your own messages

The list lives right in `LainDesktopWidget.qml` (the `messages` property), formatted
as `{ layer, jp, en }`: `layer` is the label in the top-right corner, `jp` is the
line above the text (may be empty), `en` is the main text. Edit it by hand and
reload the plugin to pick up the changes.

## Files

| File | What is inside |
|---|---|
| `dms-plugin/plugin.json` | the DMS plugin manifest |
| `dms-plugin/LainDesktopWidget.qml` | the widget itself: panel, messages, defaults |
| `dms-plugin/LainSettings.qml` | the settings panel in DMS |
| `install-dms-plugin.sh` | installs into `~/.config/DankMaterialShell/plugins/lainWidget/` |

## License

The code is MIT (see [LICENSE](LICENSE)).

The message strings: some are recognizable quotes from *Serial Experiments Lain*,
some are stylized "in the spirit of" the Wired. Rights to the original series
belong to its rights holders; this is a non-commercial fan work.
