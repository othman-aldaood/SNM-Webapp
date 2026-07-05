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

    pageContext.setAttribute("peerId", activePeer.getPeerID());
    pageContext.setAttribute("openPorts", activePeer.getOpenSockets().size());
    pageContext.setAttribute("activeConns", activePeer.getActiveConnections().size());
%>
<!DOCTYPE html>
<html lang="en">
<ui:head title="Overview - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "network"); %>
        <jsp:include page="sidebar.jsp" />

        <div class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-5xl mx-auto space-y-4 md:space-y-6">

                <%-- Page Top Header Action Bar --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 md:mb-6 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold" data-i18n="net.title">Network Overview</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="net.desc">Manage direct TCP connections and open ports.</p>
                    </div>
                    <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="refreshData()">
                        <i class="fas fa-sync-alt"></i> <span data-i18n="net.refresh">Refresh Network</span>
                    </button>
                </div>

                <%-- Connections & Control Orchestration Panel --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <h3 class="text-lg font-bold border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4" data-i18n="net.direct_conns">Direct TCP Connections</h3>

                    <%-- Form 1: Listen Socket Initializer Context --%>
                    <div class="mb-6">
                        <h4 class="font-semibold text-gray-800 dark:text-gray-200 mb-3 text-sm md:text-base" data-i18n="net.listen_port">Listen on New Port</h4>
                        <div class="flex flex-col sm:flex-row gap-3 items-end">
                            <div class="w-full sm:flex-1">
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" data-i18n="net.port_number">Port Number</label>
                                <input type="number" id="newTcpPort" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="e.g., 8080" value="8080">
                            </div>
                            <button class="w-full sm:w-auto bg-gray-800 hover:bg-gray-900 dark:bg-gray-700 dark:hover:bg-gray-600 text-white font-medium py-2.5 px-5 rounded-lg transition-colors flex justify-center items-center" onclick="openTcpPort()" data-i18n="net.btn_open">
                                Open Port
                            </button>
                        </div>
                    </div>

                    <hr class="border-gray-100 dark:border-gray-700 my-6">

                    <%-- Form 2: Outbound Peer Target Connector --%>
                    <div>
                        <h4 class="font-semibold text-gray-800 dark:text-gray-200 mb-3 text-sm md:text-base" data-i18n="net.connect_peer">Connect to Peer</h4>
                        <div class="flex flex-col sm:flex-row gap-3 items-end">
                            <div class="w-full sm:flex-[3]">
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" data-i18n="net.peer_address">Peer Address</label>
                                <input type="text" id="peerAddress" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="e.g., localhost" value="localhost">
                            </div>
                            <div class="w-full sm:flex-[2]">
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" data-i18n="net.port_number">Port</label>
                                <input type="number" id="peerPort" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow" placeholder="e.g., 8080">
                            </div>
                            <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2.5 px-5 rounded-lg transition-colors flex justify-center items-center" onclick="connectToPeer()" data-i18n="net.btn_connect">
                                Connect
                            </button>
                        </div>
                    </div>
                </div>

                <%-- Active Local Listening Sockets Table Card --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700">
                        <h3 class="text-lg font-bold" data-i18n="net.active_ports">Active TCP Ports</h3>
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

                <%-- Established Outbound Connections Topology Grid --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700">
                        <h3 class="text-lg font-bold" data-i18n="net.established_conns">Established Connections</h3>
                    </div>
                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                                <tr>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.remote_address">Remote Address</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.remote_port">Remote Port</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.th.status">Status</th>
                                </tr>
                            </thead>
                            <tbody id="activeConnectionsList" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400" data-i18n="common.loading">Loading connections...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <%-- General Network Signal Footer Status --%>
                <div class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400 py-4 justify-center md:justify-start">
                    <i class="fas fa-signal text-green-500"></i>
                    <span data-i18n="net.operational">Network Status: All systems operational</span>
                </div>
            </div>
        </div>
    </div>

    <%-- Client Logic Sub-System --%>
    <script>
        /**
         * Global language helper function to fetch tokens safely inside dynamic nodes.
         * @param {string} key - Dictionary node key mapping context
         * @param {string} fallback - Literal safe default visualization return values boundary
         */
        function tl(key, fallback) {
            const currentLang = localStorage.getItem('snm-lang') || 'en';
            return (window.translations && window.translations[currentLang] && window.translations[currentLang][key]) ? window.translations[currentLang][key] : fallback;
        }

        /**
         * Fetches and refreshes the network data (ports and connections)
         * @return {void}
         */
        function refreshData() {
            if (!window.currentActivePeerId) return;
            const peerId = window.currentActivePeerId;

            fetch('/snm-webapp/api/tcp/list', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ peerId: peerId })
            })
            .then(r => r.json())
            .then(data => {
                // 1. Update Active Ports Table layouts using escaped character maps to pass JSP compilation safely
                const list = document.getElementById('activePortsList');
                list.innerHTML = "";

                if (data.openPorts && data.openPorts.length > 0) {
                    data.openPorts.forEach(port => {
                        const tr = document.createElement('tr');
                        tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
                        tr.innerHTML = `
                            <td class="px-6 py-4 font-mono font-medium">\${port}</td>
                            <td class="px-6 py-4"><span class="px-2.5 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs font-bold rounded-full">\${tl("net.status.listening", "Listening")}</span></td>
                            <td class="px-6 py-4 text-right">
                                <button class="px-3 py-1.5 text-xs bg-red-100 hover:bg-red-200 text-red-600 dark:bg-red-900/30 dark:text-red-400 dark:hover:bg-red-900/50 rounded transition-colors font-medium" onclick="closePort(\${port})">\${tl("common.close", "Close")}</button>
                            </td>
                        `;
                        list.appendChild(tr);
                    });
                } else {
                    list.innerHTML = `<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">\${tl("net.no_ports", "No active TCP ports.")}</td></tr>`;
                }

                // 2. Update Established Connections Table layouts using escaped character maps to pass JSP compilation safely
                const connList = document.getElementById('activeConnectionsList');
                connList.innerHTML = "";

                if (data.connections && data.connections.length > 0) {
                    data.connections.forEach(conn => {
                        const tr = document.createElement('tr');
                        tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
                        tr.innerHTML = `
                            <td class="px-6 py-4 font-mono">\${conn.remoteAddress || 'Unknown'}</td>
                            <td class="px-6 py-4 font-mono">\${conn.remotePort || '-'}</td>
                            <td class="px-6 py-4"><span class="px-2.5 py-0.5 bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400 text-xs font-bold rounded-full">\${tl("net.status.connected", "Connected")}</span></td>
                        `;
                        connList.appendChild(tr);
                    });
                } else {
                    connList.innerHTML = `<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">\${tl("net.no_conns", "No outgoing connections visible.")}</td></tr>`;
                }
            })
            .catch(err => console.error("Error refreshing network data:", err));
        }

        /**
         * Opens a new TCP port
         * @return {void}
         */
        function openTcpPort() {
            const portInput = document.getElementById('newTcpPort');
            const port = portInput.value;
            if (!port) {
                alert(tl("net.alert.port", "Please enter a port number."));
                return;
            }

            fetch('/snm-webapp/api/tcp/open', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    peerId: window.currentActivePeerId,
                    port: parseInt(port)
                })
            }).then(r => r.json()).then(data => {
                alert(data.msg);
                refreshData();
            }).catch(err => {
                alert("Error opening port: " + err.message);
            });
        }

        /**
         * Connects to a remote peer via IP/Port
         * @return {void}
         */
        function connectToPeer() {
            const host = document.getElementById('peerAddress').value;
            const port = document.getElementById('peerPort').value;

            if (!host || !port) {
                alert(tl("net.alert.address_port", "Please enter both address and port."));
                return;
            }

            fetch('/snm-webapp/api/tcp/connect', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    peerId: window.currentActivePeerId,
                    host: host,
                    port: parseInt(port)
                })
            }).then(r => {
                if (r.ok) return r.json();
                throw new Error("Connection failed");
            }).then(data => {
                alert(data.msg);
                refreshData();
            }).catch(err => {
                alert(err.message);
            });
        }

        /**
         * Closes a currently listening port
         * @param {number} port - The port number to close
         * @return {void}
         */
        function closePort(port) {
            if (!confirm(tl("net.confirm.close", "Are you sure you want to close port ") + port + "?")) return;

            fetch('/snm-webapp/api/tcp/close', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ peerId: window.currentActivePeerId, port: port })
            }).then(r => r.json()).then(data => {
                alert(data.msg);
                refreshData();
            }).catch(err => {
                alert("Error closing port: " + err.message);
            });
        }

        // Initialize Data on Page Load
        window.addEventListener('peerReady', () => refreshData());

        // Fallback execution check loops mapping contexts
        setTimeout(() => { if (window.currentActivePeerId) refreshData(); }, 500);
    </script>
</body>
</html>