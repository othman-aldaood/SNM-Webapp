<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%
    /**
     * ==========================================
     * Peer Session Validation & Variable Scope
     * ==========================================
     * Resolves the active identity runtime session from management layers.
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

<ui:head title="Persons - SharkNet Messenger"/>
<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "persons"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-6xl mx-auto space-y-4 md:space-y-6">

                <%-- Main Page Header Bar --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 md:mb-6 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold" data-i18n="persons.title">Persons Management</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="persons.desc">Manage PKI identities, trust levels, and contact information.</p>
                    </div>
                    <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2.5 px-5 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="refreshPersons()">
                        <i class="fas fa-sync-alt"></i> <span data-i18n="persons.btn_refresh">Refresh Data</span>
                    </button>
                </div>

                <%-- Statistics Overview Widgets Panel --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="border-b border-gray-100 dark:border-gray-700 pb-3 md:pb-4 mb-4">
                        <h3 class="text-lg font-bold" data-i18n="persons.overview_title">Known Persons Overview</h3>
                    </div>
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                        <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4 flex flex-col items-center justify-center border border-gray-100 dark:border-gray-700">
                            <div class="text-3xl font-bold text-blue-600 dark:text-blue-400" id="total-persons">0</div>
                            <div class="text-sm text-gray-500 dark:text-gray-400 mt-1 font-medium" data-i18n="persons.total_persons">Total Persons</div>
                        </div>
                        <div class="bg-green-50 dark:bg-green-900/20 rounded-lg p-4 flex flex-col items-center justify-center border border-green-100 dark:border-green-800/30">
                            <div class="text-3xl font-bold text-green-600 dark:text-green-400" id="trusted-persons">0</div>
                            <div class="text-sm text-green-600 dark:text-green-400 mt-1 font-medium" data-i18n="persons.trusted">Trusted</div>
                        </div>
                        <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4 flex flex-col items-center justify-center border border-gray-100 dark:border-gray-700">
                            <div class="text-3xl font-bold text-gray-600 dark:text-gray-400" id="unknown-persons">0</div>
                            <div class="text-sm text-gray-500 dark:text-gray-400 mt-1 font-medium" data-i18n="persons.unknown">Unknown</div>
                        </div>
                    </div>
                </div>

                <%-- Main Contacts Registry Summary Table Area --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                        <h3 class="text-lg font-bold" data-i18n="persons.all_persons">All Persons</h3>
                        <div class="w-full sm:w-64 relative">
                            <i class="fas fa-search absolute left-3 top-3 text-gray-400"></i>
                            <input type="text" id="person-search" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg py-2 pl-10 pr-4 text-sm focus:ring-2 focus:ring-blue-500 outline-none transition-shadow text-gray-900 dark:text-white" placeholder="Search name or ID..." data-i18n-placeholder="persons.search_placeholder" onkeyup="filterPersons()">
                        </div>
                    </div>

                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap" id="persons-table">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-700">
                                <tr>
                                    <th class="px-6 py-4 font-semibold" data-i18n="persons.th.name">Name</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="persons.th.peer_id">Peer ID</th>
                                    <th class="px-6 py-4 font-semibold text-center" data-i18n="persons.th.trust_level">Trust Level</th>
                                    <th class="px-6 py-4 font-semibold text-center" data-i18n="persons.th.signing_rate">Signing Rate</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="persons.th.identity_assurance">Identity Assurance</th>
                                    <th class="px-6 py-4 font-semibold text-right" data-i18n="common.actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="persons-tbody" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="6" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400" data-i18n="persons.loading">Loading persons...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <%-- Custom Rename Person Overlay Context boundary --%>
    <div id="rename-modal" class="fixed inset-0 z-50 hidden bg-gray-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden">
            <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-700/50">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white" data-i18n="persons.modal.rename_title">Rename Person</h3>
                <button class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20" onclick="hideRenameModal()">&times;</button>
            </div>
            <div class="p-6 space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" data-i18n="persons.modal.current_name">Current Name:</label>
                    <input type="text" id="current-name" class="w-full bg-gray-100 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 text-sm text-gray-500 dark:text-gray-400 cursor-not-allowed" readonly>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1" data-i18n="persons.modal.new_name">New Name:</label>
                    <input type="text" id="new-name" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none" placeholder="Enter new name" data-i18n-placeholder="persons.modal.new_name_placeholder">
                </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex justify-end gap-3">
                <button class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 text-sm font-medium transition-colors" onclick="hideRenameModal()" data-i18n="common.cancel">Cancel</button>
                <button class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium shadow-sm transition-colors" onclick="renamePerson()" data-i18n="persons.modal.rename_title">Rename</button>
            </div>
        </div>
    </div>

    <%-- Custom Identity Details Overlay Context boundary --%>
    <div id="details-modal" class="fixed inset-0 z-50 hidden bg-gray-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 w-full max-w-2xl rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden max-h-[90vh]">
            <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-700/50">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white" data-i18n="persons.modal.details_title">Person Details</h3>
                <button class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20" onclick="hideDetailsModal()">&times;</button>
            </div>
            <div class="p-6 overflow-y-auto">
                <div id="person-details" class="text-sm text-gray-700 dark:text-gray-300 space-y-4">
                </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex justify-end">
                <button class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 text-sm font-medium transition-colors" onclick="hideDetailsModal()" data-i18n="common.close">Close</button>
            </div>
        </div>
    </div>

    <script src="js/persons.js?v=2.1"></script>
</body>
</html>