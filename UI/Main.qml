import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Theme.js" as Theme
import "components"
import "views"
import "dialogs"

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: app.currentTitle
    color: Theme.background

    // Ensure application quits when window closes
    onClosing: Qt.quit()

    property int refreshCounter: 0

    Connections {
        target: app
        function onRequestImageRefresh() {
            refreshCounter++
        }
    }

    menuBar: AppMenuBar {
        onOpenSequenceTriggered: openFileDialog.open()
        onExportTriggered: exportFolderDialog.open()
        onBatchPaletteTriggered: colorReplaceDialog.show()

        onCheckGuideColorTriggered: guideColorDialog.show()
        onAlphaCheckTriggered: alphaCheckDialog.show()
    }

    // Main Layout - Vertical Split (Canvas Top, Timeline Bottom)
    SplitView {
        id: mainSplit
        anchors.fill: parent
        orientation: Qt.Vertical
        handle: Rectangle {
            implicitWidth: mainSplit.orientation === Qt.Vertical ? parent.width : 4
            implicitHeight: mainSplit.orientation === Qt.Vertical ? 4 : parent.height

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
            // Status & Zoom Overlay
            RowLayout {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                spacing: 20

                Label {
                    text: app.statusMessage
                    color: Theme.text
                    font.pixelSize: Theme.smallFontPixelSize
                    opacity: 0.7
                }

                Button {
                    id: zoomBtn
                    text: "Zoom: " + Math.round(canvasView.zoomFactor * 100) + "%"
                    font.pixelSize: Theme.smallFontPixelSize
                    flat: true
                    
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.hovered ? Theme.accent : Theme.text
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: "transparent"
                    }

                    onClicked: zoomMenu.open()

                    Menu {
                        id: zoomMenu
                        y: -height
                        
                        background: Rectangle {
                            implicitWidth: 150
                            color: Theme.panel
                            border.color: Theme.panelBorder
                        }

                        MenuItem {
                            text: qsTr("Fit to Screen")
                            onTriggered: canvasView.fitToScreen()
                            palette.text: Theme.text
                            palette.highlightedText: "white"
                        }
                        MenuSeparator {
                            contentItem: Rectangle { 
                                implicitWidth: 150; implicitHeight: 1; color: Theme.panelBorder 
                            }
                        }
                        MenuItem { 
                            text: "200%"
                            onTriggered: canvasView.zoomFactor = 2.0 
                            palette.text: Theme.text
                            palette.highlightedText: "white"
                        }
                        MenuItem { 
                            text: "100%"
                            onTriggered: canvasView.zoomFactor = 1.0 
                            palette.text: Theme.text
                            palette.highlightedText: "white"
                        }
                        MenuItem { 
                            text: "50%"
                            onTriggered: canvasView.zoomFactor = 0.5 
                            palette.text: Theme.text
                            palette.highlightedText: "white"
                        }
                        MenuItem { 
                            text: "25%"
                            onTriggered: canvasView.zoomFactor = 0.25 
                            palette.text: Theme.text
                            palette.highlightedText: "white"
                        }

                        delegate: MenuItem {
                            id: menuItem
                            implicitWidth: 150
                            implicitHeight: 30
                            
                            contentItem: Text {
                                text: menuItem.text
                                font.pixelSize: Theme.smallFontPixelSize
                                color: menuItem.highlighted ? "white" : Theme.text
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }
                            background: Rectangle {
                                color: menuItem.highlighted ? Theme.accent : "transparent"
                            }
                        }
                    }
                }
            }
        }

        // Timeline Area
        Rectangle {
            SplitView.preferredHeight: 160
            color: Theme.panel
            
            TimelineHeader {
                id: timelineHeader
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
    GuideColorDialog {
        id: guideColorDialog
    }

    AlphaCheckDialog {
        id: alphaCheckDialog
    }

    FileDialog {
        id: openFileDialog
        title: qsTr("Open Image Sequence")
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.tga *.targa *.tif *.tiff)", "All files (*)"]
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
