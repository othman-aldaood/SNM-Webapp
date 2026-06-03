<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%
    PeerRuntimeManager headerManager = PeerRuntimeManager.getInstance();
    PeerRuntime headerActivePeer = headerManager.getActivePeer();

    String activePeerName = (headerActivePeer != null) ? headerActivePeer.getPeerName() : "";
    String activePeerId = (headerActivePeer != null) ? headerActivePeer.getPeerID().toString() : "";

    // Redirect to login if no active peer is found
    if (headerActivePeer == null) {
        response.sendRedirect("login.jsp");
        return;
    }
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

<!-- Sticky Header fixed to h-16 (64px) -->
<header class="sticky top-0 z-50 w-full h-16 backdrop-blur-md bg-white/80 dark:bg-dark-card/80 border-b border-gray-200 dark:border-dark-border px-4 sm:px-6 transition-colors duration-300 shadow-sm flex items-center justify-between">
    
    <!-- Left: Toggle & Brand -->
    <div class="flex items-center gap-3 sm:gap-4">
        <button onclick="toggleSidebar()" class="text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 p-2 rounded-lg transition-colors focus:outline-none" title="Toggle Sidebar">
            <i class="fas fa-bars text-xl"></i>
        </button>
        <div class="bg-gradient-to-br from-primary-500 to-blue-700 text-white font-bold w-9 h-9 sm:w-10 sm:h-10 flex items-center justify-center rounded-lg text-lg sm:text-xl shadow-md">
            <i class="fas fa-water"></i>
        </div>
        <span class="font-bold text-lg sm:text-xl text-gray-800 dark:text-white font-mono hidden sm:block tracking-tight">SharkNet</span>
    </div>

    <!-- Right: Status, Help, Theme, Logout -->
    <div class="flex items-center gap-2 sm:gap-4">
        <div class="hidden lg:flex items-center gap-2 border-r border-gray-200 dark:border-gray-700 pr-4">
            <div class="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-full bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 border border-blue-100 dark:border-blue-800/50 shadow-sm" title="Active Peer">
                <i class="fas fa-user-circle text-sm"></i> <span id="activePeerName"><%= activePeerName %></span>
            </div>
            <div class="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-full bg-green-50 text-green-700 dark:bg-green-900/30 dark:text-green-400 border border-green-100 dark:border-green-800/50 shadow-sm" title="Network Mode">
                <i class="fas fa-globe text-sm"></i> Internet
            </div>
            <div class="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-full bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300 border border-gray-200 dark:border-gray-700 shadow-sm" title="Online Peers Count">
                <i class="fas fa-users text-sm"></i> <span id="globalPeerCount">...</span>
            </div>
        </div>

        <a href="welcome.jsp" class="flex items-center gap-2 text-gray-500 hover:text-primary-600 dark:text-gray-400 dark:hover:text-primary-400 hover:bg-gray-100 dark:hover:bg-gray-800 px-3 py-2 rounded-lg transition-colors font-medium text-sm" title="Help & Welcome Page">
            <i class="fas fa-question-circle text-lg"></i>
            <span class="hidden md:block">Help</span>
        </a>

        <button id="themeToggleBtn" onclick="toggleTheme()" class="text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 p-2 rounded-lg transition-colors flex items-center justify-center w-9 h-9 sm:w-10 sm:h-10 focus:outline-none" title="Toggle Dark Mode">
            <i class="fas fa-moon text-lg"></i>
        </button>

        <!-- Updated Logout Button to trigger the Modal -->
        <button onclick="showLogoutModal()" class="bg-red-50 hover:bg-red-100 dark:bg-red-900/20 dark:hover:bg-red-900/40 text-red-600 dark:text-red-400 border border-red-200 dark:border-red-800/50 px-3 py-2 sm:px-4 rounded-lg text-sm font-medium transition-colors shadow-sm flex items-center gap-2" title="Logout">
            <i class="fas fa-sign-out-alt"></i>
            <span class="hidden sm:block">Logout</span>
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
            <h3 class="text-xl font-bold text-gray-900 dark:text-white mb-2">Confirm Logout</h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">
                Are you sure you want to log out? This will stop the active peer and redirect you to the login screen.
            </p>
        </div>

        <div class="p-4 border-t border-gray-200 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 flex justify-center gap-3">
            <button onclick="hideLogoutModal()" class="px-5 py-2 border border-gray-300 dark:border-dark-border rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 font-medium transition-colors w-full">
                Cancel
            </button>
            <button id="confirm-logout-btn" onclick="confirmLogout()" class="px-5 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg font-medium shadow-sm transition-colors w-full flex items-center justify-center gap-2">
                <i class="fas fa-sign-out-alt"></i> Logout
            </button>
        </div>
    </div>
</div>

<script>
    window.currentActivePeerId = '<%= activePeerId %>';
</script>

<script src="js/ui-ux.js?v=6"></script>