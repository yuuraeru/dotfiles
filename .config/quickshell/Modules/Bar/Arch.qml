import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.Config
import qs.Services

Rectangle {
    implicitWidth: archLogo.implicitWidth + 24
    implicitHeight: Config.barSize

    radius: Config.rounding

    color: Colors.base

    Text {
        id: archLogo
        anchors.centerIn: parent
        text: "󰣇"
        color: Colors.blue
        font {
            family: Fonts.icon
            pixelSize: Fonts.iconSmall
            bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: LauncherService.toggle("AppLauncher")
    }
}
