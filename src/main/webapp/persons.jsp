<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    /**
     * The Persons tab was removed: the redesigned Certificates page (UC4)
     * shows the same data (peers with IA score and signing failure rate).
     * This page remains as a permanent redirect so old bookmarks and
     * links keep working. The /api/persons endpoint is unaffected.
     */
    response.sendRedirect("certificates.jsp");
%>
