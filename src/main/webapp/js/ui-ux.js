/**
 * ui-ux.js - Handles global User Experience enhancements
 * Features: Dark Mode Toggle, Keyboard Shortcuts, Sidebar Toggle
 */

/**
 * Initializes the application theme based on stored preference or OS level settings.
 *
 * @return {void}
 */
function initTheme() {
    const savedTheme = localStorage.getItem('snm-theme');
    const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    const themeToSet = savedTheme || (prefersDark ? 'dark' : 'light');

    applyTheme(themeToSet);
}

/**
 * Toggles the current theme and saves the preference to localStorage.
 *
 * @return {void}
 */
function toggleTheme() {
    const isDark = document.documentElement.classList.contains('dark');
    const newTheme = isDark ? 'light' : 'dark';

    applyTheme(newTheme);
    localStorage.setItem('snm-theme', newTheme);
}

/**
 * Applies the CSS classes and updates the FontAwesome toggle icon.
 *
 * @param {string} theme - The theme to apply ('dark' or 'light')
 * @return {void}
 */
function applyTheme(theme) {
    const btnIcon = document.querySelector('#themeToggleBtn i');

    if (theme === 'dark') {
        document.documentElement.classList.add('dark');
        if (btnIcon) {
            btnIcon.classList.remove('fa-moon');
            btnIcon.classList.add('fa-sun');
        }
    } else {
        document.documentElement.classList.remove('dark');
        if (btnIcon) {
            btnIcon.classList.remove('fa-sun');
            btnIcon.classList.add('fa-moon');
        }
    }
}

/**
 * Toggles the sidebar visibility with a smooth slide animation.
 * On mobile: Slides completely in and out of the screen.
 * On desktop: Smoothly collapses width to show icons only (w-20) or expands to full width (w-64).
 *
 * @return {void}
 */
function toggleSidebar() {
    const sidebar = document.getElementById('app-sidebar');
    const texts = document.querySelectorAll('.sidebar-text');

    if (!sidebar) return;

    const isMobile = window.innerWidth < 768; // 768px is the 'md' breakpoint in Tailwind

    if (isMobile) {
        // Mobile behavior: Slide in / Slide out completely
        sidebar.classList.toggle('-translate-x-full');

        // Ensure it's full width and texts are visible when opened on mobile
        sidebar.classList.remove('md:w-20');
        sidebar.classList.add('md:w-64');
        texts.forEach(text => {
            text.style.display = 'block';
            setTimeout(() => text.style.opacity = '1', 10);
        });
    } else {
        // Desktop behavior: Collapse / Expand width
        sidebar.classList.toggle('md:w-64');
        sidebar.classList.toggle('md:w-20'); // w-20 = 80px (Centers the icon perfectly)

        const isCollapsed = sidebar.classList.contains('md:w-20');

        texts.forEach(text => {
            if (isCollapsed) {
                // Fade out text, then hide it so it doesn't take space
                text.style.opacity = '0';
                setTimeout(() => {
                    text.style.display = 'none';
                }, 200);
            } else {
                // Display text, then fade it in smoothly
                text.style.display = 'block';
                setTimeout(() => {
                    text.style.opacity = '1';
                }, 10);
            }
        });
    }
}

// Optional: Reset sidebar state correctly if user resizes the browser window
window.addEventListener('resize', () => {
    const sidebar = document.getElementById('app-sidebar');
    if (!sidebar) return;

    if (window.innerWidth >= 768) {
        // Ensure it's not pushed off-screen on desktop
        sidebar.classList.remove('-translate-x-full');
    }
});
// Global Keyboard Shortcuts Event Listener
document.addEventListener('keydown', (e) => {
    // [Ctrl + K] or [Cmd + K] => Global Search Focus
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        const searchBar = document.querySelector('.search-bar');
        if (searchBar) {
            searchBar.focus();
        }
    }
});

// Run initialization immediately on script load
initTheme();

// ==========================================
// Header & Network Status Logic
// ==========================================

