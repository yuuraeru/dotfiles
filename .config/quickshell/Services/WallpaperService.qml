pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string wallpaperDir: "/home/yurareru/Pictures/Wallpapers"
    property var wallpapers: []
    property var filteredWallpapers: []
    property string currentWallpaper: ""
    property int selectedIndex: 0

    property var settings: Settings {
        category: "Wallpaper"

        property string currentWallpaper: ""
    }

    function reset() {
        root.selectedIndex = 0;
    }

    function updateFiltered() {
        const q = LauncherService.query.trim().toLowerCase();

        root.filteredWallpapers = root.wallpapers.filter(filename => {
            return q === "" || filename.toLowerCase().includes(q);
        });

        if (root.filteredWallpapers.length === 0) {
            root.selectedIndex = 0;
            return;
        }

        if (root.selectedIndex >= root.filteredWallpapers.length)
            root.selectedIndex = root.filteredWallpapers.length - 1;
    }

    function navigate(delta) {
        const count = root.filteredWallpapers.length;

        if (count <= 0)
            return;

        root.selectedIndex = (root.selectedIndex + delta + count) % count;
    }

    function setWallpaper(filename) {
        if (!filename)
            return;

        const path = `${root.wallpaperDir}/${filename}`;

        root.currentWallpaper = path;
        root.settings.currentWallpaper = path;
    }

    function refresh() {
        scan.running = true;
    }

    Process {
        id: scan

        property var results: []

        command: ["sh", "-c", `find "${root.wallpaperDir}" -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) -printf '%f\\n'`]

        stdout: SplitParser {
            onRead: data => {
                const filename = data.trim();

                if (filename)
                    scan.results.push(filename);
            }
        }

        onRunningChanged: {
            if (running) {
                results = [];
                return;
            }

            root.wallpapers = results;
            root.updateFiltered();
        }
    }

    Connections {
        target: LauncherService

        function onQueryChanged() {
            root.updateFiltered();
        }
    }

    Component.onCompleted: {
        root.currentWallpaper = root.settings.currentWallpaper;
        root.refresh();
    }
}
