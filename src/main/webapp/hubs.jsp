<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    /**
     * Hub management has been merged into the Network page (Hub tab)
     * as part of the UC1 redesign. This page remains as a permanent
     * redirect so old bookmarks and links keep working.
     */
    response.sendRedirect("network.jsp?tab=hub");
%>
