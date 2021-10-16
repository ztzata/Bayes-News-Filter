import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: vSplit
    property real tableVScale: 0.25
    y: parent.height * tableVScale
    height: 3
    color: "darkGray"
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.leftMargin: 0
    onYChanged: {
        if (mouseV.drag.active) {
            tableVScale = y / parent.height
        }
    }
    MouseArea {
        id: mouseV
        anchors.fill: parent
        cursorShape: Qt.SplitVCursor
        drag.target: vSplit
        drag.axis: Drag.YAxis
        drag.minimumY: 0
    }
}
