/**
 * certificates.js - Certificate & Identity Assurance Management (v5.0)
 * Redesigned UC4 layout: peers list + detail panel (IA score, SF, certificates).
 * Tailwind CSS, dark mode and i18n aware.
 */

let persons = [];
let certificates = [];
let pendingCredentials = [];
let ownPeerId = null;
let selectedPersonId = null;
let selectedCertIdx = 0;
let lastRefreshTime = 0;
const REFRESH_INTERVAL = 15000;

/* ------------------------------------------------------------------ */
/* Helpers                                                             */
/* ------------------------------------------------------------------ */

function tl(key, fallback) {
    // NOTE: i18n.js declares `translations` with `const` at script top-level, so it
    // lives in the shared global lexical scope, not as a `window` property - reference
    // it directly (not via `window.translations`, which is always undefined).
    const currentLang = localStorage.getItem('snm-lang') || 'en';
    return (typeof translations !== 'undefined' && translations[currentLang] && translations[currentLang][key]) ? translations[currentLang][key] : fallback;
}

function escapeHtml(text) {
    if (!text) return '';
    return text.toString()
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function formatCertificateDate(value, withTime) {
    if (value === undefined || value === null) return 'Unknown';
    const str = String(value).trim();
    let date;

    if (/^\-?\d+$/.test(str)) {
        date = new Date(Number(str));
    } else {
        date = new Date(str);
        if (isNaN(date.getTime())) {
            const scrubbed = str.replace(/\s[A-Z]{3,4}\s/, ' ');
            date = new Date(scrubbed);
        }
    }

    if (isNaN(date.getTime())) return 'Unknown';

    try {
        const options = withTime ?
            {day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit'} :
            {day: '2-digit', month: '2-digit', year: 'numeric'};
        return date.toLocaleDateString(undefined, options);
    } catch (e) {
        return 'Unknown';
    }
}

/* IA color helpers (score 0..10) */
function iaBarColor(score) {
    if (score >= 8) return 'bg-green-500';
    if (score >= 4) return 'bg-yellow-400';
    if (score > 0) return 'bg-orange-400';
    return 'bg-gray-300 dark:bg-gray-600';
}

function iaTextColor(score) {
    if (score >= 8) return 'text-green-600 dark:text-green-400';
    if (score >= 4) return 'text-yellow-600 dark:text-yellow-500';
    if (score > 0) return 'text-orange-500';
    return 'text-gray-500 dark:text-gray-400';
}

function iaBadgeClass(score) {
    if (score >= 8) return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400';
    if (score >= 4) return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-500';
    if (score > 0) return 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400';
    return 'bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-400';
}

function iaLabel(score) {
    if (score >= 10) return tl('cert.ia.verified', 'Verified by you');
    if (score >= 8) return tl('cert.ia.high', 'High');
    if (score >= 4) return tl('cert.ia.medium', 'Medium');
    if (score > 0) return tl('cert.ia.low', 'Low');
    return tl('cert.ia.unknown', 'Unknown');
}

/* Renders a 10-segment IA bar into the given element */
function renderIABar(el, score, small) {
    el.innerHTML = '';
    const h = small ? 'h-1.5' : 'h-2';
    for (let i = 1; i <= 10; i++) {
        const seg = document.createElement('span');
        seg.className = `flex-1 ${h} rounded-sm ${i <= score ? iaBarColor(score) : 'bg-gray-200 dark:bg-gray-700'}`;
        el.appendChild(seg);
    }
}

/* ------------------------------------------------------------------ */
/* Info-tip tooltips                                                   */
/* ------------------------------------------------------------------ */

// Tooltip is position:fixed (to escape ancestor overflow clipping), so its offsets must be computed here.
function positionInfoTip(tip) {
    const btn = tip.querySelector('.info-tip__btn');
    const tooltip = tip.querySelector('.info-tip__tooltip');
    if (!btn || !tooltip) return;

    const margin = 8;
    const gap = 9;
    const btnRect = btn.getBoundingClientRect();
    const tipRect = tooltip.getBoundingClientRect();

    let left = btnRect.left + btnRect.width / 2 - tipRect.width / 2;
    left = Math.max(margin, Math.min(left, window.innerWidth - tipRect.width - margin));

    let top = btnRect.top - tipRect.height - gap;
    let placement = 'top';
    if (top < margin) {
        top = btnRect.bottom + gap;
        placement = 'bottom';
    }

    const arrowLeft = btnRect.left + btnRect.width / 2 - left;
    tooltip.style.setProperty('--tip-left', left + 'px');
    tooltip.style.setProperty('--tip-top', top + 'px');
    tooltip.style.setProperty('--tip-arrow-left', arrowLeft + 'px');
    tooltip.setAttribute('data-placement', placement);
}

function initInfoTips() {
    const tips = document.querySelectorAll('.info-tip');
    tips.forEach(tip => {
        const btn = tip.querySelector('.info-tip__btn');
        if (!btn) return;
        const update = () => positionInfoTip(tip);
        btn.addEventListener('mouseenter', update);
        btn.addEventListener('focus', update);
    });

    const repositionOpenTip = () => {
        const open = document.querySelector('.info-tip:hover, .info-tip:focus-within');
        if (open) positionInfoTip(open);
    };
    window.addEventListener('scroll', repositionOpenTip, true);
    window.addEventListener('resize', repositionOpenTip);
}

/* ------------------------------------------------------------------ */
/* Language change reactivity                                          */
/* ------------------------------------------------------------------ */

// setLanguage() (i18n.js) only retranslates static [data-i18n] elements; the
// peers table, pending-credentials list and detail panel are built from JS
// templates, so re-render them from already-cached data on a live switch.
document.addEventListener('snm:languagechange', function () {
    renderPeers();
    displayPendingCredentials();
    if (selectedPersonId) selectPeer(selectedPersonId, true);
});

/* ------------------------------------------------------------------ */
/* Bootstrapping                                                       */
/* ------------------------------------------------------------------ */

document.addEventListener('DOMContentLoaded', function () {
    initInfoTips();
    loadAll();

    setInterval(() => {
        const now = Date.now();
        const anyModalOpen = ['import-modal', 'revoke-modal', 'confirm-modal'].some(id => {
            const el = document.getElementById(id);
            return el && !el.classList.contains('hidden');
        });

        if (!anyModalOpen && (now - lastRefreshTime >= REFRESH_INTERVAL)) {
            lastRefreshTime = now;
            loadAll(true);
        }
    }, 5000);
});

async function loadAll(silent = false) {
    try {
        await loadOwnPeer();
        await Promise.all([loadPersons(silent), loadCertificates(silent), loadPendingCredentials()]);
        renderPeers();
        // keep / initialise selection
        if (selectedPersonId && persons.some(p => p.id === selectedPersonId)) {
            selectPeer(selectedPersonId, true);
        } else if (persons.length > 0) {
            selectPeer(persons[0].id, true);
        }
    } catch (error) {
        console.error('Error loading PKI data:', error);
    }
}

async function loadOwnPeer() {
    try {
        const response = await fetch('/snm-webapp/api/peer');
        if (response.ok) {
            const peers = await response.json();
            const activePeer = peers.find(p => p.active);
            if (activePeer) {
                ownPeerId = activePeer.peerId;
                const el = document.getElementById('your-peer-id');
                if (el) el.textContent = activePeer.peerId;
            }
        }
    } catch (error) {
        console.error('Error loading own peer:', error);
    }
}

async function loadPersons(silent = false) {
    try {
        const response = await fetch('/snm-webapp/api/persons');
        if (!response.ok) throw new Error('Persons API not OK');
        const data = await response.json();
        persons = data.persons || [];
    } catch (error) {
        if (!silent) {
            const tbody = document.getElementById('peers-tbody');
            tbody.innerHTML = `<tr><td colspan="3" class="px-6 py-8 text-center text-red-500">${tl('common.error', 'Error')}: ${escapeHtml(error.message)}</td></tr>`;
        }
        persons = [];
    }
}

async function loadCertificates(silent = false) {
    try {
        if (!ownPeerId) return;
        const certResponse = await fetch(`/snm-webapp/api/pki/certificates?peerId=${encodeURIComponent(ownPeerId)}`);
        if (!certResponse.ok) throw new Error('Certificate API not OK');
        const certData = await certResponse.json();
        certificates = certData.certificates || [];
    } catch (error) {
        if (!silent) console.error('Error loading certificates:', error);
        certificates = [];
    }
}

/* ------------------------------------------------------------------ */
/* Peers list (left column)                                            */
/* ------------------------------------------------------------------ */

function latestCertFor(subjectId) {
    const certs = certificates.filter(c => (c.subject && c.subject.id) === subjectId);
    if (certs.length === 0) return null;
    certs.sort((a, b) => Number(b.validUntil || 0) - Number(a.validUntil || 0));
    return certs[0];
}

function renderPeers() {
    const tbody = document.getElementById('peers-tbody');

    if (persons.length === 0) {
        tbody.innerHTML = `<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">${tl('cert.no_peers', 'No peers known yet.')}</td></tr>`;
        return;
    }

    tbody.innerHTML = '';
    persons.forEach(p => {
        const ia = (p.identityAssurance && p.identityAssurance.value) || 0;
        const cert = latestCertFor(p.id);
        const validUntil = cert ? formatCertificateDate(cert.validUntil, false) : '—';
        const name = escapeHtml(p.name || tl('common.unknown', 'Unknown'));
        const id = escapeHtml(p.id || '');
        const isSelected = p.id === selectedPersonId;

        const tr = document.createElement('tr');
        tr.dataset.personId = p.id;
        tr.className = `cursor-pointer transition-colors ${isSelected ? 'bg-blue-50 dark:bg-blue-900/20' : 'hover:bg-gray-50 dark:hover:bg-gray-700/50'}`;
        tr.onclick = () => selectPeer(p.id);

        tr.innerHTML = `
            <td class="px-4 md:px-6 py-3.5">
                <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center text-gray-500 dark:text-gray-400 flex-shrink-0 font-semibold text-xs">${name.charAt(0).toUpperCase()}</div>
                    <div class="min-w-0">
                        <div class="font-semibold text-gray-900 dark:text-white truncate">${name}</div>
                        <div class="font-mono text-xs text-gray-500 dark:text-gray-400 truncate max-w-[140px]" title="${id}">${id}</div>
                    </div>
                </div>
            </td>
            <td class="px-4 md:px-6 py-3.5">
                <div class="flex items-center gap-2.5">
                    <div class="flex gap-0.5 w-24 flex-shrink-0" id="ia-bar-${cssSafe(p.id)}"></div>
                    <span class="font-mono text-sm font-bold ${iaTextColor(ia)}">${ia}</span>
                </div>
            </td>
            <td class="px-4 md:px-6 py-3.5 font-mono text-xs text-gray-600 dark:text-gray-300 whitespace-nowrap">${validUntil}</td>
        `;
        tbody.appendChild(tr);
        renderIABar(document.getElementById(`ia-bar-${cssSafe(p.id)}`), ia, true);
    });
}

function cssSafe(id) {
    return String(id).replace(/[^a-zA-Z0-9_-]/g, '_');
}

function filterPeers() {
    const searchTerm = document.getElementById('peer-search').value.toLowerCase();
    document.querySelectorAll('#peers-tbody tr').forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

/* ------------------------------------------------------------------ */
/* Detail panel (right column)                                         */
/* ------------------------------------------------------------------ */

function selectPeer(personId, keepCertIdx = false) {
    const p = persons.find(x => x.id === personId);
    if (!p) return;

    selectedPersonId = personId;
    if (!keepCertIdx) selectedCertIdx = 0;

    // highlight row
    document.querySelectorAll('#peers-tbody tr').forEach(row => {
        const active = row.dataset.personId === personId;
        row.className = `cursor-pointer transition-colors ${active ? 'bg-blue-50 dark:bg-blue-900/20' : 'hover:bg-gray-50 dark:hover:bg-gray-700/50'}`;
    });

    document.getElementById('detail-empty').style.display = 'none';
    const content = document.getElementById('detail-content');
    content.classList.remove('hidden');
    content.style.display = 'flex';

    const ia = (p.identityAssurance && p.identityAssurance.value) || 0;
    const iaText = (p.identityAssurance && p.identityAssurance.explanation) || '';
    const name = p.name || tl('common.unknown', 'Unknown');

    document.getElementById('detail-avatar').textContent = name.charAt(0).toUpperCase();
    document.getElementById('detail-name').textContent = name;
    document.getElementById('detail-peerid').textContent = p.id || '';

    const scoreEl = document.getElementById('detail-score-num');
    scoreEl.textContent = `${ia}/10`;
    scoreEl.className = `font-mono text-xl font-bold ${iaTextColor(ia)}`;

    renderIABar(document.getElementById('detail-bar'), ia, false);

    const badge = document.getElementById('detail-label-badge');
    badge.textContent = iaLabel(ia);
    badge.className = `inline-flex px-2.5 py-0.5 rounded-full text-xs font-semibold ${iaBadgeClass(ia)}`;
    document.getElementById('detail-label-desc').textContent = iaText;

    const sf = (p.signingFailureRate !== undefined && p.signingFailureRate !== null) ? p.signingFailureRate : '—';
    document.getElementById('detail-sf').textContent = `${sf}/10`;

    renderCertCard();
}

function renderCertCard() {
    const certs = certificates.filter(c => (c.subject && c.subject.id) === selectedPersonId);
    const selector = document.getElementById('cert-selector');
    const body = document.getElementById('cert-body');
    const none = document.getElementById('cert-none');

    selector.innerHTML = '';

    if (certs.length === 0) {
        body.classList.add('hidden');
        none.classList.remove('hidden');
        return;
    }

    body.classList.remove('hidden');
    none.classList.add('hidden');

    if (selectedCertIdx >= certs.length) selectedCertIdx = 0;

    // selector chips (only when several certificates exist)
    if (certs.length > 1) {
        certs.forEach((c, i) => {
            const btn = document.createElement('button');
            btn.textContent = i + 1;
            btn.className = `w-6 h-6 rounded-md text-xs font-bold transition-colors ${i === selectedCertIdx
                ? 'bg-blue-600 text-white'
                : 'bg-gray-200 text-gray-600 dark:bg-gray-700 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-600'}`;
            btn.onclick = () => { selectedCertIdx = i; renderCertCard(); };
            selector.appendChild(btn);
        });
    }

    const cert = certs[selectedCertIdx];
    const subjectName = cert.subject?.name || tl('common.unknown', 'Unknown');
    const subjectId = cert.subject?.id || tl('common.unknown', 'Unknown');
    const issuerName = cert.issuedBy?.name || tl('common.unknown', 'Unknown');
    const issuerId = cert.issuedBy?.id || tl('common.unknown', 'Unknown');

    document.getElementById('cert-subject-name').textContent = subjectName;
    document.getElementById('cert-subject-id').textContent = subjectId;
    document.getElementById('cert-issuer-name').textContent = issuerName;
    document.getElementById('cert-issuer-id').textContent = issuerId;
    document.getElementById('cert-issuer-badge').classList.toggle('hidden', !(ownPeerId && issuerId === ownPeerId));
    document.getElementById('cert-valid-from').textContent = formatCertificateDate(cert.validSince, false);
    document.getElementById('cert-valid-until').textContent = formatCertificateDate(cert.validUntil, false);
    document.getElementById('cert-fingerprint').textContent = cert.publicKeyFingerprint || tl('cert.no_fingerprint', 'Not available');

    document.getElementById('cert-revoke-btn').onclick = () => showRevokeModal(subjectId, subjectName);
}

/* ------------------------------------------------------------------ */
/* Pending credentials                                                 */
/* ------------------------------------------------------------------ */

async function loadPendingCredentials() {
    try {
        const response = await fetch('/snm-webapp/api/pki/pendingCredentials');
        if (response.ok) {
            const data = await response.json();
            pendingCredentials = data.pendingCredentials || [];
            displayPendingCredentials();
        }
    } catch (error) {
        console.error('Error loading pending credentials:', error);
    }
}

function displayPendingCredentials() {
    const container = document.getElementById('pending-credentials-container');
    const countBadge = document.getElementById('pending-count');

    countBadge.textContent = pendingCredentials.length;

    if (pendingCredentials.length === 0) {
        container.innerHTML = `<div class="text-gray-500 dark:text-gray-400 text-sm italic py-2 text-center">${tl('cert.no_pending', 'No pending credential requests')}</div>`;
        return;
    }

    container.innerHTML = '';
    pendingCredentials.forEach((cred, index) => {
        const name = escapeHtml(cred.credential?.name || tl('cert.unknown_sender', 'Unknown Sender'));
        const id = escapeHtml(cred.credential?.id || '');

        const credDiv = document.createElement('div');
        credDiv.className = 'bg-white dark:bg-gray-800 border border-amber-200 dark:border-amber-500/30 rounded-lg p-3.5 flex flex-col sm:flex-row sm:items-center justify-between gap-3';

        credDiv.innerHTML = `
            <div class="flex items-center gap-3 min-w-0">
                <div class="w-9 h-9 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center text-gray-500 dark:text-gray-400 flex-shrink-0">
                    <i class="fas fa-user text-sm"></i>
                </div>
                <div class="min-w-0">
                    <div class="font-semibold text-sm text-gray-900 dark:text-white truncate">${name}</div>
                    <div class="font-mono text-xs text-gray-500 dark:text-gray-400 truncate">${id}</div>
                </div>
            </div>
            <div class="flex gap-2 flex-shrink-0 w-full sm:w-auto">
                <button class="flex-1 sm:flex-none bg-green-600 hover:bg-green-700 text-white px-4 py-1.5 rounded-md text-sm font-semibold transition-colors" onclick="confirmAcceptCredential(${index})">${tl('cert.accept', 'Accept')}</button>
                <button class="flex-1 sm:flex-none bg-white dark:bg-gray-800 border border-red-400 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 px-4 py-1.5 rounded-md text-sm font-semibold transition-colors" onclick="refuseCredential(${index})">${tl('cert.decline', 'Decline')}</button>
            </div>
        `;
        container.appendChild(credDiv);
    });
}

function confirmAcceptCredential(index) {
    const cred = pendingCredentials[index];
    const name = cred?.credential?.name || tl('cert.this_peer', 'this peer');
    openConfirmModal({
        title: tl('cert.confirm.accept_title', 'Accept credential?'),
        message: tl('cert.confirm.accept_msg', 'By accepting you certify that this key really belongs to') + ' "' + name + '". ' + tl('cert.confirm.accept_msg2', 'Other peers may rely on your judgment.'),
        confirmLabel: tl('cert.accept', 'Accept'),
        onConfirm: () => acceptCredential(index)
    });
}

async function acceptCredential(index) {
    try {
        const cred = pendingCredentials[index];
        const response = await fetch(`/snm-webapp/api/pki/pendingCredentials/accept?index=${cred.index}`, {method: 'POST'});
        if (response.ok) {
            await loadAll();
        } else {
            throw new Error('Failed to accept credential');
        }
    } catch (error) {
        alert(tl('cert.err.accept', 'Error accepting credential:') + ' ' + error.message);
    }
}

async function refuseCredential(index) {
    try {
        const cred = pendingCredentials[index];
        const response = await fetch(`/snm-webapp/api/pki/pendingCredentials/refuse?index=${cred.index}`, {method: 'POST'});
        if (response.ok) {
            await loadPendingCredentials();
        } else {
            throw new Error('Failed to refuse credential');
        }
    } catch (error) {
        alert(tl('cert.err.refuse', 'Error refusing credential:') + ' ' + error.message);
    }
}

/* ------------------------------------------------------------------ */
/* Actions & modals                                                    */
/* ------------------------------------------------------------------ */

function exportOwnCertificate() {
    if (ownPeerId) {
        navigator.clipboard.writeText(`SharkNet Peer ID: ${ownPeerId}`).then(() => {
            alert(tl('cert.peerid_copied', 'Peer ID copied to clipboard!'));
        });
    }
}

async function sendCredentials() {
    const peerName = document.getElementById('import-peer-name').value.trim();
    try {
        const response = await fetch(`/snm-webapp/api/pki/sendCredentials?targetPeerId=${encodeURIComponent(peerName)}`, {method: 'POST'});
        if (response.ok) {
            hideImportModal();
            document.getElementById('import-peer-name').value = '';
            document.getElementById('import-message').value = '';
            alert(tl('cert.send_success', 'Credentials sent successfully!'));
        } else {
            throw new Error('Failed to send credentials');
        }
    } catch (error) {
        alert(tl('cert.err.send', 'Error sending credentials:') + ' ' + error.message);
    }
}

async function revokeCertificate() {
    const subjectId = document.getElementById('revoke-subject-id').value;
    try {
        const response = await fetch(`/snm-webapp/api/pki/revokeCertificate?subjectId=${encodeURIComponent(subjectId)}`, {method: 'POST'});
        if (response.ok) {
            hideRevokeModal();
            await loadAll();
        } else {
            throw new Error('Failed to revoke certificate');
        }
    } catch (error) {
        alert(tl('cert.err.revoke', 'Error revoking certificate:') + ' ' + error.message);
    }
}

/* Generic confirmation modal for trust-changing actions */
let _confirmCallback = null;

function openConfirmModal({title, message, confirmLabel, onConfirm}) {
    document.getElementById('cm-title').textContent = title;
    document.getElementById('cm-message').textContent = message;
    const btn = document.getElementById('cm-confirm-btn');
    btn.textContent = confirmLabel;
    _confirmCallback = onConfirm;
    btn.onclick = () => {
        closeConfirmModal();
        if (_confirmCallback) _confirmCallback();
    };
    document.getElementById('confirm-modal').classList.remove('hidden');
}

function closeConfirmModal() {
    document.getElementById('confirm-modal').classList.add('hidden');
}

function showImportModal() {
    document.getElementById('import-modal').classList.remove('hidden');
}

function hideImportModal() {
    document.getElementById('import-modal').classList.add('hidden');
}

function showRevokeModal(id, name) {
    document.getElementById('revoke-subject-id').value = id;
    document.getElementById('revoke-subject-name').value = name;
    document.getElementById('revoke-modal').classList.remove('hidden');
}

function hideRevokeModal() {
    document.getElementById('revoke-modal').classList.add('hidden');
    document.getElementById('revoke-subject-id').value = '';
    document.getElementById('revoke-subject-name').value = '';
}

window.onclick = function (event) {
    if (event.target === document.getElementById('import-modal')) hideImportModal();
    if (event.target === document.getElementById('revoke-modal')) hideRevokeModal();
    if (event.target === document.getElementById('confirm-modal')) closeConfirmModal();
}
