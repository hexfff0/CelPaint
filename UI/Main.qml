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
