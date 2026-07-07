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
<ui:head title="Network - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "network"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-5xl mx-auto space-y-4 md:space-y-6">

                <%-- Page Top Header Action Bar --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold font-mono" data-i18n="net.title">Network</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="net.desc">Manage direct TCP connections and hub links.</p>
                    </div>
                    <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="refreshAll()">
                        <i class="fas fa-sync-alt"></i> <span data-i18n="net.refresh">Refresh Network</span>
                    </button>
                </div>

                <%-- Dynamic Feedback Message Container --%>
                <div id="msg-container"></div>

                <%-- Tab Navigation (TCP | Hub) --%>
                <div class="flex border-b-2 border-gray-200 dark:border-gray-700">
                    <button id="tab-btn-tcp" onclick="switchNetTab('tcp')" class="px-6 py-2.5 font-semibold text-sm -mb-0.5 border-b-2 border-blue-600 text-blue-600 dark:text-blue-400 dark:border-blue-400 transition-colors" data-i18n="net.tab_tcp">TCP</button>
                    <button id="tab-btn-hub" onclick="switchNetTab('hub')" class="px-6 py-2.5 font-semibold text-sm -mb-0.5 border-b-2 border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 transition-colors" data-i18n="net.tab_hub">Hub</button>
                </div>

                <%-- ============================== TAB: TCP ============================== --%>
                <div id="panel-tcp" class="space-y-4 md:space-y-6">

                    <%-- Encounter status strip (data from /api/peer/status) --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 flex items-center justify-between">
                        <div class="flex items-center gap-3">
                            <div class="w-9 h-9 rounded-lg bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 flex items-center justify-center">
                                <i class="fas fa-handshake"></i>
                            </div>
                            <div>
                                <div class="font-semibold text-sm" data-i18n="net.encounter_status">Encounter Status</div>
                                <div class="text-xs text-gray-500 dark:text-gray-400" data-i18n="net.encounters_desc">Peer encounters tracked in this session</div>
                            </div>
                        </div>
                        <div class="flex items-center gap-2">
                            <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse inline-block"></span>
                            <span id="encounters-count" class="font-mono text-xl font-bold">–</span>
                        </div>
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

                <%-- ============================== TAB: HUB ============================== --%>
                <div id="panel-hub" class="hidden space-y-4 md:space-y-6">

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

            </div>
        </main>
    </div>

    <%-- Client Logic Sub-System --%>
    <script>
        /**
         * Global language helper function to fetch tokens safely inside dynamic nodes.
         * @param {string} key - Dictionary node key mapping context
         * @param {string} fallback - Literal safe default visualization return values boundary
         */
        function tl(key, fallback) {
            // NOTE: i18n.js declares `translations` with `const` at script top-level, so it
            // lives in the shared global lexical scope, not as a `window` property - reference
            // it directly (not via `window.translations`, which is always undefined).
            const currentLang = localStorage.getItem('snm-lang') || 'en';
            return (typeof translations !== 'undefined' && translations[currentLang] && translations[currentLang][key]) ? translations[currentLang][key] : fallback;
        }

        /** Utility to prevent XSS in dynamically injected nodes */
        function escapeHtml(text) {
            if (!text) return '';
            return text.toString()
                .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;").replace(/'/g, "&#039;");
        }

        /**
         * Switches between the TCP and Hub tab panels.
         * @param {string} tab - 'tcp' | 'hub'
         */
        function switchNetTab(tab) {
            const active = "px-6 py-2.5 font-semibold text-sm -mb-0.5 border-b-2 border-blue-600 text-blue-600 dark:text-blue-400 dark:border-blue-400 transition-colors";
            const inactive = "px-6 py-2.5 font-semibold text-sm -mb-0.5 border-b-2 border-transparent text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 transition-colors";
            document.getElementById('tab-btn-tcp').className = (tab === 'tcp') ? active : inactive;
            document.getElementById('tab-btn-hub').className = (tab === 'hub') ? active : inactive;
            document.getElementById('panel-tcp').classList.toggle('hidden', tab !== 'tcp');
            document.getElementById('panel-hub').classList.toggle('hidden', tab !== 'hub');
            try { localStorage.setItem('snm-net-tab', tab); } catch (e) { /* ignore */ }
        }

        /**
         * Human readable relative age from a millisecond timestamp.
         * @param {number} ms - Epoch milliseconds
         * @return {string} e.g. "14 min ago" ('' if invalid)
         */
        function netRelativeAge(ms) {
            if (!ms || isNaN(ms)) return '';
            const diffSec = Math.max(0, Math.floor((Date.now() - Number(ms)) / 1000));
            if (diffSec < 60) return tl('time.now', 'now');
            if (diffSec < 3600) return Math.floor(diffSec / 60) + ' ' + tl('time.min', 'min ago');
            if (diffSec < 86400) return Math.floor(diffSec / 3600) + ' ' + tl('time.hr', 'h ago');
            return Math.floor(diffSec / 86400) + ' ' + tl('time.day', 'd ago');
        }

        /**
         * Fetches peer status (encounters + hub connection counters)
         * from /api/peer/status/{peerId} and updates the stat widgets.
         * @return {void}
         */
        function loadPeerStatus() {
            if (!window.currentActivePeerId) return;

            fetch('/snm-webapp/api/peer/status/' + encodeURIComponent(window.currentActivePeerId))
            .then(r => { if (!r.ok) throw new Error('status ' + r.status); return r.json(); })
            .then(data => {
                const enc = (data.encounterStatus && data.encounterStatus.encountersTracked);
                const hubs = data.hubConnections || {};
                const set = (id, val) => {
                    const el = document.getElementById(id);
                    if (el) el.textContent = (val !== undefined && val !== null) ? val : '–';
                };
                set('encounters-count', enc);
                set('hubs-connected-count', hubs.hubsConnected);
                set('hubs-failed-count', hubs.failedToConnect);
            })
            .catch(err => console.error('Error loading peer status:', err));
        }

        /** Refreshes data for both tabs */
        function refreshAll() {
            refreshData();
            loadActiveHubs();
            loadPeerStatus();
        }

        /**
         * Fetches and refreshes the TCP network data (ports and connections)
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
                // 1. Active Ports table
                const list = document.getElementById('activePortsList');
                list.innerHTML = "";

                if (data.openPorts && data.openPorts.length > 0) {
                    data.openPorts.forEach(port => {
                        const tr = document.createElement('tr');
                        tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
                        tr.innerHTML = `
                            <td class="px-6 py-4 font-mono font-medium">\${port}</td>
                            <td class="px-6 py-4"><span class="px-2.5 py-0.5 bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400 text-xs font-bold rounded-full">\${tl("net.status.listening", "Listening")}</span></td>
                            <td class="px-6 py-4 text-right">
                                <button class="px-3 py-1.5 text-xs bg-white dark:bg-gray-800 border border-red-400 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-md transition-colors font-semibold" onclick="closePort(\${port})">\${tl("common.close", "Close")}</button>
                            </td>
                        `;
                        list.appendChild(tr);
                    });
                } else {
                    list.innerHTML = `<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">\${tl("net.no_ports", "No active TCP ports.")}</td></tr>`;
                }

                // 2. Established Connections table
                const connList = document.getElementById('activeConnectionsList');
                connList.innerHTML = "";

                if (data.connections && data.connections.length > 0) {
                    data.connections.forEach(conn => {
                        const tr = document.createElement('tr');
                        tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
                        tr.innerHTML = `
                            <td class="px-6 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-8 h-8 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center text-gray-500 dark:text-gray-400 flex-shrink-0">
                                        <i class="fas fa-user text-xs"></i>
                                    </div>
                                    <span class="font-mono font-medium">\${escapeHtml(conn.remoteAddress) || 'Unknown'}</span>
                                </div>
                            </td>
                            <td class="px-6 py-4 font-mono">\${conn.remotePort || '-'}</td>
                            <td class="px-6 py-4">
                                <span class="px-2.5 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs font-bold rounded-full">\${tl("net.status.connected", "Connected")}</span>
                                \${conn.timestamp ? `<div class="text-[0.7rem] text-gray-400 dark:text-gray-500 mt-1">\${netRelativeAge(conn.timestamp)}</div>` : ''}
                            </td>
                            <td class="px-6 py-4 text-right">
                                <button class="px-3 py-1.5 text-xs bg-white dark:bg-gray-800 border border-red-400 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-md transition-colors font-semibold" onclick="closePort(\${conn.remotePort})">\${tl("net.disconnect", "Disconnect")}</button>
                            </td>
                        `;
                        connList.appendChild(tr);
                    });
                } else {
                    connList.innerHTML = `<tr><td colspan="4" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">\${tl("net.no_conns", "No outgoing connections visible.")}</td></tr>`;
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
                refreshAll();
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
                refreshAll();
            }).catch(err => {
                alert(err.message);
            });
        }

        /**
         * Closes a currently listening port / connection
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
                refreshAll();
            }).catch(err => {
                alert("Error closing port: " + err.message);
            });
        }

        /**
         * Connects to a hub address (currently backed by the generic TCP connect API)
         * @return {void}
         */
        function connectNewHub() {
            const address = document.getElementById('hubAddress').value.trim();
            const portVal = document.getElementById('hubPort').value.trim();

            if (!address || !portVal) {
                alert(tl("net.alert.address_port", "Please enter both address and port."));
                return;
            }

            fetch('/snm-webapp/api/tcp/connect', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    peerId: window.currentActivePeerId,
                    host: address,
                    port: parseInt(portVal)
                })
            }).then(r => {
                if (r.ok) return r.json();
                throw new Error("Connection failed");
            }).then(data => {
                alert(data.msg);
                document.getElementById('hubAddress').value = '';
                document.getElementById('hubPort').value = '';
                refreshAll();
            }).catch(err => {
                alert(err.message);
            });
        }

        /**
         * Renders the active hub connections table (backed by the TCP list API)
         * @return {void}
         */
        function loadActiveHubs() {
            if (!window.currentActivePeerId) return;
            const tbody = document.getElementById('active-hubs-list');
            if (!tbody) return;

            fetch('/snm-webapp/api/tcp/list', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ peerId: window.currentActivePeerId })
            })
            .then(r => r.json())
            .then(data => {
                tbody.innerHTML = '';
                const connections = data.connections || [];

                connections.forEach(conn => {
                    const tr = document.createElement('tr');
                    tr.className = "hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors";
                    tr.innerHTML = `
                        <td class="px-6 py-4 font-mono font-medium">\${escapeHtml(conn.remoteAddress)}:\${conn.remotePort}</td>
                        <td class="px-6 py-4">
                            <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs font-bold rounded-full">
                                <span class="w-1.5 h-1.5 rounded-full bg-green-500 inline-block"></span>\${tl("net.status.connected", "Connected")}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-right">
                            <button class="px-3 py-1.5 text-xs bg-white dark:bg-gray-800 border border-red-400 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-md transition-colors font-semibold" onclick="closePort(\${conn.remotePort})">\${tl("net.disconnect", "Disconnect")}</button>
                        </td>
                    `;
                    tbody.appendChild(tr);
                });

                if (connections.length === 0) {
                    tbody.innerHTML = `<tr><td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400 italic">\${tl("net.no_conns", "No outgoing connections visible.")}</td></tr>`;
                }
            })
            .catch(err => console.error('loadActiveHubs error:', err));
        }

        // Restore requested tab (?tab=hub, or last used)
        (function () {
            const urlTab = new URLSearchParams(window.location.search).get('tab');
            const savedTab = (function () { try { return localStorage.getItem('snm-net-tab'); } catch (e) { return null; } })();
            const tab = (urlTab === 'hub' || urlTab === 'tcp') ? urlTab : (savedTab === 'hub' ? 'hub' : 'tcp');
            if (tab !== 'tcp') switchNetTab(tab);
        })();

        // Initialize Data on Page Load
        window.addEventListener('peerReady', () => refreshAll());

        // Fallback execution check loops mapping contexts
        setTimeout(() => { if (window.currentActivePeerId) refreshAll(); }, 500);

        // Live monitoring: auto-refresh both tabs every 15 seconds
        setInterval(() => { if (window.currentActivePeerId) refreshAll(); }, 15000);
    </script>
</body>
</html>
