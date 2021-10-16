import QtQuick
import QtQuick.Controls

import QtQuick.Controls.Material

Popup {
    property alias showUnread: showUnread
    property alias directDelete: directDelete
    property var dateGet
    anchors.centerIn: Overlay.overlay
    padding: 100
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Material.theme: Material.Dark
    Material.accent: Material.LightBlue

    background: Rectangle {
        id: optionsPopupBG
        anchors.fill: parent
        radius: 30
        color: 'black'
        border.width: 1
        border.color: 'gray'
    } //background Rect

    Column {
        id: popupCol
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 50

        GroupBox {
            id: browseBox
            label: Rectangle {
                anchors.left: browseBox.left
                anchors.leftMargin: 20
                anchors.bottom: parent.top
                anchors.bottomMargin: -height / 3
                color: optionsPopupBG.color
                width: browseBoxTitle.width
                height: browseBoxTitle.height
                Text {
                    id: browseBoxTitle
                    text: qsTr(" Browse News ")
                    color: 'white'
                    font.pointSize: 14
                }
            }

            Row {
                RadioButton {
                    id: showUnread
                    checked: true
                    text: qsTr("Unread")
                    font.pointSize: 12
                    onCheckedChanged: {
                        if (showUnread.checked === true) {
                            myModel.load_unread()
                            myTableView.rowsSelected = [0]
                            myTableView.tableViewScroll.position = 0
                            if (myModel.rowCount() == 0) {
                                myWebEngineView.loadHtml(
                                            '<!DOCTYPE html> <html> <body style="background:black"> <p style="text-align: center;font-size: 36pt;color:white">No news to show...</br></p> </body> </html>')
                            }
                            myWebEngineView.url = myModel.data(myModel.index(0,
                                                                             2))
                            btnColumn.btnLike.enabled = true
                            btnColumn.btnNoLike.enabled = true
                        } else {
                            var oldRowCount = myModel.rowCount()
                            myModel.load_read()
                            myTableView.rowsSelected = [myModel.rowCount() - 1]
                            if (myModel.rowCount() == 0) {
                                myWebEngineView.loadHtml(
                                            '<!DOCTYPE html> <html> <body style="background:black"> <p style="text-align: center;font-size: 36pt;color:white">No news to show...</br></p> </body> </html>')
                            }
                            myWebEngineView.url = myModel.data(
                                        myModel.index(myModel.rowCount() - 1,
                                                      2))
                            //A bug of ScrollBar.
                            //When reset TableView model, the ScrollBar position calculation will not update at the same time.
                            //You have to calculate its position based on the old model.
                            myTableView.tableViewScroll.position
                                    = (myTableView.rowsSelected[0] - 3) / oldRowCount
                            btnColumn.btnLike.enabled = false
                            btnColumn.btnNoLike.enabled = false
                        }
                    } //onCheckedChanged
                } //RadioButton
                RadioButton {
                    leftPadding: 100
                    id: showRead
                    text: qsTr("Read")
                    font.pointSize: 12
                } //RadioButton
            } //Row
        } //GroupBox

        GroupBox {
            id: filterBox

            label: Rectangle {
                anchors.left: filterBox.left
                anchors.leftMargin: 20
                anchors.bottom: parent.top
                anchors.bottomMargin: -height / 3
                color: optionsPopupBG.color
                width: filterBoxTitle.width
                height: filterBoxTitle.height
                Text {
                    id: filterBoxTitle
                    text: qsTr(" Filter ")
                    color: 'white'
                    font.pointSize: 14
                }
            }

            Column {
                Row {
                    id: showLikeRow
                    Label {
                        text: "⬤ Show only interesting news     Top: "
                        height: parent.height
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: "AlignVCenter"
                        font.pointSize: 12
                    } //Label
                    TextField {
                        id: showLikePercent
                        text: '50'
                        width: 50
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: 12
                        selectByMouse: true
                    } //TextField
                    Label {
                        text: " %    "
                        height: parent.height
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: "AlignVCenter"
                        font.pointSize: 12
                    } //Label

                    RoundButton {
                        id: filterLikeBtn
                        text: qsTr(" Apply ")
                        font.pointSize: 12
                        font.capitalization: Font.Capitalize
                        height: parent.height
                        background: Rectangle {
                            radius: 15
                            color: parent.down ? "black" : (parent.hovered ? "#666666" : '#333333')
                            border.width: 1
                            border.color: 'white'
                        } //background: Rectangle
                        onClicked: {
                            if (showUnread.checked === true) {
                                myModel.show_like(showLikePercent.text)
                                myWebEngineView.url = myModel.data(
                                            myModel.index(0, 2))
                            } else {
                                myModel.show_like(showLikePercent.text)
                                myWebEngineView.url = myModel.data(
                                            myModel.index(myModel.rowCount(
                                                              ) - 1, 2))
                            } //if
                        } //onClicked
                    } //RoundButton
                } //Row

                Row {
                    Label {
                        text: "⬤ Don't show boring news    Buttom: "
                        height: parent.height
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: "AlignVCenter"
                        font.pointSize: 12
                    } //Label
                    TextField {
                        id: noshowNolikePercent
                        text: '50'
                        width: 50
                        horizontalAlignment: Text.AlignRight
                        font.pointSize: 12
                        selectByMouse: true
                    } //TextField

                    Label {
                        text: " %    "
                        height: parent.height
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: "AlignVCenter"
                        font.pointSize: 12
                    } //Label

                    RoundButton {
                        id: filterNoikeBtn
                        text: qsTr(" Apply ")
                        font.pointSize: 12
                        font.capitalization: Font.Capitalize
                        height: parent.height
                        background: Rectangle {
                            radius: 15
                            color: parent.down ? "black" : (parent.hovered ? "#666666" : '#333333')
                            border.width: 1
                            border.color: 'white'
                        } //background: Rectangle
                        onClicked: {
                            if (showUnread.checked === true) {
                                myModel.noshow_nolike(noshowNolikePercent.text)
                                myWebEngineView.url = myModel.data(
                                            myModel.index(0, 2))
                            } else {
                                myModel.noshow_nolike(noshowNolikePercent.text)
                                myWebEngineView.url = myModel.data(
                                            myModel.index(myModel.rowCount(
                                                              ) - 1, 2))
                            } //if
                        } //onClicked
                    } //RoundButton
                } //Row

                RoundButton {
                    anchors.right: parent.right
                    id: filterReset
                    text: qsTr(" Reset Filter ")
                    font.pointSize: 12
                    font.capitalization: Font.Capitalize
                    height: showLikeRow.height
                    background: Rectangle {
                        radius: 15
                        color: parent.down ? "black" : (parent.hovered ? "#666666" : '#333333')
                        border.width: 1
                        border.color: 'white'
                    } //background: Rectangle
                    onClicked: {
                        if (showUnread.checked === true) {
                            myModel.load_unread()
                            myWebEngineView.url = myModel.data(myModel.index(0,
                                                                             2))
                        } else {
                            myModel.load_read()
                            myWebEngineView.url = myModel.data(
                                        myModel.index(myModel.rowCount() - 1,
                                                      2))
                        }
                    } //onClicked
                } //RoundButton
            } //Column
        } //GroupBox

        GroupBox {
            id: updateBox

            label: Rectangle {
                anchors.left: updateBox.left
                anchors.leftMargin: 20
                anchors.bottom: parent.top
                anchors.bottomMargin: -height / 3
                color: optionsPopupBG.color
                width: updateBoxTitle.width
                height: updateBoxTitle.height
                Text {
                    id: updateBoxTitle
                    text: qsTr(" Update News ")
                    font.pointSize: 14
                    color: 'white'
                }
            }

            Row {
                Label {
                    id: dateLabel
                    text: " Update News From:"
                    height: updateFromYearText.height
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 12
                } //Label

                TextField {
                    id: updateFromYearText
                    width: 60
                    horizontalAlignment: Text.AlignRight
                    text: dateGet.substr(0, 4)
                    font.pointSize: 12
                    selectByMouse: true
                    onFocusChanged: if (focus == true) {
                                        selectAll()
                                    }
                    onAccepted: {
                        updateFromMonthText.focus = true
                    }
                    onTextEdited: if (text.length == 4) {
                                      updateFromMonthText.focus = true
                                  }
                } //TextField

                Label {
                    text: "-"
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    height: updateFromYearText.height
                    horizontalAlignment: Text.AlignRight
                    font.pointSize: 12
                } //Label

                TextField {
                    id: updateFromMonthText
                    width: 30
                    horizontalAlignment: Text.AlignRight
                    text: dateGet.substr(4, 2)
                    font.pointSize: 12
                    selectByMouse: true
                    onFocusChanged: if (focus == true) {
                                        selectAll()
                                    }
                    onAccepted: {
                        if (text.length == 1) {
                            text = '0' + text
                            updateFromDayText.focus = true
                        } else if (text.length == 2) {
                            updateFromDayText.focus = true
                        }
                    }
                    onEditingFinished: {
                        if (text.length == 1) {
                            text = '0' + text
                            updateFromDayText.focus = true
                        } else if (text.length == 2) {
                            updateFromDayText.focus = true
                        }
                    }
                    onTextEdited: if (text.length == 2) {
                                      updateFromDayText.focus = true
                                  }
                } //TextField

                Label {
                    text: "-"
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    height: updateFromYearText.height
                    horizontalAlignment: Text.AlignRight
                    font.pointSize: 12
                } //Label

                TextField {
                    id: updateFromDayText
                    width: 30
                    horizontalAlignment: Text.AlignRight
                    text: dateGet.substr(-2)
                    verticalAlignment: TextInput.AlignBottom | TextField.AlignBottom
                    font.pointSize: 12
                    selectByMouse: true
                    onFocusChanged: if (focus == true) {
                                        selectAll()
                                    }
                    onAccepted: {
                        if (text.length == 1) {
                            text = '0' + text
                        }
                        updateBtn.clicked()
                    }
                    onEditingFinished: {
                        if (text.length == 1) {
                            text = '0' + text
                        }
                    }
                } //TextField

                Label {
                    text: "   To: "
                    height: parent.height
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: "AlignVCenter"
                    font.pointSize: 12
                } //Label

                TextField {
                    id: updateDaysText
                    width: 30
                    horizontalAlignment: Text.AlignRight
                    text: "2"
                    font.pointSize: 12
                    selectByMouse: true
                    onFocusChanged: if (focus == true) {
                                        selectAll()
                                    }
                    onAccepted: {
                        updateBtn.clicked()
                    }
                } //TextField

                Label {
                    text: " Days After\t"
                    height: parent.height
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: "AlignVCenter"
                    font.pointSize: 12
                } //Label

                RoundButton {
                    id: updateBtn
                    text: qsTr(" Update Now ")
                    font.pointSize: 12
                    font.capitalization: Font.Capitalize
                    height: parent.height
                    background: Rectangle {
                        radius: 15
                        color: parent.down ? "black" : (parent.hovered ? "#666666" : '#333333')
                        border.width: 1
                        border.color: 'white'
                    } //background: Rectangle
                    onClicked: {
                        updateBtn.enabled = false
                        myWebEngineView.textToShow = '<!DOCTYPE html> <html> <head> </head> <body><p style="text-align: center;"><span style="font-size: 36pt;">Updating news...</span></p>'
                        myModel.set_dates_to_get(
                                    parseInt(updateDaysText.text),
                                    updateFromYearText.text + updateFromMonthText.text
                                    + updateFromDayText.text)
                        myModel.run_in_QThread_updateNewsToModel()
                        updateBtn.enabled = true
                        optionsPopup.close()
                    } //onClicked
                } //RoundButton
            } //Row
        } //GroupBox

        GroupBox {
            id: deleteBox
            label: Rectangle {
                anchors.left: deleteBox.left
                anchors.leftMargin: 20
                anchors.bottom: parent.top
                anchors.bottomMargin: -height / 3
                color: optionsPopupBG.color
                width: deleteBoxTitle.width
                height: deleteBoxTitle.height
                Text {
                    id: deleteBoxTitle
                    text: qsTr(" Delete News Option ")
                    color: 'white'
                    font.pointSize: 14
                }
            }

            CheckBox {
                id: directDelete
                checked: false
                text: qsTr("Directly delete news from news_unread")
                font.pointSize: 12
            } //CheckBox
        } //GroupBox

        GroupBox {
            id: shortcutBox
            label: Rectangle {
                anchors.left: shortcutBox.left
                anchors.leftMargin: 20
                anchors.bottom: parent.top
                anchors.bottomMargin: -height / 3
                color: optionsPopupBG.color
                width: shortcutBoxTitle.width
                height: shortcutBoxTitle.height
                Text {
                    id: shortcutBoxTitle
                    text: qsTr(" Shortcuts ")
                    color: 'white'
                    font.pointSize: 14
                }
            }

            Row {
                Label {
                    text: qsTr("Like Btn: Ctrl+Up")
                    font.pointSize: 12
                    rightPadding: 50
                } //Label
                Label {
                    text: qsTr("NoLike Btn: Ctrl+Down")
                    font.pointSize: 12
                    rightPadding: 50
                } //Label
                Label {
                    text: qsTr("Read Btn: Del")
                    font.pointSize: 12
                } //Label
            } //Row
        } //GroupBox
    } //Column
    //property RoundButton updateBtn: updateBtn
} //Popup