document.addEventListener('DOMContentLoaded', () => {
    const globalPeerCountEl = document.getElementById('globalPeerCount');
    const activePeerNameEl = document.getElementById('activePeerName');

    // Fetch network status for header
    if (globalPeerCountEl) {
        fetch("/snm-webapp/api/peer")
            .then(r => r.json())
            .then(peers => {
                globalPeerCountEl.innerText = peers ? peers.length : 0;
                if (peers && peers.length > 0) {
                    const activePeer = peers.find(p => p.active);
                    if (activePeer) {
                        window.currentActivePeerId = activePeer.peerId;
                        if (activePeerNameEl) activePeerNameEl.innerText = activePeer.name;
                        window.dispatchEvent(new CustomEvent('peerReady', {detail: activePeer.peerId}));
                    }
                }
            })
            .catch(() => {
                globalPeerCountEl.innerText = "Offline";
            });
    }

    renderStatusUI();
});

document.addEventListener('snm:languagechange', renderStatusUI);

// ==========================================
// Presence Status (Active / Away / DND / Invisible) + Lock
// ==========================================
// Stored in localStorage (no backend endpoint exists yet for peer presence
// settings) so status/lock survive reloads and stay in sync across every
// page via the shared header markup this file already drives.

const STATUS_KEY = 'snm-status';
const STATUS_LOCK_KEY = 'snm-status-locked';
const VALID_STATUSES = ['active', 'away', 'dnd', 'invisible'];
const STATUS_DOT_CLASSES = {
    active: 'bg-green-500',
    away: 'bg-yellow-500',
    dnd: 'bg-red-500',
    invisible: 'bg-gray-400'
};
const STATUS_I18N_KEYS = {
    active: 'status.active',
    away: 'status.away',
    dnd: 'status.dnd',
    invisible: 'status.invisible'
};
const ALL_STATUS_DOT_CLASSES = Object.values(STATUS_DOT_CLASSES);

/**
 * Local i18n lookup mirroring the t()/tl() helpers used elsewhere - kept local
 * since this file loads before i18n.js but only ever calls this from
 * event-driven code (after both scripts have executed).
 * @param {string} key - Dictionary translation key
 * @param {string} fallback - Default text if no translation is found
 * @return {string}
 */
function statusT(key, fallback) {
    const lang = localStorage.getItem('snm-lang') || 'en';
    return (typeof translations !== 'undefined' && translations[lang] && translations[lang][key]) ? translations[lang][key] : fallback;
}

/**
 * Reads the currently stored presence status, defaulting to 'active'.
 * @return {string}
 */
function getPeerStatus() {
    const s = localStorage.getItem(STATUS_KEY);
    return VALID_STATUSES.includes(s) ? s : 'active';
}

/**
 * Whether the status is locked against automatic (system-driven) changes.
 * @return {boolean}
 */
function isStatusLocked() {
    return localStorage.getItem(STATUS_LOCK_KEY) === 'true';
}

/**
 * Sets the peer's presence status and re-renders every status indicator/selector
 * present on the current page (header dot + dropdown, profile page selector).
 * @param {string} status - one of VALID_STATUSES
 * @param {Object} [opts]
 * @param {boolean} [opts.auto=false] - true for automatic/system-driven changes
 *   (e.g. idle detection). Automatic changes are ignored while locked; manual
 *   changes (the user explicitly picking a status) always go through.
 * @return {void}
 */
function setPeerStatus(status, opts) {
    opts = opts || {};
    if (!VALID_STATUSES.includes(status)) return;
    if (opts.auto && isStatusLocked()) return;
    localStorage.setItem(STATUS_KEY, status);
    renderStatusUI();
}

/**
 * Locks/unlocks the status against automatic changes, and re-renders.
 * @param {boolean} locked
 * @return {void}
 */
function setStatusLocked(locked) {
    localStorage.setItem(STATUS_LOCK_KEY, locked ? 'true' : 'false');
    renderStatusUI();
}

