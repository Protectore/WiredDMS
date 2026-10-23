// The widget itself: panel, messages and default settings.
//
// The panel is draggable with the right mouse button and resizable from its
// bottom-right corner; size and position are stored per monitor. The mouse wheel
// changes the font size, and clicks pass through to whatever is underneath.

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Common
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    // The panel cannot be squeezed below this size: the content would overlap the frame.
    minWidth: 380
    minHeight: 170

    /* knobs (exposed in the widget settings in DMS) */
    readonly property int cycleInterval: pluginData.cycleInterval ?? 45
    readonly property int holdDuration: pluginData.holdDuration ?? 13
    readonly property int typeSpeed: pluginData.typeSpeed ?? 32
    readonly property bool randomOrder: pluginData.randomOrder ?? false
    readonly property bool persistentFrame: pluginData.persistentFrame ?? true
    readonly property string colorMode: pluginData.colorMode ?? "custom"
    readonly property color customInk: pluginData.customInk ?? "#dff3f5"
    readonly property real backgroundOpacity: (pluginData.backgroundOpacity ?? 66) / 100
    readonly property bool showJp: pluginData.showJp ?? true

    /* theme: either our own palette or the DMS colors */
    readonly property bool useTheme: colorMode === "theme" || colorMode === "primary"
    readonly property color ink: useTheme ? Theme.surfaceText : customInk
    readonly property color dim: useTheme ? Theme.primary : Qt.rgba(customInk.r, customInk.g, customInk.b, 0.62)
    readonly property color accent: useTheme ? Theme.primary : Qt.lighter(customInk, 1.35)
    readonly property color frameLine: useTheme ? Theme.withAlpha(Theme.primary, 0.3) : Qt.rgba(customInk.r, customInk.g, customInk.b, 0.22)
    readonly property color panelColor: useTheme
        ? Theme.withAlpha(Theme.surfaceContainer, backgroundOpacity)
        : Qt.rgba(0.024, 0.039, 0.043, backgroundOpacity)
    readonly property color glitchInk: useTheme ? Theme.error : "#ffb3bd"

    /* preset messages (edit them here) */
    readonly property var messages: [
        { layer: "LAYER 01", jp: "こんにちは。",            en: "Hello." },
        { layer: "LAYER 02", jp: "わたしはここにいる。",      en: "I am here." },
        { layer: "LAYER 03", jp: "",                     en: "Present day... present time... ha ha ha." },
        { layer: "LAYER 04", jp: "",                     en: "Close the world, open the nExt." },
        { layer: "LAYER 05", jp: "ワイアードはどこにでもある。", en: "The Wired is everywhere." },
        { layer: "LAYER 06", jp: "",                     en: "You don't seem to understand." },
        { layer: "LAYER 07", jp: "神はここにいる。",         en: "God is here." },
        { layer: "LAYER 08", jp: "すべての人はつながっている。", en: "Everyone is connected." },
        { layer: "LAYER 09", jp: "",                     en: "Are you connected to the Wired?" },
        { layer: "LAYER 10", jp: "",                     en: "Do you hear me?" },
        { layer: "LAYER 11", jp: "現実とワイアードの境界は消えていく。", en: "The border between the real world and the Wired is fading." },
        { layer: "LAYER 12", jp: "",                     en: "Tachibana General Laboratories - Copland OS 5.0" },
        { layer: "LAYER 13", jp: "みんな、レインを愛してる。",   en: "Let's all love Lain." },
        { layer: "LAYER 14", jp: "",                     en: "Knights of the Eastern Calculus." },
        { layer: "LAYER 15", jp: "",                     en: "No matter where you go, everyone's connected." },
        { layer: "LAYER 16", jp: "",                     en: "Protocol 7 - psyche processor online." },
        { layer: "LAYER 17", jp: "あなたは誰？",            en: "Who are you?" },
        { layer: "LAYER 18", jp: "",                     en: "It is not a lie. The Wired is real." },
        { layer: "LAYER 19", jp: "どこにいても、あなたとつながっている。", en: "Wherever you are, I am connected to you." },
        { layer: "LAYER 20", jp: "",                     en: "I am everywhere. I am nowhere." },
        { layer: "LAYER 21", jp: "接続が切断された。",        en: "Connection terminated." },
        { layer: "LAYER 22", jp: "",                     en: "> unsolicited packet from the Wired" },
        { layer: "LAYER 23", jp: "",                     en: "> tracing route to layer 07 ... ok" },
        { layer: "LAYER 24", jp: "",                     en: "> noise floor 0.04% - signal clean" },
        { layer: "LAYER 25", jp: "",                     en: "> the Wired is listening" },
        { layer: "LAYER 26", jp: "眠らないで。",            en: "Don't fall asleep." },
        { layer: "LAYER 27", jp: "",                     en: "You are watching, aren't you?" },
        { layer: "LAYER 28", jp: "またね。",               en: "See you." }
    ]

    readonly property string monoFont: pluginData.monoFont ?? "JetBrainsMono Nerd Font Mono"
    readonly property real basePixelSize: pluginData.fontPixelSize ?? 17

    // Window size comes from the wrapper (item.widgetWidth/widgetHeight are bound to the window).
    readonly property real fontScale: widgetHeight > 0 ? Math.max(0.55, Math.min(2.4, widgetHeight / 168)) : 1
    readonly property int enPixelSize: Math.max(9, Math.round(basePixelSize * fontScale))
    readonly property int jpPixelSize: Math.max(8, Math.round((basePixelSize - 4) * fontScale))
    readonly property int chromePixelSize: Math.max(7, Math.round(10 * fontScale))
    readonly property int pad: Math.max(6, Math.round(14 * fontScale))

    /* state */
    property var current: null
    property int revealed: 0
    property bool typing: false
    property bool glitching: false
    property int glitchShift: 0
    property bool cursorOn: true
    property real contentOpacity: 0
    property string clock: Qt.formatTime(new Date(), "hh:mm:ss")
    property var order: []
    property int orderPos: -1

    readonly property string messageText: current ? (current.en ?? "") : ""
    readonly property string visibleText: messageText.substring(0, revealed)
    readonly property string cursorGlyph: (typing || cursorOn) ? "\u258c" : ""
    readonly property string jpText: (current && showJp) ? (current.jp ?? "") : ""
    readonly property bool showing: persistentFrame || contentOpacity > 0.01

    function buildOrder() {
        const out = [];
        for (let i = 0; i < root.messages.length; ++i)
            out.push(i);

        if (randomOrder) {
            for (let i = out.length - 1; i > 0; --i) {
                const j = Math.floor(Math.random() * (i + 1));
                const swap = out[i];
                out[i] = out[j];
                out[j] = swap;
            }
        }
        order = out;
    }

    function showNext() {
        if (order.length === 0)
            buildOrder();

        orderPos = (orderPos + 1) % order.length;
        current = root.messages[order[orderPos]];
        revealed = 0;
        contentOpacity = 1;
        typing = true;
        holdTimer.stop();
    }

    // A right-click without movement advances to the next message.
    function peekNext() {
        showNext();
    }

    /* timers */
    Timer {
        interval: typeSpeed
        repeat: true
        running: root.typing
        onTriggered: {
            root.revealed += 1;
            if (root.revealed >= root.messageText.length) {
                root.typing = false;
                holdTimer.restart();
            }
        }
    }

    Timer {
        id: holdTimer
        interval: root.holdDuration * 1000
        repeat: false
        onTriggered: root.contentOpacity = 0
    }

    Timer {
        id: cycleTimer
        interval: root.cycleInterval * 1000
        repeat: true
        onTriggered: root.showNext()
    }

    Timer {
        interval: 1200
        repeat: false
        running: true
        onTriggered: {
            root.showNext();
            cycleTimer.start();
        }
    }

    Timer {
        interval: 4200 + Math.floor(Math.random() * 9000)
        repeat: true
        running: true
        onTriggered: {
            root.glitchShift = (Math.random() < 0.5 ? -1 : 1) * (1 + Math.floor(Math.random() * 3));
            root.glitching = true;
            glitchOff.restart();
            interval = 4200 + Math.floor(Math.random() * 9000);
        }
    }

    Timer {
        id: glitchOff
        interval: 90
        repeat: false
        onTriggered: {
            root.glitching = false;
            root.glitchShift = 0;
        }
    }

    Timer {
        interval: 520
        repeat: true
        running: true
        onTriggered: root.cursorOn = !root.cursorOn
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.clock = Qt.formatTime(new Date(), "hh:mm:ss")
    }

    // Take the duration from the DMS theme instead of hardcoding it: the wrapper
    // puts its own revealFade on the loader with a length of exactly
    // Theme.mediumDuration and the same OutCubic curve. If the numbers diverge,
    // the two curves multiply and the fade becomes abrupt at the start and
    // sluggish in the tail.
    Behavior on contentOpacity {
        NumberAnimation {
            duration: Theme.mediumDuration
            easing.type: Theme.standardEasing
        }
    }

    /* chassis */
    Rectangle {
        id: frame
        anchors.fill: parent
        color: root.showing ? root.panelColor : "transparent"
        border.width: 1
        border.color: root.showing ? root.frameLine : "transparent"
        radius: 4
        clip: true

        // scanlines
        Item {
            anchors.fill: parent
            opacity: root.showing ? 1 : 0

            Repeater {
                model: Math.ceil(frame.height / 3)

                Rectangle {
                    x: 0
                    y: index * 3
                    width: frame.width
                    height: 1
                    color: "#000000"
                    opacity: 0.14
                }
            }
        }

        Rectangle {
            x: 0
            y: Math.round(frame.height * 0.44)
            width: frame.width
            height: 2
            color: root.accent
            opacity: root.glitching ? 0.18 : 0
        }

        Text {
            id: brand
            anchors {
                top: parent.top
                left: parent.left
                margins: root.pad
            }
            text: "// WIRED"
            color: root.dim
            opacity: 0.85
            font {
                family: root.monoFont
                pixelSize: root.chromePixelSize
                letterSpacing: 1.6
            }
        }

        Text {
            id: layerLabel
            anchors {
                top: parent.top
                right: parent.right
                margins: root.pad
            }
            text: root.current ? (root.current.layer ?? "") : ""
            color: root.dim
            opacity: 0.85
            font {
                family: root.monoFont
                pixelSize: root.chromePixelSize
                letterSpacing: 1.6
            }
        }

        Rectangle {
            id: separator
            anchors {
                top: brand.bottom
                left: parent.left
                right: parent.right
                margins: root.pad
                topMargin: 8
            }
            height: 1
            color: root.frameLine
        }

        Column {
            id: body
            anchors {
                top: separator.bottom
                left: parent.left
                right: parent.right
                margins: root.pad
                topMargin: 12
            }
            spacing: 6
            x: root.glitching ? root.glitchShift : 0
            opacity: root.contentOpacity

            Text {
                width: parent.width
                visible: text.length > 0
                text: root.jpText
                color: root.dim
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                font {
                    family: root.monoFont
                    pixelSize: root.jpPixelSize
                }
            }

            Text {
                width: parent.width
                text: root.visibleText + root.cursorGlyph
                color: root.glitching ? root.glitchInk : root.ink
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                font {
                    family: root.monoFont
                    pixelSize: root.enPixelSize
                }
            }
        }

        Text {
            anchors {
                bottom: parent.bottom
                left: parent.left
                margins: root.pad
                bottomMargin: Math.max(5, root.pad - 3)
            }
            text: root.typing ? "▚ receiving..." : (root.current ? "▚ sync ok" : "▚ standby")
            color: root.dim
            opacity: 0.7
            font {
                family: root.monoFont
                pixelSize: root.chromePixelSize
                letterSpacing: 1.2
            }
        }

        Text {
            anchors {
                bottom: parent.bottom
                right: parent.right
                margins: root.pad
                bottomMargin: Math.max(5, root.pad - 3)
            }
            text: root.clock
            color: root.dim
            opacity: 0.7
            font {
                family: root.monoFont
                pixelSize: root.chromePixelSize
                letterSpacing: 1.2
            }
        }

        // Mouse wheel over the widget changes the font size. It only lives while
        // DMS has not overridden the mask (clickThrough = false), otherwise the
        // event goes through to what is underneath.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheel => {
                const step = wheel.angleDelta.y > 0 ? 1 : -1;
                const next = Math.max(11, Math.min(34, root.basePixelSize + step));
                if (root.pluginService)
                    root.pluginService.savePluginData(root.pluginId, "fontPixelSize", next);
                wheel.accepted = true;
            }
        }
    }
}
