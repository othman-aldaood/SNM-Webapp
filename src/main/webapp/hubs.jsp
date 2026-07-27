<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    /**
     * Hub management now lives on its own page (hub-connections.jsp).
     * This page remains as a permanent redirect so old bookmarks and
     * links keep working.
     */
    response.sendRedirect("hub-connections.jsp");
%>
