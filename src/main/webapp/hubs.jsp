<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%
    /**
     * ==========================================
     * Peer Session Validation & Variable Scope
     * ==========================================
     * Resolves the active peer session and extracts runtime parameters.
     */
    PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    PeerRuntime activePeer = manager.getActivePeer();

    if (activePeer == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    pageContext.setAttribute("peerId", activePeer.getPeerID());
    pageContext.setAttribute("openPorts", activePeer.getOpenSockets().size());
    pageContext.setAttribute("activeConns", activePeer.getActiveConnections().size());
%>
<!DOCTYPE html>
<html lang="en">
<ui:head title="Hub - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "hubs"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-6xl mx-auto space-y-4 md:space-y-6">

                <%-- Main Page Top Header --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 md:mb-6 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold" data-i18n="hubs.title">ASAP Hub Management</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="hubs.desc">Connect and manage your ASAP Hub connections.</p>
                    </div>
                </div>

                <%-- Dynamic Feedback Message Hub Notifications Container --%>
                <div id="msg-container"></div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">

                    <%-- Card Form 1: Outgoing Sync Link Orchestration --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                        <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">
                            <h3 class="text-lg font-bold flex items-center gap-2">
                                <i class="fas fa-network-wired text-blue-500"></i> <span data-i18n="hubs.connect_title">Connect to Hub</span>
                            </h3>
                        </div>
                        <div class="space-y-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" data-i18n="hubs.address_label">Hub Address</label>
                                <input type="text" id="hubAddress" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="e.g., 192.168.1.50 or hub.sharknet.org" data-i18n-placeholder="hubs.address_placeholder">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" data-i18n="hubs.port_label">Port</label>
                                <input type="number" id="hubPort" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="e.g., 9001" data-i18n-placeholder="hubs.port_placeholder">
                            </div>
                            <button class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2.5 rounded-lg transition-colors flex justify-center items-center gap-2" onclick="connectNewHub()">
                                <i class="fas fa-link"></i> <span data-i18n="hubs.btn_connect">Connect</span>
                            </button>
                        </div>
                    </div>

                    <%-- Card Form 2: Inbound Sockets Acceptance Configuration --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                        <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">
                            <h3 class="text-lg font-bold flex items-center gap-2">
                                <i class="fas fa-door-open text-green-500"></i> <span data-i18n="hubs.open_title">Open Local Port</span>
                            </h3>
                        </div>
                        <div class="space-y-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" data-i18n="hubs.port_label">Port</label>
                                <input type="number" id="openPort" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="e.g., 9001" data-i18n-placeholder="hubs.port_placeholder">
                            </div>
                            <div class="hidden sm:block h-[68px]"></div>
                            <button class="w-full bg-gray-800 hover:bg-gray-900 dark:bg-gray-700 dark:hover:bg-gray-600 text-white font-medium py-2.5 rounded-lg transition-colors flex justify-center items-center gap-2" onclick="openLocalPort()">
                                <i class="fas fa-play"></i> <span data-i18n="hubs.btn_open">Open Port</span>
                            </button>
                        </div>
                    </div>
                </div>

                <%-- Connections Status & Topology Verification Table Section --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                        <h3 class="text-lg font-bold" data-i18n="hubs.active_connections">Active Hub Connections</h3>
                        <button class="w-full sm:w-auto bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-800 dark:text-gray-200 font-medium py-2 px-4 rounded-lg text-sm transition-colors flex justify-center items-center gap-2 border border-gray-300 dark:border-gray-600" onclick="loadActiveHubs()">
                            <i class="fas fa-sync-alt"></i> <span data-i18n="爷爷.refresh">Refresh</span>
                        </button>
                    </div>

                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                                <tr>
                                    <th class="px-6 py-4 font-semibold" data-i18n="cert.th.issuer">Hub Address</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="cert.th.valid_until">Port</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="common.status">Status</th>
                                    <th class="px-6 py-4 font-semibold text-right" data-i18n="common.actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="active-hubs-list" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="4" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400" data-i18n="hubs.loading">Loading active connections...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <%-- Forced client version routing configuration parameter mapping --%>
    <script src="js/hubs.js?v=4.1"></script>
</body>
</html>