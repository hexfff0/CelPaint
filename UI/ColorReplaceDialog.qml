import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Window {
    id: root
    width: 600
    height: 500
    title: qsTr("Batch Palette (色置換)")
    modality: Qt.NonModal
    flags: Qt.Dialog

    color: "#3c3c3c"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Toolbar
        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            
            Button {
                text: qsTr("Add")
                onClicked: app.colorSwapModel.addSwap("#ffffff", "#0000ff", 0)
            }
            Button {
                text: qsTr("Clear All")
                onClicked: app.colorSwapModel.clear()
            }
            
            Item { Layout.fillWidth: true }
            
            Label {
                text: qsTr("Set All Tolerance:")
                color: "white"
            }
            SpinBox {
                id: toleranceSpinner
                from: 0
                to: 255
                value: 0
                implicitWidth: 80
            }
            Button {
                text: qsTr("Set")
                onClicked: app.colorSwapModel.setAllTolerance(toleranceSpinner.value)
            }
        }

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 30
            color: "#505050"
            radius: 3
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                
                Label { 
                    text: qsTr("On")
                    color: "white"
                    font.bold: true
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignHCenter
                }
                Label { 
                    text: qsTr("Source")
                    color: "white"
                    font.bold: true
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignHCenter
                }
                Label { 
                    text: "→"
                    color: "white"
                    font.bold: true
                    Layout.preferredWidth: 30
                    horizontalAlignment: Text.AlignHCenter
                }
                Label { 
                    text: qsTr("Dest")
                    color: "white"
                    font.bold: true
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignHCenter
                }
                Label { 
                    text: qsTr("Tolerance")
                    color: "white"
                    font.bold: true
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignHCenter
                }
                Item { Layout.fillWidth: true }
            }
        }

        // Color swap list
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: app.colorSwapModel
            spacing: 2
            
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: Rectangle {
                width: listView.width - 20
                height: 40
                color: index % 2 === 0 ? "#454545" : "#404040"
                radius: 3
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10
                    
                    // Enabled Checkbox
                    CheckBox {
                        Layout.preferredWidth: 40
                        checked: model.enabled
                        onToggled: model.enabled = checked
                    }
                    
                    // Source Color (clickable)
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 30
                        color: model.sourceColor
                        border.color: "black"
                        border.width: 1
                        radius: 3
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                colorPicker.targetIndex = index
                                colorPicker.targetRole = "source"
                                colorPicker.setColor(model.sourceColor)
                                colorPicker.show()
                            }
                        }
                    }
                    
                    // Arrow
                    Label {
                        Layout.preferredWidth: 30
                        text: "→"
                        color: "white"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    // Dest Color (clickable)
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 30
                        color: model.destColor
                        border.color: "black"
                        border.width: 1
                        radius: 3
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                colorPicker.targetIndex = index
                                colorPicker.targetRole = "dest"
                                colorPicker.setColor(model.destColor)
                                colorPicker.show()
                            }
                        }
                    }
                    
                    // Tolerance
                    SpinBox {
                        Layout.preferredWidth: 80
                        from: 0
                        to: 255
                        value: model.tolerance
                        onValueModified: model.tolerance = value
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Remove button
                    Button {
                        text: "✕"
                        implicitWidth: 30
                        implicitHeight: 30
                        onClicked: app.colorSwapModel.removeSwap(index)
                    }
                }
            }
            
            // Empty state
            Label {
                anchors.centerIn: parent
                text: qsTr("Click on image to pick colors,\nor click 'Add' to add manually")
                color: "#888888"
                visible: listView.count === 0
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Footer Actions
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: qsTr("Apply (Current Frame)")
                onClicked: app.applyColorReplacement(false)
            }
            
            Button {
                text: qsTr("Apply All (Sequence)")
                highlighted: true
                onClicked: app.applyColorReplacement(true)
            }
        }
    }

    PhotoshopColorPicker {
        id: colorPicker
        property int targetIndex: -1
        property string targetRole: ""
        
        onAccepted: (color) => {
            if (targetIndex >= 0) {
                if (targetRole === "dest") {
                    app.colorSwapModel.setDestColor(targetIndex, color)
                } else if (targetRole === "source") {
                    app.colorSwapModel.setSourceColor(targetIndex, color)
                }
            }
        }
    }
}
