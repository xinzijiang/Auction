<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head><title>My Alerts</title></head>
<body>
    <h2>My Notifications</h2>
    <a href="browse.jsp">Back to Browse</a>
    <hr>
    
    <table border="1" width="80%">
        <tr><th>Date</th><th>Message</th></tr>
        <%
            if (session.getAttribute("userID") == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            int uid = (Integer) session.getAttribute("userID");
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();
            
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM Alert WHERE userID=? ORDER BY createdAt DESC");
            ps.setInt(1, uid);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
        %>
            <tr>
                <td><%= rs.getTimestamp("createdAt") %></td>
                <td><%= rs.getString("message") %></td>
            </tr>
        <% 
            }
            db.closeConnection(conn);
        %>
    </table>
</body>
</html>