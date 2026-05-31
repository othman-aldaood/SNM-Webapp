<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%
    // Initialize peer manager and check for active peer session
    PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    PeerRuntime activePeer = manager.getActivePeer();

    // Redirect to login if no active peer is found
    if (activePeer == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SharkNet Messenger</title>

    <style>
        /* Custom scrollbar styling for chat logs to maintain a clean UI with Tailwind */
        .chat-scroll::-webkit-scrollbar { width: 6px; }
        .chat-scroll::-webkit-scrollbar-track { background: transparent; }
        .chat-scroll::-webkit-scrollbar-thumb { background-color: #cbd5e1; border-radius: 20px; }
        .dark .chat-scroll::-webkit-scrollbar-thumb { background-color: #475569; }
    </style>
</head>

<body class="bg-gray-50 dark:bg-dark-bg text-gray-900 dark:text-gray-100 min-h-screen flex flex-col transition-colors duration-300">

    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row flex-1">

        <% request.setAttribute("activePage", "messenger"); %>
        <jsp:include page="sidebar.jsp" />

        <div class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">

            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">

                <div class="lg:col-span-4 xl:col-span-3 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm flex flex-col h-[400px] lg:h-[calc(100vh-140px)]">

                    <div class="p-4 border-b border-gray-200 dark:border-dark-border flex justify-between items-center bg-gray-50 dark:bg-gray-800/50 rounded-t-xl">
                        <h3 class="font-bold text-gray-800 dark:text-white flex items-center gap-2">
                            <i class="fas fa-list-ul text-primary-500"></i> Channels
                        </h3>
                        <button onclick="showCreateChannelModal()" class="text-primary-500 hover:text-primary-600 transition-colors" title="Create Channel">
                            <i class="fas fa-plus-circle text-xl"></i>
                        </button>
                    </div>

                    <div id="channel-list" class="flex-1 overflow-y-auto chat-scroll p-4">
                        <div class="w-full text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-lg dark:bg-dark-card dark:border-dark-border dark:text-white shadow-sm">
                            </div>
                    </div>
                </div>

                <div class="lg:col-span-8 xl:col-span-6 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm flex flex-col h-[600px] lg:h-[calc(100vh-140px)]">

                    <div class="p-4 border-b border-gray-200 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 rounded-t-xl">
                        <div class="font-bold text-lg text-gray-800 dark:text-white" id="current-channel-name">Select a channel</div>
                        <div class="flex items-center gap-2 text-xs text-gray-500 dark:text-gray-400 mt-1">
                            <span class="w-2 h-2 rounded-full bg-gray-400" id="status-indicator"></span>
                            <span id="current-channel-pki-status">Waiting for selection...</span>
                        </div>
                    </div>

                    <div class="flex-1 overflow-y-auto chat-scroll p-4 bg-gray-50/50 dark:bg-dark-bg/50" id="chat-log">
                        <div class="flex flex-col items-center justify-center h-full text-center space-y-3 opacity-60">
                            <i class="fas fa-comments text-5xl text-primary-500"></i>
                            <h3 class="text-xl font-bold">Welcome to SharkNet Messenger</h3>
                            <p class="text-sm">Select a channel from the left to start messaging</p>
                        </div>
                    </div>

                    <div class="p-3 border-t border-gray-200 dark:border-dark-border bg-white dark:bg-dark-card rounded-b-xl">
                        <div class="flex flex-wrap items-center gap-4 mb-2 text-sm">
                            <select id="message-receiver" class="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-dark-border text-gray-700 dark:text-gray-300 rounded px-2 py-1 outline-none focus:ring-1 focus:ring-primary-500 cursor-pointer">
                                <option value="ANY_SHARKNET_PEER">Anyone</option>
                            </select>

                            <div class="flex items-center gap-4">
                                <label class="flex items-center gap-1.5 cursor-pointer text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200 transition-colors">
                                    <input type="checkbox" id="sign-message" checked class="rounded border-gray-300 text-primary-500 focus:ring-primary-500">
                                    <span><i class="fas fa-signature text-xs"></i> Sign</span>
                                </label>
                                <label class="flex items-center gap-1.5 cursor-pointer text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200 transition-colors">
                                    <input type="checkbox" id="encrypt-message" class="rounded border-gray-300 text-primary-500 focus:ring-primary-500">
                                    <span><i class="fas fa-lock text-xs"></i> Encrypt</span>
                                </label>
                            </div>
                        </div>

                        <div class="flex gap-2">
                            <textarea id="message-input" rows="2" class="flex-1 resize-none border border-gray-300 dark:border-dark-border rounded-lg p-2 text-sm bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500" placeholder="Type your message here..."></textarea>
                            <button id="send-btn" onclick="sendMessage()" class="bg-primary-500 hover:bg-primary-600 text-white rounded-lg px-4 font-bold flex flex-col items-center justify-center gap-1 transition-colors">
                                <i class="fas fa-paper-plane text-base"></i>
                                <span class="text-xs">Send</span>
                            </button>
                        </div>
                    </div>
                </div>

                <div class="hidden xl:block xl:col-span-3 space-y-6 h-auto lg:h-[calc(100vh-140px)] overflow-y-auto chat-scroll pr-2 pb-6">
                    <div class="bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm p-4">
                        <h4 class="font-bold border-b border-gray-100 dark:border-dark-border pb-2 mb-3 text-gray-800 dark:text-white flex items-center gap-2">
                            <i class="fas fa-server text-gray-400"></i> Peer Info
                        </h4>
                        <div class="space-y-3 text-sm">
                            <div class="flex flex-col gap-1">
                                <span class="text-gray-500 dark:text-gray-400 text-xs uppercase tracking-wider font-semibold">Peer ID</span>
                                <span class="font-mono text-gray-800 dark:text-gray-200 break-all bg-gray-50 dark:bg-gray-800/50 p-2 rounded border border-gray-100 dark:border-dark-border"><%= activePeer !=null ? activePeer.getPeerID() : "Unknown" %></span>
                            </div>
                            <div class="flex justify-between items-center pt-2">
                                <span class="text-gray-500 dark:text-gray-400">Status</span>
                                <span class="px-2 py-1 bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400 rounded-md text-xs font-bold">Active</span>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm p-4">
                        <h4 class="font-bold border-b border-gray-100 dark:border-dark-border pb-2 mb-3 text-gray-800 dark:text-white flex items-center gap-2">
                            <i class="fas fa-chart-pie text-gray-400"></i> Statistics
                        </h4>
                        <div class="space-y-3 text-sm">
                            <div class="flex justify-between items-center">
                                <span class="text-gray-500 dark:text-gray-400">Channels</span>
                                <span id="active-channel-count" class="font-bold text-gray-800 dark:text-gray-200 bg-gray-100 dark:bg-gray-800 px-2 py-0.5 rounded">0</span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-gray-500 dark:text-gray-400">Open Ports</span>
                                <span class="font-bold text-gray-800 dark:text-gray-200 bg-gray-100 dark:bg-gray-800 px-2 py-0.5 rounded"><%= activePeer !=null ? activePeer.getOpenSockets().size() : 0 %></span>
                            </div>
                            <div class="flex justify-between items-center">
                                <span class="text-gray-500 dark:text-gray-400">Connections</span>
                                <span class="font-bold text-gray-800 dark:text-gray-200 bg-gray-100 dark:bg-gray-800 px-2 py-0.5 rounded"><%= activePeer !=null ? activePeer.getActiveConnections().size() : 0 %></span>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm p-4">
                        <h4 class="font-bold border-b border-gray-100 dark:border-dark-border pb-2 mb-3 text-gray-800 dark:text-white flex items-center gap-2">
                            <i class="fas fa-fingerprint text-gray-400"></i> Identity Key
                        </h4>
                        <div class="text-sm">
                            <div class="bg-gray-50 dark:bg-gray-800/50 p-3 rounded-lg border border-gray-200 dark:border-dark-border font-mono text-xs text-center text-gray-700 dark:text-gray-300 break-all" title="<%= activePeer != null ? activePeer.getPublicKeyFingerprint() : "" %>">
                                <%
                                    String fp = activePeer != null ? activePeer.getPublicKeyFingerprint() : "";
                                    if (fp.length() > 16) {
                                        fp = fp.substring(0, 8) + "..." + fp.substring(fp.length() - 8);
                                    }
                                %>
                                <%= fp %>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <div id="create-channel-form" class="fixed inset-0 z-50 bg-gray-900/50 backdrop-blur-sm hidden items-center justify-center p-4">
        <div class="bg-white dark:bg-dark-card w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-dark-border flex flex-col overflow-hidden animate-[fadeIn_0.2s_ease-out]" onclick="event.stopPropagation()">

            <div class="p-4 border-b border-gray-200 dark:border-dark-border flex justify-between items-center bg-gray-50 dark:bg-gray-800/50">
                <h3 class="font-bold text-lg text-gray-800 dark:text-white"><i class="fas fa-satellite-dish mr-2 text-primary-500"></i>Create Channel</h3>
                <button onclick="hideCreateChannelModal()" class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <div class="p-6 space-y-5">
                <div>
                    <label class="block mb-1.5 font-semibold text-sm text-gray-700 dark:text-gray-300">Channel URI <span class="text-red-500">*</span></label>
                    <input type="text" id="new-channel-uri" class="w-full border border-gray-300 dark:border-dark-border rounded-lg p-2.5 bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 outline-none font-mono text-sm transition-shadow" placeholder="e.g. shark://my-channel">
                </div>
                <div>
                    <label class="block mb-1.5 font-semibold text-sm text-gray-700 dark:text-gray-300">Display Name (optional)</label>
                    <input type="text" id="new-channel-name" class="w-full border border-gray-300 dark:border-dark-border rounded-lg p-2.5 bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 outline-none text-sm transition-shadow" placeholder="e.g. My Secret Channel">
                </div>
            </div>

            <div class="p-4 border-t border-gray-200 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 flex justify-end gap-3">
                <button onclick="hideCreateChannelModal()" class="px-4 py-2 border border-gray-300 dark:border-dark-border rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 font-medium transition-colors">Cancel</button>
                <button onclick="createChannel()" class="px-4 py-2 bg-primary-500 hover:bg-primary-600 text-white rounded-lg font-medium shadow-sm transition-colors flex items-center gap-2">
                    <i class="fas fa-check"></i> Create
                </button>
            </div>
        </div>
    </div>

    <script src="js/messenger.js?v=20"></script>

</body>

</html>