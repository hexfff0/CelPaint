import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../Theme.js" as Theme

Window {
    id: root
    width: 600
    height: 400
    visible: false
    title: qsTr("Validate Alpha")
    color: Theme.background
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    property color markerColor: "red"

    // Prevent closing, just hide
    onClosing: close => {
        close.accepted = false;
        root.hide();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // Header
        Label {
            text: qsTr("Validate Alpha")
            color: Theme.text
            font.pixelSize: Theme.fontPixelSize
            font.bold: true
        }

        Divider {
            Layout.fillWidth: true
        }

        // Settings Grid
        GridLayout {
            columns: 3
            Layout.fillWidth: true
            rowSpacing: 15
            columnSpacing: 10

            // Row 1: Indicator Color
            Label {
                text: qsTr("Indicator Color:")
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
                Layout.alignment: Qt.AlignVCenter
            }
            Rectangle {
                Layout.preferredWidth: 60
                Layout.preferredHeight: 30
                color: root.markerColor
                border.color: Theme.panelBorder
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorPicker.setColor(root.markerColor);
                        colorPicker.show();
                    }
                }
            }
            Label {
                text: "(" + root.markerColor.toString() + ")"
                color: Theme.textDisabled
                font.pixelSize: Theme.smallFontPixelSize
                Layout.fillWidth: true
            }
        }

        Item {
            Layout.fillHeight: true
        } // Spacer

        Divider {
            Layout.fillWidth: true
        }

        GridLayout {
            columns: 3
            Layout.fillWidth: true
            rowSpacing: 15
            columnSpacing: 10

            // Row 2: Crosshair Size
            Label {
                text: qsTr("Crosshair Size:")
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
            }
            Slider {
                id: sizeSlider
                from: 4
                to: 100
                value: 20
                stepSize: 1
                Layout.fillWidth: true
            }
            Label {
                text: Math.round(sizeSlider.value) + " px"
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
                Layout.preferredWidth: 60
                horizontalAlignment: Text.AlignRight
            }

            // Row 3: Line Stroke
            Label {
                text: qsTr("Line Stroke:")
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
            }
            Slider {
                id: thicknessSlider
                from: 1
                to: 10
                value: 2
                stepSize: 1
                Layout.fillWidth: true
            }
            Label {
                text: Math.round(thicknessSlider.value) + " px"
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
                Layout.preferredWidth: 60
                horizontalAlignment: Text.AlignRight
            }
        }

        Divider {
            Layout.fillWidth: true
        }

        // Action Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            StandardButton {
                text: qsTr("Check Current")
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                onClicked: {
                    app.applyAlphaCheck(false, root.markerColor, sizeSlider.value, thicknessSlider.value);
                }
            }

            StandardButton {
                text: qsTr("Check All")
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                isAccent: true
                onClicked: {
                    app.applyAlphaCheck(true, root.markerColor, sizeSlider.value, thicknessSlider.value);
                }
            }
        }
    }

    ColorPicker {
        id: colorPicker
        title: qsTr("Select Indicator Color")
        onAccepted: color => {
            root.markerColor = color;
        }
    }

    // Helper Components (Standardized)
    component Divider: Rectangle {
        height: 1
        color: Theme.panelBorder
    }

    component StandardButton: Button {
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
            font.bold: isAccent
        }
    }
}
