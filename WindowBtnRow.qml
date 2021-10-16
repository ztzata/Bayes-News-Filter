import QtQuick
import QtQuick.Window
import QtQuick.Controls

Row {
    width: parent.width
    height: parent.height / 5

    RoundButton {
        id: btnMin
        text: "<font color='white'>一</font>"
        font.pointSize: 10
        width: parent.width / 3
        height: parent.height
        background: Rectangle {
            anchors.fill: parent
            color: parent.down ? "#d6d6d6" : (parent.hovered ? "#bbbbbb" : "black")
        }
        onClicked: window.showMinimized()
    }

    RoundButton {
        id: btnMax
        text: window.sizeStatus === 'max' ? "❐" : "口"
        contentItem: Text {
            text: btnMax.text
            font.pointSize: 10
            color: 'white'
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        } //设置字体颜色

        width: parent.width / 3
        height: parent.height
        background: Rectangle {
            anchors.fill: parent
            color: parent.down ? "#d6d6d6" : (parent.hovered ? "#bbbbbb" : "black")
        }

        onClicked: {
            if (window.sizeStatus === 'max') {
                window.x = Screen.width / 4
                window.y = Screen.height / 4
                window.width = 960
                window.height = 540
                window.sizeStatus = 'normal'
            } else {
                window.x = 1
                window.y = 0
                window.width = Screen.width - 1 //There is a bug. See main.qml
                window.height = Screen.height
                window.sizeStatus = 'max'
            }
        } //onClicked
    } //btnMax

    RoundButton {
        id: btnClose
        text: "<font color='white'>X</font>"
        font.pointSize: 10
        width: parent.width / 3
        height: parent.height
        background: Rectangle {
            anchors.fill: parent
            color: parent.down ? "darkred" : (parent.hovered ? "red" : "black")
        }
        onClicked: Qt.quit()
    }
}
