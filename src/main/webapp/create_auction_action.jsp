<%@ page import="com.cs336.pkg.*, java.sql.*, java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("userID") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int sellerID = (Integer) session.getAttribute("userID");

    // 1. Get General Parameters
    String type = request.getParameter("type");
    String brand = request.getParameter("brand");
    String material = request.getParameter("material");
    String condition = request.getParameter("condition");
    String color = request.getParameter("color");
    String size = request.getParameter("size");
    String title = request.getParameter("title");
    
    // 2. Get Auction Parameters
    String endTimeStr = request.getParameter("endTime"); 
    String minPriceStr = request.getParameter("minPrice");
    String reservePriceStr = request.getParameter("reservePrice");
    String incrementStr = request.getParameter("increment");

    ApplicationDB db = new ApplicationDB();
    Connection conn = db.getConnection();

    try {
        conn.setAutoCommit(false); // Start Transaction

        // ---------------------------------------------------------
        // Step A: Insert into Parent Table (ClothingItem)
        // ---------------------------------------------------------
        String sqlItem = "INSERT INTO ClothingItem (type, brand, material, `condition`, color, size) VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement psItem = conn.prepareStatement(sqlItem, Statement.RETURN_GENERATED_KEYS);
        psItem.setString(1, type);
        psItem.setString(2, brand);
        psItem.setString(3, material);
        psItem.setString(4, condition);
        psItem.setString(5, color);
        psItem.setString(6, size);
        psItem.executeUpdate();
        
        ResultSet rsItem = psItem.getGeneratedKeys();
        int clothingID = 0;
        if(rsItem.next()) {
            clothingID = rsItem.getInt(1);
        } else {
            throw new Exception("Failed to retrieve clothingID.");
        }

        // ---------------------------------------------------------
        // Step B: Insert into Sub-Table (Shirt / Pants / OuterWear)
        // ---------------------------------------------------------
        if ("Shirt".equals(type)) {
            String sleeve = request.getParameter("sleeveLength");
            String neckline = request.getParameter("necklineType");
            String buttonsStr = request.getParameter("hasButtons");
            int buttons = (buttonsStr != null && !buttonsStr.isEmpty()) ? Integer.parseInt(buttonsStr) : 0;
            
            String sqlShirt = "INSERT INTO Shirt (clothingID, sleeveLength, necklineType, hasButtons) VALUES (?, ?, ?, ?)";
            PreparedStatement psShirt = conn.prepareStatement(sqlShirt);
            psShirt.setInt(1, clothingID);
            psShirt.setString(2, sleeve);
            psShirt.setString(3, neckline);
            psShirt.setInt(4, buttons);
            psShirt.executeUpdate();
            
        } else if ("Pants".equals(type)) {
            String waist = request.getParameter("waistlineSize");
            String pLenStr = request.getParameter("pantLength");
            int pLen = (pLenStr != null && !pLenStr.isEmpty()) ? Integer.parseInt(pLenStr) : 0;
            String zipperStr = request.getParameter("hasZipper");
            int zipper = (zipperStr != null && !zipperStr.isEmpty()) ? Integer.parseInt(zipperStr) : 0;
            
            String sqlPants = "INSERT INTO Pants (clothingID, waistlineSize, pantLength, hasZipper) VALUES (?, ?, ?, ?)";
            PreparedStatement psPants = conn.prepareStatement(sqlPants);
            psPants.setInt(1, clothingID);
            psPants.setString(2, waist);
            psPants.setInt(3, pLen);
            psPants.setInt(4, zipper);
            psPants.executeUpdate();
            
        } else if ("OuterWear".equals(type)) {
            String closure = request.getParameter("closureType");
            String hoodStr = request.getParameter("hasHood");
            int hood = (hoodStr != null && !hoodStr.isEmpty()) ? Integer.parseInt(hoodStr) : 0;
            String waterproofStr = request.getParameter("isWaterproof");
            int waterproof = (waterproofStr != null && !waterproofStr.isEmpty()) ? Integer.parseInt(waterproofStr) : 0;
            
            String sqlOuter = "INSERT INTO OuterWear (clothingID, closureType, hasHood, isWaterproof) VALUES (?, ?, ?, ?)";
            PreparedStatement psOuter = conn.prepareStatement(sqlOuter);
            psOuter.setInt(1, clothingID);
            psOuter.setString(2, closure);
            psOuter.setInt(3, hood);
            psOuter.setInt(4, waterproof);
            psOuter.executeUpdate();
        }

        // ---------------------------------------------------------
        // Step C: Insert Auction
        // ---------------------------------------------------------
        // Fix Date Format: HTML5 returns "YYYY-MM-DDTHH:MM", MySQL needs "YYYY-MM-DD HH:MM:SS"
        String cleanEndTime = endTimeStr.replace("T", " ");
        if(cleanEndTime.length() == 16) {
            cleanEndTime += ":00"; // Append seconds if missing
        }
        
        float minPrice = Float.parseFloat(minPriceStr);
        float reservePrice = (reservePriceStr != null && !reservePriceStr.isEmpty()) ? Float.parseFloat(reservePriceStr) : 0.0f;
        float increment = Float.parseFloat(incrementStr);

        String sqlAuc = "INSERT INTO Auction (sellerID, clothingID, title, minPrice, reservePrice, currentPrice, increment, status, endTime) VALUES (?, ?, ?, ?, ?, ?, ?, 'Active', ?)";
        PreparedStatement psAuc = conn.prepareStatement(sqlAuc);
        psAuc.setInt(1, sellerID);
        psAuc.setInt(2, clothingID);
        psAuc.setString(3, title);
        psAuc.setFloat(4, minPrice);
        psAuc.setFloat(5, reservePrice);
        psAuc.setFloat(6, minPrice); 
        psAuc.setFloat(7, increment);
        psAuc.setString(8, cleanEndTime);
        psAuc.executeUpdate();

        // ---------------------------------------------------------
        // Step D: Check Alerts (CORRECTED LOGIC)
        // ---------------------------------------------------------
        // We want to find users who are looking for THIS item.
        // Logic: If the user specified a Brand, it MUST match. If they left Brand NULL, they don't care (match anything).
        // Same for Type and Color.
        String sqlAlertCheck = "SELECT userID FROM AlertCriteria " +
                               "WHERE (desiredType IS NULL OR desiredType = ?) " +
                               "AND (desiredBrand IS NULL OR desiredBrand = ?) " +
                               "AND (desiredColor IS NULL OR desiredColor = ?)";
                               
        PreparedStatement psCheck = conn.prepareStatement(sqlAlertCheck);
        psCheck.setString(1, type);
        psCheck.setString(2, brand);
        psCheck.setString(3, color);
        ResultSet rsCheck = psCheck.executeQuery();
        
        while(rsCheck.next()) {
            int targetUser = rsCheck.getInt("userID");
            if(targetUser == sellerID) continue; // Don't alert the seller themselves

            String msg = "New Item Alert: A " + color + " " + brand + " " + type + " has been listed!";
            PreparedStatement psInsAlert = conn.prepareStatement("INSERT INTO Alert (userID, message) VALUES (?, ?)");
            psInsAlert.setInt(1, targetUser);
            psInsAlert.setString(2, msg);
            psInsAlert.executeUpdate();
        }

        conn.commit(); // Commit Transaction
        out.println("Auction Created Successfully! <a href='browse.jsp'>Back to Browse</a>");

    } catch (Exception e) {
        try { if(conn != null) conn.rollback(); } catch(SQLException se) {}
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        try { if(conn != null) conn.setAutoCommit(true); } catch(SQLException se) {}
        db.closeConnection(conn);
    }
%>