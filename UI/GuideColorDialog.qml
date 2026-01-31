import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "Theme.js" as Theme

Window {
    id: root
    width: 600
    height: 700
    title: qsTr("Guide Color Check")
    visible: false
    color: Theme.background
    flags: Qt.Dialog

    // Removed properties to match ColorReplaceDialog scope usage


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // Header
        Label {
            text: qsTr("Check Guide Color")
            font.bold: true
            font.pixelSize: Theme.fontPixelSize
            color: Theme.text
        }

        // List Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Label { text: "No."; color: Theme.textDisabled; font.pixelSize: Theme.smallFontPixelSize; Layout.preferredWidth: 30; horizontalAlignment: Text.AlignHCenter }
            Label { text: "Use"; color: Theme.textDisabled; font.pixelSize: Theme.smallFontPixelSize; Layout.preferredWidth: 40; horizontalAlignment: Text.AlignHCenter }
            Label { text: "Source (Detect)"; color: Theme.textDisabled; font.pixelSize: Theme.smallFontPixelSize; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignHCenter }
            Item { width: 10 } // Arrow space
            Label { text: "Selection (Circle)"; color: Theme.textDisabled; font.pixelSize: Theme.smallFontPixelSize; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignHCenter }
            Label { text: "Tolerance"; color: Theme.textDisabled; font.pixelSize: Theme.smallFontPixelSize; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignHCenter }
            Item { Layout.fillWidth: true }
        }

        Divider { Layout.fillWidth: true }

        // Color List
        ListView {
            id: guideList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: app.guideCheckModel
            spacing: 2

            delegate: Rectangle {
                width: ListView.view.width
                height: 36
                color: Theme.panel
                border.color: Theme.panelBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    spacing: 5

                    // No.
                    Label { 
                        text: (index + 1).toString()
                        color: Theme.text
                        font.pixelSize: Theme.smallFontPixelSize
                        Layout.preferredWidth: 30
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Checkbox (Enable)
                    CheckBox {
                        checked: model.enabled
                        Layout.preferredWidth: 40
                        Layout.alignment: Qt.AlignHCenter
                        onToggled: app.guideCheckModel.setEnabled(index, checked)
                        
                        indicator: Rectangle {
                            implicitWidth: 16
                            implicitHeight: 16
                            x: (parent.width - width) / 2
                            y: (parent.height - height) / 2
                            radius: 2
                            color: parent.checked ? Theme.accent : Theme.inputBackground
                            border.color: Theme.panelBorder
                            
                            Text {
                                anchors.centerIn: parent
                                text: "✔"
                                font.pixelSize: 12
                                color: "white"
                                visible: parent.parent.checked
                            }
                        }
                    }

                    // Source Color
                    Rectangle {
                        Layout.preferredWidth: 90; Layout.fillHeight: true
                        Layout.margins: 4
                        color: model.sourceColor
                        border.color: Theme.panelBorder
                        border.width: 1
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                colorPicker.targetIndex = index
                                colorPicker.targetRole = "source"
                                colorPicker.setColor(model.sourceColor)
                                colorPicker.show()
                            }
                        }
                        
                        Text {
                             anchors.centerIn: parent
                             text: model.sourceColor.toString()
                             visible: false // Hidden, mostly for debug
                        }
                    }

                    // Arrow
                    Label { text: "→"; color: Theme.textDisabled; Layout.alignment: Qt.AlignHCenter }

                    // Selection Color
                    Rectangle {
                        Layout.preferredWidth: 90; Layout.fillHeight: true
                        Layout.margins: 4
                        color: model.selectionColor
                        border.color: Theme.panelBorder
                        border.width: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                colorPicker.targetIndex = index
                                colorPicker.targetRole = "selection"
                                colorPicker.setColor(model.selectionColor)
                                colorPicker.show()
                            }
                        }
                    }
                    
                    // Tolerance Input
                    SpinBox {
                        id: toleranceSpinBox
                        from: 0; to: 255
                        value: model.tolerance
                        editable: true
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 30
                        
                        onValueModified: {
                            if (linkToleranceBtn.checked) {
                                app.guideCheckModel.setAllTolerances(value)
                            } else {
                                app.guideCheckModel.setTolerance(index, value)
                            }
                        }
                        
                        contentItem: TextInput {
                            text: toleranceSpinBox.textFromValue(toleranceSpinBox.value, toleranceSpinBox.locale)
                            font.pixelSize: Theme.smallFontPixelSize
                            color: Theme.text
                            selectionColor: Theme.selection
                            selectedTextColor: "white"
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            readOnly: !parent.editable
                            validator: parent.validator
                            inputMethodHints: Qt.ImhDigitsOnly
                        }
                        background: Rectangle {
                            color: Theme.inputBackground
                            border.color: parent.activeFocus ? Theme.accent : Theme.inputBorder
                        }
                    }

                    Item { Layout.fillWidth: true } // Spacer

                    // Remove Button
                    Button {
                        text: "×"
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 25
                        background: Rectangle {
                            color: parent.down ? Theme.buttonPressed : (parent.hovered ? Theme.buttonHover : "transparent")
                            radius: 2
                        }
                        contentItem: Text {
                            text: parent.text; color: Theme.text; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: app.guideCheckModel.removeCheck(index)
                    }
                }
            }
        }

        Divider { Layout.fillWidth: true }

        // Link Tolerance Toggle
        RowLayout {
            Layout.fillWidth: true
            
            Button {
                id: linkToleranceBtn
                checkable: true
                checked: true // Default to linked
                text: checked ? qsTr("🔗 Link Tolerance (ON)") : qsTr("🔗 Link Tolerance (OFF)")
                
                background: Rectangle {
                    color: parent.checked ? Theme.selection : "transparent"
                    border.color: Theme.panelBorder
                    radius: 2
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.checked ? "white" : Theme.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.smallFontPixelSize
                }
            }
            
            Item { Layout.fillWidth: true }
        }

        Divider { Layout.fillWidth: true }

        // Parameters (Global)
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            rowSpacing: 10
            columnSpacing: 10

            Text { text: "Circle Radius:"; color: Theme.text }
            RowLayout {
                Slider {
                    id: radSlider
                    from: 5; to: 100
                    value: 20
                    Layout.fillWidth: true
                }
                Text { text: Math.round(radSlider.value) + "px"; color: Theme.text; Layout.preferredWidth: 40 }
            }

            Text { text: "Line Thickness:"; color: Theme.text }
            RowLayout {
                Slider {
                    id: thickSlider
                    from: 1; to: 10
                    value: 3
                    Layout.fillWidth: true
                }
                Text { text: Math.round(thickSlider.value) + "px"; color: Theme.text; Layout.preferredWidth: 40 }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            StandardButton {
                text: qsTr("+ Add New Pair")
                Layout.fillWidth: true
                onClicked: app.guideCheckModel.addCheck(Qt.rgba(1,0,0,1), Qt.rgba(1,1,0,1), 0)
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            StandardButton {
                text: qsTr("Apply (Current)")
                Layout.fillWidth: true
                onClicked: {
                    app.applyGuideCheck(false, Math.round(radSlider.value), Math.round(thickSlider.value))
                }
            }
            StandardButton {
                text: qsTr("Apply (All Frames)")
                Layout.fillWidth: true
                isAccent: true
                onClicked: {
                    app.applyGuideCheck(true, Math.round(radSlider.value), Math.round(thickSlider.value))
                }
            }
        }
    }

    PhotoshopColorPicker {
        id: colorPicker
        onAccepted: (color) => {
            if (targetIndex >= 0) {
                if (targetRole === "source") app.guideCheckModel.setSourceColor(targetIndex, color)
                else if (targetRole === "selection") app.guideCheckModel.setSelectionColor(targetIndex, color)
            }
        }
    }

    // Helper Components
    component Divider : Rectangle {
        height: 1
        color: Theme.panelBorder
    }

    component StandardButton : Button {
        property bool isAccent: false
        background: Rectangle {
            color: parent.down ? Theme.buttonPressed : (parent.hovered ? Theme.buttonHover : (isAccent ? Theme.accent : Theme.buttonNormal))
            radius: 2
            border.color: Theme.panelBorder
        }
        contentItem: Text {
            text: parent.text
            color: isAccent ? "white" : Theme.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontPixelSize
        }
    }
}
