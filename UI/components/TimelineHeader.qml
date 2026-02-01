import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Theme.js" as Theme

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
