<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
/**
 * Sidebar Navigation Component
 * Provides responsive navigation links across the application using FontAwesome icons.
 */
--%>
<nav id="app-sidebar" class="w-full md:w-64 bg-white dark:bg-dark-card border-r border-gray-200 dark:border-dark-border min-h-screen p-4 flex flex-col gap-2 transition-all duration-300">

    <a href="index.jsp" class="flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-colors duration-200 ${activePage == 'messenger' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-6 text-center"><i class="fas fa-comment-dots"></i></span>
        <span>Messenger</span>
    </a>

    <a href="contacts.jsp" class="flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-colors duration-200 ${activePage == 'contacts' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-6 text-center"><i class="fas fa-users"></i></span>
        <span>Peer</span>
    </a>

    <a href="persons.jsp" class="flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-colors duration-200 ${activePage == 'persons' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-6 text-center"><i class="fas fa-user"></i></span>
        <span>Persons</span>
    </a>

    <a href="certificates.jsp" class="flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-colors duration-200 ${activePage == 'certificates' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-6 text-center"><i class="fas fa-key"></i></span>
        <span>Certificates</span>
    </a>

    <a href="network.jsp" class="flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-colors duration-200 ${activePage == 'network' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-6 text-center"><i class="fas fa-network-wired"></i></span>
        <span>Network Status</span>
    </a>

    <a href="hubs.jsp" class="flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-colors duration-200 ${activePage == 'hubs' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-6 text-center"><i class="fas fa-satellite-dish"></i></span>
        <span>ASAP Hubs</span>
    </a>

    <a href="settings.jsp" class="flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-colors duration-200 ${activePage == 'settings' ? 'bg-primary-500 text-white shadow-md' : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'}">
        <span class="text-xl w-6 text-center"><i class="fas fa-cog"></i></span>
        <span>Settings</span>
    </a>

</nav>