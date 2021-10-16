import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: hSplit
    property real tableHScale: 0.9
    x: parent.width * tableHScale
    width: 3
    color: "gray"
    anchors.top: parent.top
    anchors.bottom: vSplit.top
    anchors.topMargin: 0
    anchors.bottomMargin: 0
    onXChanged: {
        if (mouseH.drag.active) {
            tableHScale = x / parent.width
            myTableView.forceLayout()
        }
    }
    MouseArea {
        id: mouseH
        anchors.fill: parent
        cursorShape: Qt.SplitHCursor
        drag.target: hSplit
        drag.axis: Drag.XAxis
        drag.minimumX: 0
    }
}
