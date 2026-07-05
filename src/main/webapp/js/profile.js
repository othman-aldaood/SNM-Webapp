/**
 * profile.js - Handles user profile interactions and dynamic data loading.
 * Separated from the view for better maintainability.
 */

/**
 * Fetches the PKI fingerprint dynamically via the backend API upon page load.
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

/**
 * Generates and downloads a JSON file containing the peer's identity data.
 * @return {void}
 */
function exportProfileData() {
    // Validate context existence
    if (!window.PROFILE_CONTEXT) {
        alert("Cannot export profile data. Context is missing.");
        return;
    }

    // Construct the payload mapping
    const peerData = {
        id: window.PROFILE_CONTEXT.peerId,
        name: window.PROFILE_CONTEXT.peerName,
        exportTimestamp: new Date().toISOString()
    };

    // Encode the JSON string into a downloadable data URI
    const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(peerData, null, 2));

    // Create a temporary anchor node to trigger the download process
    const downloadAnchorNode = document.createElement('a');
    downloadAnchorNode.setAttribute("href", dataStr);
    downloadAnchorNode.setAttribute("download", `SharkNet_Identity_${window.PROFILE_CONTEXT.peerName.replace(/\s+/g, '_')}.json`);

    document.body.appendChild(downloadAnchorNode); // Required for Firefox execution
    downloadAnchorNode.click();
    downloadAnchorNode.remove();
}