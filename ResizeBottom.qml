import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

MouseArea {
    id: resizeBottom
    width: window.width
    height: 5
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 0
    cursorShape: Qt.SizeVerCursor
    hoverEnabled: true

    DragHandler {
        onActiveChanged: if (active) {
                             if (window.sizeStatus === 'max') {
                                 window.sizeStatus = 'normal'
                             }
                             window.startSystemResize(Qt.BottomEdge)
                         }
    }
}
