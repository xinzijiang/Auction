<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String email = request.getParameter("email");

    if(username == null || password == null || email == null ||
       username.isEmpty() || password.isEmpty() || email.isEmpty()) {
        response.sendRedirect("register.jsp?msg=All fields are required");
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();

    try {
        // Check duplicate username
        PreparedStatement psCheck = conn.prepareStatement("SELECT userID FROM EndUser WHERE username=?");
        psCheck.setString(1, username);
        ResultSet rs = psCheck.executeQuery();
        if(rs.next()) {
            response.sendRedirect("register.jsp?msg=Username already exists");
            return;
        }

        PreparedStatement ps = conn.prepareStatement("INSERT INTO EndUser (username, password, email) VALUES (?, ?, ?)");
        ps.setString(1, username);
        ps.setString(2, password);
        ps.setString(3, email);
        ps.executeUpdate();

        response.sendRedirect("login.jsp?msg=Registration successful, please log in");
    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        db.closeConnection(conn);
    }
%>