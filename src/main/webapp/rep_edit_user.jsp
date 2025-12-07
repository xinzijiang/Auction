<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head><title>Edit User</title></head>
<body>
    <%
        if (session.getAttribute("role") == null || !session.getAttribute("role").equals("rep")) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    <h2>Edit User Account</h2>
    <%
        String uidStr = request.getParameter("uid");
        if(uidStr == null) {
            response.sendRedirect("rep_dashboard.jsp");
            return;
        }
        int uid = Integer.parseInt(uidStr);
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM EndUser WHERE userID=?");
        ps.setInt(1, uid);
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
    %>
        <form action="rep_edit_user_action.jsp" method="post">
            <input type="hidden" name="uid" value="<%= uid %>">
            Username: <input type="text" name="username" value="<%= rs.getString("username") %>" readonly><br>
            Password: <input type="text" name="password" value="<%= rs.getString("password") %>"><br>
            Email: <input type="text" name="email" value="<%= rs.getString("email") %>"><br>
            <input type="submit" value="Update User">
        </form>
    <%
        } else {
            out.println("User not found.");
        }
        db.closeConnection(conn);
    %>
    <br><a href="rep_dashboard.jsp">Back</a>
</body>
</html>