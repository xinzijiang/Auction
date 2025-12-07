<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head><title>Q&A Forum</title></head>
<body>
    <h2>Customer Service Q&A</h2>
    <a href="browse.jsp">Back to Browse</a>
    <hr>
    
    <h3>Ask a Question</h3>
    <form action="ask_question_action.jsp" method="post">
        <textarea name="question" rows="3" cols="50" required></textarea><br>
        <input type="submit" value="Post Question">
    </form>
    
    <hr>
    <form action="qa_forum.jsp" method="get">
        Search Questions: <input type="text" name="keyword">
        <input type="submit" value="Search">
    </form>
    
    <h3>Questions & Answers</h3>
    <table border="1" width="100%">
        <tr><th>Question</th><th>Answer (from Rep)</th><th>Date</th></tr>
        <%
            String keyword = request.getParameter("keyword");
            ApplicationDB db = new ApplicationDB();
            Connection conn = db.getConnection();
            
            String sql = "SELECT * FROM Questions";
            PreparedStatement ps;
            
            // Use PreparedStatement to prevent SQL injection
            if(keyword != null && !keyword.trim().isEmpty()) {
                sql += " WHERE questionText LIKE ? OR answerText LIKE ?";
                ps = conn.prepareStatement(sql + " ORDER BY postDate DESC");
                String searchPattern = "%" + keyword.trim() + "%";
                ps.setString(1, searchPattern);
                ps.setString(2, searchPattern);
            } else {
                ps = conn.prepareStatement(sql + " ORDER BY postDate DESC");
            }
            
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                String ans = rs.getString("answerText");
                if(ans == null) ans = "<i>Waiting for reply...</i>";
        %>
            <tr>
                <td><%= rs.getString("questionText") %></td>
                <td><%= ans %></td>
                <td><%= rs.getTimestamp("postDate") %></td>
            </tr>
        <% } 
           rs.close();
           ps.close();
           db.closeConnection(conn); 
        %>
    </table>
</body>
</html>