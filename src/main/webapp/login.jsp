<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - SharkNet Messenger</title>

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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body class="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-dark-bg transition-colors duration-300 p-4">

    <div class="absolute top-6 right-6">
        <button onclick="toggleLoginTheme()" class="w-10 h-10 rounded-full bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border text-gray-600 dark:text-gray-300 flex items-center justify-center shadow-sm hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" title="Toggle Dark Mode">
            <i class="fas fa-moon dark:hidden"></i>
            <i class="fas fa-sun hidden dark:inline"></i>
        </button>
    </div>

    <div class="bg-white dark:bg-dark-card rounded-2xl shadow-xl w-full max-w-md p-8 border border-gray-200 dark:border-dark-border transition-colors duration-300 animate-[fadeIn_0.3s_ease-out]">

        <div class="text-center mb-8">
            <div class="w-16 h-16 bg-primary-500 text-white rounded-2xl flex items-center justify-center text-3xl mx-auto mb-4 shadow-lg">
                <i class="fas fa-water"></i>
            </div>
            <h1 class="text-2xl font-bold text-gray-900 dark:text-white font-mono tracking-tight">SharkNet</h1>
            <p class="text-gray-500 dark:text-gray-400 text-sm mt-2 font-medium">Decentralized P2P Communication</p>
        </div>

        <div id="error-message" class="hidden bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 p-3 rounded-lg text-sm mb-4 border border-red-200 dark:border-red-800/30 flex items-center gap-2"></div>
        <div id="success-message" class="hidden bg-green-50 dark:bg-green-900/20 text-green-600 dark:text-green-400 p-3 rounded-lg text-sm mb-4 border border-green-200 dark:border-green-800/30 flex items-center gap-2"></div>

        <div id="loading" class="hidden text-center py-6">
            <i class="fas fa-spinner fa-spin text-3xl text-primary-500 mb-3"></i>
            <div class="text-gray-500 dark:text-gray-400 text-sm font-medium">Processing request...</div>
        </div>

        <div id="existing-peer-form" class="login-form space-y-4">
            <div>
                <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Select Existing Peer</label>
                <div class="relative custom-dropdown">
                    <button type="button" onclick="toggleDropdown()" class="w-full flex justify-between items-center bg-gray-50 dark:bg-dark-bg border border-gray-300 dark:border-dark-border text-gray-900 dark:text-white px-4 py-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 transition-shadow">
                        <span id="selected-peer-text" class="truncate">-- Select a peer --</span>
                        <i class="fas fa-chevron-down text-gray-400 text-sm transition-transform duration-200" id="dropdown-arrow"></i>
                    </button>
                    <div id="peer-dropdown-options" class="hidden absolute z-50 w-full mt-2 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-lg shadow-xl max-h-48 overflow-y-auto">
                        </div>
                </div>
            </div>
            <button type="button" onclick="selectExistingPeer()" class="w-full bg-primary-500 hover:bg-primary-600 text-white font-bold py-3 px-4 rounded-lg transition-colors flex justify-center items-center gap-2 shadow-sm">
                <span>Continue</span> <i class="fas fa-arrow-right text-sm"></i>
            </button>
        </div>

        <div class="flex items-center my-6 login-form">
            <div class="flex-1 border-t border-gray-200 dark:border-dark-border"></div>
            <span class="px-3 text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider">OR</span>
            <div class="flex-1 border-t border-gray-200 dark:border-dark-border"></div>
        </div>

        <div id="new-peer-form" class="login-form space-y-4">
            <div>
                <label class="block text-sm font-bold text-gray-700 dark:text-gray-300 mb-2">Create New Peer</label>
                <input type="text" id="peer-name" placeholder="Enter peer name..." maxlength="50" class="w-full bg-gray-50 dark:bg-dark-bg border border-gray-300 dark:border-dark-border text-gray-900 dark:text-white px-4 py-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 transition-shadow placeholder-gray-400">
            </div>
            <button type="button" onclick="createNewPeer()" class="w-full bg-gray-800 hover:bg-gray-900 dark:bg-gray-700 dark:hover:bg-gray-600 text-white font-bold py-3 px-4 rounded-lg transition-colors shadow-sm flex justify-center items-center gap-2">
                <i class="fas fa-plus text-sm"></i> <span>Create New Peer</span>
            </button>
        </div>

        <div class="mt-6 text-center login-form">
            <button type="button" onclick="refreshPeers()" class="text-sm text-primary-500 hover:text-primary-600 dark:text-primary-400 dark:hover:text-primary-300 font-bold flex justify-center items-center gap-1.5 mx-auto transition-colors">
                <i class="fas fa-sync-alt"></i> Refresh Peer List
            </button>
        </div>

    </div>

    <script>
        // Check local storage for theme preference, or fallback to OS preference
        const savedTheme = localStorage.getItem('snm-theme');
        const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

        if (savedTheme === 'dark' || (!savedTheme && prefersDark)) {
            document.documentElement.classList.add('dark');
        }

        // Toggle Theme Function specific to Login Page
        function toggleLoginTheme() {
            document.documentElement.classList.toggle('dark');
            const isDark = document.documentElement.classList.contains('dark');
            localStorage.setItem('snm-theme', isDark ? 'dark' : 'light');
        }
    </script>
    <script src="js/login.js?v=3"></script>
</body>

</html>