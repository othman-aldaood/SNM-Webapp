<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%
    /**
     * PKI Concepts Tutorial (UC4) - educational page explaining Identity
     * Assurance, Signing Failure Rate, Trust Chains and Certificates.
     * Pure client-side content, no backend calls required.
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
<ui:head title="PKI Tutorial - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "certificates"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-4xl mx-auto space-y-4 md:space-y-6">

                <%-- Page Header --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold font-mono" data-i18n="tut.title">PKI Concepts: Tutorial</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="tut.desc">Everything you need to understand the Certificates screen. No technical background required.</p>
                    </div>
                    <a href="certificates.jsp" class="w-full sm:w-auto bg-gray-200 hover:bg-gray-300 text-gray-800 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600 px-4 py-2.5 rounded-lg font-medium transition-colors shadow-sm flex justify-center items-center gap-2">
                        <i class="fas fa-arrow-left"></i> <span data-i18n="tut.back">Back to Certificates</span>
                    </a>
                </div>

                <%-- Identity Assurance --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="flex items-center gap-2.5 mb-4">
                        <div class="w-7 h-7 rounded-md bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 font-bold text-xs flex items-center justify-center flex-shrink-0">IA</div>
                        <h3 class="font-bold text-base" data-i18n="tut.ia_title">Identity Assurance</h3>
                    </div>
                    <p class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed mb-5" data-i18n="tut.ia_p">
                        Identity Assurance (IA) is a score from 0 to 10 that tells you how confident you can be about a peer's identity. A 10 means you verified them yourself — you got their key directly from them. Lower scores mean you're relying on a chain of people who each vouched for the next. The longer that chain, and the less careful those people are, the lower the score.
                    </p>
                    <div id="score-rows" class="flex flex-col gap-1.5"></div>
                </div>

                <%-- Signing Failure Rate --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="flex items-center gap-2.5 mb-4">
                        <div class="w-7 h-7 rounded-md bg-amber-50 dark:bg-amber-900/30 text-amber-600 dark:text-amber-400 font-bold text-xs flex items-center justify-center flex-shrink-0">SF</div>
                        <h3 class="font-bold text-base" data-i18n="tut.sf_title">Signing Failure Rate</h3>
                    </div>
                    <p class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed mb-5" data-i18n="tut.sf_p">
                        Signing Failure Rate (SF) is your estimate of how someone verifies people before vouching for them. The question is not whether you like them as a person — it's about what they actually do before signing a certificate: do they meet people in person, or do they sign for anyone who asks? You set it yourself; nothing is tracked automatically. Every peer starts at 5.
                    </p>
                    <div class="flex flex-col gap-2">
                        <div class="flex items-center gap-3 px-3.5 py-2.5 rounded-lg bg-green-50 dark:bg-green-900/10 border border-green-200 dark:border-green-900/40">
                            <span class="font-mono font-bold text-xs text-green-700 dark:text-green-400 w-9 flex-shrink-0">1–2</span>
                            <span class="w-1.5 h-1.5 rounded-full bg-green-500 flex-shrink-0"></span>
                            <span class="text-sm text-gray-600 dark:text-gray-300" data-i18n="tut.sf_low">Signs only after meeting in person or through established channels</span>
                        </div>
                        <div class="flex items-center gap-3 px-3.5 py-2.5 rounded-lg bg-amber-50 dark:bg-amber-900/10 border border-amber-200 dark:border-amber-900/40">
                            <span class="font-mono font-bold text-xs text-amber-700 dark:text-amber-400 w-9 flex-shrink-0">4–6</span>
                            <span class="w-1.5 h-1.5 rounded-full bg-amber-500 flex-shrink-0"></span>
                            <span class="text-sm text-gray-600 dark:text-gray-300" data-i18n="tut.sf_mid">You know them, but have never seen how they verify people</span>
                        </div>
                        <div class="flex items-center gap-3 px-3.5 py-2.5 rounded-lg bg-red-50 dark:bg-red-900/10 border border-red-200 dark:border-red-900/40">
                            <span class="font-mono font-bold text-xs text-red-700 dark:text-red-400 w-9 flex-shrink-0">8–10</span>
                            <span class="w-1.5 h-1.5 rounded-full bg-red-500 flex-shrink-0"></span>
                            <span class="text-sm text-gray-600 dark:text-gray-300" data-i18n="tut.sf_high">Signs for anyone who asks</span>
                        </div>
                    </div>
                    <div class="text-xs text-gray-400 dark:text-gray-500 mt-3" data-i18n="tut.sf_note">These are guidelines, not rules. You decide what feels right for each peer.</div>
                </div>

                <%-- Trust Chain --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="flex items-center gap-2.5 mb-4">
                        <div class="w-7 h-7 rounded-md bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-400 font-bold text-[0.65rem] flex items-center justify-center flex-shrink-0">TC</div>
                        <h3 class="font-bold text-base" data-i18n="tut.tc_title">Trust Chain</h3>
                    </div>
                    <p class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed mb-5" data-i18n="tut.tc_p">
                        A Trust Chain is a chain of introductions. You know Alice, Alice knows Bob, Bob knows Clara — so you can reach Clara through that path. But each step adds a little uncertainty. The longer the chain, the less confident you can be at the end of it.
                    </p>
                    <div id="static-chain" class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-5 flex items-start justify-center gap-2 flex-wrap"></div>
                    <p class="text-xs text-gray-400 dark:text-gray-500 leading-relaxed mt-3" data-i18n="tut.tc_caption">
                        You know Alice directly. Alice vouches for Bob. Bob vouches for Clara, someone you've never met. Each step dilutes the confidence a little.
                    </p>
                </div>

                <%-- Certificate --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="flex items-center gap-2.5 mb-4">
                        <div class="w-7 h-7 rounded-md bg-indigo-50 dark:bg-indigo-900/30 text-indigo-600 dark:text-indigo-400 font-bold text-xs flex items-center justify-center flex-shrink-0">C</div>
                        <h3 class="font-bold text-base" data-i18n="tut.cert_title">Certificate</h3>
                    </div>
                    <p class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed mb-5" data-i18n="tut.cert_p">
                        A Certificate is one person vouching for another: "I know this person, and that key is really theirs." There's no central authority — certificates spread naturally as people connect with each other. They expire after 1 year: trust should be renewed, not assumed indefinitely.
                    </p>

                    <%-- Field guide --%>
                    <div class="flex flex-col gap-2 mb-5">
                        <div class="flex gap-3.5 px-4 py-3 bg-gray-50 dark:bg-gray-900/50 rounded-lg items-start">
                            <span class="font-mono text-xs font-bold text-indigo-700 dark:text-indigo-300 bg-indigo-100 dark:bg-indigo-900/40 rounded px-2 py-0.5 whitespace-nowrap flex-shrink-0" data-i18n="cert.f.subject">Subject</span>
                            <span class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="tut.f_subject">The person the certificate is about. Who is being identified and vouched for.</span>
                        </div>
                        <div class="flex gap-3.5 px-4 py-3 bg-gray-50 dark:bg-gray-900/50 rounded-lg items-start">
                            <span class="font-mono text-xs font-bold text-indigo-700 dark:text-indigo-300 bg-indigo-100 dark:bg-indigo-900/40 rounded px-2 py-0.5 whitespace-nowrap flex-shrink-0" data-i18n="cert.f.issuer">Issuer</span>
                            <span class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="tut.f_issuer">The person who signed this certificate. They're saying: "I know this person, and this key is really theirs." Their Signing Failure Rate affects how much weight this carries.</span>
                        </div>
                        <div class="flex gap-3.5 px-4 py-3 bg-gray-50 dark:bg-gray-900/50 rounded-lg items-start">
                            <span class="font-mono text-xs font-bold text-indigo-700 dark:text-indigo-300 bg-indigo-100 dark:bg-indigo-900/40 rounded px-2 py-0.5 whitespace-nowrap flex-shrink-0" data-i18n="tut.f_valid_label">Valid From / Until</span>
                            <span class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="tut.f_valid">Certificates are not permanent. After 1 year they expire and no longer count toward any IA score. Trust has to be renewed.</span>
                        </div>
                        <div class="flex gap-3.5 px-4 py-3 bg-gray-50 dark:bg-gray-900/50 rounded-lg items-start">
                            <span class="font-mono text-xs font-bold text-indigo-700 dark:text-indigo-300 bg-indigo-100 dark:bg-indigo-900/40 rounded px-2 py-0.5 whitespace-nowrap flex-shrink-0" data-i18n="tut.f_conn_label">Connection Type</span>
                            <span class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="tut.f_conn">How the two peers connect. For example, TCP for a direct internet connection. This tells the app how to reach the subject.</span>
                        </div>
                        <div class="flex gap-3.5 px-4 py-3 bg-gray-50 dark:bg-gray-900/50 rounded-lg items-start">
                            <span class="font-mono text-xs font-bold text-indigo-700 dark:text-indigo-300 bg-indigo-100 dark:bg-indigo-900/40 rounded px-2 py-0.5 whitespace-nowrap flex-shrink-0" data-i18n="tut.f_pubkey_label">Public Key</span>
                            <span class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="tut.f_pubkey">A unique mathematical fingerprint tied to one person. Anyone can see it; only the subject can use the matching private key to prove they are who they say they are.</span>
                        </div>
                    </div>

                    <div class="text-xs text-gray-400 dark:text-gray-500 mb-3" data-i18n="tut.cert_example">Here's what a real certificate looks like in the app:</div>

                    <%-- Example certificate --%>
                    <div class="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
                        <div class="bg-gray-50 dark:bg-gray-900/50 px-4 py-2.5 border-b border-gray-200 dark:border-gray-700 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider" data-i18n="cert.cert_title">Certificate</div>
                        <div class="px-4 py-2.5 border-b border-gray-100 dark:border-gray-700 flex gap-4">
                            <span class="text-xs text-gray-500 dark:text-gray-400 w-28 pt-0.5 flex-shrink-0" data-i18n="cert.f.subject">Subject</span>
                            <div>
                                <div class="font-semibold text-sm">Bob</div>
                                <div class="font-mono text-xs text-gray-500 dark:text-gray-400 mt-0.5">Bob_7mR2nX4p</div>
                            </div>
                        </div>
                        <div class="px-4 py-2.5 border-b border-gray-100 dark:border-gray-700 flex gap-4">
                            <span class="text-xs text-gray-500 dark:text-gray-400 w-28 pt-0.5 flex-shrink-0" data-i18n="cert.f.issuer">Issuer</span>
                            <div>
                                <div class="flex items-center gap-2">
                                    <span class="font-semibold text-sm">Alice</span>
                                    <span class="px-2 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400" data-i18n="cert.issued_by_you">Issued by you</span>
                                </div>
                                <div class="font-mono text-xs text-gray-500 dark:text-gray-400 mt-0.5">Alice_3Kf9xZ2m</div>
                            </div>
                        </div>
                        <div class="px-4 py-2.5 border-b border-gray-100 dark:border-gray-700 grid grid-cols-2 gap-3">
                            <div>
                                <div class="text-xs text-gray-500 dark:text-gray-400 mb-0.5" data-i18n="cert.f.valid_from">Valid From</div>
                                <div class="font-mono text-xs font-semibold">2025-10-15</div>
                            </div>
                            <div>
                                <div class="text-xs text-gray-500 dark:text-gray-400 mb-0.5" data-i18n="cert.th.valid_until">Valid Until</div>
                                <div class="font-mono text-xs font-semibold text-green-700 dark:text-green-400">2026-10-15</div>
                            </div>
                        </div>
                        <div class="px-4 py-2.5 border-b border-gray-100 dark:border-gray-700 flex gap-4 items-center">
                            <span class="text-xs text-gray-500 dark:text-gray-400 w-28 flex-shrink-0" data-i18n="tut.f_conn_label">Connection Type</span>
                            <span class="inline-flex px-2.5 py-0.5 rounded-full text-xs font-semibold bg-blue-50 text-blue-600 dark:bg-blue-900/30 dark:text-blue-400">TCP</span>
                        </div>
                        <div class="px-4 py-2.5">
                            <div class="text-xs text-gray-500 dark:text-gray-400 mb-1.5" data-i18n="tut.f_pubkey_label">Public Key</div>
                            <div class="font-mono text-xs text-gray-700 dark:text-gray-300 bg-gray-50 dark:bg-gray-900/50 rounded-md p-2.5 break-all leading-relaxed">MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3q7vBH3dX9kL2mPwZ5...</div>
                        </div>
                    </div>
                </div>

                <%-- Peers --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="flex items-center gap-2.5 mb-4">
                        <div class="w-7 h-7 rounded-md bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400 font-bold text-xs flex items-center justify-center flex-shrink-0">P</div>
                        <h3 class="font-bold text-base" data-i18n="cert.peers">Peers</h3>
                    </div>
                    <p class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="tut.peers_p">
                        There's no central server and no administrator. Every peer manages their own keys and decides independently who to trust, based only on what certificates they've personally received. Two people can have different IA scores for the same peer. That's not a bug — it's how the system works.
                    </p>
                </div>

                <%-- Interactive Playground --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="flex items-center gap-2.5 mb-1.5">
                        <h3 class="font-bold text-base" data-i18n="tut.play_title">Interactive Playground</h3>
                        <span class="inline-flex px-2.5 py-0.5 rounded-full text-xs font-semibold bg-blue-50 text-blue-600 dark:bg-blue-900/30 dark:text-blue-400" data-i18n="tut.live">Live</span>
                    </div>
                    <p class="text-sm text-gray-500 dark:text-gray-400 mb-5 leading-relaxed" data-i18n="tut.play_desc">
                        Adjust the SF sliders and watch the IA scores update in real time. See how one person's judgment ripples through the entire chain.
                    </p>

                    <div id="play-chain" class="bg-gray-50 dark:bg-gray-900/50 rounded-xl p-5 mb-5 flex items-start justify-center gap-2 flex-wrap overflow-x-auto"></div>

                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-5">
                        <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4 flex flex-col gap-2">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-semibold text-gray-500 dark:text-gray-400">Alice — <span data-i18n="cert.sf_title">Signing Failure Rate</span></span>
                                <span id="alice-sf-val" class="font-mono text-sm font-bold"></span>
                            </div>
                            <input type="range" min="1" max="10" value="2" id="alice-sf" class="w-full cursor-pointer">
                            <div class="flex justify-between text-[0.65rem] text-gray-400"><span data-i18n="tut.sf_scale_low">1: very trusted</span><span data-i18n="tut.sf_scale_high">10: unreliable</span></div>
                            <div class="text-xs text-gray-400 dark:text-gray-500 leading-relaxed" data-i18n="tut.slider_alice">Alice's SF directly affects Bob's IA</div>
                        </div>
                        <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4 flex flex-col gap-2">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-semibold text-gray-500 dark:text-gray-400">Bob — <span data-i18n="cert.sf_title">Signing Failure Rate</span></span>
                                <span id="bob-sf-val" class="font-mono text-sm font-bold"></span>
                            </div>
                            <input type="range" min="1" max="10" value="5" id="bob-sf" class="w-full cursor-pointer">
                            <div class="flex justify-between text-[0.65rem] text-gray-400"><span data-i18n="tut.sf_scale_low">1: very trusted</span><span data-i18n="tut.sf_scale_high">10: unreliable</span></div>
                            <div class="text-xs text-gray-400 dark:text-gray-500 leading-relaxed" data-i18n="tut.slider_bob">Bob's SF directly affects Clara's IA</div>
                        </div>
                        <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg p-4 flex flex-col gap-2">
                            <div class="flex items-center justify-between">
                                <span class="text-xs font-semibold text-gray-500 dark:text-gray-400">Clara — <span data-i18n="cert.sf_title">Signing Failure Rate</span></span>
                                <span id="clara-sf-val" class="font-mono text-sm font-bold"></span>
                            </div>
                            <input type="range" min="1" max="10" value="7" id="clara-sf" class="w-full cursor-pointer">
                            <div class="flex justify-between text-[0.65rem] text-gray-400"><span data-i18n="tut.sf_scale_low">1: very trusted</span><span data-i18n="tut.sf_scale_high">10: unreliable</span></div>
                            <div class="text-xs text-gray-400 dark:text-gray-500 leading-relaxed" data-i18n="tut.slider_clara">Clara's SF directly affects David's IA</div>
                        </div>
                    </div>

                    <div class="bg-blue-50 dark:bg-blue-900/10 border border-blue-200 dark:border-blue-900/40 rounded-lg px-4 py-3.5">
                        <div class="font-semibold text-xs text-blue-800 dark:text-blue-300 mb-2" data-i18n="tut.formula_title">How the score is calculated</div>
                        <div id="play-formula" class="font-mono text-xs text-blue-700 dark:text-blue-300 leading-loose"></div>
                    </div>
                </div>

                <%-- Interactive: 4 IA factors --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <h3 class="font-bold text-base mb-1" data-i18n="tut.factors_title">What affects the IA score?</h3>
                    <p class="text-sm text-gray-500 dark:text-gray-400 mb-5" data-i18n="tut.factors_desc">Interact with each factor to see it in action.</p>

                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">

                        <%-- Factor 1: Chain Length --%>
                        <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 flex flex-col gap-3">
                            <div class="flex items-center gap-2">
                                <div class="w-5 h-5 rounded-md bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 font-bold text-xs flex items-center justify-center flex-shrink-0">1</div>
                                <span class="font-semibold text-sm" data-i18n="cert.factor1_title">Certificate Chain</span>
                            </div>
                            <p class="text-xs text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="tut.f1_desc">Each extra hop between you and a peer adds uncertainty. Adjust the chain length and watch the IA drop.</p>
                            <div id="f1-viz" class="flex items-center gap-1.5 flex-wrap bg-gray-50 dark:bg-gray-900/50 rounded-lg px-3 py-2.5"></div>
                            <div>
                                <div class="flex justify-between text-xs text-gray-500 dark:text-gray-400 mb-1">
                                    <span data-i18n="tut.f1_slider">Chain length (hops)</span>
                                    <span id="f1-hops-val" class="font-mono font-bold text-gray-900 dark:text-white"></span>
                                </div>
                                <input type="range" min="1" max="5" value="2" id="f1-hops" class="w-full cursor-pointer" style="accent-color:#2563eb">
                                <div class="text-[0.65rem] text-gray-400 mt-0.5" data-i18n="tut.f1_note">SF = 3 assumed for everyone</div>
                            </div>
                            <div class="flex items-center gap-2.5 pt-2 border-t border-gray-100 dark:border-gray-700">
                                <span class="text-xs text-gray-500 dark:text-gray-400" data-i18n="tut.peer_ia">Peer's IA:</span>
                                <span id="f1-ia-num" class="font-mono font-bold text-sm"></span>
                                <div id="f1-ia-bar" class="flex gap-0.5 flex-1 max-w-[120px]"></div>
                                <span id="f1-ia-badge" class="inline-flex px-2 py-0.5 rounded-full text-xs font-semibold"></span>
                            </div>
                        </div>

                        <%-- Factor 2: SF of Issuer --%>
                        <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 flex flex-col gap-3">
                            <div class="flex items-center gap-2">
                                <div class="w-5 h-5 rounded-md bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 font-bold text-xs flex items-center justify-center flex-shrink-0">2</div>
                                <span class="font-semibold text-sm" data-i18n="cert.factor2_title">SF of the Issuer</span>
                            </div>
                            <p class="text-xs text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="tut.f2_desc">An issuer with a high SF lowers the IA of everyone they vouched for. Adjust Alice's SF and see what Bob gets.</p>
                            <div id="f2-viz" class="flex items-center justify-center gap-1.5 bg-gray-50 dark:bg-gray-900/50 rounded-lg px-3 py-2.5"></div>
                            <div>
                                <div class="flex justify-between text-xs text-gray-500 dark:text-gray-400 mb-1">
                                    <span data-i18n="tut.f2_slider">Alice's Signing Failure Rate</span>
                                    <span id="f2-sf-val" class="font-mono font-bold"></span>
                                </div>
                                <input type="range" min="1" max="10" value="5" id="f2-sf" class="w-full cursor-pointer">
                                <div class="flex justify-between text-[0.65rem] text-gray-400 mt-0.5"><span data-i18n="tut.sf_scale_low">1: very trusted</span><span data-i18n="tut.sf_scale_high">10: unreliable</span></div>
                            </div>
                            <div class="flex items-center gap-2.5 pt-2 border-t border-gray-100 dark:border-gray-700">
                                <span class="text-xs text-gray-500 dark:text-gray-400" data-i18n="tut.bob_ia">Bob's IA:</span>
                                <span id="f2-ia-num" class="font-mono font-bold text-sm"></span>
                                <div id="f2-ia-bar" class="flex gap-0.5 flex-1 max-w-[120px]"></div>
                                <span id="f2-ia-badge" class="inline-flex px-2 py-0.5 rounded-full text-xs font-semibold"></span>
                            </div>
                        </div>

                        <%-- Factor 3: Validity --%>
                        <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 flex flex-col gap-3">
                            <div class="flex items-center gap-2">
                                <div class="w-5 h-5 rounded-md bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 font-bold text-xs flex items-center justify-center flex-shrink-0">3</div>
                                <span class="font-semibold text-sm" data-i18n="cert.factor3_title">Validity</span>
                            </div>
                            <p class="text-xs text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="tut.f3_desc">Certificates older than 1 year stop counting toward the IA score. Trust has to be renewed.</p>
                            <div class="bg-gray-50 dark:bg-gray-900/50 rounded-lg px-3.5 py-3 flex flex-col gap-2">
                                <div class="flex justify-between items-center">
                                    <span class="text-xs text-gray-500 dark:text-gray-400" data-i18n="tut.f3_cert">Alice's certificate for Bob</span>
                                    <span id="f3-status" class="px-2 py-0.5 rounded-full text-xs font-semibold transition-colors"></span>
                                </div>
                                <div id="f3-age-note" class="text-xs text-gray-400"></div>
                                <div class="h-1 rounded-full bg-gray-200 dark:bg-gray-700 overflow-hidden relative">
                                    <div id="f3-bar" class="h-full rounded-full transition-all"></div>
                                </div>
                                <div class="flex justify-between text-[0.62rem] text-gray-400"><span data-i18n="tut.f3_now">now</span><span data-i18n="tut.f3_1y">1 year</span><span data-i18n="tut.f3_2y">2 years</span></div>
                            </div>
                            <div>
                                <div class="flex justify-between text-xs text-gray-500 dark:text-gray-400 mb-1">
                                    <span data-i18n="tut.f3_slider">Months since issued</span>
                                    <span id="f3-age-val" class="font-mono font-bold"></span>
                                </div>
                                <input type="range" min="0" max="24" value="6" id="f3-age" class="w-full cursor-pointer">
                            </div>
                            <div class="flex items-center gap-2.5 pt-2 border-t border-gray-100 dark:border-gray-700">
                                <span class="text-xs text-gray-500 dark:text-gray-400" data-i18n="tut.f3_counts">Counts toward IA:</span>
                                <span id="f3-counts" class="font-bold text-sm transition-colors"></span>
                            </div>
                        </div>

                        <%-- Factor 4: Direct Exchange --%>
                        <div id="f4-card" class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 flex flex-col gap-3 transition-colors">
                            <div class="flex items-center gap-2">
                                <div id="f4-num" class="w-5 h-5 rounded-md bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 font-bold text-xs flex items-center justify-center flex-shrink-0 transition-colors">4</div>
                                <span class="font-semibold text-sm" data-i18n="cert.factor4_title">Direct Exchange</span>
                            </div>
                            <p class="text-xs text-gray-500 dark:text-gray-400 leading-relaxed" data-i18n="tut.f4_desc">If you got someone's key directly from them, no chain applies. IA is always 10.</p>
                            <div class="flex gap-2">
                                <button id="f4-btn-network" class="flex-1 py-2 rounded-lg border-2 font-semibold text-xs transition-all" data-i18n="tut.f4_network">Through the network</button>
                                <button id="f4-btn-direct" class="flex-1 py-2 rounded-lg border-2 font-semibold text-xs transition-all" data-i18n="tut.f4_direct">Directly from them</button>
                            </div>
                            <div id="f4-viz" class="rounded-lg px-3.5 py-3 flex flex-col items-center gap-2 transition-colors"></div>
                            <div class="flex items-center gap-2.5 pt-2 border-t border-gray-100 dark:border-gray-700">
                                <span class="text-xs text-gray-500 dark:text-gray-400" data-i18n="tut.bob_ia">Bob's IA:</span>
                                <span id="f4-ia-num" class="font-mono font-bold text-sm"></span>
                                <div id="f4-ia-bar" class="flex gap-0.5 flex-1 max-w-[120px]"></div>
                                <span id="f4-ia-badge" class="inline-flex px-2 py-0.5 rounded-full text-xs font-semibold"></span>
                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </main>
    </div>

    <script src="js/pki-tutorial.js?v=1.0"></script>
</body>
</html>
