#!/usr/bin/env bash
# Installs the "Wired (Lain)" widget as a DMS desktop plugin.
# Copies dms-plugin/* into ~/.config/DankMaterialShell/plugins/lainWidget/.
#
# The widget instance itself is not created here. Do that in DMS:
# Settings -> Desktop -> add the "Wired (Lain)" widget.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$here/dms-plugin"
dst="$HOME/.config/DankMaterialShell/plugins/lainWidget"

if [ ! -f "$src/plugin.json" ]; then
    echo "! no $src/plugin.json, run this from the widget directory" >&2
    exit 1
fi

mkdir -p "$dst"
install -m 644 "$src/plugin.json" "$src/LainDesktopWidget.qml" "$src/LainSettings.qml" "$dst/"

echo "ok: plugin installed to $dst"
echo
echo "Next:"
echo "  1) add the widget in DMS: Settings -> Desktop -> \"Wired (Lain)\""
echo "  2) after installing or editing plugin files, reload it:"
echo "       id=\$(ls /run/user/1000/quickshell/by-id/ | head -1)"
echo "       qs ipc -i \$id call plugin-scan reload lainWidget"
echo "       qs ipc -i \$id call plugin-scan status lainWidget   # expect 'loaded  desktop'"
echo
echo "     Use reload, not rescan: rescan unloads the plugin and does not"
echo "     bring it back, so the widget disappears from the screen."
