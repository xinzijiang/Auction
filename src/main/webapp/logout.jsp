<%@ page session="true" %>
<%@ page import="javax.servlet.RequestDispatcher" %>
<%
    session.invalidate();

    request.setAttribute("message", "You have been logged out successfully.");
    

    RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
    rd.forward(request, response);
%>