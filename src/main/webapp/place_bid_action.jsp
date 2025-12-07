<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%
    // Check if user is logged in
    if (session.getAttribute("userID") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userID = (Integer) session.getAttribute("userID");
    int auctionID = Integer.parseInt(request.getParameter("auctionID"));
    float bidAmount = Float.parseFloat(request.getParameter("amount"));
    
    // Get optional automatic bidding limit
    String autoLimitStr = request.getParameter("autoLimit");
    float myAutoLimit = (autoLimitStr != null && !autoLimitStr.isEmpty()) ? Float.parseFloat(autoLimitStr) : bidAmount;
    
    // FIXED: Ensure auto-limit is at least the manual bid amount
    if(myAutoLimit < bidAmount) myAutoLimit = bidAmount;

    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();

    try {
        conn.setAutoCommit(false); // Start Transaction for safety

        // 1. Get Current Auction State
        String sqlAuc = "SELECT currentPrice, increment, sellerID, status, minPrice FROM Auction WHERE auctionID=?";
        PreparedStatement psAuc = conn.prepareStatement(sqlAuc);
        psAuc.setInt(1, auctionID);
        ResultSet rsAuc = psAuc.executeQuery();
        
        if(!rsAuc.next()) { 
            out.println("Auction not found."); 
            return; 
        }
        
        float currentPrice = rsAuc.getFloat("currentPrice");
        float increment = rsAuc.getFloat("increment");
        int sellerID = rsAuc.getInt("sellerID");
        String status = rsAuc.getString("status");
        rsAuc.close();
        psAuc.close();
        
        if(!"Active".equals(status)) {
            out.println("Auction is closed.");
            return;
        }

        // Prevent seller from bidding on their own auction
        if(userID == sellerID) {
            out.println("You cannot bid on your own item. <a href='item_details.jsp?id="+auctionID+"'>Back</a>");
            return;
        }

        // Check if there are any existing bids to determine minimum requirement
        PreparedStatement psCount = conn.prepareStatement("SELECT COUNT(*) FROM Bid WHERE auctionID=?");
        psCount.setInt(1, auctionID);
        ResultSet rsCount = psCount.executeQuery();
        rsCount.next();
        int bidCount = rsCount.getInt(1);
        rsCount.close();
        psCount.close();

        // Validate bid amount
        // Logic: If it's the FIRST bid, it can be equal to currentPrice (Start Price).
        // If there are existing bids, it must be >= currentPrice + increment.
        float minReq = (bidCount == 0) ? currentPrice : (currentPrice + increment);

        if(bidAmount < minReq) {
             out.println("Bid too low. Minimum is $" + minReq + ". <a href='item_details.jsp?id="+auctionID+"'>Back</a>");
             return;
        }

        // 2. Get Current Highest Bidder info
        // Order by amount DESC, then bidTime ASC (First person to bid that amount holds priority)
        String sqlMaxBid = "SELECT * FROM Bid WHERE auctionID=? ORDER BY amount DESC, bidTime ASC LIMIT 1";
        PreparedStatement psMax = conn.prepareStatement(sqlMaxBid);
        psMax.setInt(1, auctionID);
        ResultSet rsMax = psMax.executeQuery();
        
        boolean hasPrevBidder = rsMax.next();
        int prevUserID = hasPrevBidder ? rsMax.getInt("userID") : -1;
        float prevAmount = hasPrevBidder ? rsMax.getFloat("amount") : 0.0f;
        float prevAutoMax = hasPrevBidder ? rsMax.getFloat("autoBidMax") : 0.0f;
        // FIXED: Ensure prevAutoMax is at least the bid amount
        if(prevAutoMax < prevAmount) prevAutoMax = prevAmount;
        
        rsMax.close();
        psMax.close();

        // 3. Determine the Winner and New Price (Automatic Bidding Battle Logic)
        
        float newCurrentPrice = currentPrice; // Default to existing price
        int winnerID = -1;
        boolean immediateOutbid = false;

        if (!hasPrevBidder) {
            // Case A: First Bidder - No competition
            PreparedStatement psIns = conn.prepareStatement("INSERT INTO Bid (auctionID, userID, amount, autoBidMax) VALUES (?, ?, ?, ?)");
            psIns.setInt(1, auctionID);
            psIns.setInt(2, userID);
            psIns.setFloat(3, bidAmount);
            psIns.setFloat(4, myAutoLimit);
            psIns.executeUpdate();
            psIns.close();
            
            // Price stays at start price (or manual bid if higher)
            newCurrentPrice = bidAmount >= currentPrice ? bidAmount : currentPrice; 
            winnerID = userID;
            
        } else {
            // Case B: Battle between New Bidder vs Previous Bidder
            
            if (myAutoLimit > prevAutoMax) {
                // *** NEW BIDDER WINS ***
                winnerID = userID;
                
                // FIXED: Price is pushed to (Previous Max + Increment), capped by New Bidder's limit
                float potentialPrice = prevAutoMax + increment;
                
                // Cannot exceed new bidder's limit
                if (potentialPrice > myAutoLimit) potentialPrice = myAutoLimit;
                
                // Also ensure it's at least the manual bid amount
                if (potentialPrice < bidAmount) potentialPrice = bidAmount;
                
                newCurrentPrice = potentialPrice;
                
                // Insert New Bid Record
                PreparedStatement psIns = conn.prepareStatement("INSERT INTO Bid (auctionID, userID, amount, autoBidMax) VALUES (?, ?, ?, ?)");
                psIns.setInt(1, auctionID);
                psIns.setInt(2, userID);
                psIns.setFloat(3, bidAmount); // Record manual bid
                psIns.setFloat(4, myAutoLimit); // Record auto limit
                psIns.executeUpdate();
                psIns.close();
                
                // Alert Previous Bidder (Checklist: alert buyers in case someone bids more than their upper limit)
                String msg = "You have been outbid on Auction #" + auctionID + "! Your auto-limit of $" + prevAutoMax + " was exceeded. Current price: $" + newCurrentPrice;
                PreparedStatement psAlert = conn.prepareStatement("INSERT INTO Alert (userID, message) VALUES (?, ?)");
                psAlert.setInt(1, prevUserID);
                psAlert.setString(2, msg);
                psAlert.executeUpdate();
                psAlert.close();
                
            } else {
                // *** OLD BIDDER STAYS WINNER (Auto-Defense) ***
                winnerID = prevUserID;
                immediateOutbid = true;
                
                // FIXED: Price is pushed to (New Bidder's Max + Increment), capped by Old Bidder's limit
                float potentialPrice = myAutoLimit + increment;
                if (potentialPrice > prevAutoMax) potentialPrice = prevAutoMax;
                
                newCurrentPrice = potentialPrice;
                
                // 1. Record the New User's bid attempt (for history)
                PreparedStatement psInsLoser = conn.prepareStatement("INSERT INTO Bid (auctionID, userID, amount, autoBidMax) VALUES (?, ?, ?, ?)");
                psInsLoser.setInt(1, auctionID);
                psInsLoser.setInt(2, userID);
                psInsLoser.setFloat(3, bidAmount); 
                psInsLoser.setFloat(4, myAutoLimit);
                psInsLoser.executeUpdate();
                psInsLoser.close();
                
                // Alert New Bidder (they were outbid immediately)
                String msg = "Your bid on Auction #" + auctionID + " was immediately outbid by an automatic bidder. Current price: $" + newCurrentPrice;
                PreparedStatement psAlert = conn.prepareStatement("INSERT INTO Alert (userID, message) VALUES (?, ?)");
                psAlert.setInt(1, userID);
                psAlert.setString(2, msg);
                psAlert.executeUpdate();
                psAlert.close();
            }
        }

        // 4. Update Auction Current Price
        PreparedStatement psUpd = conn.prepareStatement("UPDATE Auction SET currentPrice=? WHERE auctionID=?");
        psUpd.setFloat(1, newCurrentPrice);
        psUpd.setInt(2, auctionID);
        psUpd.executeUpdate();
        psUpd.close();
        
        // 5. Alert All Other Bidders (Checklist: alert other buyers... manual)
        // Alert everyone who has bid on this auction, except the current winner and seller
        String sqlOthers = "SELECT DISTINCT userID FROM Bid WHERE auctionID=? AND userID NOT IN (?, ?)";
        PreparedStatement psOthers = conn.prepareStatement(sqlOthers);
        psOthers.setInt(1, auctionID);
        psOthers.setInt(2, winnerID); // Don't alert the winner
        psOthers.setInt(3, sellerID); // Don't alert the seller
        ResultSet rsOthers = psOthers.executeQuery();
        
        PreparedStatement psAlertGeneric = conn.prepareStatement("INSERT INTO Alert (userID, message) VALUES (?, ?)");
        while(rsOthers.next()) {
            int otherID = rsOthers.getInt("userID");
            String msg = "New activity on Auction #" + auctionID + ". Current price is now $" + newCurrentPrice;
            psAlertGeneric.setInt(1, otherID);
            psAlertGeneric.setString(2, msg);
            psAlertGeneric.executeUpdate();
        }
        rsOthers.close();
        psOthers.close();
        psAlertGeneric.close();

        conn.commit(); // Commit Transaction
        
        if (immediateOutbid) {
             out.println("Bid placed, but you were immediately outbid by an automatic bid! Current price: $" + newCurrentPrice + " <a href='item_details.jsp?id="+auctionID+"'>Back</a>");
        } else {
             out.println("Bid Placed Successfully! You are the highest bidder at $" + newCurrentPrice + ". <a href='item_details.jsp?id="+auctionID+"'>Back</a>");
        }

    } catch (Exception e) {
        try { if(conn != null) conn.rollback(); } catch(SQLException se) {}
        out.println("Error placing bid: " + e.getMessage());
        e.printStackTrace();
    } finally {
        try { if(conn != null) conn.setAutoCommit(true); } catch(SQLException se) {}
        db.closeConnection(conn);
    }
%>