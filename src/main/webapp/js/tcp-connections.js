/**
 * tcp-connections.js - TCP Connections page logic.
 * Split out of the former network.jsp (TCP/Hub tabs) so each network-related
 * page owns its own focused script, matching this app's per-page JS convention.
 */

/**
 * Global language helper function to fetch tokens safely inside dynamic nodes.
 * @param {string} key - Dictionary node key mapping context
 * @param {string} fallback - Literal safe default visualization return values boundary
 */
function tl(key, fallback) {
    // NOTE: i18n.js declares `translations` with `const` at script top-level, so it
    // lives in the shared global lexical scope, not as a `window` property - reference
    // it directly (not via `window.translations`, which is always undefined).
    const currentLang = localStorage.getItem('snm-lang') || 'en';
    return (typeof translations !== 'undefined' && translations[currentLang] && translations[currentLang][key]) ? translations[currentLang][key] : fallback;
}

/** Utility to prevent XSS in dynamically injected nodes */
function escapeHtml(text) {
    if (!text) return '';
    return text.toString()
        .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;").replace(/'/g, "&#039;");
}

/**
 * Human readable relative age from a millisecond timestamp.
 * @param {number} ms - Epoch milliseconds
 * @return {string} e.g. "14 min ago" ('' if invalid)
 */
function netRelativeAge(ms) {
    if (!ms || isNaN(ms)) return '';
    const diffSec = Math.max(0, Math.floor((Date.now() - Number(ms)) / 1000));
    if (diffSec < 60) return tl('time.now', 'now');
    if (diffSec < 3600) return Math.floor(diffSec / 60) + ' ' + tl('time.min', 'min ago');
    if (diffSec < 86400) return Math.floor(diffSec / 3600) + ' ' + tl('time.hr', 'h ago');
    return Math.floor(diffSec / 86400) + ' ' + tl('time.day', 'd ago');
}

/**
 * Fetches and refreshes the TCP network data (ports and connections)
 * @return {void}
 */
function refreshData() {
    if (!window.currentActivePeerId) return;
    const peerId = window.currentActivePeerId;

    fetch('/snm-webapp/api/tcp/list', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ peerId: peerId })
    })
    .then(r => r.json())
    .then(data => {
        // 1. Active Ports table
        const list = document.getElementById('activePortsList');
        list.innerHTML = "";

        if (data.openPorts && data.openPorts.length > 0) {
            data.openPorts.forEach(port => {
                const tr = document.createElement('tr');
                tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
                tr.innerHTML = `
                    <td class="px-6 py-4 font-mono font-medium">${port}</td>
                    <td class="px-6 py-4"><span class="px-2.5 py-0.5 bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400 text-xs font-bold rounded-full">${tl("net.status.listening", "Listening")}</span></td>
                    <td class="px-6 py-4 text-right">
                        <button class="px-3 py-1.5 text-xs bg-white dark:bg-gray-800 border border-red-400 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-md transition-colors font-semibold" onclick="closePort(${port})">${tl("common.close", "Close")}</button>
                    </td>
                `;
                list.appendChild(tr);
            });
        } else {
            list.innerHTML = `<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">${tl("net.no_ports", "No active TCP ports.")}</td></tr>`;
        }

        // 2. Established Connections table
        const connList = document.getElementById('activeConnectionsList');
        connList.innerHTML = "";

        if (data.connections && data.connections.length > 0) {
            data.connections.forEach(conn => {
                const tr = document.createElement('tr');
                tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
                tr.innerHTML = `
                    <td class="px-6 py-4">
                        <div class="flex items-center gap-3">
                            <div class="w-8 h-8 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center text-gray-500 dark:text-gray-400 flex-shrink-0">
                                <i class="fas fa-user text-xs"></i>
                            </div>
                            <span class="font-mono font-medium">${escapeHtml(conn.remoteAddress) || 'Unknown'}</span>
                        </div>
                    </td>
                    <td class="px-6 py-4 font-mono">${conn.remotePort || '-'}</td>
                    <td class="px-6 py-4">
                        <span class="px-2.5 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs font-bold rounded-full">${tl("net.status.connected", "Connected")}</span>
                        ${conn.timestamp ? `<div class="text-[0.7rem] text-gray-400 dark:text-gray-500 mt-1">${netRelativeAge(conn.timestamp)}</div>` : ''}
                    </td>
                    <td class="px-6 py-4 text-right">
                        <button class="px-3 py-1.5 text-xs bg-white dark:bg-gray-800 border border-red-400 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-md transition-colors font-semibold" onclick="closePort(${conn.remotePort})">${tl("net.disconnect", "Disconnect")}</button>
                    </td>
                `;
                connList.appendChild(tr);
            });
        } else {
            connList.innerHTML = `<tr><td colspan="4" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">${tl("net.no_conns", "No outgoing connections visible.")}</td></tr>`;
        }
    })
    .catch(err => console.error("Error refreshing network data:", err));
}

/**
 * Opens a new TCP port
 * @return {void}
 */
function openTcpPort() {
    const portInput = document.getElementById('newTcpPort');
    const port = portInput.value;
    if (!port) {
        alert(tl("net.alert.port", "Please enter a port number."));
        return;
    }

    fetch('/snm-webapp/api/tcp/open', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            peerId: window.currentActivePeerId,
            port: parseInt(port)
        })
    }).then(r => r.json()).then(data => {
        alert(data.msg);
        refreshAll();
    }).catch(err => {
        alert("Error opening port: " + err.message);
    });
}

/**
 * Connects to a remote peer via IP/Port
 * @return {void}
 */
function connectToPeer() {
    const host = document.getElementById('peerAddress').value;
    const port = document.getElementById('peerPort').value;

    if (!host || !port) {
        alert(tl("net.alert.address_port", "Please enter both address and port."));
        return;
    }

    fetch('/snm-webapp/api/tcp/connect', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            peerId: window.currentActivePeerId,
            host: host,
            port: parseInt(port)
        })
    }).then(r => {
        if (r.ok) return r.json();
        throw new Error("Connection failed");
    }).then(data => {
        alert(data.msg);
        refreshAll();
    }).catch(err => {
        alert(err.message);
    });
}

/**
 * Closes a currently listening port / connection
 * @param {number} port - The port number to close
 * @return {void}
 */
function closePort(port) {
    if (!confirm(tl("net.confirm.close", "Are you sure you want to close port ") + port + "?")) return;

    fetch('/snm-webapp/api/tcp/close', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ peerId: window.currentActivePeerId, port: port })
    }).then(r => r.json()).then(data => {
        alert(data.msg);
        refreshAll();
    }).catch(err => {
        alert("Error closing port: " + err.message);
    });
}

/** Refreshes all data on this page */
function refreshAll() {
    refreshData();
}

// Initialize Data on Page Load
window.addEventListener('peerReady', () => refreshAll());

// Fallback execution check loops mapping contexts
setTimeout(() => { if (window.currentActivePeerId) refreshAll(); }, 500);

// Live monitoring: auto-refresh every 15 seconds
setInterval(() => { if (window.currentActivePeerId) refreshAll(); }, 15000);
