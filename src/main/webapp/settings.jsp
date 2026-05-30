<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - SharkNet</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = { darkMode: 'class' }
    </script>
</head>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "settings"); %>
        <jsp:include page="sidebar.jsp" />

        <div class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-4xl mx-auto space-y-4 md:space-y-6">

                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 md:mb-6 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold">Settings & Configuration</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Manage peer configuration and application settings.</p>
                    </div>
                    <div class="w-full sm:w-auto">
                        <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2.5 px-5 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="saveSettings()">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">
                        <h3 class="text-lg font-bold">Peer Status</h3>
                    </div>
                    <div id="peer-status-content">
                        <div class="animate-pulse text-gray-500 dark:text-gray-400 text-sm">Loading peer status...</div>
                    </div>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4 md:mb-6">
                        <h3 class="text-lg font-bold">Application Settings</h3>
                    </div>

                    <h4 class="font-semibold text-base mb-4 text-gray-800 dark:text-gray-200">Message Defaults</h4>
                    <div class="space-y-4 mb-6">
                        <label class="inline-flex items-center cursor-pointer">
                            <input type="checkbox" id="defaultSignMsg" class="sr-only peer">
                            <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600 shrink-0"></div>
                            <span class="ms-3 text-sm sm:text-base font-medium text-gray-700 dark:text-gray-300">Sign messages by default</span>
                        </label>
                        <br> <label class="inline-flex items-center cursor-pointer mt-2">
                            <input type="checkbox" id="defaultEncryptMsg" class="sr-only peer">
                            <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600 shrink-0"></div>
                            <span class="ms-3 text-sm sm:text-base font-medium text-gray-700 dark:text-gray-300">Encrypt messages by default</span>
                        </label>
                    </div>

                    <hr class="border-gray-100 dark:border-gray-700 my-6">

                    <h4 class="font-semibold text-base mb-4 text-gray-800 dark:text-gray-200">Hub Connection Settings</h4>
                    <div class="space-y-5 mb-6">
                        <div>
                            <label class="inline-flex items-center cursor-pointer">
                                <input type="checkbox" id="rememberNewHubConnections" class="sr-only peer">
                                <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600 shrink-0"></div>
                                <span class="ms-3 text-sm sm:text-base font-medium text-gray-700 dark:text-gray-300">Remember new hub connections</span>
                            </label>
                            <div class="text-xs sm:text-sm text-gray-500 dark:text-gray-400 ml-14 mt-1">
                                Automatically save and reconnect to previously used hub connections.
                            </div>
                        </div>

                        <div>
                            <label class="inline-flex items-center cursor-pointer">
                                <input type="checkbox" id="hubReconnect" class="sr-only peer">
                                <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600 shrink-0"></div>
                                <span class="ms-3 text-sm sm:text-base font-medium text-gray-700 dark:text-gray-300">Enable hub reconnection</span>
                            </label>
                            <div class="text-xs sm:text-sm text-gray-500 dark:text-gray-400 ml-14 mt-1">
                                Automatically attempt to reconnect to hubs when connection is lost.
                            </div>
                        </div>
                    </div>

                    <hr class="border-gray-100 dark:border-gray-700 my-6">

                    <h4 class="font-semibold text-base mb-3 text-gray-800 dark:text-gray-200">Display Preferences</h4>
                    <div class="mb-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Peer Display Name Customization</label>
                        <input type="text" id="customDisplayName" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="Enter custom display name...">
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6 w-full overflow-hidden">
                        <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">
                            <h3 class="text-lg font-bold">PKI Status</h3>
                        </div>
                        <div id="pki-status-content" class="w-full">
                            <div class="animate-pulse text-gray-500 dark:text-gray-400 text-sm">Loading PKI status...</div>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6 w-full overflow-hidden">
                        <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">
                            <h3 class="text-lg font-bold">Network Status</h3>
                        </div>
                        <div id="network-status-content" class="w-full">
                            <div class="animate-pulse text-gray-500 dark:text-gray-400 text-sm">Loading network status...</div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script src="js/settings.js?v=6"></script>
</body>

</html>