import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Config
import qs.Services

PanelWindow {
    id: root
    visible: !NotificationService.centerIsOpen && NotificationService.popupList.length > 0

    WlrLayershell.namespace: "qs_notification_popup"
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        right: true
    }

    implicitWidth: column.implicitWidth + Config.gaps
    implicitHeight: column.implicitHeight + Config.gaps

    color: "transparent"

    Column {
        id: column

        anchors {
            top: parent.top
            topMargin: Config.gaps
        }

        spacing: 10

        Repeater {
            model: NotificationService.popupList

            delegate: NotificationItem {
                id: notificationItem
                required property var modelData

                notification: modelData
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationService.removePopup(notificationItem.modelData.id)
                }
            }
        }
    }
}
