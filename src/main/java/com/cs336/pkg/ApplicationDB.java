package com.cs336.pkg;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ApplicationDB {

    public ApplicationDB() {
        // default constructor
    }

    public Connection getConnection() {
        // Configure your DB credentials here
        String dbHost = "localhost";
        String dbPort = "3306";
        String dbName = "group62_db";
        String dbUser = "root";
        String dbPass = "1234"; //-> Please change this if your MySQL password differs

        String jdbcUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName
                + "?useSSL=false&serverTimezone=UTC";
        String driver = "com.mysql.cj.jdbc.Driver";

        Connection conn = null;
        try {
            Class.forName(driver);
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
        } catch (ClassNotFoundException e) {
            System.out.println("JDBC Driver not found. Add the MySQL connector JAR to WEB-INF/lib.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("Database connection failed. Check dbName, dbUser, and dbPass.");
            e.printStackTrace();
        }
        return conn;
    }

    public void closeConnection(Connection conn) {
        try {
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}