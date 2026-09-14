import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services

Rectangle {
    id: root

    implicitWidth: row.implicitWidth + 24
    implicitHeight: Config.barSize

    radius: Config.rounding

    color: Colors.base

    Item {
        id: row
        implicitWidth: 20
        implicitHeight: 24
        anchors.centerIn: parent

        Text {
            text: NotificationService.dnd ? "󰪑" : "󰂜"
            anchors.centerIn: parent
            color: NotificationService.dnd ? Colors.red : Colors.mauve
            font {
                family: Fonts.icon
                pixelSize: Fonts.iconSmall
            }
        }

        Text {
            visible: NotificationService.historyList.length > 0
            text: ""
            color: "#ff0000"
            font.pixelSize: 9
            anchors {
                top: row.top
                right: row.right
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: e => e.button === Qt.LeftButton ? NotificationService.toggleCenter() : NotificationService.toggleDND()
    }
}
