import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Config

Rectangle {
    id: root

    implicitWidth: clock.implicitWidth + 24
    implicitHeight: Config.barSize

    property string time: Qt.formatDateTime(new Date(), "hh:mm:ss A")
    property string date: Qt.formatDateTime(new Date(), "ddd, MMM d yyyy")

    radius: Config.rounding

    color: Colors.base

    RowLayout {
        id: clock
        anchors.centerIn: parent

        Text {
            text: ""
            font {
                family: Fonts.icon
                pixelSize: Fonts.iconSmall
            }
            color: Colors.pink
        }
        Text {
            text: root.time
            font {
                family: Fonts.normal
                pixelSize: Fonts.textNormal
                bold: true
            }
            color: Colors.pink
        }
        Text {
            text: " "
            font {
                family: Fonts.icon
                pixelSize: Fonts.iconSmall
            }
            color: Colors.pink
        }
        Text {
            text: root.date
            font {
                family: Fonts.normal
                pixelSize: Fonts.textNormal
                bold: true
            }
            color: Colors.pink
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.time = Qt.formatDateTime(new Date(), "hh:mm:ss A");
            root.date = Qt.formatDateTime(new Date(), "ddd, MMM d yyyy");
        }
    }
}
