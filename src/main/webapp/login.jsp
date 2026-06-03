<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html lang="en">

<ui:head title="Login - SharkNet Messenger"/>

<body class="min-h-screen flex items-center justify-center transition-colors duration-300 p-4 relative overflow-hidden">

    <div id="vanta-bg" class="absolute inset-0 z-0"></div>

    <div class="absolute top-6 right-6 z-20">
        <button onclick="toggleLoginTheme()" class="w-10 h-10 rounded-full bg-white/80 dark:bg-dark-card/80 backdrop-blur-md border border-gray-200 dark:border-dark-border text-gray-600 dark:text-gray-300 flex items-center justify-center shadow-sm hover:bg-white dark:hover:bg-gray-800 transition-colors" title="Toggle Dark Mode">
            <i class="fas fa-moon dark:hidden"></i>
            <i class="fas fa-sun hidden dark:inline"></i>
        </button>
    </div>

    <div class="relative z-10 bg-white/85 dark:bg-dark-card/85 backdrop-blur-xl rounded-2xl shadow-2xl w-full max-w-md p-8 border border-white/50 dark:border-white/10 transition-colors duration-300 animate-[fadeIn_0.3s_ease-out]">

        <div class="text-center mb-8">
            <div class="w-16 h-16 bg-primary-500 text-white rounded-2xl flex items-center justify-center text-3xl mx-auto mb-4 shadow-lg">
                <i class="fas fa-water"></i>
            </div>
            <h1 class="text-2xl font-bold text-gray-900 dark:text-white font-mono tracking-tight">SharkNet</h1>
            <p class="text-gray-500 dark:text-gray-400 text-sm mt-2 font-medium">Decentralized P2P Communication</p>
        </div>

        <div id="error-message" class="hidden bg-red-50 dark:bg-red-900/40 text-red-600 dark:text-red-400 p-3 rounded-lg text-sm mb-4 border border-red-200 dark:border-red-800/50 flex items-center gap-2"></div>
        <div id="success-message" class="hidden bg-green-50 dark:bg-green-900/40 text-green-600 dark:text-green-400 p-3 rounded-lg text-sm mb-4 border border-green-200 dark:border-green-800/50 flex items-center gap-2"></div>

        <div id="loading" class="hidden text-center py-6">
            <i class="fas fa-spinner fa-spin text-3xl text-primary-500 mb-3"></i>
            <div class="text-gray-500 dark:text-gray-400 text-sm font-medium">Processing request...</div>
        </div>

        <div id="existing-peer-form" class="login-form space-y-4">
            <div>
                <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Select Existing Peer</label>

                <div class="relative custom-dropdown">
                    <button type="button" onclick="toggleDropdown()" class="w-full flex justify-between items-center bg-gray-50/80 dark:bg-dark-bg/80 border border-gray-300 dark:border-dark-border text-gray-900 dark:text-white px-4 py-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 transition-shadow backdrop-blur-sm">
                        <span id="selected-peer-text" class="truncate">-- Select a peer --</span>
                        <i class="fas fa-chevron-down text-gray-400 text-sm transition-transform duration-200" id="dropdown-arrow"></i>
                    </button>
                    <div id="peer-dropdown-options" class="hidden absolute z-50 w-full mt-2 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-lg shadow-xl max-h-48 overflow-y-auto backdrop-blur-md">
                    </div>
                </div>
            </div>

            <ui:button text="Continue" theme="primary" size="lg" icon="fas fa-arrow-right" onClick="selectExistingPeer()" cssClass="w-full font-bold" />
        </div>

        <div class="flex items-center my-6 login-form">
            <div class="flex-1 border-t border-gray-200 dark:border-dark-border"></div>
            <span class="px-3 text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider">OR</span>
            <div class="flex-1 border-t border-gray-200 dark:border-dark-border"></div>
        </div>

        <div id="new-peer-form" class="login-form space-y-4">
            <div>
                <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Create New Peer</label>
                <input type="text" id="peer-name" placeholder="Enter peer name..." maxlength="50" class="w-full bg-gray-50/80 dark:bg-dark-bg/80 border border-gray-300 dark:border-dark-border text-gray-900 dark:text-white px-4 py-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 transition-shadow placeholder-gray-400 backdrop-blur-sm">
            </div>

            <ui:button text="Create New Peer" theme="primary" size="lg" icon="fas fa-plus" onClick="createNewPeer()" cssClass="w-full font-bold !bg-gray-800 hover:!bg-gray-900 dark:!bg-gray-700 dark:hover:!bg-gray-600 !border-transparent" />
        </div>

        <div class="mt-6 text-center login-form">
            <ui:button text="Refresh Peer List" theme="transparent" icon="fas fa-sync-alt" onClick="refreshPeers()" cssClass="font-bold mx-auto" />
        </div>

    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r134/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/vanta@latest/dist/vanta.net.min.js"></script>

    <script>
        const savedTheme = localStorage.getItem('snm-theme');
        const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
        let isDarkTheme = savedTheme === 'dark' || (!savedTheme && prefersDark);

        if (isDarkTheme) {
            document.documentElement.classList.add('dark');
        }

        let vantaEffect = null;

        function initVanta(isDark) {
            if (vantaEffect) {
                vantaEffect.destroy();
            }
            if (typeof VANTA !== 'undefined') {
                vantaEffect = VANTA.NET({
                    el: "#vanta-bg",
                    mouseControls: true,
                    touchControls: true,
                    gyroControls: false,
                    minHeight: 200.00,
                    minWidth: 200.00,
                    scale: 1.00,
                    scaleMobile: 1.00,
                    color: isDark ? 0x60a5fa : 0x2563eb,
                    backgroundColor: isDark ? 0x0f172a : 0xf0f9ff,
                    points: 13.00,
                    maxDistance: 22.00,
                    spacing: 18.00,
                    showDots: true
                });
            }
        }

        document.addEventListener('DOMContentLoaded', () => {
            initVanta(isDarkTheme);
        });

        function toggleLoginTheme() {
            document.documentElement.classList.toggle('dark');
            isDarkTheme = document.documentElement.classList.contains('dark');
            localStorage.setItem('snm-theme', isDarkTheme ? 'dark' : 'light');
            initVanta(isDarkTheme);
        }
    </script>

    <script src="js/login.js?v=5"></script>
</body>
</html>