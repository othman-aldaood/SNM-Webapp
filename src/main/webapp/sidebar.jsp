<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntimeManager" %>
<%@ page import="net.sharksystem.web.peer.PeerRuntime" %>

<%
    PeerRuntimeManager sidebarManager = PeerRuntimeManager.getInstance();
    PeerRuntime sidebarActivePeer = sidebarManager.getActivePeer();

    if (sidebarActivePeer == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<nav id="app-sidebar" class="fixed md:sticky top-16 left-0 z-40 h-[calc(100vh-4rem)] w-72 md:w-72 -translate-x-full md:translate-x-0 transition-all duration-300 ease-in-out bg-white dark:bg-dark-card border-r border-gray-200 dark:border-dark-border p-3 flex flex-col gap-2 overflow-x-hidden overflow-y-auto shadow-2xl md:shadow-none">

    <a href="index.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'messenger' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-comment-dots"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.messenger">Messenger</span>
    </a>

    <a href="contacts.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'contacts' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-users"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.peer">Manageable Peers</span>
    </a>

    <a href="encounters.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'encounters' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-handshake"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.encounters">Encounter Management</span>
    </a>

    <a href="tcp-connections.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'tcp' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-network-wired"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.tcp">TCP Connections</span>
    </a>

    <a href="hub-connections.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'hubs' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-server"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.hubs">Hub Connections</span>
    </a>

    <a href="certificates.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'certificates' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-key"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.certificates">Certificate Management</span>
    </a>

    <a href="settings.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'settings' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-cog"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.settings">Settings</span>
    </a>

    <a href="profile.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'profile' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-id-card"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.profile">My Profile</span>
    </a>

</nav>