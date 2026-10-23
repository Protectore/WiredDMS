// Настройки виджета «Wired (Lain)» в DMS.
// Хост (PluginDesktopWidgetSettings) сам кладёт сюда instanceData и instanceId,
// поэтому пишем прямо в config этого экземпляра — у каждого своя палитра и ритм.

pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.Widgets

Column {
    id: root

    property string instanceId: ""
    property var instanceData: null

    readonly property var cfg: instanceData?.config ?? {}

    function updateConfig(key, value) {
        if (!instanceId)
            return;
        var updates = {};
        updates[key] = value;
        SettingsData.updateDesktopWidgetInstanceConfig(instanceId, updates);
    }

    width: parent?.width ?? 400
    spacing: 0

    SettingsDropdownRow {
        text: "Палитра"
        options: ["Своя (CRT)", "Тема DMS"]
        currentValue: (cfg.colorMode ?? "custom") === "theme" ? "Тема DMS" : "Своя (CRT)"
        onValueChanged: value => root.updateConfig("colorMode", value === "Тема DMS" ? "theme" : "custom")
    }

    SettingsDivider {
        visible: (cfg.colorMode ?? "custom") !== "theme"
    }

    SettingsColorPicker {
        visible: (cfg.colorMode ?? "custom") !== "theme"
        colorMode: "custom"
        customColor: cfg.customInk ?? "#dff3f5"
        pickerTitle: "Цвет текста панели"
        onCustomColorSelected: selectedColor => root.updateConfig("customInk", selectedColor.toString())
    }

    SettingsDivider {}

    SettingsSliderRow {
        text: "Пауза между сообщениями"
        minimum: 5
        maximum: 300
        step: 5
        value: cfg.cycleInterval ?? 45
        unit: " с"
        onSliderValueChanged: newValue => root.updateConfig("cycleInterval", newValue)
    }

    SettingsDivider {}

    SettingsSliderRow {
        text: "Сколько сообщение на экране"
        minimum: 3
        maximum: 120
        step: 1
        value: cfg.holdDuration ?? 13
        unit: " с"
        onSliderValueChanged: newValue => root.updateConfig("holdDuration", newValue)
    }

    SettingsDivider {}

    SettingsSliderRow {
        text: "Скорость печати"
        minimum: 5
        maximum: 150
        step: 1
        value: cfg.typeSpeed ?? 32
        unit: " мс/символ"
        onSliderValueChanged: newValue => root.updateConfig("typeSpeed", newValue)
    }

    SettingsDivider {}

    SettingsToggleRow {
        text: "Случайный порядок сообщений"
        checked: cfg.randomOrder ?? false
        onToggled: checked => root.updateConfig("randomOrder", checked)
    }

    SettingsDivider {}

    SettingsToggleRow {
        text: "Показывать японскую строку"
        checked: cfg.showJp ?? true
        onToggled: checked => root.updateConfig("showJp", checked)
    }

    SettingsDivider {}

    SettingsSliderRow {
        text: "Прозрачность фона"
        minimum: 0
        maximum: 100
        step: 2
        value: cfg.backgroundOpacity ?? 66
        unit: "%"
        onSliderValueChanged: newValue => root.updateConfig("backgroundOpacity", newValue)
    }

    SettingsDivider {}

    SettingsSliderRow {
        text: "Базовый кегль текста (колесо мыши по виджету — быстрее)"
        minimum: 11
        maximum: 34
        step: 1
        value: cfg.fontPixelSize ?? 17
        unit: " px"
        onSliderValueChanged: newValue => root.updateConfig("fontPixelSize", newValue)
    }
}
