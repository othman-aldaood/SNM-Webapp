<%@ tag description="Reusable Tailwind Card Component for Layouts" pageEncoding="UTF-8"%>

<%-- ==========================================
     1. Attribute Declarations
=========================================== --%>
<%-- Optional: The title displayed in the card header --%>
<%@ attribute name="title" required="false" type="java.lang.String" %>

<%-- Optional: FontAwesome icon class to display next to the title (e.g., fas fa-server) --%>
<%@ attribute name="icon" required="false" type="java.lang.String" %>

<%-- Optional: Padding utility class for the card body (default: p-4) --%>
<%@ attribute name="padding" required="false" type="java.lang.String" %>

<%-- Optional: Additional Tailwind CSS classes for the main card container --%>
<%@ attribute name="cssClass" required="false" type="java.lang.String" %>

<%
    /**
     * ==========================================
     * 2. Default Fallbacks Processing
     * ==========================================
     * Processes optional attributes and assigns default values.
     * This component acts as a flexible container and renders any nested HTML
     * via the <jsp:doBody/> tag.
     *
     * @param padding  The Tailwind padding utility class for the card body (default: "p-4")
     * @param cssClass Additional CSS classes for custom layout styling (default: "")
     */

    String finalPadding = (padding != null && !padding.isEmpty()) ? padding : "p-4";
    String extraClasses = (cssClass != null) ? cssClass : "";
%>

<%-- ==========================================
     3. Final HTML Rendering
=========================================== --%>
<div class="bg-white dark:bg-dark-card border border-gray-200 dark:border-dark-border rounded-xl shadow-sm flex flex-col <%= extraClasses %>">

    <%-- Render the Header only if a title is explicitly provided --%>
    <% if (title != null && !title.isEmpty()) { %>
        <div class="p-4 border-b border-gray-200 dark:border-dark-border bg-gray-50 dark:bg-gray-800/50 rounded-t-xl flex items-center gap-2">

            <%-- Render the icon if provided --%>
            <% if (icon != null && !icon.isEmpty()) { %>
                <i class="${icon} text-gray-500 dark:text-gray-400"></i>
            <% } %>

            <%-- Render the card title --%>
            <h3 class="font-bold text-gray-800 dark:text-white">${title}</h3>
        </div>
    <% } %>

    <%-- Card Body: Renders whatever content is placed inside the component tags --%>
    <div class="<%= finalPadding %> flex-1">
        <jsp:doBody/>
    </div>
</div>