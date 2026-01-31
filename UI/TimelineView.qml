import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

Rectangle {
    id: root
    color: Theme.panel

    ListView {
        id: listView
        anchors.fill: parent
        // Leave space at bottom for ScrollBar if needed, or let it overlay. 
        // User requested "slide below", so we make it prominent.
        anchors.bottomMargin: 14 
        
        orientation: ListView.Horizontal
        spacing: 1
        clip: true
        
        model: app.timelineModel

        delegate: Rectangle {
            id: delegateRoot
            width: 90
            height: listView.height // Fill list height
            color: (index === app.currentIndex) ? Theme.selection : Theme.background
            border.color: (index === app.currentIndex) ? Theme.accent : Theme.panelBorder
            border.width: (index === app.currentIndex) ? 1 : 1
            
            MouseArea {
                anchors.fill: parent
                onClicked: app.setCurrentIndex(index)
            }

            Column {
                anchors.centerIn: parent
                spacing: 2
                
                // Thumbnail
                Rectangle {
                    width: 76; height: 44 // Adjusted for 16:9 aspect match
                    color: "transparent"
                    clip: true
                    
                    Image {
                        anchors.fill: parent
                        source: "image://sequence/" + model.imageId + "?thumbnail=true&r=" + (Window.window ? Window.window.refreshCounter : 0)
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        asynchronous: false
                    }
                }

                Text {
                    text: model.label
                    color: (index === app.currentIndex) ? "white" : Theme.text
                    font.pixelSize: Theme.smallFontPixelSize
                    font.bold: (index === app.currentIndex)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        // Horizontal ScrollBar
        ScrollBar.horizontal: ScrollBar {
            id: hbar
            policy: ScrollBar.AlwaysOn
            active: true
            size: listView.width / listView.contentWidth
            
            // Custom styling for the scrollbar to look like a "slide"
            contentItem: Rectangle {
                implicitHeight: 6
                implicitWidth: 100
                radius: 3
                color: hbar.pressed ? Theme.accent : Theme.textDisabled
            }
            background: Rectangle {
                implicitHeight: 6
                color: "#1a1a1a"
            }
            
            anchors.bottom: parent.bottom // Attached to ListView
            anchors.left: parent.left
            anchors.right: parent.right
        }
        
        // Auto scroll to current
        Connections {
            target: app
            function onCurrentIndexChanged() {
                listView.positionViewAtIndex(app.currentIndex, ListView.Center)
            }
        }
    }
}
