<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.cs336.pkg.*, java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Create Auction</title>
<script>
    function showSpecificFields() {
        var type = document.getElementById("typeSelect").value;
        document.getElementById("shirtFields").style.display = "none";
        document.getElementById("pantsFields").style.display = "none";
        document.getElementById("outerwearFields").style.display = "none";

        if (type === "Shirt") {
            document.getElementById("shirtFields").style.display = "block";
        } else if (type === "Pants") {
            document.getElementById("pantsFields").style.display = "block";
        } else if (type === "OuterWear") {
            document.getElementById("outerwearFields").style.display = "block";
        }
    }
</script>
</head>
<body onload="showSpecificFields()">
    <h2>Create a New Auction</h2>
    <a href="browse.jsp">Back to Browse</a>
    <hr>
    
    <%
        if (session.getAttribute("userID") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>

    <form method="post" action="create_auction_action.jsp"> 
        <h3>1. General Clothing Details</h3>
        <table> 
            <tr>
                <td>Type:</td>
                <td>
                    <select name="type" id="typeSelect" onchange="showSpecificFields()">
                        <option value="Shirt">Shirt</option>
                        <option value="Pants">Pants</option>
                        <option value="OuterWear">OuterWear</option>
                    </select>
                </td>
            </tr>
            <tr><td>Brand:</td><td><input type="text" name="brand" required></td></tr> 
            <tr><td>Material:</td><td><input type="text" name="material"></td></tr> 
            <tr><td>Condition:</td><td><input type="text" name="condition"></td></tr>
            <tr><td>Color:</td><td><input type="text" name="color" required></td></tr> 
            <tr><td>Size:</td><td><input type="text" name="size"></td></tr>
            <tr><td>Title/Description:</td><td><input type="text" name="title" required></td></tr> 
        </table>

        <!-- Specific Fields for Shirt -->
        <div id="shirtFields" style="display:none; background:#f0f8ff; padding:10px; margin:10px 0;">
            <h4>Shirt Details</h4>
            Sleeve Length: <input type="text" name="sleeveLength"><br>
            Neckline Type: <input type="text" name="necklineType"><br>
            Has Buttons: 
            <select name="hasButtons">
                <option value="1">Yes</option>
                <option value="0">No</option>
            </select>
        </div>

        <!-- Specific Fields for Pants -->
        <div id="pantsFields" style="display:none; background:#f0fff0; padding:10px; margin:10px 0;">
            <h4>Pants Details</h4>
            Waistline Size: <input type="text" name="waistlineSize"><br>
            Pant Length (number): <input type="number" name="pantLength"><br>
            Has Zipper: 
            <select name="hasZipper">
                <option value="1">Yes</option>
                <option value="0">No</option>
            </select>
        </div>

        <!-- Specific Fields for OuterWear -->
        <div id="outerwearFields" style="display:none; background:#fff0f5; padding:10px; margin:10px 0;">
            <h4>OuterWear Details</h4>
            Closure Type: <input type="text" name="closureType"><br>
            Has Hood: 
            <select name="hasHood">
                <option value="1">Yes</option>
                <option value="0">No</option>
            </select><br>
            Is Waterproof: 
            <select name="isWaterproof">
                <option value="1">Yes</option>
                <option value="0">No</option>
            </select>
        </div>

        <h3>2. Auction Settings</h3> 
        <table> 
            <tr> 
                <td>End Date (YYYY-MM-DD HH:MM:SS):</td>
                <td><input type="datetime-local" name="endTime" required></td> 
            </tr> 
            <tr> 
                <td>Start Price (Min Bid):</td> 
                <td><input type="number" step="0.01" name="minPrice" required></td> 
            </tr> 
            <tr> 
                <td>Reserve Price (Hidden Minimum):</td> 
                <td><input type="number" step="0.01" name="reservePrice" placeholder="Optional"></td> 
            </tr> 
            <tr> 
                <td>Bid Increment:</td> 
                <td><input type="number" step="0.01" name="increment" value="1.00"></td> 
            </tr> 
        </table> 
        <br> 
        <input type="submit" value="Create Auction"> 
    </form>
</body>
</html>