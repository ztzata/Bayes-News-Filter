import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: statusBar
    anchors.left: parent.left
    anchors.leftMargin: 25
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 25
    width: childrenRect.width
    height: childrenRect.height

    property alias statusBarText: statusBarText
    Text {
        id: statusBarText
        text: ''
        font.pointSize: 10
    }
}
