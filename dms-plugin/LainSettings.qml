// Settings for the "Wired (Lain)" widget in DMS.
// The host (PluginDesktopWidgetSettings) injects instanceData and instanceId here,
// so we write straight into this instance's config — each one has its own palette and rhythm.

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
        text: "Palette"
        options: ["Custom (CRT)", "DMS theme"]
        currentValue: (cfg.colorMode ?? "custom") === "theme" ? "DMS theme" : "Custom (CRT)"
        onValueChanged: value => root.updateConfig("colorMode", value === "DMS theme" ? "theme" : "custom")
    }

    SettingsDivider {
        visible: (cfg.colorMode ?? "custom") !== "theme"
    }

    SettingsColorPicker {
        visible: (cfg.colorMode ?? "custom") !== "theme"
        colorMode: "custom"
        customColor: cfg.customInk ?? "#dff3f5"
        pickerTitle: "Panel text color"
        onCustomColorSelected: selectedColor => root.updateConfig("customInk", selectedColor.toString())
    }

    SettingsDivider {}

    SettingsSliderRow {
        text: "Pause between messages"
        minimum: 5
        maximum: 300
        step: 5
        value: cfg.cycleInterval ?? 45
        unit: " s"
        onSliderValueChanged: newValue => root.updateConfig("cycleInterval", newValue)
    }

    SettingsDivider {}

    SettingsSliderRow {
        text: "How long a message stays on screen"
        minimum: 3
        maximum: 120
        step: 1
        value: cfg.holdDuration ?? 13
        unit: " s"
        onSliderValueChanged: newValue => root.updateConfig("holdDuration", newValue)
    }

    SettingsDivider {}

    SettingsSliderRow {
        text: "Typing speed"
        minimum: 5
        maximum: 150
        step: 1
        value: cfg.typeSpeed ?? 32
        unit: " ms/char"
        onSliderValueChanged: newValue => root.updateConfig("typeSpeed", newValue)
    }

    SettingsDivider {}

    SettingsToggleRow {
        text: "Random message order"
        checked: cfg.randomOrder ?? false
        onToggled: checked => root.updateConfig("randomOrder", checked)
    }

    SettingsDivider {}

    SettingsToggleRow {
        text: "Show the Japanese line"
        checked: cfg.showJp ?? true
        onToggled: checked => root.updateConfig("showJp", checked)
    }

    SettingsDivider {}

    SettingsSliderRow {
        text: "Background opacity"
        minimum: 0
        maximum: 100
        step: 2
        value: cfg.backgroundOpacity ?? 66
        unit: "%"
        onSliderValueChanged: newValue => root.updateConfig("backgroundOpacity", newValue)
    }

    SettingsDivider {}

    SettingsSliderRow {
        text: "Base font size (wheel over the widget is faster)"
        minimum: 11
        maximum: 34
        step: 1
        value: cfg.fontPixelSize ?? 17
        unit: " px"
        onSliderValueChanged: newValue => root.updateConfig("fontPixelSize", newValue)
    }
}
