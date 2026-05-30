<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%
    PeerRuntimeManager manager=PeerRuntimeManager.getInstance();
    PeerRuntime activePeer=manager.getActivePeer();
    String activePeerName=(activePeer !=null) ? activePeer.getPeerName() : "" ;
    String activePeerId=(activePeer !=null) ? activePeer.getPeerID().toString() : "" ;
%>

<!-- Tailwind CSS CDN & Configuration -->
<script src="https://cdn.tailwindcss.com"></script>
<script>
    tailwind.config = {
        darkMode: 'class',
        theme: {
            extend: {
                colors: {
                    primary: {
                        500: '#3b82f6',
                        600: '#2563eb',
                    },
                    dark: {
                        bg: '#0f172a',
                        card: '#1e293b',
                        border: '#334155'
                    }
                }
            }
        }
    }
</script>

<!-- FontAwesome CDN -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<header class="flex flex-wrap justify-between items-center bg-white dark:bg-dark-card border-b border-gray-200 dark:border-dark-border px-6 py-4 transition-colors duration-300">
    <!-- Brand & Sidebar Toggle -->
    <div class="flex items-center gap-4">
        <!-- Sidebar Toggle Button -->
        <button onclick="toggleSidebar()"
                class="text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 p-2 rounded-md transition-colors duration-200"
                title="Toggle Sidebar">
            <i class="fas fa-bars text-xl"></i>
        </button>

        <div class="bg-primary-500 text-white font-bold w-10 h-10 flex items-center justify-center rounded-lg text-xl shadow-md">
            <i class="fas fa-water"></i>
        </div>
        <span class="font-bold text-xl text-gray-800 dark:text-white font-mono hidden sm:block">SharkNet Messenger</span>
    </div>

    <!-- Status & Actions -->
    <div class="flex items-center gap-4">
        <div class="text-sm text-gray-600 dark:text-gray-300 hidden md:block">
            Active Peer: <span id="activePeerName" class="font-bold text-gray-900 dark:text-white"><%= activePeerName %></span>
        </div>
        <div class="text-sm text-gray-600 dark:text-gray-300 hidden sm:block">
            Peer Count: <span id="globalPeerCount" class="font-bold text-gray-900 dark:text-white">...</span>
        </div>
        <div class="text-sm text-gray-600 dark:text-gray-300 hidden sm:block">
            Network Mode: <span>Internet</span>
        </div>

        <!-- Theme Toggle Button -->
        <button id="themeToggleBtn" onclick="toggleTheme()"
                class="p-2 rounded-full border border-gray-300 dark:border-dark-border text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors duration-200 flex items-center justify-center w-10 h-10"
                title="Toggle Dark Mode">
            <i class="fas fa-moon"></i>
        </button>

        <!-- Logout Button -->
        <button onclick="logout()"
                class="bg-red-500 hover:bg-red-600 text-white px-4 py-2 rounded-md text-sm font-mono transition-colors duration-200 shadow-sm flex items-center gap-2"
                title="Logout and switch peer">
            <i class="fas fa-sign-out-alt"></i> Logout
        </button>
    </div>
</header>

<script>
    window.currentActivePeerId = '<%= activePeerId %>';
    fetch("/snm-webapp/api/peer").then(r => r.json()).then(peers => {
        document.getElementById('globalPeerCount').innerText = peers ? peers.length : 0;
        if (peers && peers.length > 0) {
            const activePeer = peers.find(p => p.active);
            if (activePeer) {
                window.currentActivePeerId = activePeer.peerId;
                document.getElementById('activePeerName').innerText = activePeer.name;
                window.dispatchEvent(new CustomEvent('peerReady', { detail: activePeer.peerId }));
            }
        }
    }).catch(() => {
        const el = document.getElementById('globalPeerCount');
        if (el) el.innerText = "Offline";
    });

    function logout() {
        if (confirm('Are you sure you want to logout? This will stop the active peer.')) {
            if (window.currentActivePeerId) {
                fetch(`/snm-webapp/api/stop/${window.currentActivePeerId}`, {
                    method: 'POST'
                }).then(() => {
                    window.location.href = '/snm-webapp/login.jsp';
                }).catch(() => {
                    window.location.href = '/snm-webapp/login.jsp';
                });
            } else {
                window.location.href = '/snm-webapp/login.jsp';
            }
        }
    }
</script>

<!-- Script for Dark Mode, Shortcuts & Sidebar -->
<script src="js/ui-ux.js?v=3"></script>