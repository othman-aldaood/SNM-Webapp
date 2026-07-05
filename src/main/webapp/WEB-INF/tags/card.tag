<%@ tag description="Reusable Tailwind Card Component for Layouts" pageEncoding="UTF-8"%>

<%-- ==========================================
     1. Attribute Declarations
=========================================== --%>
<%@ attribute name="title" required="false" type="java.lang.String" %>
<%@ attribute name="icon" required="false" type="java.lang.String" %>
<%@ attribute name="padding" required="false" type="java.lang.String" %>
<%@ attribute name="cssClass" required="false" type="java.lang.String" %>
<%-- Added optional localization key attribute --%>
<%@ attribute name="key" required="false" type="java.lang.String" %>

<%
    /**
     * ==========================================
     * 2. Default Fallbacks Processing
     * ==========================================
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

            <%-- Render the card title with optional i18n support attribute --%>
            <h3 class="font-bold text-gray-800 dark:text-white" <% if (key != null && !key.isEmpty()) { %> data-i18n="<%= key %>" <% } %>>${title}</h3>
        </div>
    <% } %>

    <%-- Card Body --%>
    <div class="<%= finalPadding %> flex-1">
        <jsp:doBody/>
    </div>
</div>