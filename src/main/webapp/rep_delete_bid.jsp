 <%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%
    // Security check: verify user is a customer rep
    if (session.getAttribute("role") == null || !session.getAttribute("role").equals("rep")) {
        response.sendRedirect("login.jsp");
        return;
    }

    String bidStr = request.getParameter("bid");
    if(bidStr != null) {
        int bidID = Integer.parseInt(bidStr);
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();
        try {
            // 1. Get the auctionID associated with this bid BEFORE deleting it
            int auctionID = -1;
            PreparedStatement psGet = conn.prepareStatement("SELECT auctionID FROM Bid WHERE bidID=?");
            psGet.setInt(1, bidID);
            ResultSet rsGet = psGet.executeQuery();
            if(rsGet.next()) {
                auctionID = rsGet.getInt("auctionID");
            }
            rsGet.close();
            psGet.close();

            if(auctionID != -1) {
                // 2. Delete the Bid
                PreparedStatement psDel = conn.prepareStatement("DELETE FROM Bid WHERE bidID=?");
                psDel.setInt(1, bidID);
                psDel.executeUpdate();
                psDel.close();

                // 3. Recalculate the correct price for the auction
                // Find the NEW highest bid
                PreparedStatement psMax = conn.prepareStatement("SELECT amount FROM Bid WHERE auctionID=? ORDER BY amount DESC LIMIT 1");
                psMax.setInt(1, auctionID);
                ResultSet rsMax = psMax.executeQuery();
                
                float newPrice = 0;
                if(rsMax.next()) {
                    // If there are still bids, set price to the highest remaining bid
                    newPrice = rsMax.getFloat("amount");
                } else {
                    // If no bids left, reset to the original minimum price (start price)
                    PreparedStatement psMin = conn.prepareStatement("SELECT minPrice FROM Auction WHERE auctionID=?");
                    psMin.setInt(1, auctionID);
                    ResultSet rsMin = psMin.executeQuery();
                    if(rsMin.next()) {
                        newPrice = rsMin.getFloat("minPrice");
                    }
                    rsMin.close();
                    psMin.close();
                }
                rsMax.close();
                psMax.close();

                // 4. Update the Auction table
                PreparedStatement psUpdate = conn.prepareStatement("UPDATE Auction SET currentPrice=? WHERE auctionID=?");
                psUpdate.setFloat(1, newPrice);
                psUpdate.setInt(2, auctionID);
                psUpdate.executeUpdate();
                psUpdate.close();
            }

            out.println("Bid deleted and auction price updated. <a href='rep_dashboard.jsp'>Back</a>");
        } catch(Exception e) {
            out.println("Error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            db.closeConnection(conn);
        }
    } else {
        response.sendRedirect("rep_dashboard.jsp");
    }
%>