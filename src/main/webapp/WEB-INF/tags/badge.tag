<%@ tag description="Reusable Tailwind Badge Component for Status Indicators" pageEncoding="UTF-8"%>

<%-- ==========================================
     1. Attribute Declarations
=========================================== --%>
<%-- Required: The text to display inside the badge --%>
<%@ attribute name="text" required="true" type="java.lang.String" %>

<%-- Optional: Theme color, icon, and custom CSS classes --%>
<%@ attribute name="theme" required="false" type="java.lang.String" %>
<%@ attribute name="icon" required="false" type="java.lang.String" %>
<%@ attribute name="cssClass" required="false" type="java.lang.String" %>

<%
    /**
     * ==========================================
     * 2. Theme Processing & Default Fallbacks
     * ==========================================
     * Evaluates the requested theme and assigns the corresponding Tailwind
     * utility classes for background, text, and border colors.
     *
     * @param theme    The semantic color theme (default: "info")
     * Accepts: "success", "warning", "danger", "primary"
     * @param cssClass Additional CSS classes for custom styling
     */
    String finalTheme = (theme != null && !theme.isEmpty()) ? theme : "info";
    String extraClasses = (cssClass != null) ? cssClass : "";

    // Default theme (info/gray)
    String themeClasses = "bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300 border border-gray-200 dark:border-gray-700";

    if ("success".equals(finalTheme)) {
        themeClasses = "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400 border border-green-200 dark:border-green-800/50";
    } else if ("warning".equals(finalTheme)) {
        themeClasses = "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400 border border-yellow-200 dark:border-yellow-800/50";
    } else if ("danger".equals(finalTheme)) {
        themeClasses = "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400 border border-red-200 dark:border-red-800/50";
    } else if ("primary".equals(finalTheme)) {
        themeClasses = "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 border border-blue-200 dark:border-blue-800/50";
    }
%>

<%-- ==========================================
     3. Final HTML Rendering
=========================================== --%>
<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold shadow-sm <%= themeClasses %> <%= extraClasses %>">
    <% if (icon != null && !icon.isEmpty()) { %>
        <i class="${icon} text-[10px]"></i>
    <% } %>
    <span>${text}</span>
</span>