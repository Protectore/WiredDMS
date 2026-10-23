# WiredDMS

Виджет "Wired (Lain)" для рабочего стола [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) (DMS).

[English](README.md) | [Русский](README.ru.md)

![Лицензия](https://img.shields.io/badge/license-MIT-b9c8da)
![DMS](https://img.shields.io/badge/DankMaterialShell-%3E%3D%201.2.0-9ccbfb)
![Quickshell](https://img.shields.io/badge/Quickshell-%3E%3D%200.3.2-9ccbfb)

<p align="center">
  <img src="https://github.com/user-attachments/assets/4b412028-7ac0-44b0-8831-290d9025d938" alt="Виджет перелистывает сообщения" width="640">
</p>

CRT-панель, которая живёт на рабочем столе и перелистывает сообщения в духе
*Serial Experiments Lain*: сканлайны, посимвольная печать, глитчи, японская
строка над английской и часы в кадре.

Это плагин рабочего стола для DMS, написанный на [Quickshell](https://quickshell.org/).

## Что умеет

- Сообщения сменяют друг друга: печать по символам, пауза, угасание, следующее.
- Порядок по слоям (`LAYER 01` ... `LAYER NN`) или случайный.
- Глитч-вспышка при смене сообщения.
- Японская строка опционально; шрифт добирается фолбэком.
- Палитра: своя CRT-палитра или цвета темы DMS.
- Таскается мышкой, тянется за угол, кегль колесом. Позиция и размер
  сохраняются **для каждого монитора** отдельно.

## Требования

| Что | Версия |
|---|---|
| DankMaterialShell | >= 1.2.0 |
| Quickshell | >= 0.3.2 |
| Шрифт | `JetBrainsMono Nerd Font Mono` (японский доберётся из `Noto Sans CJK JP`) |

Шрифт не обязателен, но без него виджет выглядит иначе. Подставь свой в
`monoFont` в `LainDesktopWidget.qml`, если этого нет.

## Установка

```bash
git clone https://github.com/Protectore/WiredDMS.git
cd WiredDMS
./install-dms-plugin.sh
```

Скрипт копирует `dms-plugin/*` в `~/.config/DankMaterialShell/plugins/lainWidget/`.

Дальше в DMS: **Настройки -> Рабочий стол -> добавить виджет "Wired (Lain)"**.

После установки или правки файлов плагина перезагрузи его:

```bash
id=$(ls "/run/user/$(id -u)/quickshell/by-id/" | head -1)
qs ipc -i "$id" call plugin-scan reload lainWidget
qs ipc -i "$id" call plugin-scan status lainWidget   # ждём "loaded  desktop"
```

Нужен `reload`, а не `rescan`: команда `plugin-scan rescan` выгружает плагин и
обратно не поднимает, поэтому виджет исчезнет с экрана, а `status` покажет
`unloaded`.

## Управление

| Действие | Как |
|---|---|
| Перетащить | **правая кнопка мыши** по панели (левая проходит сквозь, clickThrough) |
| Изменить размер | **правая кнопка** по правому нижнему углу панели |
| Кегль текста | **колесо мыши** по панели (работает, когда clickThrough = false) |
| Настройки | Настройки DMS -> Рабочий стол -> виджеты -> "Wired (Lain)" |

Пока панель тащат, DMS поднимает её в слой `Overlay`, после возвращает в `Bottom`.
Позиция и размер пишутся в `~/.local/state/DankMaterialShell/session.json`, ключ
`desktopWidgetInstancePositions`.

## Настройки

| Параметр | По умолчанию | Смысл |
|---|---|---|
| `cycleInterval` | `45` | пауза между сообщениями, с |
| `holdDuration` | `13` | сколько сообщение на экране, с |
| `typeSpeed` | `32` | скорость печати, мс на символ |
| `randomOrder` | `false` | случайный порядок вместо "по слоям" |
| `showJp` | `true` | показывать японскую строку |
| `colorMode` | `custom` | `custom` это своя палитра, `theme` это цвета темы DMS |
| `customInk` | `#dff3f5` | цвет текста в режиме `custom` |
| `backgroundOpacity` | `66` | прозрачность фона, % |
| `fontPixelSize` | `17` | базовый кегль (масштабируется от размера окна) |

## Свои сообщения

Список лежит прямо в `LainDesktopWidget.qml` (свойство `messages`), формат
`{ layer, jp, en }`: `layer` это подпись справа сверху, `jp` это строка над
текстом (может быть пустой), `en` это основной текст. Правится руками,
перезагрузка плагина подхватывает изменения.

```js
{ layer: "LAYER 01", jp: "こんにちは。", en: "Hello." },
```

## Файлы

| Файл | Что внутри |
|---|---|
| `dms-plugin/plugin.json` | манифест DMS-плагина |
| `dms-plugin/LainDesktopWidget.qml` | сам виджет: панель, сообщения, настройки по умолчанию |
| `dms-plugin/LainSettings.qml` | панель настроек в DMS |
| `install-dms-plugin.sh` | установка в `~/.config/DankMaterialShell/plugins/lainWidget/` |

## Лицензия

Код под MIT (см. [LICENSE](LICENSE)).

Строки сообщений: часть это узнаваемые реплики из *Serial Experiments Lain*, часть
стилизация "под Wired". Права на исходный сериал принадлежат его правообладателям;
это некоммерческая фанатская работа.
