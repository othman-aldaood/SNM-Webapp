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
<ui:head title="Home - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-dark-bg text-gray-900 dark:text-gray-100 min-h-screen flex flex-col transition-colors duration-300">

    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row flex-1 relative">

        <% request.setAttribute("activePage", "messenger"); %>
        <jsp:include page="sidebar.jsp" />

        <div class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden relative">

            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

                <%-- Channel List Panel --%>
                <div class="lg:col-span-4 xl:col-span-3 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm flex flex-col h-[400px] lg:h-[calc(100vh-140px)]">

                    <div class="p-4 border-b border-gray-200 dark:border-dark-border flex justify-between items-center bg-gray-50 dark:bg-gray-800/50 rounded-t-xl">
                        <h3 class="font-bold text-gray-800 dark:text-white flex items-center gap-2">
                            <i class="fas fa-list-ul text-primary-500"></i> <span data-i18n="msg.channels">Channels</span>
                        </h3>
                        <button onclick="showCreateChannelModal()" class="text-primary-500 hover:text-primary-600 transition-colors" title="Create Channel">
                            <i class="fas fa-plus-circle text-xl"></i>
                        </button>
                    </div>

                    <div id="channel-list" class="flex-1 overflow-y-auto chat-scroll p-4">
                        <div class="w-full text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-lg dark:bg-dark-card dark:border-dark-border dark:text-white shadow-sm" id="dynamic-channel-list">
                        </div>
                    </div>
                </div>

                <%-- Chat Log Panel --%>
                <div class="lg:col-span-8 xl:col-span-6 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm flex flex-col h-[600px] lg:h-[calc(100vh-140px)] relative">

                    <div class="p-4 border-b border-gray-200 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 rounded-t-xl flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3 relative">
                        <div>
                            <div class="font-bold text-lg text-gray-800 dark:text-white" id="current-channel-name">Select a channel</div>
                            <div class="flex items-center gap-2 text-xs text-gray-500 dark:text-gray-400 mt-1">
                                <span class="w-2 h-2 rounded-full bg-gray-400" id="status-indicator"></span>
                                <span id="current-channel-pki-status">Waiting for selection...</span>
                            </div>
                        </div>

                        <div class="relative w-full sm:w-auto flex items-center gap-2">
                            <div class="relative w-full sm:w-48 lg:w-64">
                                <i class="fas fa-search absolute left-3 top-2.5 text-gray-400 text-sm"></i>
                                <input type="text" id="message-search" class="w-full bg-white dark:bg-dark-bg border border-gray-300 dark:border-dark-border rounded-lg pl-9 pr-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 transition-shadow disabled:opacity-50 text-gray-900 dark:text-white" placeholder="Search text..." data-i18n-placeholder="msg.search_ph" disabled onkeyup="applyFilters()">
                            </div>
                            <button id="filter-toggle-btn" class="p-1.5 text-gray-500 hover:text-primary-500 dark:text-gray-400 dark:hover:text-primary-400 disabled:opacity-50 transition-colors" disabled onclick="toggleFilterPanel()" title="Advanced Filters">
                                <i class="fas fa-sliders-h"></i>
                            </button>

                            <%-- Filter Panel --%>
                            <div id="filter-panel" class="hidden absolute right-0 top-full mt-2 w-72 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-lg shadow-xl z-50 p-4 space-y-3">
                                <h4 class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-2 border-b border-gray-100 dark:border-dark-border pb-1" data-i18n="msg.filters">Filters</h4>
                                <div>
                                    <label class="block text-xs text-gray-700 dark:text-gray-300 mb-1" data-i18n="msg.sender_name">Sender Name</label>
                                    <input type="text" id="filter-sender" class="w-full bg-gray-50 dark:bg-dark-bg border border-gray-300 dark:border-dark-border rounded px-2 py-1 text-sm outline-none focus:ring-1 focus:ring-primary-500 text-gray-900 dark:text-white" onkeyup="applyFilters()">
                                </div>
                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <label class="block text-xs text-gray-700 dark:text-gray-300 mb-1" data-i18n="msg.from_date">From Date</label>
                                        <input type="date" id="filter-date-start" class="w-full bg-gray-50 dark:bg-dark-bg border border-gray-300 dark:border-dark-border rounded px-2 py-1 text-[11px] outline-none focus:ring-1 focus:ring-primary-500 text-gray-900 dark:text-white" onchange="applyFilters()">
                                    </div>
                                    <div>
                                        <label class="block text-xs text-gray-700 dark:text-gray-300 mb-1" data-i18n="msg.to_date">To Date</label>
                                        <input type="date" id="filter-date-end" class="w-full bg-gray-50 dark:bg-dark-bg border border-gray-300 dark:border-dark-border rounded px-2 py-1 text-[11px] outline-none focus:ring-1 focus:ring-primary-500 text-gray-900 dark:text-white" onchange="applyFilters()">
                                    </div>
                                </div>
                                <div class="pt-2 flex justify-end">
                                    <button onclick="clearFilters()" class="text-xs text-primary-500 hover:text-primary-600 font-medium" data-i18n="msg.clear_filters">Clear Filters</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="flex-1 overflow-y-auto chat-scroll p-4 bg-gray-50/50 dark:bg-dark-bg/50 relative" id="chat-log">
                        <div class="flex flex-col items-center justify-center h-full text-center space-y-3 opacity-60">
                            <i class="fas fa-comments text-5xl text-primary-500"></i>
                            <h3 class="text-xl font-bold">Welcome to SharkNet Messenger</h3>
                        </div>
                    </div>

                    <%-- Message Input Area --%>
                    <div class="p-3 border-t border-gray-200 dark:border-dark-border bg-white dark:bg-dark-card rounded-b-xl relative z-10">
                        <div class="flex flex-wrap items-center gap-4 mb-2 text-sm">
                            <select id="message-receiver" class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-dark-border text-gray-700 dark:text-gray-300 rounded px-2 py-1 outline-none focus:ring-1 focus:ring-primary-500 cursor-pointer">
                                <option value="ANY_SHARKNET_PEER">Anyone</option>
                            </select>

                            <%-- E2E security options group --%>
                            <div class="flex items-center gap-3 bg-gray-50 dark:bg-gray-800/60 border border-gray-200 dark:border-dark-border rounded-lg px-3 py-1.5">
                                <span class="text-xs font-semibold text-gray-500 dark:text-gray-400 flex items-center gap-1.5">
                                    <i class="fas fa-shield-alt text-primary-500"></i> <span data-i18n="msg.security">Security</span>
                                </span>
                                <label class="flex items-center gap-1.5 cursor-pointer text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200 transition-colors" title="Attach your digital signature so the receiver can verify the sender">
                                    <input type="checkbox" id="sign-message" checked class="rounded border-gray-300 text-primary-500 focus:ring-primary-500">
                                    <span data-i18n="msg.sign"><i class="fas fa-signature text-xs"></i> Sign</span>
                                </label>
                                <label class="flex items-center gap-1.5 cursor-pointer text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200 transition-colors" title="Encrypt so only the selected receiver can read the message">
                                    <input type="checkbox" id="encrypt-message" class="rounded border-gray-300 text-primary-500 focus:ring-primary-500">
                                    <span data-i18n="msg.encrypt"><i class="fas fa-lock text-xs"></i> Encrypt</span>
                                </label>
                            </div>
                        </div>

                        <div class="flex gap-2 items-end">
                            <textarea id="message-input" rows="2" class="flex-1 resize-none border border-gray-300 dark:border-dark-border rounded-lg p-2 text-sm bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500" placeholder="Type your message here..." data-i18n-placeholder="msg.type_here"></textarea>
                            <div class="flex flex-col gap-1" id="action-buttons-container">
                                <%-- Using verified key routing matching safe tag attributes layout validation mapping --%>
                                <ui:button text="Send" theme="primary" icon="fas fa-paper-plane" onClick="sendMessage()" cssClass="h-[52px] !flex-col !gap-1 min-w-[70px] !text-xs !py-1" />
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Side Info Panel --%>
                <div class="hidden xl:block xl:col-span-3 space-y-6 h-auto lg:h-[calc(100vh-140px)] overflow-y-auto chat-scroll pr-2 pb-6">
                    <%-- Using the new valid 'key' attribute infrastructure to inject the mapping context --%>
                    <ui:card title="Peer Info" icon="fas fa-server" key="msg.peer_info">
                        <div class="space-y-3 text-sm">
                            <div class="flex flex-col gap-1">
                                <span class="text-gray-500 dark:text-gray-400 text-xs uppercase tracking-wider font-semibold">Peer ID</span>
                                <span class="font-mono text-gray-800 dark:text-gray-200 break-all bg-gray-50 dark:bg-gray-800/50 p-2 rounded border border-gray-100 dark:border-dark-border">${peerId}</span>
                            </div>
                        </div>
                    </ui:card>

                    <ui:card title="Statistics" icon="fas fa-chart-pie" key="msg.stats">
                        <div class="space-y-3 text-sm">
                            <div class="flex justify-between items-center">
                                <span class="text-gray-500 dark:text-gray-400">Channels</span>
                                <span id="active-channel-count" class="font-bold text-gray-800 dark:text-gray-200 bg-gray-100 dark:bg-gray-800 px-2 py-0.5 rounded">0</span>
                            </div>
                        </div>
                    </ui:card>
                </div>
            </div>
        </div>
    </div>

    <%-- Modals and Create-Forms configuration overlays --%>
    <div id="create-channel-form" class="fixed inset-0 z-50 bg-gray-900/50 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-dark-card w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-dark-border flex flex-col overflow-hidden animate-[fadeIn_0.2s_ease-out]" onclick="event.stopPropagation()">
            <div class="p-4 border-b border-gray-200 dark:border-dark-border flex justify-between items-center bg-gray-50 dark:bg-gray-800/50">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white"><i class="fas fa-plus-circle mr-2 text-primary-500"></i>Create New Channel</h3>
                <button onclick="hideCreateChannelModal()" class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="p-6 space-y-4">
                <div>
                    <label class="block mb-1.5 font-semibold text-sm text-gray-700 dark:text-gray-300">Channel URI <span class="text-red-500">*</span></label>
                    <input type="text" id="new-channel-uri" class="w-full border border-gray-300 dark:border-dark-border rounded-lg p-2.5 bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 outline-none text-sm transition-shadow font-mono" placeholder="shark://my-topic-stream">
                </div>
                <div>
                    <label class="block mb-1.5 font-semibold text-sm text-gray-700 dark:text-gray-300">Friendly Name</label>
                    <input type="text" id="new-channel-name" class="w-full border border-gray-300 dark:border-dark-border rounded-lg p-2.5 bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 outline-none text-sm transition-shadow" placeholder="e.g. My Secret Channel">
                </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 flex justify-end gap-3">
                <ui:button text="Cancel" theme="secondary" onClick="hideCreateChannelModal()" />
                <ui:button text="Create" theme="primary" icon="fas fa-check" onClick="createChannel()" />
            </div>
        </div>
    </div>

    <div id="message-context-menu" class="hidden fixed z-[100] w-48 bg-white dark:bg-dark-card rounded-lg shadow-xl border border-gray-200 dark:border-dark-border py-1 text-sm transition-opacity duration-200 opacity-0 pointer-events-none">
        <button onclick="triggerEditFromMenu()" class="w-full text-left px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-700 dark:text-gray-300 flex items-center gap-2 transition-colors">
            <i class="fas fa-edit text-blue-500 w-4"></i> Edit Message
        </button>
        <button onclick="triggerDeleteFromMenu()" class="w-full text-left px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-800 text-red-500 flex items-center gap-2 transition-colors">
            <i class="fas fa-trash-alt text-red-500 w-4"></i> Delete Message
        </button>
    </div>

    <script src="js/messenger.js?v=1004"></script>
</body>
</html>