import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../Theme.js" as Theme

Window {
    id: root
    width: 720
    height: 480
    title: qsTr("Color Picker")
    // Remove icon from window decoration
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    modality: Qt.ApplicationModal
    color: Theme.background

    property color selectedColor: "#ff0000"
    property color initialColor: "white"

    // Compatibility properties for ColorReplaceDialog
    property int targetIndex: -1
    property string targetRole: ""

    signal accepted(color color)
    signal rejected

    // Internal HSV state
    property real h: 0.0
    property real s: 1.0
    property real v: 1.0

    property bool updating: false

    function setColor(c) {
        if (updating)
            return;
        updating = true;
        initialColor = c; // Set initial only when opened/reset externally, or maybe just once?
        // Usually setColor is called to initialize.

        // If we want to preserve initialColor when user plays around, we shouldn't overwrite it here if it's already set?
        // But setColor is used for initialization. Let's assume invalid initialColor means we set it.
        // Actually, normally the caller sets this.
        // Let's rely on the caller setting initialColor property if they want.
        // But wait, the previous implementation set initialColor = c in setColor.
        // Let's keep that behavior for now, assuming setColor is called on open.
        // To make "Old" color work, we need to ensure initialColor isn't updated during dragging.

        selectedColor = c;
        updateInternalHSV(c);
        updating = false;
    }

    // Helper to update selectedColor without touching initialColor
    function updateSelectedColor(c) {
        if (updating)
            return;
        updating = true;
        selectedColor = c;
        updateInternalHSV(c);
        updating = false;
    }

    function updateInternalHSV(c) {
        let r = c.r, g = c.g, b = c.b;
        let max = Math.max(r, g, b), min = Math.min(r, g, b);
        let d = max - min;

        let hue = 0;
        let sat = (max === 0 ? 0 : d / max);
        let val = max;

        if (max !== min) {
            switch (max) {
            case r:
                hue = (g - b) / d + (g < b ? 6 : 0);
                break;
            case g:
                hue = (b - r) / d + 2;
                break;
            case b:
                hue = (r - g) / d + 4;
                break;
            }
            hue /= 6;
        }

        root.h = hue;
        root.s = sat;
        root.v = val;
    }

    function updateColorFromHSV() {
        if (updating)
            return;
        updating = true;
        selectedColor = Qt.hsva(root.h, root.s, root.v, 1.0);
        updating = false;
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // 1. Color Box (Saturation / Value)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 250 // Prevent squeeze
            border.color: Theme.panelBorder
            border.width: 1
            clip: true

            // Base: Current Hue
            Rectangle {
                anchors.fill: parent
                color: Qt.hsva(root.h, 1.0, 1.0, 1.0)
            }

            // Layer 1: Saturation (White to Transparent)
            // Left (S=0) -> Right (S=1) [Assuming standard Photoshop box where X is Saturation]
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop {
                        position: 0.0
                        color: "#FFFFFFFF"
                    } // White
                    GradientStop {
                        position: 1.0
                        color: "#00FFFFFF"
                    } // Transparent
                }
            }

            // Layer 2: Brightness/Value (Transparent to Black)
            // Top (V=1) -> Bottom (V=0)
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop {
                        position: 0.0
                        color: "#00000000"
                    } // Transparent
                    GradientStop {
                        position: 1.0
                        color: "#FF000000"
                    } // Black
                }
            }

            // Selection Circle
            Rectangle {
                x: root.s * parent.width - width / 2
                y: (1.0 - root.v) * parent.height - height / 2
                width: 12
                height: 12
                radius: 6
                color: "transparent"
                border.color: (root.v < 0.5) ? "white" : "black" // Contrast
                border.width: 2
            }

            MouseArea {
                anchors.fill: parent
                function handle(mouse) {
                    root.s = Math.max(0, Math.min(1, mouse.x / width));
                    root.v = Math.max(0, Math.min(1, 1 - mouse.y / height));
                    updateColorFromHSV();
                }
                onPressed: handle(mouse)
                onPositionChanged: handle(mouse)
            }
        }

        // 2. Hue Slider (Vertical)
        Rectangle {
            Layout.preferredWidth: 35
            Layout.fillHeight: true
            border.color: Theme.panelBorder
            border.width: 1

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop {
                        position: 0.00
                        color: "#FF0000"
                    }
                    GradientStop {
                        position: 0.17
                        color: "#FF00FF"
                    }
                    GradientStop {
                        position: 0.33
                        color: "#0000FF"
                    }
                    GradientStop {
                        position: 0.50
                        color: "#00FFFF"
                    }
                    GradientStop {
                        position: 0.67
                        color: "#00FF00"
                    }
                    GradientStop {
                        position: 0.83
                        color: "#FFFF00"
                    }
                    GradientStop {
                        position: 1.00
                        color: "#FF0000"
                    }
                }
            }

            // Handle (Arrows)
            Item {
                width: parent.width
                height: 10
                y: (1.0 - root.h) * parent.height - 5 // Invert H for standard color wheel (Red at bottom/top)?
                // Standard Qt gradient usually has Red at 0. Let's stick to gradient stops.
                // Wait, if 0 is Red (top) and 1 is Red (bottom).

                // Left Arrow
                Canvas {
                    anchors.left: parent.left
                    width: 5
                    height: 10
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.fillStyle = "white";
                        ctx.moveTo(0, 0);
                        ctx.lineTo(5, 5);
                        ctx.lineTo(0, 10);
                        ctx.fill();
                    }
                }
                // Right Arrow
                Canvas {
                    anchors.right: parent.right
                    width: 5
                    height: 10
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.fillStyle = "white";
                        ctx.moveTo(5, 0);
                        ctx.lineTo(0, 5);
                        ctx.lineTo(5, 10);
                        ctx.fill();
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                function handle(mouse) {
                    // Standard rainbow usually 0 at top?
                    // Let's map Y to Hue.
                    // If bottom is 1.0.
                    var val = Math.max(0, Math.min(1, mouse.y / height));
                    root.h = 1.0 - val; // Invert to match standard sliders usually
                    updateColorFromHSV();
                }
                onPressed: handle(mouse)
                onPositionChanged: handle(mouse)
            }
        }

        // 3. Right Panel (Controls)
        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 230
            Layout.maximumWidth: 230 // Strict constraint
            spacing: 12

            // Preview (New / Old)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: root.selectedColor
                    border.color: Theme.panelBorder
                    border.width: 1
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: root.initialColor
                    border.color: Theme.panelBorder
                    border.width: 1

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setColor(root.initialColor)
                    }
                }
            }

            // Eyedropper & Spacer
            RowLayout {
                Layout.fillWidth: true
                Item {
                    Layout.fillWidth: true
                }
                Button {
                    icon.source: "../icon/Eye-Dropper--Streamline-Font-Awesome.svg"
                    icon.color: Theme.text
                    implicitWidth: 30
                    implicitHeight: 30
                    background: Rectangle {
                        color: "transparent"
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Pick from Screen")
                    onClicked: screenPickerOverlay.visible = true
                }
            }

            // Inputs Grid (HSB / RGB)
            GridLayout {
                Layout.fillWidth: true
                columns: 4
                rowSpacing: 8
                columnSpacing: 6

                // HSL
                RadioButton {
                    checked: true
                    text: "H"
                    checkable: false
                    Layout.preferredHeight: 20
                }
                ValueInput {
                    to: 360
                    value: Math.round(root.h * 360)
                    onValueModified: {
                        root.h = value / 360.0;
                        updateColorFromHSV();
                    }
                }
                Label {
                    text: "°"
                    color: Theme.text
                }
                Item {
                    Layout.fillWidth: true
                }

                RadioButton {
                    checked: false
                    text: "S"
                    checkable: false
                    Layout.preferredHeight: 20
                }
                ValueInput {
                    to: 100
                    value: Math.round(root.s * 100)
                    onValueModified: {
                        root.s = value / 100.0;
                        updateColorFromHSV();
                    }
                }
                Label {
                    text: "%"
                    color: Theme.text
                }
                Item {
                    Layout.fillWidth: true
                }

                RadioButton {
                    checked: false
                    text: "L"
                    checkable: false
                    Layout.preferredHeight: 20
                }
                ValueInput {
                    to: 100
                    value: Math.round(root.v * 100)
                    onValueModified: {
                        root.v = value / 100.0;
                        updateColorFromHSV();
                    }
                }
                Label {
                    text: "%"
                    color: Theme.text
                }
                Item {
                    Layout.fillWidth: true
                }

                // RGB
                RadioButton {
                    checked: false
                    text: "R"
                    checkable: false
                    Layout.preferredHeight: 20
                }
                ValueInput {
                    to: 255
                    value: Math.round(root.selectedColor.r * 255)
                    onValueModified: {
                        var c = root.selectedColor;
                        updateSelectedColor(Qt.rgba(value / 255, c.g, c.b, 1));
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                }

                RadioButton {
                    checked: false
                    text: "G"
                    checkable: false
                    Layout.preferredHeight: 20
                }
                ValueInput {
                    to: 255
                    value: Math.round(root.selectedColor.g * 255)
                    onValueModified: {
                        var c = root.selectedColor;
                        updateSelectedColor(Qt.rgba(c.r, value / 255, c.b, 1));
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                }

                RadioButton {
                    checked: false
                    text: "B"
                    checkable: false
                    Layout.preferredHeight: 20
                }
                ValueInput {
                    to: 255
                    value: Math.round(root.selectedColor.b * 255)
                    onValueModified: {
                        var c = root.selectedColor;
                        updateSelectedColor(Qt.rgba(c.r, c.g, value / 255, 1));
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                }

                // Hex
                Label {
                    text: "#"
                    color: Theme.text
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    text: root.selectedColor.toString()
                    implicitWidth: 80
                    implicitHeight: 26
                    color: Theme.text
                    font.pixelSize: Theme.fontPixelSize
                    Layout.columnSpan: 3
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: Theme.inputBackground
                        border.color: parent.activeFocus ? Theme.accent : Theme.inputBorder
                    }
                    onEditingFinished: updateSelectedColor(text)
                }
            }

            Item {
                Layout.fillHeight: true
            } // Spacer

            // Buttons
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10

                Button {
                    text: qsTr("OK")
                    Layout.preferredWidth: 80
                    background: Rectangle {
                        color: parent.down ? Theme.buttonPressed : (parent.hovered ? Theme.buttonHover : Theme.buttonNormal)
                        border.color: Theme.panelBorder
                        radius: 3
                    }
                    contentItem: Text {
                        text: parent.text
                        color: Theme.text
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        root.accepted(root.selectedColor);
                        root.close();
                    }
                }

                Button {
                    text: qsTr("Cancel")
                    Layout.preferredWidth: 80
                    background: Rectangle {
                        color: parent.down ? Theme.buttonPressed : (parent.hovered ? Theme.buttonHover : Theme.buttonNormal)
                        border.color: Theme.panelBorder
                        radius: 3
                    }
                    contentItem: Text {
                        text: parent.text
                        color: Theme.text
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        root.rejected();
                        root.close();
                    }
                }
            }
        }
    }

    component ValueInput: SpinBox {
        editable: true
        from: 0
        to: 255
        implicitWidth: 70
        implicitHeight: 26
        // Removed Layout.fillWidth: true for compact look

        background: Rectangle {
            color: Theme.inputBackground
            border.color: parent.activeFocus ? Theme.accent : Theme.inputBorder
        }
        contentItem: TextInput {
            text: parent.textFromValue(parent.value, parent.locale)
            color: Theme.text
            horizontalAlignment: Qt.AlignRight
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: Theme.fontPixelSize
            inputMethodHints: Qt.ImhDigitsOnly
            selectByMouse: true
        }
        up.indicator: Item {}
        down.indicator: Item {}
    }

    component InputLabel: Label {
        color: Theme.text
        font.pixelSize: Theme.fontPixelSize
    }

    // Eyedropper Overlay
    Window {
        id: screenPickerOverlay
        // ... as before ...
        x: 0
        y: 0
        width: Screen.width
        height: Screen.height
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WA_TranslucentBackground
        color: "transparent"
        visible: false

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.CrossCursor
            onClicked: {
                var c = app.pickScreenColor(mouse.x, mouse.y);
                root.updateSelectedColor(c);
                screenPickerOverlay.visible = false;
            }
        }
        Shortcut {
            sequence: "Esc"
            onActivated: screenPickerOverlay.visible = false
        }
    }
}
