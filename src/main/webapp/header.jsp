<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%
    /**
     * Resolves the active peer session and extracts identity details for the header UI.
     */
    PeerRuntimeManager headerManager = PeerRuntimeManager.getInstance();
    PeerRuntime headerActivePeer = headerManager.getActivePeer();

    if (headerActivePeer == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String activePeerName = headerActivePeer.getPeerName();
    String activePeerId = headerActivePeer.getPeerID().toString();
%>

<!-- Tailwind CSS CDN & Configuration -->
<script src="https://cdn.tailwindcss.com"></script>
<script>
    tailwind.config = {
        darkMode: 'class',
        theme: {
            extend: {
                colors: {
                    primary: { 500: '#3b82f6', 600: '#2563eb' },
                    dark: { bg: '#0f172a', card: '#1e293b', border: '#334155' }
                }
            }
        }
    }
</script>

<!-- FontAwesome CDN -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">

<!-- Sticky Header -->
<header class="sticky top-0 z-50 w-full h-16 backdrop-blur-md bg-white/80 dark:bg-dark-card/80 border-b border-gray-200 dark:border-dark-border px-4 sm:px-6 transition-colors duration-300 shadow-sm flex items-center justify-between">

    <div class="flex items-center gap-3 sm:gap-4">
        <button onclick="toggleSidebar()" class="text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 p-2 rounded-lg transition-colors focus:outline-none" title="Toggle Sidebar">
            <i class="fas fa-bars text-xl"></i>
        </button>
        <div class="bg-gradient-to-br from-primary-500 to-blue-700 text-white font-bold w-9 h-9 sm:w-10 sm:h-10 flex items-center justify-center rounded-lg text-lg sm:text-xl shadow-md">
            <i class="fas fa-water"></i>
        </div>
        <span class="font-bold text-lg sm:text-xl text-gray-800 dark:text-white font-mono hidden sm:block tracking-tight">SharkNet</span>
    </div>

    <div class="flex items-center gap-2 sm:gap-4">
        <div class="hidden lg:flex items-center gap-2 border-r border-gray-200 dark:border-gray-700 pr-4">

            <!-- Profile Link -->
            <a href="profile.jsp" class="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-full bg-blue-50 hover:bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:hover:bg-blue-900/50 dark:text-blue-400 border border-blue-100 dark:border-blue-800/50 shadow-sm transition-colors cursor-pointer" title="View Profile">
                <i class="fas fa-user-circle text-sm"></i> <span id="activePeerName"><%= activePeerName %></span>
            </a>

            <div class="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-full bg-green-50 text-green-700 dark:bg-green-900/30 dark:text-green-400 border border-green-100 dark:border-green-800/50 shadow-sm">
                <i class="fas fa-globe text-sm"></i> <span data-i18n="header.internet">Internet</span>
            </div>
            <div class="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-full bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300 border border-gray-200 dark:border-gray-700 shadow-sm">
                <i class="fas fa-users text-sm"></i> <span id="globalPeerCount">...</span>
            </div>
        </div>

        <!-- Mobile Profile Link -->
        <a href="profile.jsp" class="lg:hidden flex items-center justify-center text-gray-500 hover:text-primary-600 dark:text-gray-400 dark:hover:text-primary-400 hover:bg-gray-100 dark:hover:bg-gray-800 p-2 rounded-lg transition-colors w-9 h-9 sm:w-10 sm:h-10 focus:outline-none" title="My Profile">
            <i class="fas fa-id-card text-lg"></i>
        </a>

        <!-- I18N Language Switcher Dropdown -->
        <div class="relative">
            <button onclick="toggleLangDropdown()" class="text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 p-2 rounded-lg transition-colors flex items-center justify-center w-9 h-9 sm:w-10 sm:h-10 focus:outline-none" title="Language / Sprache">
                <i id="lang-icon" class="fas fa-globe text-lg"></i>
            </button>
            <div id="lang-dropdown" class="hidden absolute right-0 mt-2 w-32 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-lg shadow-xl z-50 overflow-hidden">
                <button onclick="setLanguage('en'); toggleLangDropdown()" class="w-full text-left px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 flex items-center gap-2">🇬🇧 English</button>
                <button onclick="setLanguage('de'); toggleLangDropdown()" class="w-full text-left px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 flex items-center gap-2">🇩🇪 Deutsch</button>
                <button onclick="setLanguage('tr'); toggleLangDropdown()" class="w-full text-left px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 flex items-center gap-2">🇹🇷 Türkçe</button>
                <button onclick="setLanguage('ar'); toggleLangDropdown()" class="w-full text-left px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 flex items-center gap-2">🇸🇦 العربية</button>
            </div>
        </div>

        <button id="themeToggleBtn" onclick="toggleTheme()" class="text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 p-2 rounded-lg transition-colors flex items-center justify-center w-9 h-9 sm:w-10 sm:h-10 focus:outline-none">
            <i class="fas fa-moon text-lg"></i>
        </button>

        <button onclick="showLogoutModal()" class="bg-red-50 hover:bg-red-100 dark:bg-red-900/20 dark:hover:bg-red-900/40 text-red-600 dark:text-red-400 border border-red-200 dark:border-red-800/50 px-3 py-2 sm:px-4 rounded-lg text-sm font-medium transition-colors shadow-sm flex items-center gap-2">
            <i class="fas fa-sign-out-alt"></i>
            <span class="hidden sm:block" data-i18n="header.logout">Logout</span>
        </button>
    </div>
</header>

<!-- Custom Tailwind Logout Modal -->
<div id="logout-modal" class="fixed inset-0 z-[100] bg-gray-900/50 backdrop-blur-sm hidden items-center justify-center p-4 opacity-0 transition-opacity duration-300">
    <div class="bg-white dark:bg-dark-card w-full max-w-sm rounded-xl shadow-2xl border border-gray-200 dark:border-dark-border flex flex-col overflow-hidden transform scale-95 transition-transform duration-300" onclick="event.stopPropagation()">
        <div class="p-6 text-center">
            <div class="w-16 h-16 rounded-full bg-red-100 dark:bg-red-900/30 text-red-500 mx-auto flex items-center justify-center text-3xl mb-4 shadow-sm">
                <i class="fas fa-sign-out-alt"></i>
            </div>
            <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2" data-i18n="header.logout_confirm">Confirm Logout</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400" data-i18n="header.logout_desc">
                Are you sure you want to log out?<br>This will stop the active peer and redirect you to the login screen.
            </p>
        </div>
        <div class="p-4 border-t border-gray-200 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 flex justify-center gap-3">
            <button onclick="hideLogoutModal()" class="px-5 py-2 border border-gray-300 dark:border-dark-border rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 font-medium transition-colors w-full" data-i18n="common.cancel">Cancel</button>
            <button id="confirm-logout-btn" onclick="confirmLogout()" class="px-5 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg font-medium shadow-sm transition-colors w-full flex items-center justify-center gap-2">
                <i class="fas fa-sign-out-alt"></i> <span data-i18n="header.logout">Logout</span>
            </button>
        </div>
    </div>
</div>

<script>
    window.currentActivePeerId = '<%= activePeerId %>';

    /**
     * Toggles the language dropdown visibility in the header.
     * @return {void}
     */
    function toggleLangDropdown() {
        const dropdown = document.getElementById('lang-dropdown');
        if(dropdown) {
            dropdown.classList.toggle('hidden');
        }
    }

    // Close language dropdown when clicking outside
    document.addEventListener('click', function(event) {
        const dropdown = document.getElementById('lang-dropdown');
        const btn = event.target.closest('button[title="Language / Sprache"]');
        if (dropdown && !dropdown.classList.contains('hidden') && !btn && !event.target.closest('#lang-dropdown')) {
            dropdown.classList.add('hidden');
        }
    });
</script>
<script src="js/ui-ux.js?v=6"></script>
<script src="js/i18n.js?v=5"></script>