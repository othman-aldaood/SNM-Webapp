// settings.js - Settings page JavaScript (Tailwind Mobile Optimized)

let currentSettings = {};
let lastPeerStatusData = null;

// NOTE: `translations` is declared with `const` at the top level of i18n.js, so it
// lives in the shared global lexical scope, not as a `window` property - reference
// it directly (not via `window.translations`, which would always be undefined).
function tl(key, fallback) {
    const lang = localStorage.getItem('snm-lang') || 'en';
    return (typeof translations !== 'undefined' && translations[lang] && translations[lang][key]) ? translations[lang][key] : fallback;
}

function loadPeerStatus() {
    if (!window.currentActivePeerId) return;

    const peerId = encodeURIComponent(window.currentActivePeerId);

    fetch(`/snm-webapp/api/peer/status/${peerId}`)
        .then(response => {
            if (!response.ok) {
                return response.text().then(text => {
                    throw new Error(`Status ${response.status}: ${text}`);
                });
            }
            return response.json();
        })
        .then(data => {
            lastPeerStatusData = data;
            displayPeerStatus(data);
            displayPKIStatus(data.pkiStatus || {});
            displayNetworkStatus(data);
            loadApplicationSettings(data.appSettings || {});
        })
        .catch(err => {
            console.error('Failed to load peer status:', err);
            const content = document.getElementById('peer-status-content');
            if (content) {
                content.innerHTML = `<div class="text-red-500 text-center text-sm bg-red-50 dark:bg-red-900/20 p-3 rounded-lg border border-red-200 dark:border-red-800">${tl('settings.err.peer_status', 'Failed to load peer status:')} ${err.message}</div>`;
            }
        });
}

function displayPeerStatus(data) {
    const peerInfo = data.peerInfo || {};
    const content = document.getElementById('peer-status-content');
    if (!content) return;

    const activeBadge = peerInfo.active
        ? `<span class="px-2.5 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs font-bold rounded-full">${tl('common.active', 'Active')}</span>`
        : `<span class="px-2.5 py-0.5 bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300 text-xs font-bold rounded-full">${tl('common.inactive', 'Inactive')}</span>`;


    content.innerHTML = `
        <div class="flex flex-col gap-3 text-sm">
            <div class="flex flex-col sm:flex-row sm:justify-between items-start sm:items-center py-2 border-b border-gray-50 dark:border-gray-700/50 gap-1">
                <span class="text-gray-600 dark:text-gray-400 font-medium">${tl('settings.peer_name_label', 'Peer Name:')}</span>
                <span class="font-bold text-gray-900 dark:text-white break-all">${peerInfo.name || tl('common.unknown', 'Unknown')}</span>
            </div>
            <div class="flex flex-col sm:flex-row sm:justify-between items-start sm:items-center py-2 border-b border-gray-50 dark:border-gray-700/50 gap-1">
                <span class="text-gray-600 dark:text-gray-400 font-medium">${tl('settings.peer_id_label', 'Peer ID:')}</span>
                <span class="font-mono text-xs bg-gray-100 dark:bg-gray-900 text-gray-800 dark:text-gray-300 px-2 py-1 rounded break-all w-full sm:w-auto text-left sm:text-right mt-1 sm:mt-0">${peerInfo.id || tl('common.unknown', 'Unknown')}</span>
            </div>
            <div class="flex flex-col sm:flex-row sm:justify-between items-start sm:items-center py-2 gap-1">
                <span class="text-gray-600 dark:text-gray-400 font-medium">${tl('common.status', 'Status')}:</span>
                <div class="mt-1 sm:mt-0">${activeBadge}</div>
            </div>
        </div>
    `;
}

function displayPKIStatus(pkiStatus) {
    const content = document.getElementById('pki-status-content');
    if (!content) return;

    content.innerHTML = `
        <div class="flex flex-col gap-3 text-sm w-full">
            <div class="flex flex-col sm:flex-row sm:justify-between items-start sm:items-center py-2 border-b border-gray-50 dark:border-gray-700/50 gap-1">
                <span class="text-gray-600 dark:text-gray-400 font-medium">${tl('settings.known_persons_label', 'Known Persons:')}</span>
                <span class="font-bold text-gray-900 dark:text-white">${pkiStatus.persons || 0}</span>
            </div>
            <div class="flex flex-col sm:flex-row sm:justify-between items-start sm:items-center py-2 border-b border-gray-50 dark:border-gray-700/50 gap-1">
                <span class="text-gray-600 dark:text-gray-400 font-medium">${tl('settings.certificates_label', 'Certificates:')}</span>
                <span class="font-bold text-gray-900 dark:text-white">${pkiStatus.certificates || 0}</span>
            </div>
            <div class="flex flex-col py-2 gap-2 w-full">
                <span class="text-gray-600 dark:text-gray-400 font-medium">${tl('cert.f.pubkey', 'Public Key Fingerprint')}:</span>
                <span class="font-mono text-xs break-all bg-gray-100 dark:bg-gray-900 text-gray-700 dark:text-gray-300 p-2.5 rounded w-full border border-gray-200 dark:border-gray-800">${pkiStatus.publicKeyFingerprint || tl('cert.no_fingerprint', 'Not available')}</span>
            </div>
        </div>
    `;
}

