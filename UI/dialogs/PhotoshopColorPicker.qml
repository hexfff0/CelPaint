import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    width: 720
    height: 520
    title: qsTr("Color Picker — Plasma")
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    color: "#2a2e32" // Dark Plasma-like background

    property color selectedColor: "#ffd806"
    property color initialColor: "white"
    
    // Compatibility properties for ColorReplaceDialog
    property int targetIndex: -1
    property string targetRole: ""
    
    signal accepted(color color)
    signal rejected()

    // Internal HSV state
    property real h: 0.14 // approx yellow
    property real s: 1.0
    property real v: 1.0
    
    property bool updating: false

    function setColor(c) {
        updating = true
        initialColor = c
        selectedColor = c
        updateInternalHSV(c)
        updating = false
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
                case r: hue = (g - b) / d + (g < b ? 6 : 0); break;
                case g: hue = (b - r) / d + 2; break;
                case b: hue = (r - g) / d + 4; break;
            }
            hue /= 6;
        }
        
        root.h = hue;
        root.s = sat;
        root.v = val;
    }
    
    function updateColorFromHSV() {
        if (updating) return
        updating = true
        selectedColor = Qt.hsva(root.h, root.s, root.v, 1.0)
        updating = false
    }

    // Basic palette
    property var basicColors: [
        "#000000", "#ff0000", "#00ff00", "#0000ff", "#ffff00", "#00ffff", "#ff00ff", "#ffffff",
        "#808080", "#800000", "#008000", "#000080", "#800000", "#008080", "#800080", "#c0c0c0",
        "#404040", "#ff4040", "#40ff40", "#4040ff", "#ffff40", "#40ffff", "#ff40ff", "#e0e0e0",
        "#202020", "#c00000", "#00c000", "#0000c0", "#c0c000", "#00c0c0", "#c000c0", "#f0f0f0"
    ]

    // Main Layout
    GridLayout {
        anchors.fill: parent
        anchors.margins: 20
        columns: 2
        columnSpacing: 20
        rowSpacing: 20

        // LEFT COLUMN: Palettes
        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 280
            spacing: 20

            // 1. Basic Colors
            ColumnLayout {
                spacing: 5
                Label { text: qsTr("Basic colors"); color: "#fcfcfc"; font.bold: true }
                
                GridLayout {
                    columns: 8
                    rowSpacing: 4
                    columnSpacing: 4
                    
                    Repeater {
                        model: basicColors
                        Rectangle {
                            width: 25; height: 25
                            color: modelData
                            radius: 2
                            border.color: (root.selectedColor === modelData) ? "white" : "transparent"
                            border.width: 2
                            MouseArea {
                                anchors.fill: parent
                                onClicked: setColor(modelData)
                            }
                        }
                    }
                }
            }
            
            // 2. Screen Picker Button
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                text: qsTr("Pick Screen Color")
                icon.name: "color-picker"
                
                background: Rectangle {
                    color: parent.down ? "#4c5e70" : "#31363b"
                    border.color: "#5d6a75"
                    radius: 3
                }
                contentItem: RowLayout {
                    anchors.centerIn: parent
                    Label { text: parent.parent.text; color: "white" }
                }
                
                onPressed: {
                    screenPickerOverlay.visible = true
                }
            }

            // Spacer
            Item { Layout.fillHeight: true }

            // 3. Custom Colors
            ColumnLayout {
                spacing: 5
                Label { text: qsTr("Custom colors"); color: "#fcfcfc"; font.bold: true }
                
                GridLayout {
                    columns: 8
                    rowSpacing: 4
                    columnSpacing: 4
                    
                    Repeater {
                        model: 16 // placeholder for empty slots
                        Rectangle {
                            width: 25; height: 25
                            // Visible color style
                            visible: true 
                            opacity: 1.0
                            color: (index < app.customColors.length) ? app.customColors[index] : "transparent"
                            
                            radius: 2
                            border.color: (index < app.customColors.length && root.selectedColor == app.customColors[index]) ? "white" : "transparent"
                            border.width: (index < app.customColors.length) ? 2 : 0
                            
                            MouseArea {
                                anchors.fill: parent
                                enabled: index < app.customColors.length
                                onClicked: setColor(app.customColors[index])
                            }
                        }
                    }
                }
                
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 35
                    text: qsTr("Add to Custom Colors")
                    background: Rectangle {
                        color: parent.down ? "#4c5e70" : "#31363b"
                        border.color: "#5d6a75"
                        radius: 3
                    }
                    contentItem: Label {
                        text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: app.addCustomColor(root.selectedColor)
                }
            }
        }

        // RIGHT COLUMN: Color Map & Inputs
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 20

            // 1. Color Map + Slider
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                spacing: 15
                
                Rectangle {
                    id: hsBox
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    border.color: "#555"
                    border.width: 1
                    clip: true
                    
                    // Hue Gradient (Horizontal)
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.00; color: "#FF0000" }
                            GradientStop { position: 0.17; color: "#FFFF00" }
                            GradientStop { position: 0.33; color: "#00FF00" }
                            GradientStop { position: 0.50; color: "#00FFFF" }
                            GradientStop { position: 0.67; color: "#0000FF" }
                            GradientStop { position: 0.83; color: "#FF00FF" }
                            GradientStop { position: 1.00; color: "#FF0000" }
                        }
                    }
                    
                    // Saturation Gradient (Vertical: Top=Transparent, Bottom=White)
                    // This creates S=1 at top, S=0 at bottom (white)
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "#00FFFFFF" } 
                            GradientStop { position: 1.0; color: "#FFFFFFFF" } 
                        }
                    }
                    
                    // Crosshair
                    Item {
                        x: root.h * parent.width - 5
                        y: (1 - root.s) * parent.height - 5
                        width: 10; height: 10
                        
                        Rectangle { width: 10; height: 1; color: "black"; anchors.centerIn: parent }
                        Rectangle { width: 1; height: 10; color: "black"; anchors.centerIn: parent }
                    }

                    MouseArea {
                        anchors.fill: parent
                        function handle(mouse) {
                             root.h = Math.max(0, Math.min(1, mouse.x / width))
                             root.s = Math.max(0, Math.min(1, 1 - mouse.y / height))
                             updateColorFromHSV()
                        }
                        onPressed: handle(mouse)
                        onPositionChanged: handle(mouse)
                    }
                }

                // Value Slider (Vertical)
                Rectangle {
                    Layout.preferredWidth: 25
                    Layout.fillHeight: true
                    border.color: "#555"
                    border.width: 1
                    
                    // Gradient: Current Hue/Sat at V=1 down to Black (V=0)
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            // Top: Color at V=1
                            GradientStop { 
                                position: 0.0
                                color: Qt.hsva(root.h, root.s, 1.0, 1.0)
                            }
                            // Bottom: Black
                            GradientStop { position: 1.0; color: "black" }
                        }
                    }
                    
                    // Handle arrows
                    Item {
                        width: parent.width
                        height: 10
                        y: (1 - root.v) * parent.height - 5
                        
                        // Left arrow
                        Canvas {
                            width: 6; height: 10; anchors.left: parent.left
                            onPaint: {
                                var ctx = getContext("2d"); ctx.fillStyle="white";
                                ctx.moveTo(0,0); ctx.lineTo(6,5); ctx.lineTo(0,10); ctx.fill();
                            }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        function handle(mouse) {
                             root.v = Math.max(0, Math.min(1, 1 - mouse.y / height))
                             updateColorFromHSV()
                        }
                        onPressed: handle(mouse)
                        onPositionChanged: handle(mouse)
                    }
                }
            }
            
            // 2. Preview & Inputs
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                // Color Preview
                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.fillHeight: true
                    color: root.selectedColor
                    border.color: "#555"
                }
                
                // Inputs Grid
                GridLayout {
                    columns: 4
                    rowSpacing: 10
                    columnSpacing: 10
                    
                    // Helper
                    component SpinInput : SpinBox {
                        editable: true
                        from: 0; to: 255
                        implicitWidth: 100
                        background: Rectangle {
                            color: "#31363b"
                            border.color: parent.activeFocus ? "#3daee9" : "#5d6a75"
                        }
                        contentItem: TextInput {
                            text: parent.textFromValue(parent.value, parent.locale)
                            color: "white"
                            horizontalAlignment: Qt.AlignRight
                            verticalAlignment: Qt.AlignVCenter
                        }
                        up.indicator: Item{}
                        down.indicator: Item{}
                    }
                    
                    Label { text: "Hue:"; color: "white"; Layout.alignment: Qt.AlignRight }
                    SpinInput { 
                        to: 360; value: Math.round(root.h * 360) 
                        onValueModified: { root.h = value/360.0; updateColorFromHSV() }
                    }

                    Label { text: "Red:"; color: "white"; Layout.alignment: Qt.AlignRight }
                    SpinInput { 
                        value: Math.round(root.selectedColor.r * 255)
                        onValueModified: { var c = root.selectedColor; setColor(Qt.rgba(value/255, c.g, c.b, 1)) }
                    }

                    Label { text: "Sat:"; color: "white"; Layout.alignment: Qt.AlignRight }
                    SpinInput { 
                        value: Math.round(root.s * 255) 
                        onValueModified: { root.s = value/255.0; updateColorFromHSV() }
                    }

                    Label { text: "Green:"; color: "white"; Layout.alignment: Qt.AlignRight }
                    SpinInput { 
                        value: Math.round(root.selectedColor.g * 255)
                        onValueModified: { var c = root.selectedColor; setColor(Qt.rgba(c.r, value/255, c.b, 1)) }
                    }

                    Label { text: "Val:"; color: "white"; Layout.alignment: Qt.AlignRight }
                    SpinInput { 
                        value: Math.round(root.v * 255)
                        onValueModified: { root.v = value/255.0; updateColorFromHSV() }
                    }

                    Label { text: "Blue:"; color: "white"; Layout.alignment: Qt.AlignRight }
                    SpinInput { 
                        value: Math.round(root.selectedColor.b * 255)
                        onValueModified: { var c = root.selectedColor; setColor(Qt.rgba(c.r, c.g, value/255, 1)) }
                    }
                }
            }
            
            // HTML HEX Input
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label { text: "HTML:"; color: "white" }
                TextField {
                    text: root.selectedColor.toString()
                    implicitWidth: 120
                    color: "white"
                    background: Rectangle {
                        color: "#31363b"
                        border.color: parent.activeFocus ? "#3daee9" : "#5d6a75"
                    }
                    onEditingFinished: setColor(text)
                }
            }
            
            Item { Layout.fillHeight: true }

            // OK/Cancel Buttons
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10
                
                Button {
                    text: qsTr("OK")
                    icon.name: "dialog-ok"
                    background: Rectangle {
                        color: parent.down ? "#4c5e70" : "#31363b"
                        border.color: "#5d6a75"
                        radius: 3
                    }
                    contentItem: RowLayout {
                        anchors.centerIn: parent
                        Label { text: "✓"; color: "white" }
                        Label { text: parent.parent.text; color: "white" }
                    }
                    onClicked: { root.accepted(root.selectedColor); root.close() }
                }
                
                Button {
                    text: qsTr("Cancel")
                    icon.name: "dialog-cancel"
                    background: Rectangle {
                        color: parent.down ? "#4c5e70" : "#31363b"
                        border.color: "#5d6a75"
                        radius: 3
                    }
                    contentItem: RowLayout {
                        anchors.centerIn: parent
                        Label { text: "⊘"; color: "white" }
                        Label { text: parent.parent.text; color: "white" }
                    }
                    onClicked: { root.rejected(); root.close() }
                }
            }
        }
    }
    
    // Screen Picker Overlay
    Window {
        id: screenPickerOverlay
        x: 0; y: 0
        width: Screen.width
        height: Screen.height
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WA_TranslucentBackground
        color: "transparent"
        visible: false
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.CrossCursor
            onClicked: {
                var c = app.pickScreenColor(mouse.x, mouse.y)
                root.setColor(c)
                screenPickerOverlay.visible = false
            }
        }
        Shortcut {
            sequence: "Esc"
            onActivated: screenPickerOverlay.visible = false
        }
    }
}
