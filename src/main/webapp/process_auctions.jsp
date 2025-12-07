<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head><title>Process Auctions</title></head>
<body>
    <h2>System: Processing Expired Auctions...</h2>
    <%
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();
        
        try {
            // 1. Find Active auctions that have passed their EndTime
            String sql = "SELECT * FROM Auction WHERE status='Active' AND endTime < NOW()";
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            
            int processedCount = 0;
            
            while(rs.next()) {
                int auctionID = rs.getInt("auctionID");
                float reservePrice = rs.getFloat("reservePrice");
                String title = rs.getString("title");
                
                // Find highest bidder
                PreparedStatement psBid = conn.prepareStatement("SELECT * FROM Bid WHERE auctionID=? ORDER BY amount DESC LIMIT 1");
                psBid.setInt(1, auctionID);
                ResultSet rsBid = psBid.executeQuery();
                
                String newStatus = "Closed"; // Default to closed (unsold)
                
                if (rsBid.next()) {
                    float highestBid = rsBid.getFloat("amount");
                    int winnerID = rsBid.getInt("userID");
                    
                    // Checklist: "if yes: if the reserve is higher than the last bid none is the winner."
                    if (highestBid >= reservePrice) {
                        newStatus = "Sold";
                        
                        // Alert the Winner
                        String msg = "Congratulations! You won the auction for '" + title + "' with a bid of $" + highestBid;
                        PreparedStatement psAlert = conn.prepareStatement("INSERT INTO Alert (userID, message) VALUES (?, ?)");
                        psAlert.setInt(1, winnerID);
                        psAlert.setString(2, msg);
                        psAlert.executeUpdate();
                    } else {
                        // Reserve not met
                        newStatus = "Closed";
                    }
                }
                
                // Update Auction Status
                PreparedStatement psUpdate = conn.prepareStatement("UPDATE Auction SET status=? WHERE auctionID=?");
                psUpdate.setString(1, newStatus);
                psUpdate.setInt(2, auctionID);
                psUpdate.executeUpdate();
                
                out.println("Processed Auction ID " + auctionID + ": " + newStatus + "<br>");
                processedCount++;
            }
            
            if(processedCount == 0) {
                out.println("No expired active auctions found.<br>");
            }
            
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        } finally {
            db.closeConnection(conn);
        }
    %>
    <hr>
    <a href="browse.jsp">Back to Browse</a>
</body>
</html>