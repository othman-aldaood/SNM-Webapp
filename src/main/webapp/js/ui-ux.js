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
});

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