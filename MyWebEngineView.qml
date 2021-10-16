import QtQuick
import QtWebEngine
import QtQuick.Controls

WebEngineView {
    id: myWebEngineView
    anchors {
        top: vSplit.bottom
        bottom: parent.bottom
        left: parent.left
        right: parent.right
        margins: 0
    }

    onNewWindowRequested: function (request) {
        if (request.userInitiated) {
            myWebEngineView.url = request.requestedUrl
        }
    }

    onLoadingChanged: {
        zoomFactor = 1.3 * myWebEngineView.width / contentsSize.width
    }

    onLinkHovered: {
        statusBar.color = '#dbffd9' //'lightgreen'
        statusBar.statusBarText.text = hoveredUrl
    }

    Component.onCompleted: {
        loadHtml('<!DOCTYPE html> <html> <head> </head> <body style="background:black"><p style="text-align: center;"><span style="font-size: 36pt;color:white">Updating news...</span></p></body> </html>')
    }

    //This alternative signal is due to a WebEngineView bug that causes crash when loadHtml on Python signal.
    property string textToShow: ' '
    onTextToShowChanged: loadHtml(
                             '<!DOCTYPE html> <html> <body style="background:black"> <p style="text-align: center;font-size: 36pt;color:white">Updating news...</br>'
                             + textToShow + '</p> </body> </html>')

    Connections {
        target: myModel
        function onShow_in_browser(text_to_show) {
            myWebEngineView.textToShow = text_to_show + '</br>' + myWebEngineView.textToShow
        } //function
    } //Connections
} //myWebEngineView

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

