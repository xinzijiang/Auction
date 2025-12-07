DROP SCHEMA IF EXISTS `group62_db`;
CREATE SCHEMA `group62_db`;
USE `group62_db`;

-- ==========================================
-- 1. Users & Roles (With AUTO_INCREMENT)
-- ==========================================

-- End User Table
CREATE TABLE `EndUser` (
  `userID` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL UNIQUE,
  `password` varchar(50) NOT NULL,
  `email` varchar(100),
  `isAnonymous` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`userID`)
);

-- Admin Table
CREATE TABLE `Admin` (
  `userID` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL UNIQUE,
  `password` varchar(50) NOT NULL,
  PRIMARY KEY (`userID`)
);

-- Customer Representative Table
CREATE TABLE `CustomerRep` (
  `userID` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL UNIQUE,
  `password` varchar(50) NOT NULL,
  PRIMARY KEY (`userID`)
);

-- ==========================================
-- 2. Items & Auctions (With AUTO_INCREMENT)
-- ==========================================

-- Parent Item Table
CREATE TABLE `ClothingItem` (
  `clothingID` int NOT NULL AUTO_INCREMENT,
  `type` varchar(50), -- Shirt, Pants, OuterWear
  `brand` varchar(100),
  `material` varchar(100),
  `condition` varchar(50),
  `color` varchar(50),
  `size` varchar(20),
  PRIMARY KEY (`clothingID`)
);

-- Sub-tables (Inheritance)
-- NOTE: Removed AUTO_INCREMENT from subclasses. They share the ID from ClothingItem.
CREATE TABLE `Shirt` (
  `clothingID` int NOT NULL,
  `sleeveLength` varchar(50),
  `necklineType` varchar(50),
  `hasButtons` tinyint(1),
  PRIMARY KEY (`clothingID`),
  FOREIGN KEY (`clothingID`) REFERENCES `ClothingItem` (`clothingID`) ON DELETE CASCADE
);

CREATE TABLE `Pants` (
  `clothingID` int NOT NULL,
  `waistlineSize` varchar(5),
  `pantLength` int,
  `hasZipper` tinyint(1),
  PRIMARY KEY (`clothingID`),
  FOREIGN KEY (`clothingID`) REFERENCES `ClothingItem` (`clothingID`) ON DELETE CASCADE
);

CREATE TABLE `OuterWear` (
  `clothingID` int NOT NULL,
  `closureType` varchar(50),
  `hasHood` tinyint(1),
  `isWaterproof` tinyint(1),
  PRIMARY KEY (`clothingID`),
  FOREIGN KEY (`clothingID`) REFERENCES `ClothingItem` (`clothingID`) ON DELETE CASCADE
);

-- Auction Table
CREATE TABLE `Auction` (
  `auctionID` int NOT NULL AUTO_INCREMENT,
  `sellerID` int NOT NULL,
  `clothingID` int NOT NULL,
  `title` varchar(255),
  `minPrice` float DEFAULT 0.0,
  `reservePrice` float DEFAULT 0.0,
  `currentPrice` float DEFAULT 0.0,
  `increment` float DEFAULT 1.0,
  `status` varchar(20) DEFAULT 'Active', -- Active, Sold, Closed
  `endTime` datetime NOT NULL,
  PRIMARY KEY (`auctionID`),
  FOREIGN KEY (`sellerID`) REFERENCES `EndUser` (`userID`),
  FOREIGN KEY (`clothingID`) REFERENCES `ClothingItem` (`clothingID`)
);

-- Bid Table
CREATE TABLE `Bid` (
  `bidID` int NOT NULL AUTO_INCREMENT,
  `auctionID` int NOT NULL,
  `userID` int NOT NULL,
  `amount` float NOT NULL,
  `autoBidMax` float DEFAULT 0.0,
  `bidTime` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`bidID`),
  FOREIGN KEY (`auctionID`) REFERENCES `Auction` (`auctionID`),
  FOREIGN KEY (`userID`) REFERENCES `EndUser` (`userID`)
);

-- ==========================================
-- 3. Alerts & Questions (New Features)
-- ==========================================

-- Alert Criteria: User sets this to get notified later
CREATE TABLE `AlertCriteria` (
  `criteriaID` int NOT NULL AUTO_INCREMENT,
  `userID` int NOT NULL,
  `desiredType` varchar(50),
  `desiredColor` varchar(50),
  `desiredBrand` varchar(100),
  PRIMARY KEY (`criteriaID`),
  FOREIGN KEY (`userID`) REFERENCES `EndUser` (`userID`)
);

-- Generated Alerts: System creates these messages
CREATE TABLE `Alert` (
  `alertID` int NOT NULL AUTO_INCREMENT,
  `userID` int NOT NULL,
  `message` text,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`alertID`),
  FOREIGN KEY (`userID`) REFERENCES `EndUser` (`userID`)
);

-- Q&A Forum
CREATE TABLE `Questions` (
  `questionID` int NOT NULL AUTO_INCREMENT,
  `userID` int NOT NULL,
  `repID` int DEFAULT NULL, -- NULL if not answered yet
  `questionText` text,
  `answerText` text,
  `postDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`questionID`),
  FOREIGN KEY (`userID`) REFERENCES `EndUser` (`userID`),
  FOREIGN KEY (`repID`) REFERENCES `CustomerRep` (`userID`)
);

-- ==========================================
-- 4. Initial Data
-- ==========================================
INSERT INTO EndUser (username, password, email) VALUES ('user1', '1234', 'u1@test.com');
INSERT INTO Admin (username, password) VALUES ('admin', 'admin');
INSERT INTO CustomerRep (username, password) VALUES ('rep1', '1234');