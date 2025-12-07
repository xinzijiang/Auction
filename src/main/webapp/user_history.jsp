<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head><title>My Activity</title></head>
<body>
    <h2>My Activity History</h2>
    <a href="browse.jsp">Back to Browse</a>
    <hr>

    <%
        if (session.getAttribute("userID") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        int uid = (Integer) session.getAttribute("userID");
        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();
    %>

    <h3>Items I Have Listed (Seller History)</h3>
    <table border="1">
        <tr><th>Auction ID</th><th>Title</th><th>Status</th><th>Final/Current Price</th></tr>
        <%
            PreparedStatement psSold = conn.prepareStatement("SELECT * FROM Auction WHERE sellerID = ?");
            psSold.setInt(1, uid);
            ResultSet rsSold = psSold.executeQuery();
            while(rsSold.next()) {
        %>
            <tr>
                <td><%= rsSold.getInt("auctionID") %></td>
                <td><%= rsSold.getString("title") %></td>
                <td><%= rsSold.getString("status") %></td>
                <td>$<%= rsSold.getFloat("currentPrice") %></td>
            </tr>
        <% } %>
    </table>

    <h3>Auctions I Participated In (Bid History)</h3>
    <p><i>Showing your highest bid per auction.</i></p>
    <table border="1">
        <tr><th>Auction ID</th><th>Title</th><th>My Max Bid</th><th>Last Bid Time</th><th>Auction Status</th></tr>
        <%
            // Modified to GROUP BY auctionID so we don't see duplicate rows for the same item
            String sqlBids = "SELECT MAX(b.amount) as maxBid, MAX(b.bidTime) as lastTime, a.auctionID, a.title, a.status " +
                             "FROM Bid b JOIN Auction a ON b.auctionID = a.auctionID " +
                             "WHERE b.userID = ? " +
                             "GROUP BY a.auctionID, a.title, a.status " +
                             "ORDER BY lastTime DESC";
            PreparedStatement psBids = conn.prepareStatement(sqlBids);
            psBids.setInt(1, uid);
            ResultSet rsBids = psBids.executeQuery();
            while(rsBids.next()) {
        %>
            <tr>
                <td><%= rsBids.getInt("auctionID") %></td>
                <td><%= rsBids.getString("title") %></td>
                <td>$<%= rsBids.getFloat("maxBid") %></td>
                <td><%= rsBids.getTimestamp("lastTime") %></td>
                <td><%= rsBids.getString("status") %></td>
            </tr>
        <% } %>
    </table>

    <hr>
    <h2>Lookup Auctions for Any Buyer or Seller</h2>
    <form action="user_history.jsp" method="get">
        Username: <input type="text" name="usernameLookup" value="<%= request.getParameter("usernameLookup") != null ? request.getParameter("usernameLookup") : "" %>">
        <input type="submit" value="Search">
    </form>
    <%
        String lookupName = request.getParameter("usernameLookup");
        Integer lookupId = null;
        String lookupMessage = null;

        if (lookupName != null && !lookupName.trim().isEmpty()) {
            PreparedStatement psFind = conn.prepareStatement("SELECT userID FROM EndUser WHERE username=?");
            psFind.setString(1, lookupName.trim());
            ResultSet rsFind = psFind.executeQuery();
            if (rsFind.next()) {
                lookupId = rsFind.getInt("userID");
            } else {
                lookupMessage = "User not found.";
            }
        }

        if (lookupMessage != null) {
            out.println("<p style='color:red;'>" + lookupMessage + "</p>");
        }

        if (lookupId != null) {
    %>
        <h3>Seller History for <%= lookupName %></h3>
        <table border="1">
            <tr><th>Auction ID</th><th>Title</th><th>Status</th><th>Final/Current Price</th></tr>
            <%
                PreparedStatement psSeller = conn.prepareStatement("SELECT auctionID, title, status, currentPrice FROM Auction WHERE sellerID=? ORDER BY auctionID DESC");
                psSeller.setInt(1, lookupId);
                ResultSet rsSeller = psSeller.executeQuery();
                boolean hasSeller = false;
                while(rsSeller.next()) {
                    hasSeller = true;
            %>
                <tr>
                    <td><%= rsSeller.getInt("auctionID") %></td>
                    <td><%= rsSeller.getString("title") %></td>
                    <td><%= rsSeller.getString("status") %></td>
                    <td>$<%= rsSeller.getFloat("currentPrice") %></td>
                </tr>
            <% }
               if(!hasSeller) out.println("<tr><td colspan='4'>No auctions found for this seller.</td></tr>");
            %>
        </table>

        <h3>Bid Participation for <%= lookupName %></h3>
        <table border="1">
            <tr><th>Auction ID</th><th>Title</th><th>Max Bid Amount</th><th>Last Bid Time</th><th>Status</th></tr>
            <%
                // Also modified here to GROUP BY auctionID
                String sqlLookupBids = "SELECT MAX(b.amount) as maxBid, MAX(b.bidTime) as lastTime, a.auctionID, a.title, a.status " +
                                       "FROM Bid b JOIN Auction a ON b.auctionID = a.auctionID " +
                                       "WHERE b.userID = ? " +
                                       "GROUP BY a.auctionID, a.title, a.status " +
                                       "ORDER BY lastTime DESC";
                PreparedStatement psLookupBids = conn.prepareStatement(sqlLookupBids);
                psLookupBids.setInt(1, lookupId);
                ResultSet rsLookupBids = psLookupBids.executeQuery();
                boolean hasBids = false;
                while(rsLookupBids.next()) {
                    hasBids = true;
            %>
                <tr>
                    <td><%= rsLookupBids.getInt("auctionID") %></td>
                    <td><%= rsLookupBids.getString("title") %></td>
                    <td>$<%= rsLookupBids.getFloat("maxBid") %></td>
                    <td><%= rsLookupBids.getTimestamp("lastTime") %></td>
                    <td><%= rsLookupBids.getString("status") %></td>
                </tr>
            <% }
               if(!hasBids) out.println("<tr><td colspan='5'>No bid history for this user.</td></tr>");
            %>
        </table>
    <%
        }
        db.closeConnection(conn);
    %>
</body>
</html>