import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../Theme.js" as Theme

Window {
    id: root
    width: 400
    height: 350
    visible: false
    title: qsTr("Alpha Check")
    color: Theme.panel

    // Prevent closing, just hide
    onClosing: (close) => {
        close.accepted = false
        root.hide()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: qsTr("Mark Enclosed Alpha Regions")
            color: Theme.text
            font.pixelSize: Theme.headerFontPixelSize
            font.bold: true
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.panelBorder
        }

        // Cross Color
        RowLayout {
            Text {
                text: qsTr("Cross Color:")
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
                Layout.preferredWidth: 100
            }

            Rectangle {
                width: 30
                height: 30
                color: colorDialog.selectedColor
                border.color: Theme.panelBorder
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    onClicked: colorDialog.open()
                }
            }
            
            Text {
                text: colorDialog.selectedColor.toString()
                color: Theme.text
                font.pixelSize: Theme.smallFontPixelSize
                Layout.fillWidth: true
            }
        }

        // Cross Size
        RowLayout {
            Text {
                text: qsTr("Size:")
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
                Layout.preferredWidth: 100
            }
            Slider {
                id: sizeSlider
                from: 2
                to: 100
                value: 20
                stepSize: 1
                Layout.fillWidth: true
            }
            Text {
                text: sizeSlider.value.toString()
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignRight
            }
        }

        // Thickness
        RowLayout {
            Text {
                text: qsTr("Thickness:")
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
                Layout.preferredWidth: 100
            }
            Slider {
                id: thicknessSlider
                from: 1
                to: 20
                value: 2
                stepSize: 1
                Layout.fillWidth: true
            }
            Text {
                text: thicknessSlider.value.toString()
                color: Theme.text
                font.pixelSize: Theme.fontPixelSize
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignRight
            }
        }

        Item { Layout.fillHeight: true } // Spacer

        // Action Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: qsTr("Apply (Current)")
                Layout.fillWidth: true
                onClicked: {
                    app.applyAlphaCheck(false, colorDialog.selectedColor, sizeSlider.value, thicknessSlider.value)
                    // Don't close, user might want to try other settings
                }
            }

            Button {
                text: qsTr("Apply (All Frames)")
                Layout.fillWidth: true
                onClicked: {
                    app.applyAlphaCheck(true, colorDialog.selectedColor, sizeSlider.value, thicknessSlider.value)
                }
            }
        }
        
        Button {
            text: qsTr("Close")
            Layout.alignment: Qt.AlignRight
            onClicked: root.hide()
        }
    }

    ColorDialog {
        id: colorDialog
        title: qsTr("Select Cross Color")
        selectedColor: "red"
    }
}
