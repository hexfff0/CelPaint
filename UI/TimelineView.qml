import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    color: "#333333"
    
    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 5
        orientation: ListView.Horizontal
        clip: true
        spacing: 5
        
        model: app.timelineModel

        delegate: Item {
            id: delegateItem
            width: 120
            height: listView.height - 10

            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                color: model.isSelected ? "#505050" : "transparent"
                border.color: model.isSelected ? "#3daee9" : "#555555"
                border.width: model.isSelected ? 3 : 1
                radius: 6

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Image {
                        width: 100
                        height: 100
                        source: "image://sequence/" + model.imageId + "?thumbnail=true&r=" + (Window.window ? Window.window.refreshCounter : 0)
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        sourceSize.width: 100
                        sourceSize.height: 100
                        asynchronous: false
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: "#666666"
                            border.width: 1
                        }
                    }

                    Text {
                        text: model.label
                        color: "white"
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        app.setCurrentIndex(index)
                    }
                }
            }
        }
        
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }
    
    // Empty state
    Label {
        anchors.centerIn: parent
        text: qsTr("No images loaded. Use File → Open Sequence...")
        color: "#888888"
        visible: listView.count === 0
    }
}
