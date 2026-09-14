import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.Config

Rectangle {
    id: root

    property var battery: UPower.displayDevice
    property bool charging: battery.state === UPowerDeviceState.Charging
    readonly property int level: Math.round(battery.percentage * 100)

    visible: battery.type

    readonly property string icon: {
        if (charging)
            return "󰂄";
        if (level >= 100)
            return "󰁹";
        if (level < 10)
            return "󰂃";

        return String.fromCodePoint(0xf007a + Math.floor(level / 10) - 1);
    }

    implicitWidth: text.implicitWidth + 24
    implicitHeight: Config.barSize

    radius: Config.rounding
    color: Colors.base
    RowLayout {
        id: text
        anchors.centerIn: parent
        Text {
            text: root.icon
            color: root.charging ? Colors.green : root.level <= 15 ? Colors.red : root.level <= 30 ? Colors.yellow : Colors.green

            font {
                family: Fonts.icon
                pixelSize: Fonts.iconSmall
            }
        }
        Text {
            text: root.level + "%"
            color: root.charging ? Colors.green : root.level <= 15 ? Colors.red : root.level <= 30 ? Colors.yellow : Colors.green

            font {
                family: Fonts.normal
                pixelSize: Fonts.textNormal
                bold: true
            }
        }
    }
}
