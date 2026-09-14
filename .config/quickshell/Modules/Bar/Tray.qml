pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import qs.Config

Rectangle {
    id: root
    required property var panelWindow

    implicitWidth: tray.implicitWidth + 24
    implicitHeight: Config.barSize

    radius: Config.rounding
    color: Colors.base

    visible: SystemTray.items.values.length > 0

    Row {
        id: tray

        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: SystemTray.items

            Item {
                id: trayItem
                required property var modelData

                implicitWidth: 24
                implicitHeight: 24

                Image {
                    anchors.centerIn: parent
                    source: trayItem.modelData.icon

                    width: 20
                    height: 20

                    fillMode: Image.PreserveAspectFit
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onClicked: e => {
                        if (e.button === Qt.LeftButton) {
                            trayItem.modelData.activate();
                        } else if (e.button === Qt.RightButton) {
                            const pos = trayItem.mapToItem(root.panelWindow.contentItem, e.x, e.y);

                            trayItem.modelData.display(root.panelWindow, pos.x, pos.y);
                        } else if (e.button === Qt.MiddleButton) {
                            trayItem.modelData.secondaryActivate();
                        }
                    }
                }
            }
        }
    }
}
