<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%
    if (session.getAttribute("role") == null || !session.getAttribute("role").equals("rep")) {
        response.sendRedirect("login.jsp");
        return;
    }
    String uidStr = request.getParameter("uid");
    String pass = request.getParameter("password");
    String email = request.getParameter("email");

    if (uidStr == null || pass == null || email == null) {
        response.sendRedirect("rep_dashboard.jsp");
        return;
    }

    int uid = Integer.parseInt(uidStr);
    
    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();
    try {
        PreparedStatement ps = conn.prepareStatement("UPDATE EndUser SET password=?, email=? WHERE userID=?");
        ps.setString(1, pass);
        ps.setString(2, email);
        ps.setInt(3, uid);
        ps.executeUpdate();
        out.println("User updated successfully. <a href='rep_dashboard.jsp'>Back</a>");
    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        db.closeConnection(conn);
    }
%>