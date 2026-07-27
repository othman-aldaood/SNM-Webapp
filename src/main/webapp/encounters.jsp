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
<ui:head title="Encounter Management - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "encounters"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-5xl mx-auto space-y-4 md:space-y-6">

                <%-- Page Top Header Action Bar --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold font-mono" data-i18n="enc.title">Encounter Management</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="enc.desc">Track peer encounters recorded during this session.</p>
                    </div>
                    <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="refreshAll()">
                        <i class="fas fa-sync-alt"></i> <span data-i18n="net.refresh">Refresh Network</span>
                    </button>
                </div>

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

                <%-- Peer Encounters Table Card (data from /api/peer/status: encounters[]) --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700">
                        <h3 class="text-base font-bold" data-i18n="net.encounters_title">Peer Encounters</h3>
                    </div>
                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                                <tr>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.th.peer_id">Peer ID</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.th.connection_type">Connection Type</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="net.th.duration">Duration</th>
                                </tr>
                            </thead>
                            <tbody id="encountersList" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400" data-i18n="common.loading">Loading...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <script src="js/encounters.js?v=1"></script>
</body>
</html>
