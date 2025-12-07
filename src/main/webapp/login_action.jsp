<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%
    String user = request.getParameter("username");
    String pass = request.getParameter("password");
    
    // Default error message
    String message = "Invalid username or password.";
    
    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();
    
    try {
        // 1. Check Admin Table
        PreparedStatement psAdmin = conn.prepareStatement("SELECT userID FROM Admin WHERE username=? AND password=?");
        psAdmin.setString(1, user);
        psAdmin.setString(2, pass);
        ResultSet rsAdmin = psAdmin.executeQuery();
        
        if(rsAdmin.next()) {
            session.setAttribute("user", user);
            session.setAttribute("role", "admin");
            session.setAttribute("userID", rsAdmin.getInt("userID"));
            response.sendRedirect("admin_dashboard.jsp"); // Redirect to Admin Page
            return;
        }

        // 2. Check CustomerRep Table
        PreparedStatement psRep = conn.prepareStatement("SELECT userID FROM CustomerRep WHERE username=? AND password=?");
        psRep.setString(1, user);
        psRep.setString(2, pass);
        ResultSet rsRep = psRep.executeQuery();
        
        if(rsRep.next()) {
            session.setAttribute("user", user);
            session.setAttribute("role", "rep");
            session.setAttribute("userID", rsRep.getInt("userID"));
            response.sendRedirect("rep_dashboard.jsp"); // Redirect to Rep Page
            return;
        }

        // 3. Check EndUser Table
        PreparedStatement psUser = conn.prepareStatement("SELECT userID FROM EndUser WHERE username=? AND password=?");
        psUser.setString(1, user);
        psUser.setString(2, pass);
        ResultSet rsUser = psUser.executeQuery();
        
        if(rsUser.next()) {
            session.setAttribute("user", user);
            session.setAttribute("role", "user");
            session.setAttribute("userID", rsUser.getInt("userID"));
            response.sendRedirect("browse.jsp"); // Redirect to User Browse Page
            return;
        }
        
        // If no match found
        request.setAttribute("message", message);
        request.getRequestDispatcher("login.jsp").forward(request, response);

    } catch(Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        db.closeConnection(conn);
    }
%>