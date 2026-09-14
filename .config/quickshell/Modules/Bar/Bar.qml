import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.Config

PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    WlrLayershell.namespace: "qs_bar"

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Config.barSize + Config.gaps

    color: "transparent"

    RowLayout {
        anchors {
            fill: parent
            leftMargin: Config.gaps
            rightMargin: Config.gaps
            topMargin: Config.gaps
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.left: parent.left
                spacing: Config.spacing

                Arch {}

                Hyprland {
                    screen: bar.modelData
                }

                Monitor {}
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Clock {
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.right: parent.right
                spacing: Config.spacing
                Tray {
                    panelWindow: bar
                }
                Audio {}
                Battery {}
                Notification {}
            }
        }
    }
}
