import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Config
import qs.Services

PanelWindow {
    id: root
    visible: NotificationService.centerIsOpen

    WlrLayershell.namespace: "qs_notification_center"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    color: "transparent"

    Item {
        id: keyHandler
        focus: root.visible

        Keys.onEscapePressed: {
            NotificationService.hideCenter();
        }
    }

    onVisibleChanged: {
        if (visible)
            keyHandler.forceActiveFocus();
    }

    MouseArea {
        anchors.fill: parent
        onClicked: NotificationService.hideCenter()
    }

    Rectangle {
        id: center

        anchors {
            top: parent.top
            right: parent.right
            topMargin: Config.barSize + Config.gaps * 2
            rightMargin: Config.gaps
        }

        implicitWidth: 400
        implicitHeight: 800

        color: Colors.base
        radius: Config.rounding

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Notifications"

                    font {
                        family: Fonts.normal
                        pixelSize: Fonts.textLarge
                        bold: true
                    }

                    color: Colors.blue
                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40

                        radius: Config.rounding

                        color: dndMouseArea.containsMouse ? Colors.red : NotificationService.dnd ? Colors.red : Colors.base

                        Text {
                            text: NotificationService.dnd ? "󰪑" : "󰂜"

                            anchors.centerIn: parent

                            color: dndMouseArea.containsMouse ? Colors.base : NotificationService.dnd ? Colors.base : Colors.red
                            font {
                                family: Fonts.icon
                                pixelSize: Fonts.iconNormal
                            }
                        }

                        MouseArea {
                            id: dndMouseArea
                            anchors.fill: parent

                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: NotificationService.toggleDND()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40

                        radius: Config.rounding

                        color: clearMouseArea.containsMouse ? Colors.red : Colors.base

                        Text {
                            text: "󰎟"

                            anchors.centerIn: parent

                            color: !clearMouseArea.containsMouse ? Colors.red : Colors.base
                            font {
                                family: Fonts.icon
                                pixelSize: Fonts.iconNormal
                            }
                        }

                        MouseArea {
                            id: clearMouseArea
                            anchors.fill: parent

                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: NotificationService.clearHistory()
                        }
                    }
                }
            }

            ColumnLayout {
                Text {
                    visible: NotificationService.historyList.length === 0

                    text: "No notifications"

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    color: Colors.subtext0
                    font {
                        family: Fonts.normal
                        pixelSize: Fonts.textNormal
                    }
                }

                ListView {
                    id: list
                    visible: NotificationService.historyList.length > 0

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    spacing: 10
                    clip: true

                    model: NotificationService.historyList

                    delegate: NotificationItem {
                        id: item
                        required property var modelData
                        width: parent.width
                        notification: modelData
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationService.removeHistory(item.modelData.id)
                        }
                    }
                }
            }
        }
    }
}
