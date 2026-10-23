#!/usr/bin/env bash
# Устанавливает виджет «Wired (Lain)» как DMS-плагин рабочего стола.
# Копирует dms-plugin/* в ~/.config/DankMaterialShell/plugins/lainWidget/.
#
# Экземпляр виджета создаётся не здесь: в DMS → Настройки → Рабочий стол →
# добавить виджет «Wired (Lain)». Подробности и обходной путь — в README.md.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$here/dms-plugin"
dst="$HOME/.config/DankMaterialShell/plugins/lainWidget"

if [ ! -f "$src/plugin.json" ]; then
    echo "! нет $src/plugin.json — запускать из каталога виджета" >&2
    exit 1
fi

mkdir -p "$dst"
install -m 644 "$src/plugin.json" "$src/LainDesktopWidget.qml" "$src/LainSettings.qml" "$dst/"

echo "ok: плагин установлен в $dst"
echo
echo "Дальше:"
echo "  1) в DMS добавь виджет: Настройки → Рабочий стол → «Wired (Lain)»"
echo "  2) после установки/правки файлов перезагрузи плагин:"
echo "       id=\$(ls /run/user/1000/quickshell/by-id/ | head -1)"
echo "       qs ipc -i \$id call plugin-scan reload lainWidget"
echo "       qs ipc -i \$id call plugin-scan status lainWidget   # ждём 'loaded  desktop'"
echo
echo "     Внимание: rescan выгружает плагин и обратно НЕ поднимает —"
echo "     виджет пропадёт с экрана. Поднимает только reload."
echo
echo "Проверка живости:"
echo "  qs ipc -i \$id call lainWidget ping"
