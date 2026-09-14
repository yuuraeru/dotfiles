pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var entries: []
    property var filteredEntries: []
    property var decodingIds: []
    property var decodeQueue: []
    property int selectedIndex: 0

    property string cacheDir: (Quickshell.env("XDG_CACHE_HOME") || Quickshell.env("HOME") + "/.cache") + "/cliphist/thumbnails"

    function reset() {
        root.selectedIndex = 0;
    }

    function updateFiltered() {
        const q = LauncherService.query.trim().toLowerCase();

        root.filteredEntries = root.entries.filter(entry => {
            return q === "" || entry.preview.toLowerCase().includes(q);
        });

        if (root.filteredEntries.length === 0) {
            root.selectedIndex = 0;
            return;
        }

        if (root.selectedIndex >= root.filteredEntries.length)
            root.selectedIndex = root.filteredEntries.length - 1;
    }

    function navigate(delta) {
        const count = root.filteredEntries.length;

        if (count <= 0)
            return;

        root.selectedIndex = (root.selectedIndex + delta + count) % count;
    }

    function cachePath(entry) {
        return root.cacheDir + "/" + entry.id + "." + entry.extension;
    }

    function isDecoding(id) {
        return root.decodingIds.indexOf(id) !== -1 || root.decodeQueue.indexOf(id) !== -1;
    }

    function requestImage(entry) {
        if (!entry || !entry.isImage || root.isDecoding(entry.id))
            return;

        root.decodeQueue = root.decodeQueue.concat([entry.id]);
        root.processNextDecode();
    }

    function processNextDecode() {
        if (decodeProcess.running)
            return;

        if (root.decodeQueue.length === 0)
            return;

        const id = root.decodeQueue[0];

        root.decodeQueue = root.decodeQueue.slice(1);
        root.decodingIds = root.decodingIds.concat([id]);

        const updated = root.entries.slice();
        const index = updated.findIndex(entry => entry.id === id);

        if (index === -1) {
            root.decodingIds = root.decodingIds.filter(item => item !== id);

            root.processNextDecode();
            return;
        }

        const entry = updated[index];

        decodeProcess.currentId = id;
        decodeProcess.command = ["sh", "-c", 'mkdir -p "$1"; if [ ! -f "$1/$2.$3" ]; then printf "%s\\t\\n" "$2" | cliphist decode > "$1/$2.$3"; fi', "sh", root.cacheDir, entry.id, entry.extension];

        decodeProcess.running = true;
    }

    function finishDecode(id) {
        root.decodingIds = root.decodingIds.filter(item => item !== id);

        const updated = root.entries.slice();
        const index = updated.findIndex(entry => entry.id === id);

        if (index !== -1) {
            const entry = updated[index];

            updated[index] = {
                id: entry.id,
                preview: entry.preview,
                isImage: entry.isImage,
                extension: entry.extension,
                cached: true
            };

            root.entries = updated;
            root.updateFiltered();
        }

        root.processNextDecode();
    }

    function refresh() {
        if (listProcess.running)
            listProcess.running = false;

        listProcess.running = true;
    }

    function copyEntry(entry) {
        if (!entry)
            return;

        copyProcess.command = ["sh", "-c", 'printf "%s\\t\\n" "$1" | cliphist decode | wl-copy', "sh", entry.id];

        copyProcess.running = true;
        LauncherService.hide();
    }

    function deleteEntry(entry) {
        if (!entry)
            return;

        root.decodeQueue = root.decodeQueue.filter(id => id !== entry.id);

        root.decodingIds = root.decodingIds.filter(id => id !== entry.id);

        deleteProcess.command = ["sh", "-c", 'printf "%s\\t\\n" "$1" | cliphist delete', "sh", entry.id];

        deleteProcess.running = true;

        root.entries = root.entries.filter(item => item.id !== entry.id);

        root.updateFiltered();

        if (root.filteredEntries.length === 0) {
            root.selectedIndex = 0;
        } else if (root.selectedIndex >= root.filteredEntries.length) {
            root.selectedIndex = root.filteredEntries.length - 1;
        }
    }

    Process {
        id: listProcess

        command: ["cliphist", "list"]

        stdout: SplitParser {
            onRead: data => {
                const line = data.replace(/\r?\n$/, "");

                if (!line)
                    return;

                const separator = line.indexOf("\t");

                if (separator === -1)
                    return;

                const id = line.slice(0, separator);
                const preview = line.slice(separator + 1);

                const imageMatch = preview.match(/^\[\[\s*binary data\s+\d+\s*(?:KiB|MiB|GiB|bytes?)\s+(png|jpg|jpeg|bmp|webp|tiff?)\s+\d+x\d+\s*\]\]$/i);

                root.entries = root.entries.concat([
                    {
                        id: id,
                        preview: preview,
                        isImage: imageMatch !== null,
                        extension: imageMatch ? imageMatch[1].toLowerCase() : "",
                        cached: false
                    }
                ]);
            }
        }

        onRunningChanged: {
            if (running) {
                root.entries = [];
            } else {
                root.updateFiltered();
            }
        }
    }

    Process {
        id: decodeProcess

        property string currentId: ""

        onRunningChanged: {
            if (!running && currentId !== "") {
                const id = currentId;

                currentId = "";

                root.finishDecode(id);
            }
        }
    }

    Process {
        id: copyProcess
    }

    Process {
        id: deleteProcess

        onRunningChanged: {
            if (!running)
                root.refresh();
        }
    }
}
