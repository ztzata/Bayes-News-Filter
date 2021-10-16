import QtQuick
import QtQuick.Window
import QtQuick.Controls

import QtQuick.Controls.Material

Window {
    id: window
    x: 1
    y: 0
    property string sizeStatus: "max"
    width: Screen.width - 1 //There is a bug for showMaximized and FramelessWindowHint, it will enter full screen mode automatically.
    height: Screen.height
    minimumWidth: 640
    minimumHeight: 480
    visible: true
    color: "#000000"
    flags: Qt.FramelessWindowHint | Qt.Window

    VerticalHeaderView {
        Material.theme: Material.Dark
        id: verticalHeader
        syncView: myTableView
        anchors.top: myTableView.top
    }

    onWidthChanged: myTableView.forceLayout()
    MyTableView {
        id: myTableView
    }

    //Mimic SplitView Handle
    HSplit {
        id: hSplit
    }

    BtnColumn {
        id: btnColumn
    }

    OptionsPopup {
        id: optionsPopup
    }

    //Mimic SplitView Handle
    VSplit {
        id: vSplit
    }

    MyWebEngineView {
        id: myWebEngineView
    }
    MoveWindowRect {
        id: moveWindowRect
    }

    ResizeBottom {
        id: resizeBottom
    }

    ResizeRight {
        id: resizeRight
    }

    ResizeRightBottom {
        id: resizeRightBottom
    }

    StatusBar {
        id: statusBar
    }

    Shortcut {
        //There is a bug that caused WebEngineView not receiving Keys event.
        sequence: 'Backspace'
        onActivated: myWebEngineView.goBack()
    }

    Shortcut {
        sequence: 'Del'
        onActivated: btnColumn.btnRead.clicked()
    }

    Shortcut {
        sequence: 'Ctrl+Up'
        onActivated: btnColumn.btnLike.clicked()
    }

    Shortcut {
        sequence: 'Ctrl+Down'
        onActivated: btnColumn.btnNoLike.clicked()
    }
} //Window
