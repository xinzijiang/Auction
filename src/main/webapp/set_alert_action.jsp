<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%
    // Ensure user is logged in
    if (session.getAttribute("userID") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int uid = (Integer) session.getAttribute("userID");
    String type  = request.getParameter("type");
    String brand = request.getParameter("brand");
    String color = request.getParameter("color");

    // Helper function to handle empty strings as NULL
    // If the user leaves a field blank, we want it to be NULL in the database
    // so we can match "Any Brand" or "Any Color" later.
    if (type != null && type.trim().isEmpty()) type = null;
    if (brand != null && brand.trim().isEmpty()) brand = null;
    if (color != null && color.trim().isEmpty()) color = null;

    // Basic input validation
    if (type == null && brand == null && color == null) {
        out.println("Please provide at least one alert criterion. <a href='set_alert.jsp'>Back</a>");
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();
    
    try {
        // FIXED: Column order now matches schema: desiredType, desiredColor, desiredBrand
        String sql = "INSERT INTO AlertCriteria (userID, desiredType, desiredColor, desiredBrand) VALUES (?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, uid);
        ps.setString(2, type);   // desiredType
        ps.setString(3, color);  // desiredColor
        ps.setString(4, brand);  // desiredBrand
        ps.executeUpdate();
        ps.close();

        out.println("Alert Criteria Saved! <a href='browse.jsp'>Back</a>");
    } catch (Exception e) {
        out.println("Error saving alert criteria: " + e.getMessage());
    } finally {
        db.closeConnection(conn);
    }
%>