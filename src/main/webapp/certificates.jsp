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
%>
<!DOCTYPE html>
<html lang="en">
<ui:head title="Certificates - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <%-- Info-tip (?) tooltip component styles --%>
    <style>
        .info-tip { position: relative; display: inline-flex; align-items: center; vertical-align: middle; line-height: 1; }
        .info-tip__btn {
            display: inline-flex; align-items: center; justify-content: center;
            width: 15px; height: 15px; border: 1.5px solid currentColor; background: none;
            padding: 0; cursor: pointer; color: #b0b7c3; font-size: 0.6rem; font-weight: 700;
            line-height: 1; border-radius: 50%; transition: color 0.15s; flex-shrink: 0; font-family: inherit;
        }
        .info-tip__btn:hover, .info-tip__btn:focus-visible { color: #2563eb; }
        .info-tip__tooltip {
            position: absolute; bottom: calc(100% + 9px); left: 50%; transform: translateX(-50%);
            width: max-content; max-width: min(280px, calc(100vw - 32px));
            background: #1e293b; color: #e2e8f0; font-size: 0.775rem; font-weight: 400; line-height: 1.6;
            padding: 10px 13px; border-radius: 8px; box-shadow: 0 6px 20px rgba(0,0,0,0.22);
            z-index: 200; pointer-events: none; opacity: 0; visibility: hidden;
            transition: opacity 0.12s ease, visibility 0.12s ease;
            text-transform: none; letter-spacing: normal; white-space: normal; text-align: left;
        }
        .info-tip__tooltip::after {
            content: ''; position: absolute; top: 100%; left: 50%; transform: translateX(-50%);
            border: 5px solid transparent; border-top-color: #1e293b;
        }
        .info-tip:hover .info-tip__tooltip, .info-tip:focus-within .info-tip__tooltip { opacity: 1; visibility: visible; }
        .info-tip--flip .info-tip__tooltip { left: auto; right: 0; transform: none; }
        .info-tip--flip .info-tip__tooltip::after { left: auto; right: 8px; transform: none; }
    </style>

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "certificates"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-6xl mx-auto space-y-4 md:space-y-6">

                <%-- Page Header --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold font-mono" data-i18n="cert.title">Certificates</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="cert.desc">Manage PKI credentials, trust and identity certificates.</p>
                    </div>
                    <div class="flex flex-col sm:flex-row w-full sm:w-auto gap-2 sm:gap-3">
                        <a href="pki-tutorial.jsp" class="w-full sm:w-auto bg-gray-200 hover:bg-gray-300 text-gray-800 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600 px-4 py-2.5 rounded-lg font-medium transition-colors shadow-sm flex justify-center items-center gap-2">
                            <i class="fas fa-graduation-cap"></i> <span data-i18n="cert.tutorial_link">How PKI works</span>
                        </a>
                        <button class="w-full sm:w-auto bg-blue-600 hover:bg-blue-700 text-white px-4 py-2.5 rounded-lg font-medium transition-colors shadow-sm flex justify-center items-center gap-2" onclick="showImportModal()">
                            <i class="fas fa-paper-plane"></i> <span data-i18n="cert.send">Send Certificate</span>
                        </button>
                    </div>
                </div>

                <%-- Hidden node kept for export helper --%>
                <span id="your-peer-id" class="hidden">Loading...</span>

                <%-- Pending Credentials (amber attention card) --%>
                <div class="border border-amber-300 dark:border-amber-500/40 rounded-xl bg-amber-50 dark:bg-amber-900/10 p-4 md:p-6">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="font-bold text-base flex items-center gap-2.5">
                            <i class="fas fa-exclamation-circle text-amber-600 dark:text-amber-500"></i>
                            <span data-i18n="cert.pending">Pending Credentials</span>
                        </h3>
                        <span class="bg-amber-100 text-amber-700 dark:bg-amber-900/40 dark:text-amber-400 text-xs font-bold px-2.5 py-0.5 rounded-full"><span id="pending-count">0</span> <span data-i18n="cert.pending_suffix">pending</span></span>
                    </div>
                    <div id="pending-credentials-container" class="space-y-2.5">
                        <div class="text-gray-500 dark:text-gray-400 text-sm italic py-2 text-center" data-i18n="cert.no_pending">No pending credential requests</div>
                    </div>
                </div>

                <%-- 2-Column: Peers list + Detail Panel --%>
                <div class="grid grid-cols-1 lg:grid-cols-[1fr_380px] gap-4 md:gap-6 items-start">

                    <%-- LEFT: Peers list --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden">
                        <div class="p-4 md:px-6 md:py-5 border-b border-gray-100 dark:border-gray-700 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3">
                            <h3 class="font-bold text-base flex items-center gap-1.5">
                                <span data-i18n="cert.peers">Peers</span>
                                <span class="info-tip">
                                    <button class="info-tip__btn" type="button" aria-label="About Peers">?</button>
                                    <span role="tooltip" class="info-tip__tooltip" data-i18n="cert.tip.peers">Peers are the other users in your network — there's no central server. Each peer manages its own keys and decides on its own whom to trust.</span>
                                </span>
                            </h3>
                            <div class="relative w-full sm:w-56">
                                <i class="fas fa-search absolute left-3 top-2.5 text-gray-400 text-xs"></i>
                                <input type="text" id="peer-search" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg py-1.5 pl-8 pr-3 text-sm outline-none focus:ring-2 focus:ring-blue-500 text-gray-900 dark:text-white" placeholder="Search..." data-i18n-placeholder="cert.search_placeholder" onkeyup="filterPeers()">
                            </div>
                        </div>
                        <div class="overflow-x-auto w-full">
                            <table class="w-full text-left text-sm">
                                <thead class="text-xs uppercase bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300">
                                    <tr>
                                        <th class="px-4 md:px-6 py-3.5 font-semibold" data-i18n="cert.th.peer">Peer</th>
                                        <th class="px-4 md:px-6 py-3.5 font-semibold">
                                            <span data-i18n="cert.th.ia">Identity Assurance</span>
                                            <span class="info-tip" style="text-transform:none; letter-spacing:normal;">
                                                <button class="info-tip__btn" type="button" aria-label="About Identity Assurance">?</button>
                                                <span role="tooltip" class="info-tip__tooltip" data-i18n="cert.tip.ia">How sure you can be that this contact really is who they claim to be. 10 means you verified them yourself. Lower scores mean you're trusting them through other people.</span>
                                            </span>
                                        </th>
                                        <th class="px-4 md:px-6 py-3.5 font-semibold whitespace-nowrap" data-i18n="cert.th.valid_until">Valid Until</th>
                                    </tr>
                                </thead>
                                <tbody id="peers-tbody" class="divide-y divide-gray-200 dark:divide-gray-700">
                                    <tr>
                                        <td colspan="3" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400" data-i18n="common.loading">Loading...</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <%-- RIGHT: Peer detail panel --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">

                        <div id="detail-empty" class="text-center py-12 text-sm text-gray-400 dark:text-gray-500">
                            <i class="fas fa-user-shield text-3xl mb-3 block"></i>
                            <span data-i18n="cert.select_peer">Select a peer to view details</span>
                        </div>

                        <div id="detail-content" class="hidden flex-col gap-5" style="display:none;">

                            <%-- Header --%>
                            <div class="flex items-center gap-3.5">
                                <div id="detail-avatar" class="w-11 h-11 rounded-full flex items-center justify-center font-bold text-lg flex-shrink-0 bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300"></div>
                                <div class="min-w-0">
                                    <div id="detail-name" class="font-bold text-base truncate"></div>
                                    <div id="detail-peerid" class="font-mono text-xs text-gray-500 dark:text-gray-400 mt-0.5 truncate"></div>
                                </div>
                            </div>

                            <%-- IA Score --%>
                            <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4">
                                <div class="flex items-baseline justify-between mb-2.5">
                                    <div class="font-semibold text-sm text-gray-500 dark:text-gray-400 flex items-center gap-1.5">
                                        <span data-i18n="cert.ia_title">Identity Assurance</span>
                                        <span class="info-tip info-tip--flip">
                                            <button class="info-tip__btn" type="button" aria-label="About Identity Assurance">?</button>
                                            <span role="tooltip" class="info-tip__tooltip" data-i18n="cert.tip.ia">How sure you can be that this contact really is who they claim to be. 10 means you verified them yourself. Lower scores mean you're trusting them through other people.</span>
                                        </span>
                                    </div>
                                    <div id="detail-score-num" class="font-mono text-xl font-bold"></div>
                                </div>
                                <div id="detail-bar" class="flex gap-1 mb-2"></div>
                                <div class="flex items-center gap-1.5 flex-wrap">
                                    <span id="detail-label-badge" class="inline-flex px-2.5 py-0.5 rounded-full text-xs font-semibold"></span>
                                    <span id="detail-label-desc" class="text-xs text-gray-500 dark:text-gray-400"></span>
                                </div>
                            </div>

                            <%-- SF (edit requires backend support) --%>
                            <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4">
                                <div class="flex items-center justify-between">
                                    <div class="font-semibold text-sm text-gray-500 dark:text-gray-400 flex items-center gap-1.5">
                                        <span data-i18n="cert.sf_title">Signing Failure Rate</span>
                                        <span class="info-tip info-tip--flip">
                                            <button class="info-tip__btn" type="button" aria-label="About Signing Failure Rate">?</button>
                                            <span role="tooltip" class="info-tip__tooltip" data-i18n="cert.tip.sf">Your personal estimate (1–10) of how carefully this contact checks people's identities before vouching for them. A higher number lowers the Identity Assurance of everyone you reach through them.</span>
                                        </span>
                                    </div>
                                    <div class="flex items-center gap-2">
                                        <div id="detail-sf" class="font-mono text-xl font-bold"></div>
                                        <button disabled class="text-gray-300 dark:text-gray-600 cursor-not-allowed p-0.5" title="Requires backend support">
                                            <i class="fas fa-pen text-xs"></i>
                                        </button>
                                    </div>
                                </div>
                                <div class="text-xs text-gray-400 dark:text-gray-500 mt-1.5 flex items-center gap-2">
                                    <span data-i18n="cert.sf_hint">The lower, the more trustworthy</span>
                                    <span class="bg-gray-200 text-gray-600 dark:bg-gray-700 dark:text-gray-400 text-[0.65rem] font-bold px-2 py-0.5 rounded-full" data-i18n="cert.sf_edit_soon">Editing coming soon</span>
                                </div>
                            </div>

                            <%-- Trust Chain (requires backend support) --%>
                            <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4 opacity-60" title="Requires backend support">
                                <div class="font-semibold text-sm text-gray-500 dark:text-gray-400 mb-2.5 flex items-center gap-1.5">
                                    <span data-i18n="cert.chain_title">Trust Chain</span>
                                    <span class="bg-gray-200 text-gray-600 dark:bg-gray-700 dark:text-gray-400 text-[0.65rem] font-bold px-2 py-0.5 rounded-full" data-i18n="common.coming_soon">Coming soon</span>
                                </div>
                                <div class="text-xs text-gray-400 dark:text-gray-500 italic" data-i18n="cert.chain_soon">Trust chain visualization will be available once supported by the backend.</div>
                            </div>

                            <%-- Certificate card --%>
                            <div id="cert-card" class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
                                <div class="px-4 py-3 bg-gray-50 dark:bg-gray-900/50 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
                                    <div class="font-semibold text-xs text-gray-500 dark:text-gray-400 uppercase tracking-wider flex items-center gap-1.5">
                                        <span data-i18n="cert.cert_title">Certificate</span>
                                        <span class="info-tip info-tip--flip" style="text-transform:none; letter-spacing:normal;">
                                            <button class="info-tip__btn" type="button" aria-label="About Certificate">?</button>
                                            <span role="tooltip" class="info-tip__tooltip" data-i18n="cert.tip.cert">A digital signature confirming "I have verified this person — their key really belongs to them." There's no central authority — certificates spread between people as they connect.</span>
                                        </span>
                                    </div>
                                    <div id="cert-selector" class="flex gap-1"></div>
                                </div>

                                <div id="cert-none" class="px-4 py-6 text-center text-xs text-gray-400 dark:text-gray-500 italic hidden" data-i18n="cert.none_for_peer">No certificates stored for this peer.</div>

                                <div id="cert-body">
                                    <div class="px-4 py-3 border-b border-gray-100 dark:border-gray-700">
                                        <div class="text-xs text-gray-500 dark:text-gray-400 mb-0.5" data-i18n="cert.f.subject">Subject</div>
                                        <div id="cert-subject-name" class="font-semibold text-sm"></div>
                                        <div id="cert-subject-id" class="font-mono text-xs text-gray-500 dark:text-gray-400 mt-0.5 break-all"></div>
                                    </div>
                                    <div class="px-4 py-3 border-b border-gray-100 dark:border-gray-700">
                                        <div class="text-xs text-gray-500 dark:text-gray-400 mb-0.5" data-i18n="cert.f.issuer">Issuer</div>
                                        <div class="flex items-center gap-2 flex-wrap">
                                            <div id="cert-issuer-name" class="font-semibold text-sm"></div>
                                            <span id="cert-issuer-badge" class="hidden px-2 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400" data-i18n="cert.issued_by_you">Issued by you</span>
                                        </div>
                                        <div id="cert-issuer-id" class="font-mono text-xs text-gray-500 dark:text-gray-400 mt-0.5 break-all"></div>
                                    </div>
                                    <div class="px-4 py-3 border-b border-gray-100 dark:border-gray-700 grid grid-cols-2 gap-3">
                                        <div>
                                            <div class="text-xs text-gray-500 dark:text-gray-400 mb-0.5" data-i18n="cert.f.valid_from">Valid From</div>
                                            <div id="cert-valid-from" class="font-mono text-xs font-semibold"></div>
                                        </div>
                                        <div>
                                            <div class="text-xs text-gray-500 dark:text-gray-400 mb-0.5" data-i18n="cert.th.valid_until">Valid Until</div>
                                            <div id="cert-valid-until" class="font-mono text-xs font-semibold"></div>
                                        </div>
                                    </div>
                                    <div class="px-4 py-3 border-b border-gray-100 dark:border-gray-700">
                                        <div class="text-xs text-gray-500 dark:text-gray-400 mb-1.5" data-i18n="cert.f.pubkey">Public Key Fingerprint</div>
                                        <div id="cert-fingerprint" class="font-mono text-xs text-gray-700 dark:text-gray-300 bg-gray-50 dark:bg-gray-900/50 rounded-md p-2.5 break-all leading-relaxed"></div>
                                    </div>
                                    <div class="px-4 py-3 flex justify-end">
                                        <button id="cert-revoke-btn" class="px-3 py-1.5 text-xs bg-white dark:bg-gray-800 border border-red-400 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-md transition-colors font-semibold" data-i18n="cert.revoke.title">Revoke Certificate</button>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>

                <%-- IA Factors explainer --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <h3 class="font-bold text-base mb-4" data-i18n="cert.ia_factors">What influences the IA (Identity Assurance) Score?</h3>
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
                        <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 flex flex-col gap-2">
                            <div class="w-6 h-6 rounded-md bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 font-bold text-xs flex items-center justify-center">1</div>
                            <div class="font-semibold text-sm" data-i18n="cert.factor1_title">Certificate Chain</div>
                            <div class="text-xs text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="cert.factor1_desc">The more hops between you and the peer, the lower the score.</div>
                        </div>
                        <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 flex flex-col gap-2">
                            <div class="w-6 h-6 rounded-md bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 font-bold text-xs flex items-center justify-center">2</div>
                            <div class="font-semibold text-sm" data-i18n="cert.factor2_title">SF of the Issuer</div>
                            <div class="text-xs text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="cert.factor2_desc">A high Signing Failure Rate of an issuer lowers the score of all peers certified by them.</div>
                        </div>
                        <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 flex flex-col gap-2">
                            <div class="w-6 h-6 rounded-md bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 font-bold text-xs flex items-center justify-center">3</div>
                            <div class="font-semibold text-sm" data-i18n="cert.factor3_title">Validity</div>
                            <div class="text-xs text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="cert.factor3_desc">Expired certificates (after 1 year) are no longer counted.</div>
                        </div>
                        <div class="border border-green-200 dark:border-green-900/40 bg-green-50 dark:bg-green-900/10 rounded-lg p-4 flex flex-col gap-2">
                            <div class="w-6 h-6 rounded-md bg-green-100 dark:bg-green-900/40 text-green-700 dark:text-green-400 font-bold text-xs flex items-center justify-center">4</div>
                            <div class="font-semibold text-sm" data-i18n="cert.factor4_title">Direct Exchange</div>
                            <div class="text-xs text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="cert.factor4_desc">You issued a certificate to this peer directly → IA = 10, regardless of chain or SF.</div>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <%-- Confirmation modal for trust-changing actions --%>
    <div id="confirm-modal" class="fixed inset-0 z-[60] hidden bg-gray-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 overflow-hidden">
            <div class="p-5">
                <h3 id="cm-title" class="font-bold text-lg text-gray-900 dark:text-white mb-2"></h3>
                <p id="cm-message" class="text-sm text-gray-600 dark:text-gray-300 leading-relaxed"></p>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex flex-col-reverse sm:flex-row justify-end gap-3">
                <button class="w-full sm:w-auto px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 text-sm font-medium transition-colors" onclick="closeConfirmModal()" data-i18n="common.cancel">Cancel</button>
                <button id="cm-confirm-btn" class="w-full sm:w-auto px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg text-sm font-medium shadow-sm transition-colors"></button>
            </div>
        </div>
    </div>

    <%-- Revoke Modal Overlay Boundary Context --%>
    <div id="revoke-modal" class="fixed inset-0 z-[60] hidden bg-gray-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden">
            <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-700/50">
                <h3 class="font-bold text-lg text-red-600 dark:text-red-400"><i class="fas fa-exclamation-triangle mr-2"></i><span data-i18n="cert.revoke.title">Revoke Certificate</span></h3>
                <button class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20" onclick="hideRevokeModal()">&times;</button>
            </div>
            <div class="p-6 space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Subject ID:</label>
                    <input type="text" id="revoke-subject-id" class="w-full bg-gray-100 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 text-sm text-gray-500 dark:text-gray-400 cursor-not-allowed font-mono" readonly>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Certificate Subject:</label>
                    <input type="text" id="revoke-subject-name" class="w-full bg-gray-100 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 rounded-lg p-2.5 text-sm text-gray-500 dark:text-gray-400 cursor-not-allowed" readonly>
                </div>
                <div class="bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-400 p-3 rounded-lg text-sm border border-red-200 dark:border-red-800/30 leading-relaxed" data-i18n="cert.revoke.warning">
                    <strong>⚠️ Warning:</strong> This action cannot be undone. The certificate will be revoked and can no longer be used for verification.
                </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex flex-col-reverse sm:flex-row justify-end gap-3">
                <button class="w-full sm:w-auto px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 text-sm font-medium transition-colors" onclick="hideRevokeModal()" data-i18n="common.cancel">Cancel</button>
                <button class="w-full sm:w-auto px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg text-sm font-medium shadow-sm transition-colors" onclick="revokeCertificate()" data-i18n="cert.revoke.title">Revoke</button>
            </div>
        </div>
    </div>

    <%-- Send Certificate Modal Overlay Boundary Context --%>
    <div id="import-modal" class="fixed inset-0 z-[60] hidden bg-gray-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white dark:bg-gray-800 w-full max-w-md rounded-xl shadow-2xl border border-gray-200 dark:border-gray-700 flex flex-col overflow-hidden">
            <div class="p-4 border-b border-gray-200 dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-700/50">
                <h3 class="font-bold text-lg text-gray-900 dark:text-white"><i class="fas fa-paper-plane text-blue-500 mr-2"></i><span data-i18n="cert.send">Send Certificate</span></h3>
                <button class="text-gray-400 hover:text-red-500 transition-colors text-xl w-8 h-8 flex items-center justify-center rounded-full hover:bg-red-50 dark:hover:bg-red-900/20" onclick="hideImportModal()">&times;</button>
            </div>
            <div class="p-6 space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Peer ID (optional):</label>
                    <input type="text" id="import-peer-name" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none" placeholder="Leave empty to broadcast">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Message (optional):</label>
                    <textarea id="import-message" rows="3" class="w-full bg-gray-50 dark:bg-gray-900 border border-gray-300 dark:border-gray-600 text-gray-900 dark:text-white rounded-lg p-2.5 text-sm focus:ring-2 focus:ring-blue-500 outline-none resize-none" placeholder="Optional message..."></textarea>
                </div>
            </div>
            <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-700/50 flex flex-col-reverse sm:flex-row justify-end gap-3">
                <button class="w-full sm:w-auto px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600 text-sm font-medium transition-colors" onclick="hideImportModal()" data-i18n="common.cancel">Cancel</button>
                <button class="w-full sm:w-auto px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium shadow-sm transition-colors" onclick="sendCredentials()" data-i18n="msg.send">Send</button>
            </div>
        </div>
    </div>

    <script src="js/certificates.js?v=5.1"></script>
</body>
</html>
