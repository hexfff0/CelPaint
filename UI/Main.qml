import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: app.currentTitle

    property int refreshCounter: 0

    Connections {
        target: app
        function onRequestImageRefresh() {
            refreshCounter++
        }
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&Open Sequence...")
                onTriggered: openFileDialog.open()
            }
            MenuItem {
                text: qsTr("&Export...")
                onTriggered: exportFolderDialog.open()
            }
            MenuSeparator {}
            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: qsTr("&Tools")
            MenuItem {
                text: qsTr("Batch Palette (色置換)")
                onTriggered: colorReplaceDialog.show()
            }
        }
    }

    footer: ToolBar {
        height: 30
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            Label {
                text: app.statusMessage
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Label {
                text: "Zoom: " + Math.round(canvasView.zoomLevel * 100) + "%"
                Layout.rightMargin: 10
            }
        }
    }

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

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        CanvasView {
            id: canvasView
            Layout.fillWidth: true
            Layout.fillHeight: true
            colorDialogOpen: colorReplaceDialog.visible
        }

        TimelineView {
            Layout.fillWidth: true
            Layout.preferredHeight: 160
        }
    }
}
