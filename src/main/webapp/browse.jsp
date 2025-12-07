<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<%@ include file="auto_settle_expired_auctions.jspf" %>
<!DOCTYPE html>
<html>
<head><title>Browse Auctions</title></head>
<body>
    <%
        if (session.getAttribute("userID") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    <h2>Browse Auctions</h2>
    
    <div style="text-align:right; border-bottom:1px solid #ccc; padding:10px;">
        Logged in as: <b><%= session.getAttribute("user") %></b> | 
        <a href="qa_forum.jsp">Q&A Forum</a> | 
        <a href="user_history.jsp">My Activity</a> | 
        <a href="set_alert.jsp">Set Alerts</a> | 
        <a href="my_alerts.jsp">My Alerts</a> | 
        <a href="ourAuction.jsp" style="font-weight:bold; color:green;">+ Sell Item</a> | 
        <a href="logout.jsp">Logout</a>
    </div>
    
    <div style="background:#f9f9f9; padding:15px; margin:10px 0;">
        <form action="browse.jsp" method="get">
            <b>Keyword:</b> 
            <input type="text" name="keyword" placeholder="Brand, Type, Title, Color" value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
            <b>Type:</b>
            <input type="text" name="typeFilter" placeholder="Shirt/Pants/OuterWear" value="<%= request.getParameter("typeFilter") != null ? request.getParameter("typeFilter") : "" %>">
            <b>Brand:</b>
            <input type="text" name="brandFilter" placeholder="Brand" value="<%= request.getParameter("brandFilter") != null ? request.getParameter("brandFilter") : "" %>">
            <b>Color:</b>
            <input type="text" name="colorFilter" placeholder="Color" value="<%= request.getParameter("colorFilter") != null ? request.getParameter("colorFilter") : "" %>">
            <b>Price From:</b>
            <input type="number" step="0.01" name="minPrice" value="<%= request.getParameter("minPrice") != null ? request.getParameter("minPrice") : "" %>">
            <b>To:</b>
            <input type="number" step="0.01" name="maxPrice" value="<%= request.getParameter("maxPrice") != null ? request.getParameter("maxPrice") : "" %>">
            
            <b>Sort By:</b> 
            <select name="sort">
                <option value="endTime ASC">Closing Soon</option>
                <option value="currentPrice ASC">Price: Low to High</option>
                <option value="currentPrice DESC">Price: High to Low</option>
                <option value="type ASC">Item Type</option>
                <option value="brand ASC">Brand</option>
            </select>
            <input type="submit" value="Search & Sort">
        </form>
    </div>
    
    <table border="1" width="100%">
        <tr>
            <th>ID</th><th>Type</th><th>Brand</th><th>Title</th>
            <th>Current Price</th><th>Status</th><th>Ends At</th><th>Action</th>
        </tr>
        <%
            String keyword = request.getParameter("keyword");
            String sort = request.getParameter("sort");
            String typeFilter = request.getParameter("typeFilter");
            String brandFilter = request.getParameter("brandFilter");
            String colorFilter = request.getParameter("colorFilter");
            String minPrice = request.getParameter("minPrice");
            String maxPrice = request.getParameter("maxPrice");
            if(sort == null || sort.isEmpty()) sort = "endTime ASC";

            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();
            
            StringBuilder sql = new StringBuilder(
                "SELECT a.auctionID, c.type, c.brand, a.title, a.currentPrice, a.status, a.endTime " +
                "FROM Auction a JOIN ClothingItem c ON a.clothingID = c.clothingID WHERE a.status = 'Active'"
            );
            java.util.List<Object> params = new java.util.ArrayList<>();

            if(keyword != null && !keyword.trim().isEmpty()) {
                sql.append(" AND (c.brand LIKE ? OR c.type LIKE ? OR a.title LIKE ? OR c.color LIKE ?)");
                String k = "%" + keyword.trim() + "%";
                params.add(k); params.add(k); params.add(k); params.add(k);
            }
            if(typeFilter != null && !typeFilter.trim().isEmpty()) {
                sql.append(" AND c.type LIKE ?");
                params.add("%" + typeFilter.trim() + "%");
            }
            if(brandFilter != null && !brandFilter.trim().isEmpty()) {
                sql.append(" AND c.brand LIKE ?");
                params.add("%" + brandFilter.trim() + "%");
            }
            if(colorFilter != null && !colorFilter.trim().isEmpty()) {
                sql.append(" AND c.color LIKE ?");
                params.add("%" + colorFilter.trim() + "%");
            }
            if(minPrice != null && !minPrice.trim().isEmpty()) {
                sql.append(" AND a.currentPrice >= ?");
                params.add(Float.parseFloat(minPrice));
            }
            if(maxPrice != null && !maxPrice.trim().isEmpty()) {
                sql.append(" AND a.currentPrice <= ?");
                params.add(Float.parseFloat(maxPrice));
            }
            
            sql.append(" ORDER BY ").append(sort);
            
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            for(int i=0; i<params.size(); i++) {
                ps.setObject(i+1, params.get(i));
            }
            
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
        %>
            <tr>
                <td><%= rs.getInt("auctionID") %></td>
                <td><%= rs.getString("type") %></td>
                <td><%= rs.getString("brand") %></td>
                <td><%= rs.getString("title") %></td>
                <td>$<%= rs.getFloat("currentPrice") %></td>
                <td><%= rs.getString("status") %></td>
                <td><%= rs.getTimestamp("endTime") %></td>
                <td><a href="item_details.jsp?id=<%= rs.getInt("auctionID") %>">View Details</a></td>
            </tr>
        <%
            }
            db.closeConnection(conn);
        %>
    </table>
</body>
</html>