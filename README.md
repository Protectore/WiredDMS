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

> **Не путай `reload` и `rescan`.** Команда `plugin-scan rescan` выгружает плагин и
> обратно **не поднимает** — виджет исчезнет с экрана, а `status` будет `unloaded`.
> Поднимает только `reload`.

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

## Свои сообщения

Список лежит прямо в `LainDesktopWidget.qml` (свойство `messages`), формат
`{ layer, jp, en }`: `layer` — подпись справа сверху, `jp` — строка над текстом
(может быть пустой), `en` — основной текст. Правится руками, перезагрузка плагина
подхватывает изменения.

## Файлы

| Файл | Что внутри |
|---|---|
| `dms-plugin/plugin.json` | манифест DMS-плагина |
| `dms-plugin/LainDesktopWidget.qml` | сам виджет: панель, сообщения, настройки по умолчанию |
| `dms-plugin/LainSettings.qml` | панель настроек в DMS |
| `install-dms-plugin.sh` | установка в `~/.config/DankMaterialShell/plugins/lainWidget/` |

## Лицензия

Код — MIT (см. [LICENSE](LICENSE)).

Строки сообщений: часть — узнаваемые реплики из *Serial Experiments Lain*, часть —
стилизация «под Wired». Права на исходный сериал принадлежат его правообладателям;
это некоммерческая фанатская работа.
