<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%
    // Ensure user is logged in
    if (session.getAttribute("userID") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int uid = (Integer) session.getAttribute("userID");
    String qText = request.getParameter("question");
    
    if (qText == null || qText.trim().isEmpty()) {
        response.sendRedirect("qa_forum.jsp?msg=Question cannot be empty");
        return;
    }
    
    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();
    
    try {
        PreparedStatement ps = conn.prepareStatement("INSERT INTO Questions (userID, questionText) VALUES (?, ?)");
        ps.setInt(1, uid);
        ps.setString(2, qText.trim());
        ps.executeUpdate();
        ps.close();
        
        response.sendRedirect("qa_forum.jsp");
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        db.closeConnection(conn);
    }
%>