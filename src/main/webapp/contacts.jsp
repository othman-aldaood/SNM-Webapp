<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%
    /**
     * ==========================================
     * Peer Session Validation & Variable Scope
     * ==========================================
     * Establishes context validation with management layers.
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
<ui:head title="Peers - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "contacts"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-5xl mx-auto space-y-4 md:space-y-6">

                <%-- Page Top Header Bar --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 md:mb-6 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold" data-i18n="contacts.title">Manageable Peers</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="contacts.desc">Create, start, stop, and manage your local peers — fully offline, no internet required.</p>
                    </div>
                    <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white font-medium py-2.5 px-5 rounded-lg shadow-sm transition-colors flex justify-center items-center gap-2" onclick="showCreatePeerModal()">
                        <i class="fas fa-plus"></i> <span data-i18n="contacts.create_btn">Create New Peer</span>
                    </button>
                </div>

                <%-- Local Peers List Summary Table Section --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden w-full">
                    <div class="p-4 md:p-6 border-b border-gray-100 dark:border-gray-700 flex justify-between items-center">
                        <h3 class="text-lg font-bold" data-i18n="contacts.local_peers">Local Peers</h3>
                        <button class="text-gray-500 hover:text-blue-600 dark:text-gray-400 dark:hover:text-blue-400 transition-colors" onclick="loadContacts()" title="Refresh List" data-i18n-title="contacts.refresh_tooltip">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                    </div>

                    <div class="overflow-x-auto w-full">
                        <table class="w-full text-left text-sm whitespace-nowrap">
                            <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                                <tr>
                                    <th class="px-6 py-4 font-semibold" data-i18n="contacts.th.status">Status</th>
                                    <th class="px-6 py-4 font-semibold" data-i18n="contacts.th.details">Peer Details</th>
                                    <th class="px-6 py-4 font-semibold text-right" data-i18n="common.actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="contactsTableBody" class="divide-y divide-gray-200 dark:divide-gray-700">
                                <tr>
                                    <td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400" data-i18n="contacts.loading">Loading peers...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <%-- Custom Create Peer Action Overlay Boundary --%>
    <div id="create-peer-modal" class="fixed inset-0 z-50 bg-gray-900/50 backdrop-blur-sm hidden items-center justify-center p-4" onclick="hideCreatePeerModal()">
        <div class="bg-white dark:bg-gray-800 w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden animate-[fadeIn_0.2s_ease-out]" onclick="event.stopPropagation()">
            <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-700/50">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white"><i class="fas fa-user-plus mr-2 text-blue-500"></i><span data-i18n="contacts.modal.title">Create New Peer</span></h3>
                <button onclick="hideCreatePeerModal()" class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="p-6 space-y-4">
                <div>
                    <label class="block mb-1.5 font-semibold text-sm text-gray-700 dark:text-gray-300"><span data-i18n="contacts.modal.label">Peer Name</span> <span class="text-red-500">*</span></label>
                    <input type="text" id="new-peer-name" class="w-full border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-white focus:ring-2 focus:ring-blue-500 outline-none text-sm transition-shadow" placeholder="e.g. My Local Node" data-i18n-placeholder="contacts.modal.placeholder">
                </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex justify-end gap-3">
                <button onclick="hideCreatePeerModal()" class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 font-medium transition-colors text-sm" data-i18n="common.cancel">Cancel</button>
                <button onclick="submitNewPeer()" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium shadow-sm transition-colors flex items-center gap-2 text-sm">
                    <i class="fas fa-check"></i> <span data-i18n="msg.create_channel">Create</span>
                </button>
            </div>
        </div>
    </div>

    <script src="js/contacts.js?v=4.1"></script>
</body>
</html>