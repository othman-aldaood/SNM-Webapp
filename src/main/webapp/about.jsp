<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>
<%
    /**
     * About page (UC-Help) - static information about the application,
     * its authors and the technology stack. No backend calls required.
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
<ui:head title="About - SharkNet Messenger"/>

<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 transition-colors duration-300">
    <jsp:include page="header.jsp" />

    <div class="flex flex-col md:flex-row min-h-screen">
        <% request.setAttribute("activePage", "about"); %>
        <jsp:include page="sidebar.jsp" />

        <main class="flex-1 p-4 md:p-6 w-full max-w-full overflow-x-hidden">
            <div class="max-w-4xl mx-auto space-y-4 md:space-y-6">

                <%-- Page Header --%>
                <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-2 gap-4">
                    <div>
                        <h1 class="text-xl md:text-2xl font-bold font-mono" data-i18n="about.title">About SharkNet Messenger</h1>
                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="about.desc">A decentralised peer-to-peer messenger built on the ASAP protocol.</p>
                    </div>
                </div>

                <%-- App Identity --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="flex items-center gap-4">
                        <div class="w-14 h-14 rounded-xl bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 flex items-center justify-center flex-shrink-0">
                            <i class="fas fa-water text-2xl"></i>
                        </div>
                        <div class="min-w-0">
                            <div class="flex items-center gap-2 flex-wrap">
                                <h2 class="font-bold text-lg">SharkNet Messenger</h2>
                                <span class="px-2 py-0.5 rounded-full text-xs font-semibold bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-300">
                                    <span data-i18n="about.version_label">Version</span> 1.0.0
                                </span>
                            </div>
                            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1" data-i18n="about.description">A decentralised peer-to-peer messenger built on the ASAP protocol</p>
                        </div>
                    </div>
                </div>

                <%-- Team & Supervisor --%>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 md:gap-6">
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                        <div class="flex items-center gap-2.5 mb-4">
                            <div class="w-7 h-7 rounded-md bg-purple-50 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400 flex items-center justify-center flex-shrink-0">
                                <i class="fas fa-users text-xs"></i>
                            </div>
                            <h3 class="font-bold text-base" data-i18n="about.team_label">Team</h3>
                        </div>
                        <ul class="space-y-2 text-sm text-gray-700 dark:text-gray-300">
                            <li class="flex items-center gap-2">
                                <i class="fas fa-user text-gray-400 text-xs"></i> Yigit Peker
                                <a href="https://github.com/yigitpeker34" target="_blank" rel="noopener noreferrer" class="text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 transition-colors" title="Yigit Peker on GitHub">
                                    <i class="fab fa-github"></i>
                                </a>
                            </li>
                            <li class="flex items-center gap-2">
                                <i class="fas fa-user text-gray-400 text-xs"></i> Othman Al Daood
                                <a href="https://github.com/othman-aldaood" target="_blank" rel="noopener noreferrer" class="text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 transition-colors" title="Othman Al Daood on GitHub">
                                    <i class="fab fa-github"></i>
                                </a>
                            </li>
                        </ul>
                    </div>

                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                        <div class="flex items-center gap-2.5 mb-4">
                            <div class="w-7 h-7 rounded-md bg-amber-50 dark:bg-amber-900/30 text-amber-600 dark:text-amber-400 flex items-center justify-center flex-shrink-0">
                                <i class="fas fa-chalkboard-teacher text-xs"></i>
                            </div>
                            <h3 class="font-bold text-base" data-i18n="about.supervisor_label">Supervisor</h3>
                        </div>
                        <p class="text-sm text-gray-700 dark:text-gray-300">Prof. T. Schwotzer</p>
                        <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">HTW Berlin</p>
                    </div>
                </div>

                <%-- Technologies Used --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="flex items-center gap-2.5 mb-4">
                        <div class="w-7 h-7 rounded-md bg-green-50 dark:bg-green-900/30 text-green-600 dark:text-green-400 flex items-center justify-center flex-shrink-0">
                            <i class="fas fa-layer-group text-xs"></i>
                        </div>
                        <h3 class="font-bold text-base" data-i18n="about.tech_label">Technologies Used</h3>
                    </div>
                    <div class="flex flex-wrap gap-2">
                        <span class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300">Java Servlets</span>
                        <span class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300">Jakarta EE</span>
                        <span class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300">Tailwind CSS</span>
                        <span class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300">Apache Tomcat 10</span>
                    </div>
                </div>

                <%-- Source Code --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-4 md:p-6">
                    <div class="flex items-center justify-between flex-wrap gap-3">
                        <div class="flex items-center gap-2.5">
                            <div class="w-7 h-7 rounded-md bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 flex items-center justify-center flex-shrink-0">
                                <i class="fab fa-github text-xs"></i>
                            </div>
                            <h3 class="font-bold text-base" data-i18n="about.source_label">Source Code</h3>
                        </div>
                        <a href="https://github.com/SharedKnowledge/SharkNetMessenger" target="_blank" rel="noopener noreferrer" class="bg-gray-800 hover:bg-gray-900 dark:bg-gray-700 dark:hover:bg-gray-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors flex items-center gap-2">
                            <i class="fab fa-github"></i> <span data-i18n="about.github_link">View on GitHub</span>
                        </a>
                    </div>
                </div>

            </div>
        </main>
    </div>
</body>
</html>
