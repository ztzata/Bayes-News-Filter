import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: moveWindowRect
    width: myTableView.width
    height: 40
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.topMargin: 0
    anchors.leftMargin: 0
    color: moveWindowMouseArea.containsMouse ? "gray" : "transparent"
    Text {
        id: moveWindowText
        text: moveWindowMouseArea.containsMouse ? qsTr("Drag here to move window") : qsTr(
                                                      "")
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 14
        color: 'lightgreen'
    }

    MouseArea {
        id: moveWindowMouseArea
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 10
        cursorShape: Qt.OpenHandCursor
        hoverEnabled: true
        DragHandler {
            onActiveChanged: if (active) {
                                 if (window.sizeStatus === 'max') {
                                     window.sizeStatus = 'normal'
                                 }
                                 window.startSystemMove()
                             }
        }
    }
}
