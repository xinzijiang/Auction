<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Rep Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .section { margin-bottom: 40px; border: 1px solid #ccc; padding: 15px; border-radius: 5px; }
        h3 { margin-top: 0; background: #eee; padding: 10px; border-bottom: 1px solid #ccc; }
        .btn { padding: 5px 10px; text-decoration: none; border-radius: 3px; font-size: 0.9em; cursor: pointer; border: none;}
        .btn-edit { background-color: #007bff; color: white; }
        .btn-delete { background-color: #dc3545; color: white; }
        .btn-reply { background-color: #28a745; color: white; }
        .logout { float: right; margin-bottom: 10px; }
        .answered { background-color: #e8f5e9; }
        .search-box { margin-bottom: 15px; padding: 10px; background: #f5f5f5; border-radius: 5px; }
    </style>
</head>
<body>
    <h2>Customer Representative Dashboard</h2>
    <div class="logout">Logged in as Rep | <a href="logout.jsp">Logout</a></div>
    <div style="clear:both;"></div>

    <%
        // Security check: verify user is a customer rep
        if (session.getAttribute("role") == null || !session.getAttribute("role").equals("rep")) {
            response.sendRedirect("login.jsp");
            return;
        }

        ApplicationDB db = new ApplicationDB();
        Connection conn = db.getConnection();
        Statement stmt = conn.createStatement();
        
        int repID = (Integer) session.getAttribute("userID");
        String searchKeyword = request.getParameter("searchQ");
    %>

    <!-- ==========================
         1. Pending Questions (Unanswered)
         ========================== -->
    <div class="section">
        <h3>1. Pending Questions (Unanswered)</h3>
        <table>
            <tr><th>QID</th><th>User ID</th><th>Username</th><th>Question Text</th><th>Posted Date</th><th>Action</th></tr>
            <%
                // Join with EndUser to show username for better UX
                String sqlPending = "SELECT q.questionID, q.userID, q.questionText, q.postDate, u.username " +
                                   "FROM Questions q JOIN EndUser u ON q.userID = u.userID " +
                                   "WHERE q.answerText IS NULL ORDER BY q.postDate ASC";
                ResultSet rsQ = stmt.executeQuery(sqlPending);
                boolean hasQ = false;
                while(rsQ.next()) {
                    hasQ = true;
            %>
                <tr>
                    <td><%= rsQ.getInt("questionID") %></td>
                    <td><%= rsQ.getInt("userID") %></td>
                    <td><%= rsQ.getString("username") %></td>
                    <td><%= rsQ.getString("questionText") %></td>
                    <td><%= rsQ.getTimestamp("postDate") %></td>
                    <td>
                        <form action="rep_reply_action.jsp" method="post" style="display:flex; gap:5px;">
                            <input type="hidden" name="qid" value="<%= rsQ.getInt("questionID") %>">
                            <input type="text" name="answer" placeholder="Type reply..." required style="flex:1;">
                            <input type="submit" value="Reply" class="btn btn-reply">
                        </form>
                    </td>
                </tr>
            <% } rsQ.close(); 
               if(!hasQ) out.println("<tr><td colspan='6'>No pending questions.</td></tr>");
            %>
        </table>
    </div>

    <!-- ==========================
         1B. Answered Questions (NEW)
         ========================== -->
    <div class="section">
        <h3>1B. Answered Questions (My Replies)</h3>
        
        <!-- Search Box -->
        <div class="search-box">
            <form action="rep_dashboard.jsp" method="get">
                <b>Search Questions:</b>
                <input type="text" name="searchQ" placeholder="Search by question or answer text" 
                       value="<%= searchKeyword != null ? searchKeyword : "" %>" style="width:300px; padding:5px;">
                <input type="submit" value="Search" class="btn btn-reply">
                <% if(searchKeyword != null && !searchKeyword.isEmpty()) { %>
                    <a href="rep_dashboard.jsp" class="btn btn-edit">Clear Search</a>
                <% } %>
            </form>
        </div>
        
        <table>
            <tr>
                <th>QID</th><th>User</th><th>Question</th><th>My Answer</th>
                <th>Answered By</th><th>Date</th>
            </tr>
            <%
                // Show all answered questions, with optional search filter
                StringBuilder sqlAnswered = new StringBuilder(
                    "SELECT q.questionID, q.questionText, q.answerText, q.postDate, " +
                    "u.username as asker, r.username as responder " +
                    "FROM Questions q " +
                    "JOIN EndUser u ON q.userID = u.userID " +
                    "LEFT JOIN CustomerRep r ON q.repID = r.userID " +
                    "WHERE q.answerText IS NOT NULL"
                );
                
                PreparedStatement psAnswered;
                if(searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                    sqlAnswered.append(" AND (q.questionText LIKE ? OR q.answerText LIKE ?)");
                    psAnswered = conn.prepareStatement(sqlAnswered.toString() + " ORDER BY q.postDate DESC");
                    String pattern = "%" + searchKeyword.trim() + "%";
                    psAnswered.setString(1, pattern);
                    psAnswered.setString(2, pattern);
                } else {
                    psAnswered = conn.prepareStatement(sqlAnswered.toString() + " ORDER BY q.postDate DESC");
                }
                
                ResultSet rsAnswered = psAnswered.executeQuery();
                boolean hasAnswered = false;
                while(rsAnswered.next()) {
                    hasAnswered = true;
            %>
                <tr class="answered">
                    <td><%= rsAnswered.getInt("questionID") %></td>
                    <td><%= rsAnswered.getString("asker") %></td>
                    <td><%= rsAnswered.getString("questionText") %></td>
                    <td><%= rsAnswered.getString("answerText") %></td>
                    <td><%= rsAnswered.getString("responder") %></td>
                    <td><%= rsAnswered.getTimestamp("postDate") %></td>
                </tr>
            <% } 
               rsAnswered.close();
               psAnswered.close();
               if(!hasAnswered) {
                   if(searchKeyword != null && !searchKeyword.isEmpty()) {
                       out.println("<tr><td colspan='6'>No matching answered questions found.</td></tr>");
                   } else {
                       out.println("<tr><td colspan='6'>No answered questions yet.</td></tr>");
                   }
               }
            %>
        </table>
    </div>

    <!-- ==========================
         2. Manage Users
         ========================== -->
    <div class="section">
        <h3>2. Manage Users (End Users)</h3>
        <table>
            <tr><th>ID</th><th>Username</th><th>Email</th><th>Actions</th></tr>
            <%
                ResultSet rsUsers = stmt.executeQuery("SELECT * FROM EndUser ORDER BY userID");
                while(rsUsers.next()) {
                    int uID = rsUsers.getInt("userID");
            %>
                <tr>
                    <td><%= uID %></td>
                    <td><%= rsUsers.getString("username") %></td>
                    <td><%= rsUsers.getString("email") %></td>
                    <td>
                        <!-- Edit User Info -->
                        <a href="rep_edit_user.jsp?uid=<%= uID %>" class="btn btn-edit">Edit</a>
                        
                        <!-- Delete User (with cascade warning) -->
                        <a href="rep_delete_user.jsp?uid=<%= uID %>" class="btn btn-delete" 
                           onclick="return confirm('WARNING: Deleting this user will delete all their auctions, bids, and alerts. Continue?');">
                           Delete
                        </a>
                    </td>
                </tr>
            <% } rsUsers.close(); %>
        </table>
    </div>

    <!-- ==========================
         3. Manage Auctions
         ========================== -->
    <div class="section">
        <h3>3. Manage Auctions</h3>
        <table>
            <tr><th>ID</th><th>Title</th><th>Seller</th><th>Status</th><th>Current Price</th><th>End Time</th><th>Action</th></tr>
            <%
                String sqlAuc = "SELECT a.auctionID, a.title, a.status, a.currentPrice, a.endTime, " +
                               "u.username as sellerName " +
                               "FROM Auction a JOIN EndUser u ON a.sellerID = u.userID " +
                               "ORDER BY a.endTime DESC";
                ResultSet rsAuc = stmt.executeQuery(sqlAuc);
                while(rsAuc.next()) {
                    int aID = rsAuc.getInt("auctionID");
            %>
                <tr>
                    <td><%= aID %></td>
                    <td><%= rsAuc.getString("title") %></td>
                    <td><%= rsAuc.getString("sellerName") %></td>
                    <td><%= rsAuc.getString("status") %></td>
                    <td>$<%= rsAuc.getFloat("currentPrice") %></td>
                    <td><%= rsAuc.getTimestamp("endTime") %></td>
                    <td>
                        <form action="rep_delete_auction.jsp" method="post" onsubmit="return confirm('Delete this auction and all associated bids?');">
                            <input type="hidden" name="aid" value="<%= aID %>">
                            <input type="submit" value="Delete" class="btn btn-delete">
                        </form>
                    </td>
                </tr>
            <% } rsAuc.close(); %>
        </table>
    </div>

    <!-- ==========================
         4. Manage Bids
         ========================== -->
    <div class="section">
        <h3>4. Manage Bids (Recent 50)</h3>
        <table>
            <tr><th>Bid ID</th><th>Auction ID</th><th>Auction Title</th><th>Bidder</th><th>Amount</th><th>Time</th><th>Action</th></tr>
            <%
                String sqlBids = "SELECT b.bidID, b.auctionID, b.amount, b.bidTime, " +
                                "u.username as bidderName, a.title as auctionTitle " +
                                "FROM Bid b " +
                                "JOIN EndUser u ON b.userID = u.userID " +
                                "JOIN Auction a ON b.auctionID = a.auctionID " +
                                "ORDER BY b.bidTime DESC LIMIT 50";
                ResultSet rsBids = stmt.executeQuery(sqlBids);
                while(rsBids.next()) {
                    int bID = rsBids.getInt("bidID");
            %>
                <tr>
                    <td><%= bID %></td>
                    <td><%= rsBids.getInt("auctionID") %></td>
                    <td><%= rsBids.getString("auctionTitle") %></td>
                    <td><%= rsBids.getString("bidderName") %></td>
                    <td>$<%= rsBids.getFloat("amount") %></td>
                    <td><%= rsBids.getTimestamp("bidTime") %></td>
                    <td>
                        <form action="rep_delete_bid.jsp" method="post" onsubmit="return confirm('Delete this bid? This action cannot be undone.');">
                            <input type="hidden" name="bid" value="<%= bID %>">
                            <input type="submit" value="Delete" class="btn btn-delete">
                        </form>
                    </td>
                </tr>
            <% } rsBids.close(); %>
        </table>
    </div>

    <% 
        stmt.close();
        db.closeConnection(conn); 
    %>
</body>
</html>