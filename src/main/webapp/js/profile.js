/**
 * profile.js - Handles user profile interactions and dynamic data loading.
 * Separated from the view for better maintainability.
 */

// NOTE: `translations` is declared with `const` at the top level of i18n.js, so it
// lives in the shared global lexical scope, not as a `window` property - reference
// it directly (not via `window.translations`, which would always be undefined).
function tl(key, fallback) {
    const lang = localStorage.getItem('snm-lang') || 'en';
    return (typeof translations !== 'undefined' && translations[lang] && translations[lang][key]) ? translations[lang][key] : fallback;
}

// Cached so the Active/Inactive badge (built from a translated string, unlike the raw
// peer name) can be re-rendered on a live language switch without re-fetching.
let lastPeerInfo = null;

/**
 * Renders the Active/Inactive status badge from the last fetched peer info.
 * @return {void}
 */
function renderProfileStatusBadge() {
    const statusEl = document.getElementById('profile-status-badge');
    if (!statusEl || !lastPeerInfo) return;

    statusEl.innerHTML = lastPeerInfo.active
        ? `<span class="px-2.5 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs font-bold rounded-full">${tl('common.active', 'Active')}</span>`
        : `<span class="px-2.5 py-0.5 bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300 text-xs font-bold rounded-full">${tl('common.inactive', 'Inactive')}</span>`;
}

/**
 * Fetches peer name/status/PKI fingerprint dynamically via the backend API upon page load.
 * Relies on the globally injected window.PROFILE_CONTEXT from the JSP.
 * @return {void}
 */
document.addEventListener('DOMContentLoaded', () => {
    // Ensure the context was properly injected by the JSP
    if (!window.PROFILE_CONTEXT || !window.PROFILE_CONTEXT.peerId) {
        console.error("Profile context is missing. Cannot fetch PKI status.");
        return;
    }

    const currentPeerId = encodeURIComponent(window.PROFILE_CONTEXT.peerId);

    fetch(`/snm-webapp/api/peer/status/${currentPeerId}`)
        .then(res => res.ok ? res.json() : Promise.reject('Failed to fetch PKI'))
        .then(data => {
            const peerInfo = data.peerInfo || {};
            lastPeerInfo = peerInfo;

            const nameEl = document.getElementById('profile-peer-name');
            if (nameEl) {
                nameEl.textContent = peerInfo.name || tl('common.unknown', 'Unknown');
                // Drop the placeholder's data-i18n binding now that real content is set - otherwise
                // a later setLanguage() call (i18n.js re-scans every [data-i18n] element) would
                // stomp this back to "Loading...".
                nameEl.removeAttribute('data-i18n');
            }

            renderProfileStatusBadge();

            const el = document.getElementById('profile-fingerprint');
            if (el && data.pkiStatus && data.pkiStatus.publicKeyFingerprint) {
                el.innerHTML = `
                    <div class="flex items-center justify-between">
                        <span class="truncate pr-2">${data.pkiStatus.publicKeyFingerprint}</span>
                        <i class="fas fa-copy text-gray-400 group-hover:text-primary-500 transition-colors"></i>
                    </div>`;
                // Store the raw value as a data attribute for copying
                el.setAttribute('data-fingerprint', data.pkiStatus.publicKeyFingerprint);
            }
        })
        .catch(err => console.error("PKI Fetch Error:", err));
});

// setLanguage() (i18n.js) only retranslates static [data-i18n] elements; the status
// badge is built from a JS template, so re-render it from the cached response on a
// live language switch.
document.addEventListener('snm:languagechange', renderProfileStatusBadge);

/**
 * Copies the PKI fingerprint to the user's clipboard when clicked.
 * @return {void}
 */
function copyFingerprint() {
    const el = document.getElementById('profile-fingerprint');
    if (!el) return;

    const val = el.getAttribute('data-fingerprint');
    if (val) {
        navigator.clipboard.writeText(val)
            .then(() => alert("Fingerprint copied to clipboard!"))
            .catch(err => console.error("Failed to copy text: ", err));
    }
}
