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
 * Toggles the visibility of the sidebar menu.
 *
 * @return {void}
 */
function toggleSidebar() {
    const sidebar = document.getElementById('app-sidebar');
    if (sidebar) {
        sidebar.classList.toggle('hidden');
    }
}

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