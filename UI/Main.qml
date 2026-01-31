import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Theme.js" as Theme

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: app.currentTitle
    color: Theme.background

    property int refreshCounter: 0

    Connections {
        target: app
        function onRequestImageRefresh() {
            refreshCounter++
        }
    }

    menuBar: Rectangle {
        width: parent.width
        height: 30
        color: Theme.background
        
        Rectangle { width: parent.width; height: 1; color: Theme.panelBorder; anchors.bottom: parent.bottom }

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
                        onTriggered: openFileDialog.open()
                    }
                    MenuItem {
                        text: qsTr("Export")
                        onTriggered: exportFolderDialog.open()
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
                        text: qsTr("Batch Palette (色置換)")
                        onTriggered: colorReplaceDialog.show()
                    }
                }
            }
            
            Item { Layout.fillWidth: true } // Spacer
        }
    }

    // Main Layout - Vertical Split (Canvas Top, Timeline Bottom)
    SplitView {
        anchors.fill: parent
        orientation: Qt.Vertical
        handle: Rectangle {
            implicitWidth: axis === Qt.Vertical ? parent.width : 4
            implicitHeight: axis === Qt.Vertical ? 4 : parent.height
            color: Theme.background
            Rectangle {
                anchors.centerIn: parent
                width: parent.width; height: 1
                color: Theme.panelBorder
            }
        }

        // Canvas Area
        Rectangle {
            SplitView.fillHeight: true
            SplitView.preferredHeight: 500
            color: "#151515" // Dark canvas background for contrast
            clip: true
            
            CanvasView {
                id: canvasView
                anchors.fill: parent
                colorDialogOpen: colorReplaceDialog.visible // Bind to dialog visibility
            }
            
            // Status Overlay (Creative Pro Style: Minimal text in corner)
            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                text: app.statusMessage // Removed Zoom display here as requested (redundant if shown elsewhere, or removing one if multiple exist)
                color: Theme.text
                font.pixelSize: Theme.smallFontPixelSize
                opacity: 0.7
            }
        }

        // Timeline Area
        Rectangle {
            SplitView.preferredHeight: 220
            color: Theme.panel
            
            // Header bar for Timeline
            Rectangle {
                id: timelineHeader
                width: parent.width; height: 26
                color: Theme.background
                
                Rectangle { width: parent.width; height: 1; color: Theme.panelBorder; anchors.bottom: parent.bottom }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    spacing: 15
                    
                    Text { text: "Timeline"; color: Theme.text; font.bold: true; font.pixelSize: Theme.smallFontPixelSize }
                    
                    // Compact playback controls
                    Button {
                        text: "◀"
                        implicitWidth: 30; implicitHeight: 22
                        background: Rectangle { color: "transparent" }
                        contentItem: Text { text: parent.text; color: Theme.text; horizontalAlignment: Text.AlignHCenter }
                        onClicked: if(app.currentIndex > 0) app.currentIndex--
                    }
                    Text { 
                        text: (app.currentIndex + 1) + " / " + app.frameCount 
                        color: Theme.accent
                        font.pixelSize: Theme.smallFontPixelSize 
                    }
                    Button {
                        text: "▶"
                        implicitWidth: 30; implicitHeight: 22
                        background: Rectangle { color: "transparent" }
                        contentItem: Text { text: parent.text; color: Theme.text; horizontalAlignment: Text.AlignHCenter }
                        onClicked: if(app.currentIndex < app.frameCount - 1) app.currentIndex++
                    }
                }
            }

            TimelineView {
                anchors.top: timelineHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
    }

    // Dialogs
    FileDialog {
        id: openFileDialog
        title: qsTr("Open Image Sequence")
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Images (*.png *.bmp *.jpg *.jpeg *.tif *.tiff)", "All files (*)"]
        onAccepted: {
            app.openSequence(selectedFiles)
        }
    }

    FolderDialog {
        id: exportFolderDialog
        title: qsTr("Select Export Directory")
        onAccepted: {
            if (app.saveSequence(selectedFolder)) {
                successDialog.open()
            }
        }
    }

    MessageDialog {
        id: successDialog
        title: qsTr("Success")
        text: qsTr("Sequence exported successfully.")
        buttons: MessageDialog.Ok
    }

    ColorReplaceDialog {
        id: colorReplaceDialog
    }
}
