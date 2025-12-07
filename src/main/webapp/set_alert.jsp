<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head><title>Set Alerts</title></head>
<body>
    <%
        if (session.getAttribute("userID") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    <h2>Create an Item Alert</h2>
    <p>Notify me when an item matching these criteria is listed:</p>
    
    <form action="set_alert_action.jsp" method="post">
        Desired Type (e.g., Shirt): <input type="text" name="type"><br>
        Desired Brand (e.g., Nike): <input type="text" name="brand"><br>
        Desired Color (e.g., Red): <input type="text" name="color"><br>
        <input type="submit" value="Set Alert">
    </form>
    
    <br><a href="browse.jsp">Back</a>
</body>
</html>