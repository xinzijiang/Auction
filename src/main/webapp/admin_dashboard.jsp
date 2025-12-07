<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head><title>Admin Dashboard</title></head>
<body>
    <%
        if (session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    <h2>Administrator Dashboard</h2>
    <p>Welcome, Admin!</p>
    
    <div style="border:1px solid #000; padding:10px; margin-bottom:20px;">
        <h3>Create Customer Representative</h3>
        <form action="admin_create_rep.jsp" method="post">
            Username: <input type="text" name="username" required>
            Password: <input type="text" name="password" required>
            <input type="submit" value="Create Rep Account">
        </form>
    </div>
    
    <hr>
    <h3>Sales Reports</h3>
    <%
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();
        Statement stmt = conn.createStatement();
    %>
    
    <h4>A. Total Earnings</h4>
    <%
        ResultSet rs1 = stmt.executeQuery("SELECT SUM(currentPrice) FROM Auction WHERE status='Sold'");
        if(rs1.next()) out.println("<b>Total Revenue: $" + rs1.getFloat(1) + "</b>");
        rs1.close();
    %>
    
    <h4>B. Earnings Per Item Type</h4>
    <table border="1">
    <tr><th>Type</th><th>Total Earnings</th></tr>
    <%
        String sql2 = "SELECT c.type, SUM(a.currentPrice) FROM Auction a JOIN ClothingItem c ON a.clothingID=c.clothingID WHERE a.status='Sold' GROUP BY c.type";
        ResultSet rs2 = stmt.executeQuery(sql2);
        while(rs2.next()) {
            out.println("<tr><td>" + rs2.getString(1) + "</td><td>$" + rs2.getFloat(2) + "</td></tr>");
        }
        rs2.close();
    %>
    </table>

    <h4>C. Earnings Per Specific Item</h4>
    <table border="1">
    <tr><th>Item Title</th><th>Sold Price</th></tr>
    <%
        String sqlPerItem = "SELECT title, currentPrice FROM Auction WHERE status='Sold' ORDER BY currentPrice DESC";
        ResultSet rsPerItem = stmt.executeQuery(sqlPerItem);
        while(rsPerItem.next()) {
            out.println("<tr><td>" + rsPerItem.getString(1) + "</td><td>$" + rsPerItem.getFloat(2) + "</td></tr>");
        }
        rsPerItem.close();
    %>
    </table>

    <h4>D. Earnings Per End-User (Seller Revenue)</h4>
    <table border="1">
    <tr><th>Seller Username</th><th>Total Earnings</th></tr>
    <%
        String sqlPerSeller = "SELECT u.username, SUM(a.currentPrice) as total FROM Auction a JOIN EndUser u ON a.sellerID = u.userID WHERE a.status='Sold' GROUP BY u.username ORDER BY total DESC";
        ResultSet rsPerSeller = stmt.executeQuery(sqlPerSeller);
        while(rsPerSeller.next()) {
            out.println("<tr><td>" + rsPerSeller.getString(1) + "</td><td>$" + rsPerSeller.getFloat(2) + "</td></tr>");
        }
        rsPerSeller.close();
    %>
    </table>

    <h4>E. Best Selling Items (Top 3 by Quantity)</h4>
    <table border="1">
    <tr><th>Item Type/Brand</th><th>Quantity Sold</th></tr>
    <%
        String sql3 = "SELECT CONCAT(c.brand, ' ', c.type) as name, COUNT(*) as cnt FROM Auction a JOIN ClothingItem c ON a.clothingID=c.clothingID WHERE a.status='Sold' GROUP BY name ORDER BY cnt DESC LIMIT 3";
        ResultSet rs3 = stmt.executeQuery(sql3);
        while(rs3.next()) {
            out.println("<tr><td>" + rs3.getString(1) + "</td><td>" + rs3.getInt(2) + "</td></tr>");
        }
        rs3.close();
    %>
    </table>

    <h4>F. Best Buyers (Top Spenders)</h4>
    <table border="1">
    <tr><th>User</th><th>Total Spent</th></tr>
    <%
        // Complex query to find the actual winner of each sold auction and sum their spending
        // We use a subquery to identify the winner (highest bidder) for each sold auction
        String sql4 = "SELECT u.username, SUM(final_prices.price) as total_spent " +
                      "FROM ( " +
                      "  SELECT a.auctionID, a.currentPrice as price, " +
                      "  (SELECT b.userID FROM Bid b WHERE b.auctionID = a.auctionID ORDER BY b.amount DESC, b.bidTime ASC LIMIT 1) as winnerID " +
                      "  FROM Auction a " +
                      "  WHERE a.status = 'Sold' " +
                      ") as final_prices " +
                      "JOIN EndUser u ON final_prices.winnerID = u.userID " +
                      "GROUP BY u.username " +
                      "ORDER BY total_spent DESC LIMIT 3";
                      
        ResultSet rs4 = stmt.executeQuery(sql4);
        while(rs4.next()) {
            out.println("<tr><td>" + rs4.getString(1) + "</td><td>$" + rs4.getFloat(2) + "</td></tr>");
        }
        rs4.close();
        db.closeConnection(conn);
    %>
    </table>
    
    <br><a href="logout.jsp">Logout</a>
</body>
</html>