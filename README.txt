=============================================================================
AUCTION SYSTEM - PROJECT README
=============================================================================

1. OVERVIEW
-----------------------------------------------------------------------------
This is a dynamic auction website implemented using Java (JSP/Servlets) and 
MySQL. It supports three types of users: End Users (Buyers/Sellers), 
Customer Representatives, and Administrators.

The project fulfills all requirements specified in the checklist, including:
- Auction creation, bidding (manual & automatic), and browsing.
- Advanced search and alert systems.
- Administrative and Customer Service dashboards.
- Automated handling of expired auctions.

2. CREDENTIALS (PRE-LOADED DATA)
-----------------------------------------------------------------------------
The database comes pre-populated with the following accounts for testing:

[Administrator]
Username: admin
Password: admin
* Access: admin_dashboard.jsp (Can create Reps, view Sales Reports)

[Customer Representative]
Username: rep1
Password: 1234
* Access: rep_dashboard.jsp (Can manage Users, Auctions, Bids, Q&A)

[End User]
Username: user1
Password: 1234
* Access: browse.jsp, item_details.jsp, etc. (Can Buy/Sell items)

Note: You can register new End Users via the registration page. New Customer 
Representatives can only be created by the Admin.

3. DATABASE CONFIGURATION
-----------------------------------------------------------------------------
The database schema and initial data are located in:
> sql file/group62_schema.sql

Please ensure your MySQL server is running and the connection details in 
`src/main/java/com/cs336/pkg/ApplicationDB.java` match your local setup:
- DB Name: group62_db
- User: root
- Password: 1234 (Default) -> *Please change this if your MySQL password differs*

4. KEY FEATURES & USAGE
-----------------------------------------------------------------------------
A. Automatic Bidding:
   - When placing a bid, users can set a "Secret Auto-Bid Upper Limit".
   - The system will automatically bid on their behalf up to this limit 
     if they are outbid by another user.

B. Auction Settlement:
   - Auctions are processed automatically when browsing.
   - If the Reserve Price is not met, the item is not sold.
   - Winners are alerted via the "My Alerts" page.

C. Similar Items:
   - The Item Details page automatically shows similar items sold in the 
     last 30 days to help buyers gauge market value.

D. Alerts:
   - Users can set criteria (Brand, Color, Type) in "Set Alerts".
   - When a matching item is listed, they receive a notification.

5. RUNNING THE PROJECT (ECLIPSE)
-----------------------------------------------------------------------------
1. Import the project into Eclipse Enterprise Edition.
2. Run `group62_schema.sql` in your MySQL Workbench/Terminal.
3. Right-click the project -> Run As -> Run on Server (Tomcat 9.0).
4. Access// filepath: /Users/jiangjiang/eclipse-workspace/Group62_Project/README.txt
=============================================================================
GROUP 62 AUCTION SYSTEM - PROJECT README
=============================================================================

1. OVERVIEW
-----------------------------------------------------------------------------
This is a dynamic auction website implemented using Java (JSP/Servlets) and 
MySQL. It supports three types of users: End Users (Buyers/Sellers), 
Customer Representatives, and Administrators.

The project fulfills all requirements specified in the checklist, including:
- Auction creation, bidding (manual & automatic), and browsing.
- Advanced search and alert systems.
- Administrative and Customer Service dashboards.
- Automated handling of expired auctions.

2. CREDENTIALS (PRE-LOADED DATA)
-----------------------------------------------------------------------------
The database comes pre-populated with the following accounts for testing:

[Administrator]
Username: admin
Password: admin
* Access: admin_dashboard.jsp (Can create Reps, view Sales Reports)

[Customer Representative]
Username: rep1
Password: 1234
* Access: rep_dashboard.jsp (Can manage Users, Auctions, Bids, Q&A)

[End User]
Username: user1
Password: 1234
* Access: browse.jsp, item_details.jsp, etc. (Can Buy/Sell items)

Note: You can register new End Users via the registration page. New Customer 
Representatives can only be created by the Admin.

3. DATABASE CONFIGURATION
-----------------------------------------------------------------------------
The database schema and initial data are located in:
> sql file/group62_schema.sql

Please ensure your MySQL server is running and the connection details in 
`src/main/java/com/cs336/pkg/ApplicationDB.java` match your local setup:
- DB Name: group62_db
- User: root
- Password: 1234 (Default) -> *Please change this if your MySQL password differs*

4. KEY FEATURES & USAGE
-----------------------------------------------------------------------------
A. Automatic Bidding:
   - When placing a bid, users can set a "Secret Auto-Bid Upper Limit".
   - The system will automatically bid on their behalf up to this limit 
     if they are outbid by another user.

B. Auction Settlement:
   - Auctions are processed automatically when browsing.
   - If the Reserve Price is not met, the item is not sold.
   - Winners are alerted via the "My Alerts" page.

C. Similar Items:
   - The Item Details page automatically shows similar items sold in the 
     last 30 days to help buyers gauge market value.

D. Alerts:
   - Users can set criteria (Brand, Color, Type) in "Set Alerts".
   - When a matching item is listed, they receive a notification.

5. RUNNING THE PROJECT (ECLIPSE)
-----------------------------------------------------------------------------
1. Import the project into Eclipse Enterprise Edition.
2. Run `group62_schema.sql` in your MySQL Workbench/Terminal.
3. Right-click the project -> Run As -> Run on Server (Tomcat 9.0).
4. Access