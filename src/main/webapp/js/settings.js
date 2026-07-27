// settings.js - Settings page JavaScript (Tailwind Mobile Optimized)

let currentSettings = {};

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
            loadApplicationSettings(data.appSettings || {});
        })
        .catch(err => {
            console.error('Failed to load peer status:', err);
        });
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

window.addEventListener('peerReady', () => loadPeerStatus());
setTimeout(() => {
    if (window.currentActivePeerId) loadPeerStatus();
}, 500);
setInterval(() => {
    if (window.currentActivePeerId) loadPeerStatus();
}, 30000);