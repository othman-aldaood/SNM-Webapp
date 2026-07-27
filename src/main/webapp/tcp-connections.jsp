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
<ui:head title="TCP Connections - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "tcp"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-5xl mx-auto space-y-4 md:space-y-6">

                <%-- Page Top Header Action Bar --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold font-mono" data-i18n="tcp.title">TCP Connections</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="tcp.desc">Manage direct TCP connections to other peers.</p>
                    </div>
                    <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="refreshAll()">
                        <i class="fas fa-sync-alt"></i> <span data-i18n="net.refresh">Refresh Network</span>
                    </button>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6">

                    <%-- Option A: Open Port --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6 flex flex-col">
                        <div class="text-xs font-semibold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1.5" data-i18n="net.option_a">Option A</div>
                        <h3 class="font-bold text-base mb-1.5" data-i18n="net.listen_port">Open Port</h3>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mb-5" data-i18n="net.open_desc">You wait. The other peer connects to you.</p>
                        <div class="mb-4">
                            <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5" data-i18n="net.port_number">Port Number</label>
                            <input type="number" id="newTcpPort" value="7777" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm font-mono focus:ring-2 focus:ring-blue-500 outline-none transition-shadow">
                        </div>
                        <button class="w-full mt-auto bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2.5 px-5 rounded-lg transition-colors flex justify-center items-center gap-2" onclick="openTcpPort()">
                            <span data-i18n="net.btn_open">Open Port</span> <i class="fas fa-arrow-right text-xs"></i>
                        </button>
                    </div>

                    <%-- Option B: Connect to Peer --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6 flex flex-col">
                        <div class="text-xs font-semibold uppercase tracking-wider text-gray-500 dark:text-gray-400 mb-1.5" data-i18n="net.option_b">Option B</div>
                        <h3 class="font-bold text-base mb-1.5" data-i18n="net.connect_peer">Connect to Peer</h3>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mb-5" data-i18n="net.connect_desc">The other peer has already opened a port.</p>
                        <div class="flex gap-3 mb-4">
                            <div class="flex-1">
                                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5" data-i18n="net.host_label">Host / IP Address</label>
                                <input type="text" id="peerAddress" placeholder="e.g. 192.168.1.42" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm font-mono focus:ring-2 focus:ring-blue-500 outline-none transition-shadow">
                            </div>
                            <div class="w-24 md:w-28">
                                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1.5" data-i18n="net.th.port">Port</label>
                                <input type="number" id="peerPort" placeholder="7777" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm font-mono focus:ring-2 focus:ring-blue-500 outline-none transition-shadow">
                            </div>
                        </div>
                        <button class="w-full mt-auto bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2.5 px-5 rounded-lg transition-colors flex justify-center items-center gap-2" onclick="connectToPeer()">
                            <span data-i18n="net.btn_connect">Connect</span> <i class="fas fa-arrow-right text-xs"></i>
                        </button>
                    </div>
                </div>

                <%-- Active Local Listening Sockets Table Card --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700">
                        <h3 class="text-base font-bold" data-i18n="net.active_ports">Active Ports</h3>
                    </div>
                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                                <tr>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.th.port">Port</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.th.status">Status</th>
                                    <th class="px-6 py-4 font-semibold text-right" data-i18n="common.actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="activePortsList" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400" data-i18n="common.loading">Loading active ports...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <%-- Established Outbound Connections Table Card --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700">
                        <h3 class="text-base font-bold" data-i18n="net.established_conns">Connections</h3>
                    </div>
                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                                <tr>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.th.remote_host">Remote Host</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.th.port">Port</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.th.status">Status</th>
                                    <th class="px-6 py-4 font-semibold text-right" data-i18n="common.actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="activeConnectionsList" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="4" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400" data-i18n="common.loading">Loading connections...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <%-- General Network Signal Footer Status --%>
                <div class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400 py-2 justify-center md:justify-start">
                    <i class="fas fa-signal text-green-500"></i>
                    <span data-i18n="net.operational">Network Status: All systems operational</span>
                </div>

            </div>
        </main>
    </div>

    <script src="js/tcp-connections.js?v=1"></script>
</body>
</html>
