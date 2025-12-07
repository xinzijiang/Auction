<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%

    if (session.getAttribute("userID") == null) {
        response.sendRedirect("login.jsp");
        return; 
    }


    int repID = (Integer) session.getAttribute("userID");
    
    String qidStr = request.getParameter("qid");
    String ans = request.getParameter("answer");

    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();

    try {
        if (qidStr != null && ans != null) {
            int qid = Integer.parseInt(qidStr);

            String sql = "UPDATE Questions SET answerText=?, repID=? WHERE questionID=?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, ans);
            ps.setInt(2, repID);
            ps.setInt(3, qid);
            ps.executeUpdate();
        }
        
        response.sendRedirect("rep_dashboard.jsp");

    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        db.closeConnection(conn);
    }
%>