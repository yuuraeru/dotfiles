import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services

Rectangle {
    id: root

    required property var notification
    property bool isCritical: root.notification.isCritical

    visible: !NotificationService.dnd || isCritical || NotificationService.centerIsOpen

    color: Colors.base
    radius: Config.rounding

    width: 400
    height: Math.max(80, card.height + 20)

    border {
        width: Config.borderSize
        color: isCritical ? Colors.red : Colors.subtext0
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10

        spacing: 10

        Image {
            visible: source.toString() !== ""
            source: root.notification.image
            fillMode: Image.PreserveAspectFit

            Layout.preferredWidth: 60
            Layout.preferredHeight: 60
            Layout.alignment: Qt.AlignTop
        }

        ColumnLayout {
            id: card

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.notification.summary
                    color: root.isCritical ? Colors.red : Colors.blue

                    font {
                        family: Fonts.normal
                        pixelSize: Fonts.textNormal
                        bold: true
                    }

                    Layout.fillWidth: true

                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    visible: NotificationService.centerIsOpen
                    text: `${root.notification.appName} • ${root.notification.time}`
                    color: Colors.subtext0
                    font {
                        family: Fonts.normal
                        pixelSize: Fonts.textSmall
                    }
                }
            }

            Text {
                visible: text !== ""
                text: root.notification.body
                color: Colors.text

                font {
                    family: Fonts.normal
                    pixelSize: Fonts.textSmall
                }

                Layout.fillWidth: true

                wrapMode: Text.WordWrap
                maximumLineCount: NotificationService.centerIsOpen ? 10 : 2
                elide: NotificationService.centerIsOpen ? Text.ElideNone : Text.ElideRight
            }
        }
    }
}
