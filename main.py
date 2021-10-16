# This Python file uses the following encoding: utf-8
import sys
from PySide6.QtGui import Qt
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine  # , qmlRegisterType
from PySide6.QtWebEngineQuick import QtWebEngineQuick

import MyDriversModel


if __name__ == "__main__":
    QtWebEngineQuick.initialize()
    QGuiApplication.setHighDpiScaleFactorRoundingPolicy(Qt.HighDpiScaleFactorRoundingPolicy.Floor)
    app = QGuiApplication()
    myModelInstance = MyDriversModel.MyModel()
    engine = QQmlApplicationEngine()
    engine.quit.connect(app.quit)
    engine.rootContext().setContextProperty("myModel", myModelInstance)
    engine.load("main.qml")

    myModelInstance.set_dates_to_get()
    myModelInstance.run_in_QThread(myModelInstance.update_news_to_model)

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
