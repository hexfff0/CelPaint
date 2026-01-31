import QtQuick
import QtQuick.Controls

Item {
    id: root
    clip: true
    
    property bool colorDialogOpen: false
    property real zoomLevel: zoomArea.scaleFactor

    Rectangle {
        anchors.fill: parent
        color: "#2b2b2b"
    }

    Item {
        id: zoomArea
        anchors.fill: parent
        clip: true
        focus: true

        property real scaleFactor: 1.0
        property real minScale: 0.1
        property real maxScale: 10.0
        property real tx: 0
        property real ty: 0
        property bool spaceHeld: false

        Image {
            id: displayImage
            source: "image://sequence/current?r=" + (Window.window ? Window.window.refreshCounter : 0)
            scale: zoomArea.scaleFactor
            x: zoomArea.tx + (zoomArea.width - width * scale) / 2
            y: zoomArea.ty + (zoomArea.height - height * scale) / 2
            transformOrigin: Item.TopLeft
            fillMode: Image.Pad
            cache: false
            asynchronous: false

            MouseArea {
                id: imageMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                
                onClicked: (mouse) => {
                    if (root.colorDialogOpen) {
                        let px = Math.floor(mouse.x)
                        let py = Math.floor(mouse.y)
                        
                        if (px >= 0 && px < displayImage.sourceSize.width &&
                            py >= 0 && py < displayImage.sourceSize.height) {
                            app.pickColorAt(px, py)
                        }
                    }
                }
            }
        }

        MouseArea {
            id: panMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.MiddleButton | Qt.LeftButton
            propagateComposedEvents: true
            
            property bool isPanning: false
            property point lastPos

            cursorShape: isPanning ? Qt.ClosedHandCursor : 
                         (zoomArea.spaceHeld ? Qt.OpenHandCursor : Qt.ArrowCursor)

            onPressed: (mouse) => {
                if (mouse.button === Qt.MiddleButton || 
                    (mouse.button === Qt.LeftButton && zoomArea.spaceHeld)) {
                    isPanning = true
                    lastPos = Qt.point(mouse.x, mouse.y)
                    mouse.accepted = true
                } else if (mouse.button === Qt.LeftButton && root.colorDialogOpen) {
                    // Let image mouse area handle color picking
                    mouse.accepted = false
                } else {
                    mouse.accepted = false
                }
            }
            
            onPositionChanged: (mouse) => {
                if (isPanning) {
                    let dx = mouse.x - lastPos.x
                    let dy = mouse.y - lastPos.y
                    zoomArea.tx += dx
                    zoomArea.ty += dy
                    lastPos = Qt.point(mouse.x, mouse.y)
                }
            }

            onReleased: {
                isPanning = false
            }
            
            onWheel: (wheel) => {
                let zoomFactor = 1.25
                let oldScale = zoomArea.scaleFactor
                
                if (wheel.angleDelta.y > 0) {
                    zoomArea.scaleFactor *= zoomFactor
                } else {
                    zoomArea.scaleFactor /= zoomFactor
                }
                zoomArea.scaleFactor = Math.max(zoomArea.minScale, 
                                                Math.min(zoomArea.maxScale, zoomArea.scaleFactor))
                
                app.setZoomLevel(zoomArea.scaleFactor)
            }
        }
        
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
                spaceHeld = true
                event.accepted = true
            }
        }
        
        Keys.onReleased: (event) => {
            if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
                spaceHeld = false
                panMouseArea.isPanning = false
                event.accepted = true
            }
        }
    }
    
    Text {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10
        text: zoomArea.spaceHeld ? "Pan Mode: Drag to pan" : 
              (root.colorDialogOpen ? "Click to pick color" : "Space+Drag to Pan | Scroll to Zoom")
        color: "#aaaaaa"
        font.pixelSize: 12
    }
}
