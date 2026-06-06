<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%
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
<ui:head title="Welcome to SharkNet - Onboarding Flow"/>
<body class="bg-gray-50 dark:bg-dark-bg text-gray-900 dark:text-gray-100 min-h-screen flex flex-col transition-colors duration-300"

    <jsp:include page="header.jsp" />

    <div class="flex-1 flex items-center justify-center p-6">
        <div class="max-w-2xl w-full bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-xl p-8 transition-colors duration-300">

            <div class="flex justify-between items-center mb-8 border-b border-gray-100 dark:border-dark-border pb-6">
                <div class="step-indicator flex items-center gap-2" data-step="1">
                    <span class="w-8 h-8 rounded-full bg-primary-500 text-white flex items-center justify-center font-bold text-sm shadow-sm" id="step-circle-1">1</span>
                    <span class="text-sm font-medium hidden sm:inline">Profile</span>
                </div>
                <div class="w-full h-0.5 bg-gray-200 dark:bg-dark-border mx-2"></div>
                <div class="step-indicator flex items-center gap-2" data-step="2">
                    <span class="w-8 h-8 rounded-full bg-gray-200 dark:bg-dark-border text-gray-600 dark:text-gray-400 flex items-center justify-center font-bold text-sm" id="step-circle-2">2</span>
                    <span class="text-sm font-medium text-gray-500 hidden sm:inline">Keys (PKI)</span>
                </div>
                <div class="w-full h-0.5 bg-gray-200 dark:bg-dark-border mx-2"></div>
                <div class="step-indicator flex items-center gap-2" data-step="3">
                    <span class="w-8 h-8 rounded-full bg-gray-200 dark:bg-dark-border text-gray-600 dark:text-gray-400 flex items-center justify-center font-bold text-sm" id="step-circle-3">3</span>
                    <span class="text-sm font-medium text-gray-500 hidden sm:inline">Hub Link</span>
                </div>
                <div class="w-full h-0.5 bg-gray-200 dark:bg-dark-border mx-2"></div>
                <div class="step-indicator flex items-center gap-2" data-step="4">
                    <span class="w-8 h-8 rounded-full bg-gray-200 dark:bg-dark-border text-gray-600 dark:text-gray-400 flex items-center justify-center font-bold text-sm" id="step-circle-4">4</span>
                    <span class="text-sm font-medium text-gray-500 hidden sm:inline">Channels</span>
                </div>
            </div>

            <div id="wizard-content">

                <div id="wizard-step-1" class="space-y-4">
                    <div class="text-center space-y-2 mb-6">
                        <h2 class="text-2xl font-bold font-mono text-gray-800 dark:text-white">Configure User Profile</h2>
                        <p class="text-sm text-gray-500 dark:text-gray-400">Set up your local display preference for this SharkNet peer identity[cite: 24].</p>
                    </div>
                    <div class="space-y-1">
                        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300">Peer Custom Name</label>
                        <input type="text" id="ob-displayName" class="w-full px-4 py-2 border border-gray-300 dark:border-dark-border rounded-lg bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 font-mono" placeholder="e.g. Shark_Node_Alpha">
                    </div>
                    <div class="p-4 bg-blue-50 dark:bg-slate-800 border border-blue-100 dark:border-slate-700 rounded-lg text-xs text-blue-700 dark:text-blue-300 flex items-start gap-3">
                        <i class="fas fa-info-circle mt-0.5 text-base"></i>
                        <span>This configuration establishes your personal identifier representation across active channels within the decentralized framework[cite: 24, 44].</span>
                    </div>
                </div>

                <div id="wizard-step-2" class="space-y-4 hidden">
                    <div class="text-center space-y-2 mb-6">
                        <h2 class="text-2xl font-bold font-mono text-gray-800 dark:text-white">Cryptographic Key Infrastructure</h2>
                        <p class="text-sm text-gray-500 dark:text-gray-400">Your secure decentralized cryptographic identity credentials are automatically managed[cite: 44].</p>
                    </div>
                    <div class="border border-gray-200 dark:border-dark-border rounded-lg p-5 bg-gray-50 dark:bg-dark-bg space-y-3">
                        <div class="flex justify-between items-center text-sm">
                            <span class="font-medium text-gray-600 dark:text-gray-400">PKI Infrastructure Status:</span>
                            <span class="px-2 py-0.5 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 text-xs rounded font-bold">Active</span>
                        </div>
                        <div class="space-y-1">
                            <span class="block text-xs font-semibold text-gray-500 dark:text-gray-400">Public Key Fingerprint Hash</span>
                            <div class="p-3 bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded font-mono text-xs text-gray-700 dark:text-gray-300 break-all select-all shadow-inner" id="ob-fingerprintDisplay">
                                Resolving identity fingerprint string...
                            </div>
                        </div>
                    </div>
                    <p class="text-xs text-gray-500 dark:text-gray-400 text-center"><i class="fas fa-shield-alt text-green-500"></i> Keys are stored securely inside your local peer data partition directories[cite: 38].</p>
                </div>

                <div id="wizard-step-3" class="space-y-4 hidden">
                    <div class="text-center space-y-2 mb-6">
                        <h2 class="text-2xl font-bold font-mono text-gray-800 dark:text-white">Establish Hub Link</h2>
                        <p class="text-sm text-gray-500 dark:text-gray-400">Connect to an operational ASAP protocol hub router to enable background data sync orchestration[cite: 28].</p>
                    </div>
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                        <div class="sm:col-span-2 space-y-1">
                            <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300">Hub Address / Host</label>
                            <input type="text" id="ob-hubAddress" class="w-full px-4 py-2 border border-gray-300 dark:border-dark-border rounded-lg bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 font-mono" placeholder="e.g. 192.168.1.100">
                        </div>
                        <div class="space-y-1">
                            <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300">Target TCP Port</label>
                            <input type="number" id="ob-hubPort" class="w-full px-4 py-2 border border-gray-300 dark:border-dark-border rounded-lg bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 font-mono" placeholder="9001">
                        </div>
                    </div>
                    <div class="flex justify-end pt-2">
                        <button class="bg-gray-800 hover:bg-gray-900 dark:bg-gray-700 dark:hover:bg-gray-600 text-white text-xs font-mono px-4 py-2 rounded transition-colors" onclick="triggerHubConnectAttempt()">
                            <i class="fas fa-link mr-1"></i> Dispatch Connection
                        </button>
                    </div>
                </div>

                <div id="wizard-step-4" class="space-y-4 hidden">
                    <div class="text-center space-y-2 mb-6">
                        <h2 class="text-2xl font-bold font-mono text-gray-800 dark:text-white">Initialize First Channel</h2>
                        <p class="text-sm text-gray-500 dark:text-gray-400">Establish or subscribe to a communication URI space instance channel to initiate message interactions.</p>
                    </div>
                    <div class="space-y-3">
                        <div class="space-y-1">
                            <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300">Channel Address Identity URI</label>
                            <input type="text" id="ob-channelUri" class="w-full px-4 py-2 border border-gray-300 dark:border-dark-border rounded-lg bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 font-mono" value="shark://global-backbone-stream">
                        </div>
                        <div class="space-y-1">
                            <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300">Descriptive Friendly Label Name (Optional)</label>
                            <input type="text" id="ob-channelName" class="w-full px-4 py-2 border border-gray-300 dark:border-dark-border rounded-lg bg-white dark:bg-dark-bg text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 font-mono" placeholder="Global Mesh Exchange Channel">
                        </div>
                    </div>
                </div>

            </div>

            <div class="flex justify-between items-center mt-8 pt-6 border-t border-gray-100 dark:border-dark-border">
                <button id="btn-wizard-back" class="px-5 py-2 rounded-lg border border-gray-300 dark:border-dark-border font-medium text-gray-600 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors disabled:opacity-40 disabled:cursor-not-allowed" onclick="navigatePreviousStep()" disabled>
                    <i class="fas fa-arrow-left mr-2"></i> Previous
                </button>
                <button id="btn-wizard-next" class="px-5 py-2 rounded-lg bg-primary-500 hover:bg-primary-600 text-white font-medium shadow transition-colors flex items-center gap-2" onclick="navigateNextStep()">
                    <span>Next</span> <i class="fas fa-arrow-right"></i>
                </button>
            </div>

        </div>
    </div>

    <script src="js/welcome.js?v=3"></script>
</body>

</html>