import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Services
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "qs_wallpaper"
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"

    property string displayedWallpaper: ""
    property string nextWallpaper: ""
    property string transition: ""

    property real randomX
    property real randomY

    Image {
        id: currentImage

        anchors.fill: parent
        source: root.displayedWallpaper
        fillMode: Image.PreserveAspectCrop
        cache: true
        smooth: true
    }

    Image {
        id: nextImage

        anchors.fill: parent
        source: root.nextWallpaper
        fillMode: Image.PreserveAspectCrop
        cache: true
        smooth: true
        opacity: root.transition === "fade" ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }
    }

    Item {
        id: mask

        anchors.fill: parent
        visible: false

        Rectangle {
            id: circle

            width: 0
            height: width

            x: root.randomX - width / 2
            y: root.randomY - height / 2

            radius: width / 2
            color: "white"

            Behavior on width {
                NumberAnimation {
                    duration: 1000
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    OpacityMask {
        anchors.fill: parent
        source: nextImage
        maskSource: mask
        visible: root.transition === "grow"
    }

    Connections {
        target: WallpaperService

        function onCurrentWallpaperChanged() {
            if (!WallpaperService.currentWallpaper)
                return;
            if (WallpaperService.currentWallpaper === root.displayedWallpaper)
                return;
            root.nextWallpaper = WallpaperService.currentWallpaper;

            if (Math.random() < 0.2) {
                root.transition = "fade";
                nextImage.opacity = 1;
            } else {
                root.transition = "grow";

                root.randomX = Math.random() * Screen.width;
                root.randomY = Math.random() * Screen.height;

                circle.width = Math.sqrt(Math.max(root.randomX, root.width - root.randomX) ** 2 + Math.max(root.randomY, root.height - root.randomY) ** 2) * 2;
            }

            resetTimer.start();
        }
    }

    Timer {
        id: resetTimer

        interval: 1000
        repeat: false

        onTriggered: {
            root.displayedWallpaper = root.nextWallpaper;
            nextImage.opacity = 0;
            circle.width = 0;
            root.transition = "";
        }
    }

    Component.onCompleted: {
        if (!WallpaperService.currentWallpaper)
            return;
        root.nextWallpaper = WallpaperService.currentWallpaper;
        resetTimer.start();
    }
}