/**
 * Re-renders every status dot, option list, and lock toggle present in the
 * current DOM (header + profile page share the same class/data hooks).
 * @return {void}
 */
function renderStatusUI() {
    const status = getPeerStatus();
    const locked = isStatusLocked();
    const dotClass = STATUS_DOT_CLASSES[status] || STATUS_DOT_CLASSES.active;
    const label = statusT(STATUS_I18N_KEYS[status], status);

    document.querySelectorAll('.status-indicator-dot').forEach(el => {
        el.classList.remove(...ALL_STATUS_DOT_CLASSES);
        el.classList.add(dotClass);
        el.title = label;
    });

    document.querySelectorAll('.status-option').forEach(btn => {
        const isActive = btn.dataset.status === status;
        btn.classList.toggle('bg-gray-100', isActive);
        btn.classList.toggle('dark:bg-gray-800', isActive);
        btn.classList.toggle('ring-1', isActive);
        btn.classList.toggle('ring-primary-500', isActive);
    });

    document.querySelectorAll('.status-lock-checkbox').forEach(cb => {
        cb.checked = locked;
    });
}

/**
 * Idle-based auto-away: after 5 minutes without mouse/keyboard/touch activity,
 * automatically switches to 'away' (unless the status is locked). Restores
 * 'active' on the next interaction, but only if this script is the one that
 * set 'away' in the first place - a manually chosen 'away'/'dnd'/'invisible'
 * status is left alone.
 * @return {void}
 */
function initIdleAutoAway() {
    const IDLE_MS = 5 * 60 * 1000;
    let idleTimer = null;
    let autoAway = false;

    function scheduleIdle() {
        clearTimeout(idleTimer);
        idleTimer = setTimeout(() => {
            if (getPeerStatus() === 'active') {
                autoAway = true;
                setPeerStatus('away', {auto: true});
            }
        }, IDLE_MS);
    }

    ['mousemove', 'keydown', 'click', 'touchstart'].forEach(evt => {
        document.addEventListener(evt, () => {
            if (autoAway && getPeerStatus() === 'away') {
                autoAway = false;
                setPeerStatus('active', {auto: true});
            }
            scheduleIdle();
        }, {passive: true});
    });

    scheduleIdle();
}

initIdleAutoAway();

// ==========================================
// Custom Logout Modal Logic
// ==========================================

/**
 * Displays the custom logout confirmation modal with a fade-in animation.
 */
function showLogoutModal() {
    const modal = document.getElementById('logout-modal');
    if (modal) {
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        setTimeout(() => {
            modal.classList.remove('opacity-0');
            modal.querySelector('div').classList.remove('scale-95');
            modal.querySelector('div').classList.add('scale-100');
        }, 10);
    }
}

/**
 * Hides the custom logout confirmation modal with a fade-out animation.
 */
function hideLogoutModal() {
    const modal = document.getElementById('logout-modal');
    if (modal) {
        modal.classList.add('opacity-0');
        modal.querySelector('div').classList.remove('scale-100');
        modal.querySelector('div').classList.add('scale-95');
        setTimeout(() => {
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }, 300);
    }
}

/**
 * Executes the logout logic, stops the active peer via the backend API,
 * and redirects the user to the login page.
 */
function confirmLogout() {
    const logoutBtn = document.getElementById('confirm-logout-btn');
    if (logoutBtn) {
        logoutBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Logging out...';
        logoutBtn.disabled = true;
    }

    if (window.currentActivePeerId) {
        fetch(`/snm-webapp/api/stop/${window.currentActivePeerId}`, {method: 'POST'})
            .then(() => window.location.href = '/snm-webapp/login.jsp')
            .catch(() => window.location.href = '/snm-webapp/login.jsp');
    } else {
        window.location.href = '/snm-webapp/login.jsp';
    }
}

// Close modal when clicking outside the modal content
document.addEventListener('click', function (e) {
    const modal = document.getElementById('logout-modal');
    if (modal && !modal.classList.contains('hidden') && e.target === modal) {
        hideLogoutModal();
    }
});