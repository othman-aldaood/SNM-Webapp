/**
 * encounters.js - Encounter Management page logic.
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
 * Formats a millisecond duration as a short human readable string, e.g. "5m 32s".
 * @param {number} ms - Duration in milliseconds
 * @return {string}
 */
function formatDuration(ms) {
    if (!ms || ms < 0) return '0s';
    const totalSec = Math.floor(ms / 1000);
    const h = Math.floor(totalSec / 3600);
    const m = Math.floor((totalSec % 3600) / 60);
    const s = totalSec % 60;
    if (h > 0) return `${h}h ${m}m`;
    if (m > 0) return `${m}m ${s}s`;
    return `${s}s`;
}

/**
 * Maps an encounter connection type (TCP/HUB/Ad-Hoc/Onion/Unknown) to badge color classes.
 * @param {string} type - Connection type label from /api/peer/status
 * @return {string} Tailwind classes
 */
function connectionTypeBadgeClasses(type) {
    switch (type) {
        case 'TCP': return 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400';
        case 'HUB': return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400';
        case 'Ad-Hoc': return 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400';
        case 'Onion': return 'bg-indigo-100 text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-400';
        default: return 'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400';
    }
}

/**
 * Renders the peer encounters table (peerID, connectionType, duration/ongoing).
 * @param {Array} encounters - encounters[] from /api/peer/status/{peerId}
 * @return {void}
 */
function renderEncounters(encounters) {
    const tbody = document.getElementById('encountersList');
    if (!tbody) return;

    if (!encounters || encounters.length === 0) {
        tbody.innerHTML = `<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">${tl('net.no_encounters', 'No peer encounters recorded yet.')}</td></tr>`;
        return;
    }

    tbody.innerHTML = '';
    encounters.forEach(enc => {
        const tr = document.createElement('tr');
        tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
        const isOngoing = enc.stopTime === undefined || enc.stopTime === null;
        const durationHtml = isOngoing
            ? `<span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs font-bold rounded-full"><span class="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse inline-block"></span>${tl('net.ongoing', 'Ongoing')}</span>`
            : `<span class="font-mono">${formatDuration(enc.stopTime - enc.startTime)}</span>`;

        tr.innerHTML = `
            <td class="px-6 py-4 font-mono font-medium">${escapeHtml(enc.peerID)}</td>
            <td class="px-6 py-4"><span class="px-2.5 py-0.5 text-xs font-bold rounded-full ${connectionTypeBadgeClasses(enc.connectionType)}">${escapeHtml(enc.connectionType)}</span></td>
            <td class="px-6 py-4">
                ${durationHtml}
                <div class="text-[0.7rem] text-gray-400 dark:text-gray-500 mt-1">${tl('net.started', 'Started')} ${netRelativeAge(enc.startTime)}</div>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

/**
 * Fetches peer status (encounter count + encounters[]) from /api/peer/status/{peerId}
 * and updates the stat widget + encounters table.
 * @return {void}
 */
function loadEncounterStatus() {
    if (!window.currentActivePeerId) return;

    fetch('/snm-webapp/api/peer/status/' + encodeURIComponent(window.currentActivePeerId))
        .then(r => { if (!r.ok) throw new Error('status ' + r.status); return r.json(); })
        .then(data => {
            const enc = (data.encounterStatus && data.encounterStatus.encountersTracked);
            const el = document.getElementById('encounters-count');
            if (el) el.textContent = (enc !== undefined && enc !== null) ? enc : '–';
            renderEncounters(data.encounters);
        })
        .catch(err => console.error('Error loading encounter status:', err));
}

/** Refreshes all data on this page */
function refreshAll() {
    loadEncounterStatus();
}

// Initialize Data on Page Load
window.addEventListener('peerReady', () => refreshAll());

// Fallback execution check loops mapping contexts
setTimeout(() => { if (window.currentActivePeerId) refreshAll(); }, 500);

// Live monitoring: auto-refresh every 15 seconds
setInterval(() => { if (window.currentActivePeerId) refreshAll(); }, 15000);
