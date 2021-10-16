import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

MouseArea {
    id: resizeRightBottom
    width: 10
    height: 10
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 0
    cursorShape: Qt.SizeFDiagCursor
    hoverEnabled: true
    DragHandler {
        onActiveChanged: if (active) {
                             if (window.sizeStatus === 'max') {
                                 window.sizeStatus = 'normal'
                             }
                             window.startSystemResize(
                                         Qt.BottomEdge | Qt.RightEdge)
                         }
    }
}
