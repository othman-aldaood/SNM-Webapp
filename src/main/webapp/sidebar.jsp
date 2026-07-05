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

<nav id="app-sidebar" class="fixed md:sticky top-16 left-0 z-40 h-[calc(100vh-4rem)] w-64 md:w-64 -translate-x-full md:translate-x-0 transition-all duration-300 ease-in-out bg-white dark:bg-dark-card border-r border-gray-200 dark:border-dark-border p-3 flex flex-col gap-2 overflow-x-hidden overflow-y-auto shadow-2xl md:shadow-none">

    <a href="index.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'messenger' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-comment-dots"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.messenger">Messenger</span>
    </a>

    <a href="contacts.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'contacts' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-users"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.peer">Peer Contacts</span>
    </a>

    <a href="persons.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'persons' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-user"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.persons">Persons</span>
    </a>

    <a href="certificates.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'certificates' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-key"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.certificates">Certificates</span>
    </a>

    <a href="network.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'network' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-network-wired"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.network">Network Status</span>
    </a>

    <a href="settings.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'settings' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-cog"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.settings">Settings</span>
    </a>

    <a href="profile.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'profile' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-id-card"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.profile">My Profile</span>
    </a>

    <a href="welcome.jsp" class="flex items-center gap-4 px-3 py-3 rounded-lg font-medium transition-colors duration-200 whitespace-nowrap ${activePage == 'welcome' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-8 text-center flex-shrink-0"><i class="fas fa-question-circle text-lg"></i></span>
        <span class="sidebar-text transition-opacity duration-200" data-i18n="nav.help">Help</span>
    </a>

</nav>