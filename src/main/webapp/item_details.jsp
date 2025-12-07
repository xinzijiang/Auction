<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%
    String idStr = request.getParameter("id");
    if(idStr == null) { 
        response.sendRedirect("browse.jsp"); 
        return; 
    }
    
    int auctionID = Integer.parseInt(idStr);
    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();
    
    // 1. Fetch Auction and Item Details
    String sqlItem = "SELECT a.*, c.* FROM Auction a JOIN ClothingItem c ON a.clothingID = c.clothingID WHERE a.auctionID=?";
    PreparedStatement psItem = conn.prepareStatement(sqlItem);
    psItem.setInt(1, auctionID);
    ResultSet rsItem = psItem.executeQuery();
    
    if(!rsItem.next()) {
        out.println("Item not found.");
        db.closeConnection(conn);
        return;
    }
    
    String currentType = rsItem.getString("type");
    String currentBrand = rsItem.getString("brand");
    String currentColor = rsItem.getString("color");
    float currentPrice = rsItem.getFloat("currentPrice");
    float increment = rsItem.getFloat("increment");
    String status = rsItem.getString("status");
    
    // Determine if there are existing bids to compute correct minimum required bid
    PreparedStatement psCount = conn.prepareStatement("SELECT COUNT(*) FROM Bid WHERE auctionID=?");
    psCount.setInt(1, auctionID);
    ResultSet rsCount = psCount.executeQuery();
    rsCount.next();
    int bidCount = rsCount.getInt(1);
    rsCount.close();
    psCount.close();
    
    // If no bids yet, minimum is the start price; otherwise current price + increment
    float minBid = (bidCount == 0) ? currentPrice : (currentPrice + increment);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Item Details</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { width: 100%; }
        .detail-section { background-color: #f9f9f9; padding: 15px; border-radius: 5px; }
        .bid-section { background-color: #e8f5e9; padding: 15px; border-radius: 5px; }
        .bid-closed { background-color: #ffebee; }
        .price { font-size: 1.8em; color: #2e7d32; font-weight: bold; }
    </style>
</head>
<body>
    <h2><%= rsItem.getString("title") %></h2>
    <a href="browse.jsp">← Back to Browse</a>
    
    <table border="0" width="100%">
        <tr valign="top">
            <!-- Left Column: Item Details -->
            <td width="50%" class="detail-section">
                <h3>Item Details</h3>
                <ul>
                    <li><b>Type:</b> <%= currentType %></li>
                    <li><b>Brand:</b> <%= currentBrand %></li>
                    <li><b>Color:</b> <%= currentColor %></li>
                    <li><b>Size:</b> <%= rsItem.getString("size") %></li>
                    <li><b>Material:</b> <%= rsItem.getString("material") %></li>
                    <li><b>Condition:</b> <%= rsItem.getString("condition") %></li>
                    <li><b>Auction Ends:</b> <%= rsItem.getTimestamp("endTime") %></li>
                </ul>
            </td>
            
            <!-- Right Column: Bidding Section -->
            <td width="50%" class="bid-section <%= "Active".equals(status) ? "" : "bid-closed" %>">
                <h3>Bidding Status: <%= status %></h3>
                <div class="price">Current Price: $<%= currentPrice %></div>
                
                <% if("Active".equals(status)) { %>
                    <hr>
                    <h4>Place Your Bid</h4>
                    <p><b>Minimum Bid Required:</b> $<%= minBid %></p>
                    <p><i>Note: Seller may have set a hidden reserve price.</i></p>
                    
                    <form action="place_bid_action.jsp" method="post">
                        <input type="hidden" name="auctionID" value="<%= auctionID %>">
                        
                        <label><b>Your Bid Amount ($):</b></label><br>
                        <input type="number" step="0.01" name="amount" min="<%= minBid %>" 
                               placeholder="<%= minBid %>" required 
                               style="width:200px; padding:8px; font-size:1.1em;">
                        <br><br>
                        
                        <label><b>(Optional) Secret Auto-Bid Upper Limit ($):</b></label><br>
                        <span style="font-size:0.9em; color:#666;">
                            System will automatically bid for you (in increments) up to this amount if someone outbids you.
                        </span><br>
                        <input type="number" step="0.01" name="autoLimit" 
                               placeholder="e.g., <%= minBid + increment * 5 %>" 
                               style="width:200px; padding:8px;">
                        <br><br>
                        
                        <input type="submit" value="🔨 Place Bid" 
                               style="background:#4caf50; color:white; padding:12px 24px; 
                                      font-size:1.1em; border:none; border-radius:5px; cursor:pointer;">
                    </form>
                <% } else { %>
                    <p style="color:#d32f2f; font-size:1.2em;">
                        <i>⚠ This auction is <%= status.toLowerCase() %>.</i>
                    </p>
                <% } %>
            </td>
        </tr>
    </table>

    <hr>
    
    <!-- Bid History Table -->
    <h3> Bid History</h3>
    <table border="1" cellpadding="8" cellspacing="0" width="100%">
        <tr style="background-color:#f5f5f5;">
            <th>Bidder</th>
            <th>Bid Amount</th>
            <th>Bid Time</th>
        </tr>
        <%
            String sqlHist = "SELECT b.amount, b.bidTime, u.username " +
                           "FROM Bid b JOIN EndUser u ON b.userID = u.userID " +
                           "WHERE b.auctionID=? ORDER BY b.amount DESC, b.bidTime DESC";
            PreparedStatement psHist = conn.prepareStatement(sqlHist);
            psHist.setInt(1, auctionID);
            ResultSet rsHist = psHist.executeQuery();
            
            boolean hasBids = false;
            while(rsHist.next()) {
                hasBids = true;
                String bidderName = rsHist.getString("username");
        %>
            <tr>
                <!-- Checklist Requirement: View list of auctions a specific buyer has participated in -->
                <!-- Added Link to user_history.jsp -->
                <td><a href="user_history.jsp?usernameLookup=<%= bidderName %>"><%= bidderName %></a></td>
                <td>$<%= rsHist.getFloat("amount") %></td>
                <td><%= rsHist.getTimestamp("bidTime") %></td>
            </tr>
        <% } 
           if(!hasBids) {
               out.println("<tr><td colspan='3' style='text-align:center; color:#999;'>No bids yet. Be the first!</td></tr>");
           }
           rsHist.close();
           psHist.close();
        %>
    </table>

    <hr>
    
    <!-- Similar Items (Sold in Last 30 Days) -->
    <h3>Similar Items Sold Recently (Past 30 Days)</h3>
    <p style="color:#666; font-size:0.9em;">
        View auction history of similar items to help you decide your bid.
    </p>
    <table border="1" cellpadding="8" cellspacing="0" width="100%">
        <tr style="background-color:#f5f5f5;">
            <th>Title</th>
            <th>Type</th>
            <th>Brand</th>
            <th>Final Price</th>
            <th>Sold Date</th>
        </tr>
        <%
            // Checklist: Show similar items that were sold in preceding month
            String sqlSim = "SELECT a.title, c.type, c.brand, a.currentPrice, a.endTime " +
                          "FROM Auction a JOIN ClothingItem c ON a.clothingID = c.clothingID " +
                          "WHERE (c.type = ? OR c.brand = ? OR c.color = ?) " +
                          "AND a.status = 'Sold' " +
                          "AND a.endTime BETWEEN DATE_SUB(NOW(), INTERVAL 1 MONTH) AND NOW() " +
                          "AND a.auctionID != ? " +
                          "ORDER BY a.endTime DESC LIMIT 10";
            
            PreparedStatement psSim = conn.prepareStatement(sqlSim);
            psSim.setString(1, currentType);
            psSim.setString(2, currentBrand);
            psSim.setString(3, currentColor);
            psSim.setInt(4, auctionID);
            ResultSet rsSim = psSim.executeQuery();
            
            boolean hasSimilar = false;
            while(rsSim.next()) {
                hasSimilar = true;
        %>
            <tr>
                <td><%= rsSim.getString("title") %></td>
                <td><%= rsSim.getString("type") %></td>
                <td><%= rsSim.getString("brand") %></td>
                <td>$<%= rsSim.getFloat("currentPrice") %></td>
                <td><%= rsSim.getTimestamp("endTime") %></td>
            </tr>
        <% } 
           if(!hasSimilar) {
               out.println("<tr><td colspan='5' style='text-align:center; color:#999;'>No similar items found in past 30 days.</td></tr>");
           }
           rsSim.close();
           psSim.close();
           db.closeConnection(conn);
        %>
    </table>
    
    <br>
    <a href="browse.jsp">← Back to Browse</a>
</body>
</html>