import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

MouseArea {
    id: resizeRight
    width: 5
    height: window.height
    anchors.right: parent.right
    anchors.rightMargin: 0
    cursorShape: Qt.SizeHorCursor
    hoverEnabled: true

    DragHandler {
        onActiveChanged: if (active) {
                             if (window.sizeStatus === 'max') {
                                 window.sizeStatus = 'normal'
                             }
                             window.startSystemResize(Qt.RightEdge)
                         }
    }
}
