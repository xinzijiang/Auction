<%@ page import="com.cs336.pkg.*, java.sql.*, java.util.*" %>
<%
    // Security check
    if (session.getAttribute("role") == null || !session.getAttribute("role").equals("rep")) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String uidStr = request.getParameter("uid");
    if(uidStr != null) {
        int uid = Integer.parseInt(uidStr);
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();
        try {
            // 1. Delete Bids made by this user
            PreparedStatement ps1 = conn.prepareStatement("DELETE FROM Bid WHERE userID=?");
            ps1.setInt(1, uid);
            ps1.executeUpdate();
            
            // 2. Delete Alerts/Criteria/Questions
            PreparedStatement ps2 = conn.prepareStatement("DELETE FROM Alert WHERE userID=?");
            ps2.setInt(1, uid);
            ps2.executeUpdate();
            
            PreparedStatement ps3 = conn.prepareStatement("DELETE FROM AlertCriteria WHERE userID=?");
            ps3.setInt(1, uid);
            ps3.executeUpdate();
            
            PreparedStatement ps4 = conn.prepareStatement("DELETE FROM Questions WHERE userID=?");
            ps4.setInt(1, uid);
            ps4.executeUpdate();

            // 3. Handle Auctions owned by this user (Seller)
            
            // 3a. Delete Bids on auctions owned by this user
            PreparedStatement ps5 = conn.prepareStatement("DELETE FROM Bid WHERE auctionID IN (SELECT auctionID FROM Auction WHERE sellerID=?)");
            ps5.setInt(1, uid);
            ps5.executeUpdate();
            
            // 3b. Identify ClothingItems associated with these auctions to prevent orphan records
            List<Integer> clothingIDs = new ArrayList<>();
            PreparedStatement psGetItems = conn.prepareStatement("SELECT clothingID FROM Auction WHERE sellerID=?");
            psGetItems.setInt(1, uid);
            ResultSet rsItems = psGetItems.executeQuery();
            while(rsItems.next()) {
                clothingIDs.add(rsItems.getInt("clothingID"));
            }
            rsItems.close();
            psGetItems.close();

            // 3c. Delete the Auctions
            PreparedStatement ps6 = conn.prepareStatement("DELETE FROM Auction WHERE sellerID=?");
            ps6.setInt(1, uid);
            ps6.executeUpdate();

            // 3d. Delete the ClothingItems (Cascades to Shirt/Pants/OuterWear)
            if(!clothingIDs.isEmpty()) {
                // Build dynamic IN clause
                StringBuilder sb = new StringBuilder("DELETE FROM ClothingItem WHERE clothingID IN (");
                for(int i=0; i<clothingIDs.size(); i++) {
                    sb.append(i==0 ? "?" : ",?");
                }
                sb.append(")");
                
                PreparedStatement psDelItems = conn.prepareStatement(sb.toString());
                for(int i=0; i<clothingIDs.size(); i++) {
                    psDelItems.setInt(i+1, clothingIDs.get(i));
                }
                psDelItems.executeUpdate();
                psDelItems.close();
            }

            // 4. Finally, Delete the User
            PreparedStatement ps7 = conn.prepareStatement("DELETE FROM EndUser WHERE userID=?");
            ps7.setInt(1, uid);
            ps7.executeUpdate();
            
            out.println("User and all associated data deleted successfully. <a href='rep_dashboard.jsp'>Back</a>");
        } catch(Exception e) {
            out.println("Error deleting user: " + e.getMessage());
            e.printStackTrace();
        } finally {
            db.closeConnection(conn);
        }
    } else {
        response.sendRedirect("rep_dashboard.jsp");
    }
%>