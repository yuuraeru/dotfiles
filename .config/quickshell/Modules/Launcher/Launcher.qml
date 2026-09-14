import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Services

PanelWindow {
    id: root

    visible: LauncherService.isOpen

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "qs_launcher"

    exclusionMode: ExclusionMode.Ignore

    color: "transparent"

    MouseArea {
        anchors.fill: parent
        z: -1

        onClicked: {
            LauncherService.hide();
        }
    }

    Item {
        id: launcherContainer

        anchors.centerIn: parent

        property Item currentLauncher: LauncherService.mode === "AppLauncher" ? appLauncher : LauncherService.mode === "Calculator" ? calculator : LauncherService.mode === "Clipboard" ? clipboard : LauncherService.mode === "WallpaperManager" ? wallpaperManager : LauncherService.mode === "EmojiPicker" ? emojiPicker : null

        width: currentLauncher ? currentLauncher.implicitWidth : 960

        height: currentLauncher ? currentLauncher.implicitHeight : 0

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        AppLauncher {
            id: appLauncher

            anchors.fill: parent
            visible: LauncherService.mode === "AppLauncher"
        }

        Calculator {
            id: calculator

            anchors.fill: parent
            visible: LauncherService.mode === "Calculator"
        }

        Clipboard {
            id: clipboard

            anchors.fill: parent
            visible: LauncherService.mode === "Clipboard"
        }

        WallpaperManager {
            id: wallpaperManager

            anchors.fill: parent
            visible: LauncherService.mode === "WallpaperManager"
        }

        EmojiPicker {
            id: emojiPicker

            anchors.fill: parent
            visible: LauncherService.mode === "EmojiPicker"
        }
    }
}
