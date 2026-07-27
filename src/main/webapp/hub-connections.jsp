<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%
    /**
     * Resolve active identity runtime session from management framework boundaries.
     */
    PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    PeerRuntime activePeer = manager.getActivePeer();

    if (activePeer == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<ui:head title="Hub Connections - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "hubs"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-5xl mx-auto space-y-4 md:space-y-6">

                <%-- Page Top Header Action Bar --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold font-mono" data-i18n="hubconn.title">Hub Connections</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="hubconn.desc">Connect to ASAP hub routers for background data synchronization.</p>
                    </div>
                    <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="refreshAll()">
                        <i class="fas fa-sync-alt"></i> <span data-i18n="net.refresh">Refresh Network</span>
                    </button>
                </div>

                <%-- Hub connection counters, split in two (data from /api/peer/status) --%>
                <div class="grid grid-cols-2 gap-4 md:gap-6">
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-green-50 dark:bg-green-900/30 text-green-600 dark:text-green-400 flex items-center justify-center flex-shrink-0">
                            <i class="fas fa-link"></i>
                        </div>
                        <div class="min-w-0">
                            <div id="hubs-connected-count" class="font-mono text-xl font-bold leading-tight">–</div>
                            <div class="text-xs text-gray-500 dark:text-gray-400 truncate" data-i18n="hubs.connected_count">Connected hubs</div>
                        </div>
                    </div>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-red-50 dark:bg-red-900/30 text-red-500 dark:text-red-400 flex items-center justify-center flex-shrink-0">
                            <i class="fas fa-unlink"></i>
                        </div>
                        <div class="min-w-0">
                            <div id="hubs-failed-count" class="font-mono text-xl font-bold leading-tight">–</div>
                            <div class="text-xs text-gray-500 dark:text-gray-400 truncate" data-i18n="hubs.failed_count">Failed connections</div>
                        </div>
                    </div>
                </div>

                <%-- Connected Hub Summary Card (backend pending: sync/state per hub) --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6 opacity-60" title="Requires backend support">
                    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                        <div>
                            <div class="text-xs font-semibold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1.5 flex items-center gap-2">
                                <span data-i18n="hubs.connected_hub">Connected Hub</span>
                                <span class="bg-gray-200 text-gray-600 dark:bg-gray-700 dark:text-gray-400 text-[0.65rem] font-bold px-2 py-0.5 rounded-full normal-case tracking-normal" data-i18n="common.coming_soon">Coming soon</span>
                            </div>
                            <div class="flex items-center gap-3">
                                <span class="font-mono font-semibold text-gray-400 dark:text-gray-500">&mdash;</span>
                                <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 bg-gray-100 text-gray-500 dark:bg-gray-700 dark:text-gray-400 text-xs font-bold rounded-full">
                                    <span class="w-1.5 h-1.5 rounded-full bg-gray-400 inline-block"></span>
                                    <span data-i18n="hubs.no_hub">No hub connected</span>
                                </span>
                            </div>
                        </div>
                        <div class="flex gap-2 w-full sm:w-auto">
                            <button disabled class="flex-1 sm:flex-none bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 text-gray-400 dark:text-gray-500 rounded-lg px-4 py-2 text-sm font-semibold cursor-not-allowed" data-i18n="hubs.force_sync">Force Sync</button>
                            <button disabled class="flex-1 sm:flex-none bg-white dark:bg-gray-800 border border-red-200 dark:border-red-900/40 text-red-300 dark:text-red-900 rounded-lg px-4 py-2 text-sm font-semibold cursor-not-allowed" data-i18n="net.disconnect">Disconnect</button>
                        </div>
                    </div>
                </div>

                <%-- Peers on this Hub (backend pending: peer discovery per hub) --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6 opacity-60" title="Requires backend support">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-base font-bold flex items-center gap-2">
                            <span data-i18n="hubs.peers_title">Peers on this Hub</span>
                            <span class="bg-gray-200 text-gray-600 dark:bg-gray-700 dark:text-gray-400 text-[0.65rem] font-bold px-2 py-0.5 rounded-full" data-i18n="common.coming_soon">Coming soon</span>
                        </h3>
                        <span class="px-2.5 py-0.5 bg-blue-50 text-blue-400 dark:bg-blue-900/20 dark:text-blue-700 text-xs font-bold rounded-full">0 online</span>
                    </div>
                    <div class="text-center py-8 text-sm text-gray-400 dark:text-gray-500 italic" data-i18n="hubs.peers_soon">Peer discovery on hubs will be available once supported by the backend.</div>
                </div>

                <%-- Add Hub (functional: connects via TCP API) --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <h3 class="text-base font-bold mb-4" data-i18n="hubs.add_title">Add Hub</h3>
                    <div class="flex flex-col sm:flex-row gap-3 items-end mb-4">
                        <div class="w-full sm:flex-1">
                            <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5" data-i18n="net.host_label">Host / IP Address</label>
                            <input type="text" id="hubAddress" placeholder="e.g. 192.168.1.10" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm font-mono focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" data-i18n-placeholder="hubs.address_placeholder">
                        </div>
                        <div class="w-full sm:w-36">
                            <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5" data-i18n="hubs.port_label">Port</label>
                            <input type="number" id="hubPort" placeholder="5555" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm font-mono focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" data-i18n-placeholder="hubs.port_placeholder">
                        </div>
                    </div>
                    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
                        <label class="flex items-center gap-2 opacity-50 cursor-not-allowed select-none" title="Requires backend support">
                            <input type="checkbox" disabled class="w-4 h-4 accent-blue-600 cursor-not-allowed">
                            <span class="text-sm font-medium" data-i18n="hubs.multichannel">Multichannel</span>
                            <span class="text-xs text-gray-400" data-i18n="common.coming_soon">Coming soon</span>
                        </label>
                        <div class="flex gap-2 w-full sm:w-auto">
                            <button disabled class="flex-1 sm:flex-none bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 text-gray-400 dark:text-gray-500 rounded-lg px-4 py-2.5 text-sm font-semibold cursor-not-allowed" title="Requires backend support" data-i18n="hubs.save_only">Save Only</button>
                            <button class="flex-1 sm:flex-none bg-blue-600 hover:bg-blue-700 text-white rounded-lg px-5 py-2.5 text-sm font-semibold transition-colors flex justify-center items-center gap-2 whitespace-nowrap" onclick="connectNewHub()">
                                <span data-i18n="hubs.btn_connect">Connect</span> <i class="fas fa-arrow-right text-xs"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <%-- Active Hub Connections Table Card (functional via TCP API) --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700">
                        <h3 class="text-base font-bold" data-i18n="hubs.active_connections">Active Hub Connections</h3>
                    </div>
                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                                <tr>
                                    <th class="px-6 py-4 font-semibold" data-i18n="hubs.address_label">Address</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.th.status">Status</th>
                                    <th class="px-6 py-4 font-semibold text-right" data-i18n="common.actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="active-hubs-list" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400" data-i18n="hubs.loading">Loading active connections...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <script src="js/hub-connections.js?v=1"></script>
</body>
</html>
