<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Settings - SharkNet</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>tailwind.config = { darkMode: 'class' }</script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">

    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "settings"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-6">
            <div class="max-w-4xl mx-auto space-y-6">

                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900 dark:text-white">Settings & Configuration</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400">Manage peer configuration and application settings.</p>
                    </div>
                    <button class="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded-lg font-medium shadow-sm transition-colors" onclick="saveSettings()">
                        <i class="fas fa-save mr-2"></i> Save Changes
                    </button>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 p-6 shadow-sm">
                    <h3 class="text-lg font-bold mb-4 border-b border-gray-100 dark:border-gray-700 pb-3">Peer Status</h3>
                    <div id="peer-status-content" class="space-y-3 text-sm">
                        <div class="animate-pulse text-gray-400">Loading peer status...</div>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 p-6 shadow-sm">
                    <h3 class="text-lg font-bold mb-6 border-b border-gray-100 dark:border-gray-700 pb-3">Application Settings</h3>

                    <div class="space-y-6">
                        <div>
                            <h4 class="font-semibold mb-3 text-gray-800 dark:text-gray-200">Message Defaults</h4>
                            <label class="flex items-center gap-3 cursor-pointer py-2">
                                <input type="checkbox" id="defaultSignMsg" class="w-4 h-4 text-blue-600 rounded">
                                <span>Sign messages by default</span>
                            </label>
                            <label class="flex items-center gap-3 cursor-pointer py-2">
                                <input type="checkbox" id="defaultEncryptMsg" class="w-4 h-4 text-blue-600 rounded">
                                <span>Encrypt messages by default</span>
                            </label>
                        </div>

                        <div>
                            <h4 class="font-semibold mb-3 text-gray-800 dark:text-gray-200">Hub Connection Settings</h4>
                            <label class="flex items-center gap-3 cursor-pointer py-2">
                                <input type="checkbox" id="rememberNewHubConnections" class="w-4 h-4 text-blue-600 rounded">
                                <span>Remember new hub connections</span>
                            </label>
                            <p class="text-xs text-gray-500 dark:text-gray-400 ml-7 mb-2">Automatically save and reconnect to previously used hub connections.</p>

                            <label class="flex items-center gap-3 cursor-pointer py-2">
                                <input type="checkbox" id="hubReconnect" class="w-4 h-4 text-blue-600 rounded">
                                <span>Enable hub reconnection</span>
                            </label>
                            <p class="text-xs text-gray-500 dark:text-gray-400 ml-7">Automatically attempt to reconnect to hubs when connection is lost.</p>
                        </div>

                        <div>
                            <h4 class="font-semibold mb-3 text-gray-800 dark:text-gray-200">Display Preferences</h4>
                            <label class="block text-sm mb-1 text-gray-700 dark:text-gray-300">Peer Display Name Customization</label>
                            <input type="text" id="customDisplayName" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none" placeholder="Enter custom display name...">
                        </div>
                    </div>
                </div>

                <div class="grid md:grid-cols-2 gap-6">
                    <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 p-6 shadow-sm">
                        <h3 class="text-lg font-bold mb-4 border-b border-gray-100 dark:border-gray-700 pb-3">PKI Status</h3>
                        <div id="pki-status-content" class="space-y-3 text-sm">
                            <div class="animate-pulse text-gray-400">Loading PKI status...</div>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 p-6 shadow-sm">
                        <h3 class="text-lg font-bold mb-4 border-b border-gray-100 dark:border-gray-700 pb-3">Network Status</h3>
                        <div id="network-status-content" class="space-y-3 text-sm">
                            <div class="animate-pulse text-gray-400">Loading network status...</div>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <script src="js/settings.js?v=3"></script>
    <script>
        // Update displayPeerStatus to use Tailwind badges
        function displayPeerStatus(data) {
            const peerInfo = data.peerInfo || {};
            const content = document.getElementById('peer-status-content');
            if (!content) return;

            content.innerHTML = `
                <div class="flex justify-between">
                    <span class="text-gray-500">Peer Name:</span>
                    <span class="font-bold">${escapeHtml(peerInfo.name || 'Unknown')}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Peer ID:</span>
                    <span class="font-mono text-xs bg-gray-100 dark:bg-gray-900 px-2 py-1 rounded">${peerInfo.id || 'Unknown'}</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-gray-500">Status:</span>
                    <span class="px-2 py-0.5 rounded-full text-xs font-bold ${peerInfo.active ? 'bg-green-100 text-green-700' : 'bg-gray-200 text-gray-700'}">
                        ${peerInfo.active ? 'Active' : 'Inactive'}
                    </span>
                </div>
            `;
        }
    </script>
</body>
</html>