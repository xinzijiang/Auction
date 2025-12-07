<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%
    if (session.getAttribute("role") == null || !session.getAttribute("role").equals("rep")) {
        response.sendRedirect("login.jsp");
        return;
    }
    String aidStr = request.getParameter("aid");
    if(aidStr != null) {
        int aid = Integer.parseInt(aidStr);
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();
        try {
            // 1. Get the clothingID associated with this auction BEFORE deleting the auction
            int clothingID = -1;
            PreparedStatement psGet = conn.prepareStatement("SELECT clothingID FROM Auction WHERE auctionID=?");
            psGet.setInt(1, aid);
            ResultSet rs = psGet.executeQuery();
            if(rs.next()) {
                clothingID = rs.getInt("clothingID");
            }
            rs.close();
            psGet.close();

            // 2. Delete Bids
            PreparedStatement ps1 = conn.prepareStatement("DELETE FROM Bid WHERE auctionID=?");
            ps1.setInt(1, aid);
            ps1.executeUpdate();
            
            // 3. Delete Auction
            PreparedStatement ps2 = conn.prepareStatement("DELETE FROM Auction WHERE auctionID=?");
            ps2.setInt(1, aid);
            ps2.executeUpdate();
            
            // 4. Delete ClothingItem (Cascades to Shirt/Pants/OuterWear automatically via Foreign Key)
            if(clothingID != -1) {
                PreparedStatement ps3 = conn.prepareStatement("DELETE FROM ClothingItem WHERE clothingID=?");
                ps3.setInt(1, clothingID);
                ps3.executeUpdate();
            }
            
            out.println("Auction and associated item deleted. <a href='rep_dashboard.jsp'>Back</a>");
        } catch(Exception e) {
            out.println("Error: " + e.getMessage());
        } finally {
            db.closeConnection(conn);
        }
    }
%>