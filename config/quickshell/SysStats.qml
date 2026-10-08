// CPU and memory load, read straight from /proc every two seconds.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: stats

    property real cpu: 0      // 0..1, busy share since the last sample
    property real memory: 0   // 0..1, (MemTotal - MemAvailable) / MemTotal

    property real lastTotal: 0
    property real lastIdle: 0

    FileView {
        id: procStat
        path: "/proc/stat"
        onLoaded: {
            // cpu  user nice system idle iowait irq softirq steal ...
            const fields = text().split("\n")[0].trim().split(/\s+/).slice(1, 9).map(Number);
            const total = fields.reduce((a, b) => a + b, 0);
            const idle = fields[3] + fields[4];
            const dTotal = total - stats.lastTotal;
            if (stats.lastTotal > 0 && dTotal > 0)
                stats.cpu = Math.max(0, Math.min(1, 1 - (idle - stats.lastIdle) / dTotal));
            stats.lastTotal = total;
            stats.lastIdle = idle;
        }
    }

    FileView {
        id: procMeminfo
        path: "/proc/meminfo"
        onLoaded: {
            const kb = key => {
                const m = text().match(new RegExp("^" + key + ":\\s+(\\d+)", "m"));
                return m ? Number(m[1]) : 0;
            };
            const total = kb("MemTotal");
            if (total > 0)
                stats.memory = Math.max(0, Math.min(1, (total - kb("MemAvailable")) / total));
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            procStat.reload();
            procMeminfo.reload();
        }
    }
}
