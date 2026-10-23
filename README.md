# WiredDMS — виджет «Wired (Lain)» для DankMaterialShell

CRT-панель с бегущими сообщениями в духе *Serial Experiments Lain*: сканлайны,
посимвольная печать, глитчи, японская строка над английской, часы в кадре.

Это плагин рабочего стола для [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) (DMS),
написанный на [Quickshell](https://quickshell.org/).

```
┌────────────────────────────────────────────┐
│ LAYER 07                          01:26:30 │
│                                            │
│ 神はここにいる。                             │
│ God is here.▌                              │
└────────────────────────────────────────────┘
```

## Что умеет

- Сообщения сменяют друг друга: печать по символам, пауза, угасание, следующее.
- Порядок — по слоям (`LAYER 01`…`LAYER NN`) или случайный.
- Глитч-вспышка при смене сообщения.
- Японская строка опционально; шрифт добирается фолбэком.
- Палитра: своя CRT-палитра или цвета темы DMS.
- Таскается мышкой, тянется за угол, кегль — колесом. Позиция и размер
  сохраняются **для каждого монитора** отдельно.

## Требования

| Что | Версия |
|---|---|
| DankMaterialShell | ≥ 1.2.0 |
| Quickshell | ≥ 0.3.2 |
| Шрифт | `JetBrainsMono Nerd Font Mono` (японский — фолбэк из `Noto Sans CJK JP`) |

Шрифт не обязателен, но без него виджет выглядит иначе — подставь свой в
`monoFont` в `LainDesktopWidget.qml`, если этого нет.

## Установка

```bash
git clone https://github.com/Protectore/WiredDMS.git
cd WiredDMS
./install-dms-plugin.sh
```

Скрипт копирует `dms-plugin/*` в `~/.config/DankMaterialShell/plugins/lainWidget/`.

Дальше в DMS: **Настройки → Рабочий стол → добавить виджет «Wired (Lain)»**.

После установки или правки файлов плагина — перезагрузить его:

```bash
id=$(ls /run/user/1000/quickshell/by-id/ | head -1)
qs ipc -i "$id" call plugin-scan reload lainWidget
qs ipc -i "$id" call plugin-scan status lainWidget   # ждём «loaded  desktop»
```

> **Грабля:** `plugin-scan rescan` выгружает плагин и обратно **не поднимает** —
> `status` остаётся `unloaded`, поверхность исчезает с экрана. Поднимает только
> `reload`. Если виджет пропал после `rescan` — зови `reload`, а не перезапускай шелл.

## Управление

| Действие | Как |
|---|---|
| Перетащить | **правая кнопка мыши** по панели (левая проходит сквозь — clickThrough) |
| Изменить размер | **правая кнопка** по правому нижнему углу панели |
| Кегль текста | **колесо мыши** по панели (работает, когда clickThrough = false) |
| Настройки | Настройки DMS → Рабочий стол → виджеты → «Wired (Lain)» |

Пока панель тащат, DMS поднимает её в слой `Overlay`, после — возвращает в `Bottom`.
Позиция и размер пишутся в `~/.local/state/DankMaterialShell/session.json` →
`desktopWidgetInstancePositions`.

## Настройки

| Параметр | По умолчанию | Смысл |
|---|---|---|
| `cycleInterval` | `45` | пауза между сообщениями, с |
| `holdDuration` | `13` | сколько сообщение на экране, с |
| `typeSpeed` | `32` | скорость печати, мс на символ |
| `randomOrder` | `false` | случайный порядок вместо «по слоям» |
| `showJp` | `true` | показывать японскую строку |
| `colorMode` | `custom` | `custom` — своя палитра, `theme` — цвета темы DMS |
| `customInk` | `#dff3f5` | цвет текста в режиме `custom` |
| `backgroundOpacity` | `66` | прозрачность фона, % |
| `fontPixelSize` | `17` | базовый кегль (масштабируется от размера окна) |

### Обходной путь: экземпляр через IPC не создаётся

IPC-таргет `desktopWidget` умеет только `list/status/enable/disable/toggleClickThrough`
и т.п. — создания экземпляра там нет. Если лень идти в настройки, можно дописать
инстанс в `~/.config/DankMaterialShell/settings.json` → `desktopWidgetInstances`:

```json
{
  "id": "dw_lain_01",
  "widgetType": "lainWidget",
  "name": "Wired (Lain)",
  "enabled": true,
  "config": {
    "displayPreferences": ["all"],
    "clickThrough": true,
    "colorMode": "custom",
    "customInk": "#dff3f5",
    "backgroundOpacity": 66,
    "cycleInterval": 45,
    "holdDuration": 13,
    "typeSpeed": 32,
    "randomOrder": false,
    "showJp": true,
    "fontPixelSize": 17
  }
}
```

DMS подхватывает файл на лету (FileView-watcher), перезапуск шелла не нужен.

## Проверка живости

```bash
qs ipc -i <instance-id> call lainWidget ping    # размер, экземпляр, текущий текст
qs ipc -i <instance-id> call lainWidget next    # перелистнуть сообщение
niri msg layers | grep lainWidget               # поверхность на месте?
```

`<instance-id>` — имя каталога в `/run/user/1000/quickshell/by-id/` (у DMS это
хеш вида `5313mt9nt`; если каталог один — подойдёт `ls | head -1`).

## Файлы

| Файл | Что внутри |
|---|---|
| `dms-plugin/plugin.json` | манифест DMS-плагина (`type: desktop`, `capabilities: [desktop-widget]`) |
| `dms-plugin/LainDesktopWidget.qml` | сам виджет: `DesktopPluginComponent` + сообщения + `IpcHandler` |
| `dms-plugin/LainSettings.qml` | панель настроек в DMS |
| `install-dms-plugin.sh` | установка в `~/.config/DankMaterialShell/plugins/lainWidget/` |

## Свои сообщения

Список лежит прямо в `LainDesktopWidget.qml` (свойство `messages`), формат
`{ layer, jp, en }`: `layer` — подпись справа сверху, `jp` — строка над текстом
(может быть пустой), `en` — основной текст. Правится руками, перезагрузка плагина
подхватывает изменения.

## Грабли (проверено на живой сессии)

- **`permissions` обязателен.** Без `"permissions": ["settings_read", "settings_write"]`
  DMS показывает вместо настроек ошибку «does not have 'settings_write' permission».
- **`IpcHandler` требует `import Quickshell.Io`.** Без него загрузка падает с
  `IpcHandler is not a type`, а плагин молча остаётся `disabled`.
  Диагностика: `qs ipc -i <id> call plugin-scan status lainWidget` — третье поле
  показывает текст ошибки загрузки.
- **Права на файлы.** `cp` может создать файлы с `600`; DMS читает их нормально,
  но лучше `install -m 644`.
- **Два разных IPC-таргета.** `plugins` (`list/enable/disable/reload/status`) и
  `plugin-scan` (`scan/rescan/reload/status`). Осмысленный статус с текстом ошибки
  даёт именно `plugin-scan`.
- **`qmllint` для проверки бесполезен.** Он стабильно возвращает код 255 на файлах
  с `pragma ComponentBehavior: Bound` (а он есть во всех QML-файлах DMS). Судить о
  синтаксисе по нему нельзя — проверяй живым запуском и `plugin-scan status`.

## Заметки по реализации

- **Два затухания вместо одного.** Поверх нашей прозрачности
  (`Behavior on contentOpacity`) обёртка DMS `DesktopPluginWrapper.qml` вешает на
  лоадер свой `revealFade` длиной ровно `Theme.mediumDuration` с кривой
  `Theme.standardEasing`. Если числа разойдутся, две кривые перемножатся и угасание
  станет резче в начале и вялым в хвосте — поэтому в `LainDesktopWidget.qml`
  длительность берётся из темы, а не хардкодом. Обёртку править нельзя:
  `/run/user/1000/danklinux-shell/` пересобирается.
- **`persistentFrame` живёт в коде, но не в UI.** Обёртка DMS про него не знает
  (`visible` окна определяется её собственными `contentShowing`/`surfaceLingering`),
  так что спрятать окно между сообщениями он не может. Влияет только на вид панели:
  через `showing` гасит фон, рамку и сканлайны. Свойство оставлено со значением
  `true` и намеренно убрано из настроек.

## Лицензия

Код — MIT (см. [LICENSE](LICENSE)).

Строки сообщений: часть — узнаваемые реплики из *Serial Experiments Lain*, часть —
стилизация «под Wired». Права на исходный сериал принадлежат его правообладателям;
это некоммерческая фанатская работа.
