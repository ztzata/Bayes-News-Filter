import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic

TableView {
    id: myTableView
    property bool ctrlPressed: false
    property bool shiftPressed: false
    property var rowsSelected: [0]
    property alias tableViewScroll: tableViewScroll
    anchors.top: parent.top
    anchors.topMargin: 0
    anchors.left: verticalHeader.right
    anchors.leftMargin: 0
    anchors.bottom: vSplit.top
    anchors.bottomMargin: 0
    anchors.right: hSplit.left
    anchors.rightMargin: 0
    clip: true

    ScrollBar.vertical: ScrollBar {
        id: tableViewScroll
        opacity: 0.7
        contentItem: Rectangle {
            opacity: 0.5
            implicitWidth: 25
            implicitHeight: 100
            radius: 10
            color: tableViewScroll.hovered ? "lightgray" : "bluegray"
        }
        background: Rectangle {
            color: 'darkgray'
        }
    } //ScrollBar

    property var columnWidths: [180, myTableView.width - 500, 0, 120, 100, 100]
    columnWidthProvider: function (column) {
        return columnWidths[column]
    }
    rowHeightProvider: function (row) {
        return 50
    }

    delegate: Rectangle {
        id: cellRect
        border.color: "gray"
        border.width: 1
        color: {
            if (rowsSelected.indexOf(row) != -1) {
                '#016198'
            } else {
                row % 2 === 1 ? 'black' : '#2f2f2f'
            }
        } //Color
        Text {
            id: cellText
            color: 'white'
            text: ' ' + display
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 14
            elide: Text.ElideMiddle
            font.family: 'Microsoft YaHei UI'
        }

        MouseArea {
            hoverEnabled: true
            onEntered: myTableView.focus = true
            anchors.fill: parent
            onClicked: {
                if (ctrlPressed == true && shiftPressed == false) {
                    if (rowsSelected.indexOf(row) == -1) {
                        rowsSelected.push(row)
                    } else if (rowsSelected.length > 1) {
                        rowsSelected.splice(rowsSelected.indexOf(row),
                                            1) // Remove row from rowsSelected.
                    }
                } else if (shiftPressed == true) {
                    rowsSelected = [rowsSelected[0]]
                    if (rowsSelected[0] < row) {
                        for (var i = rowsSelected[0]; i <= row; i++) {
                            if (rowsSelected.indexOf(i) == -1) {
                                rowsSelected.push(i)
                            }
                        }
                    } else if (rowsSelected[0] > row) {
                        for (var i = rowsSelected[0]; i >= row; i--) {
                            if (rowsSelected.indexOf(i) == -1) {
                                rowsSelected.push(i)
                            }
                        }
                    }
                } else {
                    rowsSelected = [row]
                }

                rowsSelectedChanged()

                myWebEngineView.url = myModel.data(myModel.index(row, 2))
                myTableView.focus = true //To get keys event!
            } //onClicked
        } //MouseArea
    } //delegate: Rectangle

    //Add this alternative signal due to bugs of WebEngineView
    property string selectedNews: ''
    onSelectedNewsChanged: {
        myWebEngineView.url = selectedNews
        myTableView.focus = true
    }

    Connections {
        target: myModel
        function onUpdate_finished() {
            if (optionsPopup.showUnread.checked == true) {
                myTableView.model = undefined
                myTableView.model = myModel
                myTableView.rowsSelected = [0]
                myTableView.tableViewScroll.position = 0
                myTableView.selectedNews = myModel.data(myModel.index(
                                                            rowsSelected[0], 2))
                myTableView.selectedNewsChanged()
            } //if
        } //function
    } //Connections

    //If you are using QtCreator 5.0.1 to edit QML files and upgraded from Qt5 to Qt6,
    //there is a bug will change "(event)=> {" to "event =>" when you use 'auto format on save'.
    //Use other text editor to change it back.
    Keys.onPressed: (event)=> {
                    switch (event.key) {
                        case Qt.Key_Control:
                        ctrlPressed = true
                        break
                        case Qt.Key_Shift:
                        shiftPressed = true
                        break
                        case Qt.Key_Down:
                        if (rowsSelected[rowsSelected.length - 1] != myModel.rowCount(
                                ) - 1) {
                            rowsSelected = [rowsSelected[rowsSelected.length - 1] + 1]
                        } else {
                            rowsSelected = [rowsSelected[rowsSelected.length - 1]]
                        }
                        tableViewScroll.position = (rowsSelected[0] - 2) / myModel.rowCount()
                        myWebEngineView.url = myModel.data(
                            myModel.index(rowsSelected[0], 2))
                        break
                        case Qt.Key_Up:
                        if (rowsSelected[rowsSelected.length - 1] != 0) {
                            rowsSelected = [rowsSelected[rowsSelected.length - 1] - 1]
                        } else {
                            rowsSelected = [rowsSelected[rowsSelected.length - 1]]
                        }
                        tableViewScroll.position = (rowsSelected[0] - 2) / myModel.rowCount()
                        myWebEngineView.url = myModel.data(
                            myModel.index(rowsSelected[0], 2))
                        break
                        //default:
                        //    return;
                    } //switch
    event.accepted = true
    } //Keys.onPressed

    Keys.onReleased: (event)=> {
        if (event.key === Qt.Key_Control) {
            ctrlPressed = false
        } else if (event.key === Qt.Key_Shift) {
        shiftPressed = false
        }
    } //Keys.onReleased
} //TableView

        /*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

