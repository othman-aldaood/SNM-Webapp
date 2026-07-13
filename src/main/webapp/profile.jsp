<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- ==========================================
     1. Required Imports & Peer Validation
=========================================== --%>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%
    /**
     * Resolve active identity runtime session from management framework boundaries.
     */
    PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    PeerRuntime activePeer = manager.getActivePeer();

    // Redirect to login if the session is unauthenticated
    if (activePeer == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Set clean EL variables to prevent Scriptlet usage in the HTML body
    pageContext.setAttribute("peerId", activePeer.getPeerID());
    pageContext.setAttribute("peerName", activePeer.getPeerName() != null ? activePeer.getPeerName() : "Unknown Peer");
    pageContext.setAttribute("openPorts", activePeer.getOpenSockets().size());
    pageContext.setAttribute("activeConns", activePeer.getActiveConnections().size());
%>

<!DOCTYPE html>
<html lang="en">
<ui:head title="My Profile - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-dark-bg text-gray-900 dark:text-gray-100 min-h-screen flex flex-col transition-colors duration-300">

    <%-- Application Header --%>
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row flex-1 relative">

        <%-- Application Sidebar (Marking 'profile' as active) --%>
        <% request.setAttribute("activePage", "profile"); %>
        <jsp:include page="sidebar.jsp" />

        <%-- Main Content Area --%>
        <div class="flex-1 p-4 md:p-8 w-full max-w-full overflow-x-hidden relative">

            <div class="max-w-5xl mx-auto space-y-6">

                <%-- Page Header Title --%>
                <div class="flex items-center gap-3 mb-6">
                    <div class="w-10 h-10 rounded-lg bg-primary-100 dark:bg-primary-900/30 text-primary-500 flex items-center justify-center text-xl">
                        <i class="fas fa-id-card"></i>
                    </div>
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900 dark:text-white" data-i18n="prof.title">Peer Profile</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400" data-i18n="prof.desc">Manage your decentralized identity and view network metrics.</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

                    <%-- ==========================================
                         Column 1: Identity Overview (Name, ID, PKI, Avatar)
                    =========================================== --%>
                    <div class="lg:col-span-1 space-y-6">
                        <ui:card cssClass="text-center">
                            <div class="flex flex-col items-center py-4">
                                <%-- Avatar Placeholder --%>
                                <div class="w-24 h-24 rounded-full bg-gradient-to-br from-primary-500 to-blue-700 text-white flex items-center justify-center text-4xl shadow-lg mb-4">
                                    <i class="fas fa-user-astronaut"></i>
                                </div>
                                <h2 class="text-xl font-bold text-gray-800 dark:text-white mb-1">${peerName}</h2>
                                <ui:badge text="Active Identity" theme="success" cssClass="mb-4" key="prof.active_identity" />

                                <%-- Export/Share Profile Button configured with valid i18n key tracking --%>
                                <ui:button text="Export Identity" theme="primary" icon="fas fa-file-export" onClick="exportProfileData()" cssClass="w-full justify-center" key="prof.export" />
                            </div>
                        </ui:card>

                        <%-- Presence Status Panel: Active/Away/DND/Invisible selector + lock toggle --%>
                        <ui:card title="Presence Status" icon="fas fa-circle-dot" key="prof.status_title">
                            <div class="space-y-3">
                                <div class="grid grid-cols-2 gap-2">
                                    <button onclick="setPeerStatus('active')" class="status-option flex items-center gap-2 px-3 py-2.5 rounded-lg border border-gray-200 dark:border-dark-border text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors" data-status="active">
                                        <span class="w-2.5 h-2.5 rounded-full bg-green-500 flex-shrink-0"></span> <span data-i18n="status.active">Active</span>
                                    </button>
                                    <button onclick="setPeerStatus('away')" class="status-option flex items-center gap-2 px-3 py-2.5 rounded-lg border border-gray-200 dark:border-dark-border text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors" data-status="away">
                                        <span class="w-2.5 h-2.5 rounded-full bg-yellow-500 flex-shrink-0"></span> <span data-i18n="status.away">Away</span>
                                    </button>
                                    <button onclick="setPeerStatus('dnd')" class="status-option flex items-center gap-2 px-3 py-2.5 rounded-lg border border-gray-200 dark:border-dark-border text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors" data-status="dnd">
                                        <span class="w-2.5 h-2.5 rounded-full bg-red-500 flex-shrink-0"></span> <span data-i18n="status.dnd">Do Not Disturb</span>
                                    </button>
                                    <button onclick="setPeerStatus('invisible')" class="status-option flex items-center gap-2 px-3 py-2.5 rounded-lg border border-gray-200 dark:border-dark-border text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors" data-status="invisible">
                                        <span class="w-2.5 h-2.5 rounded-full bg-gray-400 flex-shrink-0"></span> <span data-i18n="status.invisible">Invisible</span>
                                    </button>
                                </div>

                                <hr class="border-gray-100 dark:border-dark-border">

                                <label class="flex items-center justify-between cursor-pointer">
                                    <span class="text-sm font-medium text-gray-700 dark:text-gray-300 flex items-center gap-1.5">
                                        <i class="fas fa-lock text-xs text-gray-400"></i> <span data-i18n="status.lock_status">Lock Status</span>
                                    </span>
                                    <input type="checkbox" class="status-lock-checkbox sr-only peer" onchange="setStatusLocked(this.checked)">
                                    <div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600 shrink-0"></div>
                                </label>
                                <p class="text-xs text-gray-400 dark:text-gray-500" data-i18n="status.lock_desc">Locked status won't change automatically (e.g. when you're away).</p>
                            </div>
                        </ui:card>

                        <%-- Cryptographic Identity Panel configured with valid i18n key tracking --%>
                        <ui:card title="Cryptographic Identity" icon="fas fa-fingerprint" key="prof.crypto_id">
                            <div class="space-y-4 text-sm">
                                <div>
                                    <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1" data-i18n="prof.peer_id">Peer ID</label>
                                    <div class="p-2 bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-dark-border rounded font-mono text-xs break-all text-gray-700 dark:text-gray-300">
                                        ${peerId}
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-xs font-semibold text-gray-500 dark:text-gray-400 mb-1" data-i18n="prof.fingerprint">Public Key Fingerprint</label>
                                    <div id="profile-fingerprint" class="p-2 bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-dark-border rounded font-mono text-xs break-all text-gray-700 dark:text-gray-300 relative group cursor-pointer transition-colors hover:bg-gray-100 dark:hover:bg-gray-700" onclick="copyFingerprint()" title="Click to copy">
                                        <div class="flex items-center justify-between">
                                            <span class="opacity-60 italic" data-i18n="prof.resolving">Resolving from PKI...</span>
                                            <i class="fas fa-copy text-gray-400 group-hover:text-primary-500 transition-colors"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ui:card>
                    </div>

                    <%-- ==========================================
                         Column 2: Stats & Trust metrics
                    =========================================== --%>
                    <div class="lg:col-span-2 space-y-6">

                        <%-- Activity Statistics Grid Overview configured with valid i18n key tracking --%>
                        <ui:card title="Network Activity" icon="fas fa-chart-line" key="prof.net_activity">
                            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                                <div class="p-4 rounded-lg border border-gray-100 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 text-center">
                                    <i class="fas fa-network-wired text-2xl text-blue-500 mb-2"></i>
                                    <div class="text-3xl font-bold text-gray-800 dark:text-white">${activeConns}</div>
                                    <div class="text-xs font-semibold text-gray-500 uppercase tracking-wide mt-1" data-i18n="prof.connections">Connections</div>
                                </div>
                                <div class="p-4 rounded-lg border border-gray-100 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 text-center">
                                    <i class="fas fa-satellite-dish text-2xl text-purple-500 mb-2"></i>
                                    <div class="text-3xl font-bold text-gray-800 dark:text-white">${openPorts}</div>
                                    <div class="text-xs font-semibold text-gray-500 uppercase tracking-wide mt-1" data-i18n="prof.open_ports">Open Ports</div>
                                </div>
                                <div class="p-4 rounded-lg border border-gray-100 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 text-center relative overflow-hidden">
                                    <div class="absolute -right-2 -top-2 opacity-10 text-6xl"><i class="fas fa-envelope"></i></div>
                                    <i class="fas fa-comment-dots text-2xl text-green-500 mb-2"></i>
                                    <div class="text-3xl font-bold text-gray-800 dark:text-white" data-i18n="welcome.pki.active">Active</div>
                                    <div class="text-xs font-semibold text-gray-500 uppercase tracking-wide mt-1" data-i18n="prof.messaging_status">Messaging Status</div>
                                </div>
                            </div>
                        </ui:card>

                        <%-- Trust Level Summary Grid Overview configured with valid i18n key tracking --%>
                        <ui:card title="Web of Trust Summary" icon="fas fa-shield-alt" key="prof.wot">
                            <div class="flex flex-col sm:flex-row items-center gap-6 p-2">
                                <%-- Trust Ring Visual Charts --%>
                                <div class="relative w-32 h-32 flex-shrink-0">
                                    <svg class="w-full h-full transform -rotate-90" viewBox="0 0 36 36">
                                        <path class="text-gray-200 dark:text-gray-700" stroke-width="3" stroke="currentColor" fill="none" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
                                        <path class="text-green-500" stroke-dasharray="85, 100" stroke-width="3" stroke="currentColor" fill="none" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
                                    </svg>
                                    <div class="absolute inset-0 flex flex-col items-center justify-center">
                                        <span class="text-2xl font-bold text-gray-800 dark:text-white">85%</span>
                                        <span class="text-[10px] font-bold text-green-500 uppercase" data-i18n="prof.trusted_status">Trusted</span>
                                    </div>
                                </div>
                                <%-- Trust Details Parameters Mapping --%>
                                <div class="flex-1 space-y-3">
                                    <p class="text-sm text-gray-600 dark:text-gray-400" data-i18n="prof.wot_desc">
                                        Your identity has been verified and trusted by multiple peers within your local mesh network.
                                    </p>
                                    <div class="flex flex-wrap gap-2">
                                        <ui:badge text="Verified Certificates: 3" theme="primary" icon="fas fa-certificate" key="prof.badge_verified" />
                                        <ui:badge text="Direct Trust: High" theme="success" icon="fas fa-check-circle" key="prof.badge_direct_trust" />
                                        <ui:badge text="No security flags" theme="secondary" icon="fas fa-flag" key="prof.badge_no_flags" />
                                    </div>
                                </div>
                            </div>
                        </ui:card>

                    </div>
                </div>

            </div>
        </div>
    </div>

    <%-- Client-side Logic for Profile Data --%>
    <script>
        /**
         * Inject JSP backend variables into the global window object
         * so the external profile.js file can access them securely.
         */
        window.PROFILE_CONTEXT = {
            peerId: '${peerId}',
            peerName: '${peerName}'
        };
    </script>

    <%-- Import the external JavaScript file --%>
    <script src="js/profile.js?v=1"></script>
</body>
</html>