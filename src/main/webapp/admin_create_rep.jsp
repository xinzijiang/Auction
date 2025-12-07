<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%
    if (session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("login.jsp");
        return;
    }
    String u = request.getParameter("username");
    String p = request.getParameter("password");
    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();
    try {
        PreparedStatement ps = conn.prepareStatement("INSERT INTO CustomerRep (username, password) VALUES (?, ?)");
        ps.setString(1, u);
        ps.setString(2, p);
        ps.executeUpdate();
        response.sendRedirect("admin_dashboard.jsp");
    } catch(Exception e) {
        out.println("Error creating rep: " + e.getMessage());
    } finally {
        db.closeConnection(conn);
    }
%>