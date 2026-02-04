import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Theme.js" as Theme

Rectangle {
    width: parent.width
    height: 28
    color: Theme.background

    signal openSequenceTriggered
    signal exportTriggered
    signal batchPaletteTriggered

    signal checkGuideColorTriggered
    signal alphaCheckTriggered

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.panelBorder
        anchors.bottom: parent.bottom
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // File Menu Button
        Button {
            text: qsTr("File")
            Layout.preferredWidth: 50
            Layout.fillHeight: true
            background: Rectangle {
                color: parent.down || fileMenu.visible ? Theme.selection : (parent.hovered ? Theme.buttonHover : "transparent")
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: Theme.fontPixelSize
                color: Theme.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: fileMenu.open()

            Menu {
                id: fileMenu
                y: parent.height

                background: Rectangle {
                    implicitWidth: 200
                    color: Theme.panel
                    border.color: Theme.panelBorder
                    radius: 0
                }
                delegate: MenuItem {
                    id: menuItem
                    implicitWidth: 200
                    implicitHeight: 30
                    contentItem: Text {
                        text: menuItem.text
                        font: menuItem.font
                        color: menuItem.highlighted ? "white" : Theme.text
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: menuItem.highlighted ? Theme.accent : "transparent"
                    }
                }

                MenuItem {
                    text: qsTr("Open Sequence...")
                    onTriggered: openSequenceTriggered()
                }
                MenuItem {
                    text: qsTr("Export")
                    onTriggered: exportTriggered()
                }
                MenuSeparator {
                    contentItem: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 1
                        color: Theme.panelBorder
                    }
                }
                MenuItem {
                    text: qsTr("Exit")
                    onTriggered: Qt.quit()
                }
            }
        }

        // Tools Menu
        Button {
            text: qsTr("Tools")
            Layout.preferredWidth: 60
            Layout.fillHeight: true
            background: Rectangle {
                color: parent.down || toolsMenu.visible ? Theme.selection : (parent.hovered ? Theme.buttonHover : "transparent")
            }
            contentItem: Text {
                text: parent.text
                font.pixelSize: Theme.fontPixelSize
                color: Theme.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: toolsMenu.open()

            Menu {
                id: toolsMenu
                y: parent.height

                background: Rectangle {
                    implicitWidth: 200
                    color: Theme.panel
                    border.color: Theme.panelBorder
                    radius: 0
                }
                delegate: MenuItem {
                    id: toolItem
                    implicitWidth: 200
                    implicitHeight: 30
                    contentItem: Text {
                        text: toolItem.text
                        font: toolItem.font
                        color: toolItem.highlighted ? "white" : Theme.text
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: toolItem.highlighted ? Theme.accent : "transparent"
                    }
                }

                MenuItem {
                    text: qsTr("Remap Colors")
                    onTriggered: batchPaletteTriggered()
                }
                MenuItem {
                    text: qsTr("Validate Guides")
                    onTriggered: checkGuideColorTriggered()
                }
                MenuItem {
                    text: qsTr("Validate Alpha")
                    onTriggered: alphaCheckTriggered()
                }
            }
        }

        Item {
            Layout.fillWidth: true
        } // Spacer
    }
}