function displayNetworkStatus(data) {
    const hubStatus = data.hubConnections || {};
    const encounterStatus = data.encounterStatus || {};
    const content = document.getElementById('network-status-content');
    if (!content) return;

    content.innerHTML = `
        <div class="flex flex-col gap-3 text-sm">
            <div class="flex flex-col sm:flex-row sm:justify-between items-start sm:items-center py-2 border-b border-gray-50 dark:border-gray-700/50 gap-1">
                <span class="text-gray-600 dark:text-gray-400 font-medium">${tl('settings.connected_hubs_label', 'Connected Hubs:')}</span>
                <span class="font-bold text-gray-900 dark:text-white">${hubStatus.hubsConnected || 0}</span>
            </div>
            <div class="flex flex-col sm:flex-row sm:justify-between items-start sm:items-center py-2 border-b border-gray-50 dark:border-gray-700/50 gap-1">
                <span class="text-gray-600 dark:text-gray-400 font-medium">${tl('settings.failed_hub_connections_label', 'Failed Hub Connections:')}</span>
                <span class="font-bold text-red-600 dark:text-red-400">${hubStatus.failedToConnect || 0}</span>
            </div>
            <div class="flex flex-col sm:flex-row sm:justify-between items-start sm:items-center py-2 gap-1">
                <span class="text-gray-600 dark:text-gray-400 font-medium">${tl('settings.encounters_tracked_label', 'Encounters Tracked:')}</span>
                <span class="font-bold text-gray-900 dark:text-white">${encounterStatus.encountersTracked || 0}</span>
            </div>
        </div>
    `;
}

function loadApplicationSettings(serverSettings) {
    const mockSettings = {defaultSign: true, defaultEncrypt: false, displayName: "SharkNet_User_01"};

    const rememberEl = document.getElementById('rememberNewHubConnections');
    if (rememberEl) rememberEl.checked = (serverSettings.rememberNewHubConnections !== undefined) ? serverSettings.rememberNewHubConnections : true;

    const reconnectEl = document.getElementById('hubReconnect');
    if (reconnectEl) reconnectEl.checked = (serverSettings.hubReconnect !== undefined) ? serverSettings.hubReconnect : true;

    const signEl = document.getElementById('defaultSignMsg');
    if (signEl) signEl.checked = mockSettings.defaultSign;

    const encEl = document.getElementById('defaultEncryptMsg');
    if (encEl) encEl.checked = mockSettings.defaultEncrypt;

    const nameEl = document.getElementById('customDisplayName');
    if (nameEl) nameEl.value = mockSettings.displayName;

    currentSettings = serverSettings;
}

async function saveSettings() {
    const settingsPayload = {
        defaultSign: document.getElementById('defaultSignMsg')?.checked || false,
        defaultEncrypt: document.getElementById('defaultEncryptMsg')?.checked || false,
        rememberNewHubConnections: document.getElementById('rememberNewHubConnections')?.checked || false,
        hubReconnect: document.getElementById('hubReconnect')?.checked || false,
        displayName: document.getElementById('customDisplayName')?.value || ""
    };

    alert(tl('settings.save_success', 'Settings successfully saved! (Note: Persistence requires backend API)'));
    currentSettings = settingsPayload;
}

// setLanguage() (i18n.js) only retranslates static [data-i18n] elements; the peer
// status / PKI status / network status cards are built from JS templates, so
// re-render them from the already-cached response on a live language switch.
document.addEventListener('snm:languagechange', function () {
    if (!lastPeerStatusData) return;
    displayPeerStatus(lastPeerStatusData);
    displayPKIStatus(lastPeerStatusData.pkiStatus || {});
    displayNetworkStatus(lastPeerStatusData);
});

window.addEventListener('peerReady', () => loadPeerStatus());
setTimeout(() => {
    if (window.currentActivePeerId) loadPeerStatus();
}, 500);
setInterval(() => {
    if (window.currentActivePeerId) loadPeerStatus();
}, 30000);