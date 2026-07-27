/**
 * hub-connections.js - Hub Connections page logic.
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
 * Fetches hub connection counters from /api/peer/status/{peerId}
 * and updates the two summary stat boxes.
 * @return {void}
 */
function loadHubStatus() {
    if (!window.currentActivePeerId) return;

    fetch('/snm-webapp/api/peer/status/' + encodeURIComponent(window.currentActivePeerId))
        .then(r => { if (!r.ok) throw new Error('status ' + r.status); return r.json(); })
        .then(data => {
            const hubs = data.hubConnections || {};
            const set = (id, val) => {
                const el = document.getElementById(id);
                if (el) el.textContent = (val !== undefined && val !== null) ? val : '–';
            };
            set('hubs-connected-count', hubs.hubsConnected);
            set('hubs-failed-count', hubs.failedToConnect);
        })
        .catch(err => console.error('Error loading hub status:', err));
}

/**
 * Connects to a hub address (currently backed by the generic TCP connect API)
 * @return {void}
 */
function connectNewHub() {
    const address = document.getElementById('hubAddress').value.trim();
    const portVal = document.getElementById('hubPort').value.trim();

    if (!address || !portVal) {
        alert(tl("net.alert.address_port", "Please enter both address and port."));
        return;
    }

    fetch('/snm-webapp/api/tcp/connect', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            peerId: window.currentActivePeerId,
            host: address,
            port: parseInt(portVal)
        })
    }).then(r => {
        if (r.ok) return r.json();
        throw new Error("Connection failed");
    }).then(data => {
        alert(data.msg);
        document.getElementById('hubAddress').value = '';
        document.getElementById('hubPort').value = '';
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

/**
 * Renders the active hub connections table (backed by the TCP list API)
 * @return {void}
 */
function loadActiveHubs() {
    if (!window.currentActivePeerId) return;
    const tbody = document.getElementById('active-hubs-list');
    if (!tbody) return;

    fetch('/snm-webapp/api/tcp/list', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ peerId: window.currentActivePeerId })
    })
    .then(r => r.json())
    .then(data => {
        tbody.innerHTML = '';
        const connections = data.connections || [];

        connections.forEach(conn => {
            const tr = document.createElement('tr');
            tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
            tr.innerHTML = `
                <td class="px-6 py-4 font-mono font-medium">${escapeHtml(conn.remoteAddress)}:${conn.remotePort}</td>
                <td class="px-6 py-4">
                    <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs font-bold rounded-full">
                        <span class="w-1.5 h-1.5 rounded-full bg-green-500 inline-block"></span>${tl("net.status.connected", "Connected")}
                    </span>
                </td>
                <td class="px-6 py-4 text-right">
                    <button class="px-3 py-1.5 text-xs bg-white dark:bg-gray-800 border border-red-400 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-md transition-colors font-semibold" onclick="closePort(${conn.remotePort})">${tl("net.disconnect", "Disconnect")}</button>
                </td>
            `;
            tbody.appendChild(tr);
        });

        if (connections.length === 0) {
            tbody.innerHTML = `<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">${tl("net.no_conns", "No outgoing connections visible.")}</td></tr>`;
        }
    })
    .catch(err => console.error('loadActiveHubs error:', err));
}

/** Refreshes all data on this page */
function refreshAll() {
    loadActiveHubs();
    loadHubStatus();
}

// Initialize Data on Page Load
window.addEventListener('peerReady', () => refreshAll());

// Fallback execution check loops mapping contexts
setTimeout(() => { if (window.currentActivePeerId) refreshAll(); }, 500);

// Live monitoring: auto-refresh every 15 seconds
setInterval(() => { if (window.currentActivePeerId) refreshAll(); }, 15000);
