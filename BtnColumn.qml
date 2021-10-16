import QtQuick
import QtQuick.Window
import QtQuick.Controls

Column {
    property RoundButton btnRead: btnRead
    property RoundButton btnLike: btnLike
    property RoundButton btnNoLike: btnNoLike
    anchors.left: hSplit.right
    anchors.leftMargin: 0
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0
    anchors.bottom: vSplit.top
    anchors.bottomMargin: 0

    WindowBtnRow {
        id: windowBtnRow
    }

    RoundButton {
        id: btnLike
        text: qsTr("Like")
        font.pointSize: 12
        width: parent.width
        height: parent.height / 5
        enabled: optionsPopup.showUnread.checked ? true : false
        background: Rectangle {
            anchors.fill: parent
            radius: 30
            color: parent.down ? 'lightgreen' : (parent.hovered ? "green" : "lightgreen")
            border.width: 1
            border.color: 'black'
        }
        onClicked: {
            btnRead.enabled = false
            btnLike.enabled = false
            btnNoLike.enabled = false
            myModel.like(myTableView.rowsSelected)
            myModel.insertRow(myTableView.rowsSelected)
            myModel.removeRow(myTableView.rowsSelected)
            myTableView.rowsSelected = [Math.min(...myTableView.rowsSelected)]
            btnRead.enabled = true
            btnLike.enabled = true
            btnNoLike.enabled = true
            myWebEngineView.url = myModel.data(
                        myModel.index(myTableView.rowsSelected[0], 2))
        }
    }

    RoundButton {
        id: btnNoLike
        text: qsTr("No Like")
        font.pointSize: 12
        width: parent.width
        height: parent.height / 5
        enabled: optionsPopup.showUnread.checked ? true : false
        background: Rectangle {
            anchors.fill: parent
            radius: 30
            color: parent.down ? "pink" : (parent.hovered ? "red" : "pink")
            border.width: 1
            border.color: 'black'
        }
        onClicked: {
            btnRead.enabled = false
            btnLike.enabled = false
            btnNoLike.enabled = false
            myModel.no_like(myTableView.rowsSelected)
            myModel.insertRow(myTableView.rowsSelected)
            myModel.removeRow(myTableView.rowsSelected)
            myTableView.rowsSelected = [Math.min(...myTableView.rowsSelected)]
            btnRead.enabled = true
            btnLike.enabled = true
            btnNoLike.enabled = true
            myWebEngineView.url = myModel.data(
                        myModel.index(myTableView.rowsSelected[0], 2))
        }
    }

    RoundButton {
        id: btnRead
        text: ((optionsPopup.showUnread.checked == true)
               && (optionsPopup.directDelete.checked == false)) ? 'Read' : 'Delete'
        font.pointSize: 12
        width: parent.width
        height: parent.height / 5
        background: Rectangle {
            anchors.fill: parent
            radius: 30
            color: parent.down ? "#f6f6f6" : (parent.hovered ? "#bbbbbb" : "darkGray") // Gray scale color.
            border.width: 1
            border.color: 'black'
        }
        onClicked: {
            btnRead.enabled = false
            btnLike.enabled = false
            btnNoLike.enabled = false
            //Model operation.
            if ((optionsPopup.showUnread.checked == true)
                    && (optionsPopup.directDelete.checked == false)) {
                myModel.insertRow(myTableView.rowsSelected)
                myModel.removeRow(myTableView.rowsSelected)
            } else if (optionsPopup.showUnread.checked == false) {
                myModel.deleteRead(myTableView.rowsSelected)
            } else if ((optionsPopup.showUnread.checked == true)
                       && (optionsPopup.directDelete.checked == true)) {
                myModel.removeRow(myTableView.rowsSelected)
            }
            //rowsSelected operation.
            if (myTableView.rowsSelected.length == 1
                    && myTableView.rowsSelected[0] == myModel.rowCount()
                    && myTableView.rowsSelected[0] != 0) {
                myTableView.rowsSelected = [myTableView.rowsSelected[0] - 1]
            } else if (myTableView.rowsSelected.length > 1 && Math.min(
                           ...myTableView.rowsSelected) < myModel.rowCount()) {
                myTableView.rowsSelected = [Math.min(
                                                ...myTableView.rowsSelected)]
            } else if (myTableView.rowsSelected.length > 1) {
                myTableView.rowsSelected = [Math.min(
                                                ...myTableView.rowsSelected) - 1]
            }

            btnRead.enabled = true
            btnLike.enabled = true
            btnNoLike.enabled = true
            myWebEngineView.url = myModel.data(
                        myModel.index(myTableView.rowsSelected[0], 2))
        }
    }

    RoundButton {
        id: btnOption
        text: qsTr("Option")
        font.pointSize: 12
        width: parent.width
        height: parent.height / 5
        background: Rectangle {
            anchors.fill: parent
            radius: 30
            color: parent.down ? "#f6f6f6" : (parent.hovered ? "#bbbbbb" : "gray")
            border.width: 1
            border.color: 'black'
        }
        onClicked: {
            optionsPopup.open()
            optionsPopup.dateGet = myModel.date_to_get()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

