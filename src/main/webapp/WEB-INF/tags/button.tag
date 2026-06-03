<%@ tag description="Highly Customizable Tailwind Button Component" pageEncoding="UTF-8"%>

<%-- ==========================================
     1. Attribute Declarations
=========================================== --%>
<%-- Required: The text to display inside the button --%>
<%@ attribute name="text" required="true" type="java.lang.String" %>

<%-- Optional: Provide fallback values if omitted by the developer --%>
<%@ attribute name="theme" required="false" type="java.lang.String" %>
<%@ attribute name="size" required="false" type="java.lang.String" %>
<%@ attribute name="icon" required="false" type="java.lang.String" %>
<%@ attribute name="onClick" required="false" type="java.lang.String" %>
<%@ attribute name="type" required="false" type="java.lang.String" %>
<%@ attribute name="cssClass" required="false" type="java.lang.String" %>

<%
    /**
     * ==========================================
     * 2. Default Fallbacks & Theme Processing
     * ==========================================
     * Processes optional attributes and assigns default values to ensure
     * the component always renders correctly without breaking the UI.
     * @param type     The HTML button type (default: "button" to prevent accidental form submissions)
     * @param theme    The visual color theme (default: "primary")
     * @param size     The size of the button determining padding and text size (default: "md")
     * @param cssClass Additional custom Tailwind utility classes (default: "")
     */

    String btnType = (type != null && !type.isEmpty()) ? type : "button";
    String extraClasses = (cssClass != null) ? cssClass : "";

    /**
     * --- Theme Processing ---
     * Assigns specific Tailwind color classes based on the selected theme.
     */
    String btnTheme = (theme != null && !theme.isEmpty()) ? theme : "primary";
    String themeClasses = "bg-primary-500 hover:bg-primary-600 text-white"; // Default: Blue

    if ("danger".equals(btnTheme)) {
        themeClasses = "bg-red-500 hover:bg-red-600 text-white";
    } else if ("success".equals(btnTheme)) {
        themeClasses = "bg-green-500 hover:bg-green-600 text-white";
    } else if ("secondary".equals(btnTheme)) {
        themeClasses = "bg-gray-100 hover:bg-gray-200 text-gray-700 dark:bg-gray-800 dark:hover:bg-gray-700 dark:text-gray-300 border border-gray-300 dark:border-gray-600";
    } else if ("transparent".equals(btnTheme)) {
        themeClasses = "bg-transparent text-gray-500 hover:text-primary-500 dark:text-gray-400 dark:hover:text-primary-400";
    }

    /**
     * --- Size Processing ---
     * Assigns specific padding and text size classes based on the requested size.
     */
    String btnSize = (size != null && !size.isEmpty()) ? size : "md";
    String sizeClasses = "px-4 py-2 text-sm"; // Default: Medium

    if ("sm".equals(btnSize)) {
        sizeClasses = "px-3 py-1.5 text-xs"; // Small
    } else if ("lg".equals(btnSize)) {
        sizeClasses = "px-6 py-3 text-base"; // Large
    }
%>

<%-- ==========================================
     3. Final HTML Rendering
=========================================== --%>
<button type="<%= btnType %>"
        <% if (onClick != null && !onClick.isEmpty()) { %> onclick="${onClick}" <% } %>
        class="rounded-lg font-medium shadow-sm transition-colors flex items-center justify-center gap-2 <%= sizeClasses %> <%= themeClasses %> <%= extraClasses %>">

    <%-- Render the FontAwesome icon if provided --%>
    <% if (icon != null && !icon.isEmpty()) { %>
        <i class="${icon}"></i>
    <% } %>

    <%-- Render the mandatory button text --%>
    <span>${text}</span>
</button>