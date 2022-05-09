/*
John D'Amaro
12/1/19
CSE 581 - Project 2
*/

USE master
GO

/****** Object:  Database Competitor     ******/
IF DB_ID('Competitor') IS NOT NULL
	DROP DATABASE Competitor
GO

CREATE DATABASE Competitor
GO 

USE Competitor
GO

/****** Object:  Schema JD     ******/
IF SCHEMA_ID('JD') IS NOT NULL
	DROP SCHEMA JD
GO

CREATE SCHEMA JD
GO

/****** Object:  Table Customers  ******/   
CREATE TABLE JD.Customers(
	CustomerID           INT            PRIMARY KEY   IDENTITY,
	FirstName            VARCHAR(60)    NOT NULL,
	LastName             VARCHAR(60)    NOT NULL,
	UserName             VARCHAR(60)    NOT NULL,
	EmailAddress         VARCHAR(255)   NOT NULL      UNIQUE
)
GO

/****** Object:  Table CustomerPhoneNumbers  ******/   
CREATE TABLE JD.CustomerPhoneNumbers(
	CustomerID    INT            REFERENCES JD.Customers (CustomerID),
	Phone		  VARCHAR(12)	 NOT NULL   CHECK(LEN(Phone) = 10),
	Type		  VARCHAR(10)	 NOT NULL,
)
GO

/****** Object:  Table CustomerShippingAddress  ******/   
CREATE TABLE JD.CustomerShippingAddress(
	ShipAddressID       INT            PRIMARY KEY   IDENTITY,
	CustomerID          INT            REFERENCES JD.Customers (CustomerID),
	AddressNickName     VARCHAR(60)    NOT NULL,
	Line1               VARCHAR(255)   NOT NULL,
	Line2               VARCHAR(60)    DEFAULT NULL,
	City                VARCHAR(40)    NOT NULL,
	State               VARCHAR(2)     NOT NULL,
	ZipCode             VARCHAR(10)    NOT NULL   CHECK(LEN(ZipCode) = 5)
)
GO

/****** Object:  Table CustomerBillingAddress  ******/   
CREATE TABLE JD.CustomerBillingAddress(
	BillAddressID       INT            PRIMARY KEY   IDENTITY,
	CustomerID          INT            REFERENCES JD.Customers (CustomerID),
	AddressNickName     VARCHAR(60)    NOT NULL,
	Line1               VARCHAR(255)   NOT NULL,
	Line2               VARCHAR(60)    DEFAULT NULL,
	City                VARCHAR(40)    NOT NULL,
	State               VARCHAR(2)     NOT NULL,
	ZipCode             VARCHAR(10)    NOT NULL
)
GO

/****** Object:  Table Suppliers  ******/   
CREATE TABLE JD.Suppliers(
	SupplierID		    INT            PRIMARY KEY   IDENTITY,
	Name                VARCHAR(255)   NOT NULL,
	Line1               VARCHAR(255)   NOT NULL,
	Line2               VARCHAR(60)    DEFAULT NULL,
	City                VARCHAR(40)    NOT NULL,
	State               VARCHAR(2)     NOT NULL,
	ZipCode             VARCHAR(10)    NOT NULL      CHECK(LEN(ZipCode) = 5),
	Phone			    VARCHAR(12)	   NOT NULL      CHECK(LEN(Phone) = 10),
	EmailAddress        VARCHAR(255)   NOT NULL      UNIQUE
)
GO

/****** Object:  Table Products  ******/   
CREATE TABLE JD.Products (
	ProductID         INT            PRIMARY KEY   IDENTITY, 
	SupplierID        INT            REFERENCES JD.Suppliers (SupplierID),
	ProductCode       VARCHAR(10)    NOT NULL      UNIQUE,
	ProductName       VARCHAR(255)   NOT NULL,
	Description       TEXT           NOT NULL,
	ListPrice         MONEY          NOT NULL,
	CHECK (ListPrice > 0 AND LEN(ProductCode) = 5)
 )
 GO

/****** Object:  Table Warehouse  ******/
 CREATE TABLE JD.Warehouse(
	WarehouseID		    INT            PRIMARY KEY   IDENTITY,
	Line1               VARCHAR(255)   NOT NULL,
	Line2               VARCHAR(60)    DEFAULT NULL,
	City                VARCHAR(40)    NOT NULL,
	State               VARCHAR(2)     NOT NULL,
	ZipCode             VARCHAR(10)    NOT NULL,
	Phone			    VARCHAR(12)	   NOT NULL,
	EmailAddress        VARCHAR(255)   NOT NULL      UNIQUE
)
GO

/****** Object:  Table OrderStatus  ******/
CREATE TABLE JD.OrderStatus (
  StatusID        INT           PRIMARY KEY   IDENTITY,
  StatusName      VARCHAR(60)   NOT NULL      
)
GO

/****** Object:  Table ShippingService  ******/
CREATE TABLE JD.ShippingService (
  ShipViaID        INT           PRIMARY KEY   IDENTITY,
  ServiceName      VARCHAR(60)   NOT NULL,
  CostOfService    MONEY         NOT NULL
)
GO

/****** Object:  Table Orders  ******/
CREATE TABLE JD.Orders (
	OrderID           INT            PRIMARY KEY  IDENTITY,
	CustomerID        INT            REFERENCES JD.Customers (CustomerID),
	StatusID          INT            REFERENCES JD.OrderStatus (StatusID),
	OrderDate         SMALLDATETIME  NOT NULL,
	TotalAmount       MONEY          NOT NULL   CHECK( TotalAmount > 0),
	ShipViaID         INT            REFERENCES JD.ShippingService (ShipViaID),
	ShipAddressID     INT            NOT NULL,
	ShipAmount        MONEY          CHECK( ShipAmount > 0),
	ExpectShipDate    SMALLDATETIME  DEFAULT NULL,
	ShipDate          SMALLDATETIME  DEFAULT NULL,
	BillAddressID  INT               NOT NULL    
)
GO

/****** Object:  Table OrderItems  ******/
CREATE TABLE JD.OrderItems (
	ItemID             INT            PRIMARY KEY  IDENTITY,
	OrderID            INT            REFERENCES JD.Orders (OrderID),
	ProductID          INT            REFERENCES JD.Products (ProductID),
	ItemPrice          MONEY		  NOT NULL,
	Quantity           INT            NOT NULL,
	CHECK (ItemPrice > 0 AND Quantity > 0)
)
GO

/****** Object:  Table Reviews  ******/
CREATE TABLE JD.Reviews (
	ReviewID          INT				 PRIMARY KEY  IDENTITY,
	CustomerID        INT				 REFERENCES JD.Customers (CustomerID),
	ProductID         INT				 REFERENCES JD.Products (ProductID),
	OrderID           INT                REFERENCES JD.Orders (OrderID),
	ReviewDate        SMALLDATETIME		 NULL,
	Score             INT				 NULL,
	Text              TEXT				 NULL
)
GO

/****** Object:  Table Wishlist  ******/
CREATE TABLE JD.Wishlist (
	CustomerID        INT				REFERENCES JD.Customers (CustomerID),
	ProductID         INT				REFERENCES JD.Products (ProductID),
	DateAdded         SMALLDATETIME     DEFAULT NULL
)
GO

/****** Object:  Table Storage  ******/
CREATE TABLE JD.Storage (
	WarehouseID		  INT			 REFERENCES JD.Warehouse (WarehouseID),
	ProductID         INT			 REFERENCES JD.Products (ProductID),
	ProductName       VARCHAR(255)   NOT NULL,
	ProductInStock    INT			 NOT NULL CHECK (ProductInStock >=0),
	ProductOut		  INT			 NOT NULL CHECK (ProductOut >=0),
	ProductReturned   INT			 NOT NULL CHECK (ProductReturned >=0),
	PRIMARY KEY (WarehouseID, ProductID)
)
GO

/****** Object:  Table Distance  ******/
CREATE TABLE JD.Distance (
	DistanceID        INT           PRIMARY KEY  IDENTITY,
	RouteDistance     VARCHAR(80)   NOT NULL,
	DaysToShip        INT           NOT NULL,
	CostOfDistance    MONEY         NOT NULL CHECK( CostOfDistance >= 0)
)
GO


/****** Object:  Table ShippingFare  ******/
CREATE TABLE JD.ShippingFare (
	ShipZipCode         VARCHAR(10)    NOT NULL,
	WarehouseZipCode    VARCHAR(10)    NOT NULL,
	ShipViaID           INT            REFERENCES JD.ShippingService (ShipViaID),
	DistanceID			INT			   REFERENCES JD.Distance (DistanceID),
	ShipAmount			MONEY		   NOT NULL CHECK( ShipAmount > 0)
)
GO

/****** Data Insertion  ******/

SET IDENTITY_INSERT JD.Customers ON;

INSERT INTO JD.Customers (CustomerID, FirstName, Lastname, UserName, EmailAddress) VALUES
(1, 'John', 'Damaro', 'jdamaro', 'johndamaro@gmail.com'),
(2, 'Kristen', 'El-Amir', 'kelamir', 'kelamir@gmail.com'),
(3, 'Kevin', 'Reilly', 'kreilly', 'kreilly@gmail.com'), 
(4, 'Eric', 'Pubins', 'epubins', 'epubins@gmail.com'),
(5, 'James', 'Sikora', 'jsikora', 'jsikora@gmail.com'),
(6, 'Thomas', 'Bannon', 'tbanz', 'tbanz@gmail.com'),
(7, 'Ethan', 'Greenberg', 'egreenberg', 'egreenberg@gmail.com'),
(8, 'Matthew', 'Lafferty', 'mlafferty', 'mlafferty@gmail.com'),
(9, 'Luke', 'Lafferty', 'llafferty', 'llafferty@gmail.com'),
(10, 'Victoria', 'Preis-Reilly', 'vpreilly', 'vpreilly@gmail.com'),
(11, 'Erin', 'Storan', 'estoran', 'estoran@gmail.com'),
(12, 'Tyler', 'Bas', 'tbas', 'tbas@gmail.com'),
(13, 'Dylan', 'Norr', 'dnorr', 'dnorr@gmail.com'),
(14, 'Matthew', 'Balick', 'mbalick', 'mbalick@gmail.com'),
(15, 'Giannis', 'Anteokounmpo', 'llotardo', 'llotardo@gmail.com');

SET IDENTITY_INSERT JD.Customers OFF;

INSERT INTO JD.CustomerPhoneNumbers (CustomerID, Phone, Type) VALUES
(1, '3957205729', 'Cell'),
(1, '2048637593', 'Home'),
(2, '1458930537', 'Cell'), 
(3, '9755305732', 'Cell'),
(3, '0193758302', 'Home'),
(4, '2347895673', 'Cell'),
(5, '1684690853', 'Cell'),
(6, '5804246854', 'Cell'),
(7, '9944883211', 'Cell'),
(7, '5921342568', 'Business'),
(8, '0937599274', 'Cell'),
(9, '6437230567', 'Cell'),
(10, '4967360273', 'Cell'),
(11, '2346978204', 'Cell'),
(11, '6758493234', 'Home'),
(11, '7864930567', 'Business'),
(12, '3094587438', 'Cell'),
(13, '3945658473', 'Cell'),
(14, '4586594302', 'Cell'),
(15, '3644567394', 'Cell');

SET IDENTITY_INSERT JD.CustomerShippingAddress ON;

INSERT INTO JD.CustomerShippingAddress (ShipAddressID, CustomerID, AddressNickName, Line1, Line2, City, State, ZipCode) VALUES
(1, 1, 'Home', '4 Primrose Path', NULL, 'Manorville', 'NY', '11949'),
(2, 2, 'Home', '423 Newport Ave', NULL, 'Fitchburg', 'MA', '01420'),
(3, 2, 'University', '54 Honey Creek Road', NULL, 'Deerfield Beach', 'FL', '33442'),
(4, 3, 'Home', '9982 Lafayette Lane', NULL, 'Torrington', 'CT', '06790'),
(5, 4, 'Home', '8509 University Road', NULL, 'Odenton', 'MD', '21113'),
(6, 4, 'Apartment', '971 Mayfield St', NULL, 'Royal Oak', 'MI', '48067'),
(7, 5, 'Home', '957 Willow St', NULL, 'Roswell', 'GA', '30075'),
(8, 6, 'Home', '8114 S. Rockville Street', NULL, 'Missoula', 'MT', '59801'),
(9, 7, 'Home', '616 Hamilton Ave', NULL, 'Beltsville', 'MD', '20705'),
(10, 8, 'Boyfriends Appartment', '614 County St', NULL, 'Worcester', 'MA', '01604'),
(11, 9, 'Home', '25 Woodland Court', NULL, 'Bethesda', 'MD', '20814'),
(12, 10, 'Home', '475 Addison Drive', NULL, 'Seattle', 'WA', '98144'),
(13, 10, 'Friends House', '4 New Saddle St', NULL, 'Harvey', 'IL', '60426'),
(14, 10, 'Parents House', '83 Rock Creek Lane', NULL, 'Fitchburg', 'MA', '01420'),
(15, 11, 'Home', '5 W. Linden St', NULL, 'Flushing', 'NY', '11354'),
(16, 12, 'Home', '7077 53rd St', NULL, 'West Des Moines', 'IA', '50265'),
(17, 13, 'Home', '93 Mill Pond Dr', NULL, 'Raleigh', 'NC', '27603'),
(18, 14, 'Home', '57 Franklin Ave', NULL, 'Wappingers Falls', 'NY', '12590'),
(19, 15, 'Home', '7775 Parker Drive', NULL, 'Union City', 'NJ', '07087'),
(20, 15, 'University', '710 Fifth St', NULL, 'Bridgeton', 'NJ', '08302');

SET IDENTITY_INSERT JD.CustomerShippingAddress OFF

SET IDENTITY_INSERT JD.CustomerBillingAddress ON;

INSERT INTO JD.CustomerBillingAddress (BillAddressID, CustomerID, AddressNickName, Line1, Line2, City, State, ZipCode) VALUES
(1, 1, 'Home', '4 Primrose Path', NULL, 'Manorville', 'NY', '11949'),
(2, 2, 'Home', '423 Newport Ave', NULL, 'Fitchburg', 'MA', '01420'),
(3, 3, 'Home', '9982 Lafayette Lane', NULL, 'Torrington', 'CT', '06790'),
(4, 4, 'Home', '8509 University Road', NULL, 'Odenton', 'MD', '2113'),
(5, 4, 'Apartment', '971 Mayfield St', NULL, 'Royal Oak', 'MI', '48067'),
(6, 5, 'Home', '957 Willow St', NULL, 'Roswell', 'GA', '30075'),
(7, 6, 'Home', '8114 S. Rockville Street', NULL, 'Missoula', 'MT', '59801'),
(8, 7, 'Home', '616 Hamilton Ave', NULL, 'Beltsville', 'MD', '20705'),
(9, 8, 'Boyfriends Appartment', '614 County St', NULL, 'Worcester', 'MA', '01604'),
(10, 9, 'Home', '25 Woodland Court', NULL, 'Bethesda', 'MD', '20814'),
(11, 10, 'Home', '475 Addison Drive', NULL, 'Seattle', 'WA', '98144'),
(12, 10, 'Parents House', '83 Rock Creek Lane', NULL, 'Fitchburg', 'MA', '01420'),
(13, 11, 'Home', '5 W. Linden St', NULL, 'Flushing', 'NY', '11354'),
(14, 12, 'Home', '7077 53rd St', NULL, 'West Des Moines', 'IA', '50265'),
(15, 13, 'Home', '93 Mill Pond Dr', NULL, 'Raleigh', 'NC', '27603'),
(16, 14, 'Home', '57 Franklin Ave', NULL, 'Wappingers Falls', 'NY', '12590'),
(17, 15, 'Home', '7775 Parker Drive', NULL, 'Union City', 'NJ', '07087');

SET IDENTITY_INSERT JD.CustomerBillingAddress OFF;

SET IDENTITY_INSERT JD.Suppliers ON;

INSERT INTO JD.Suppliers (SupplierID, Name, Line1, Line2, City, State, ZipCode, Phone, EmailAddress) VALUES
(1, 'Hydro Flask', '1331 S. 7th St', NULL, 'Chambersburg', 'PA', '17201', '6729476038', 'pfa@hydroflask.com'),
(2, 'Apple', '1 Destiny USA Drive', NULL, 'Syracuse', 'NY', '13210', '3152335920', 'syracuse@apple.com'),
(3, 'Coach', '516 W. 34th St', NULL, 'New York', 'NY', '10001', '5739563723', 'hq@coach.com'),
(4, 'Bic', '953 Courtland Ave', NULL, 'Canyon Country', 'CA', '91387', '3059683721', 'hq@bic.com'),
(5, 'JanSport', '907 Windsor St', NULL, 'Hastings', 'MN', '55033', '7849305948', 'hq@jansport.com'),
(6, 'Stussy', '375 Victoria St', NULL, 'Kalispell', 'MT', '59901', '5893049284', 'hq@stussy.com'),
(7, 'Hewlett Packard', '4 St Louis Street', NULL, 'Sykesville', 'MD', '21784', '3958677483', 'hq@hp.com'),
(8, 'Spotify', '2 Thatcher Lane', NULL, 'San Angelo', 'TX', '76901', '0097348274', 'hq@spotify.com'),
(9, 'Microsoft', '9522 Saxton Lane', NULL, 'Old Bridge', 'NJ', '08857', '7738294855', 'hq@microsoft.com'),
(10, 'Supreme', '264 Franklin Ave', NULL, 'Pembroke Pines', 'FL', '33028', '9833741028', 'hq@supreme.com')

SET IDENTITY_INSERT JD.Suppliers OFF;

SET IDENTITY_INSERT JD.Products ON;

INSERT INTO JD.Products (ProductID, SupplierID, ProductCode, ProductName, Description, ListPrice) VALUES
(1, 1, '29373', 'Wide Mouth 32 oz', 'Water Bottle', 40.00),
(2, 1, '29338', '20 oz Thermos', 'Water Bottle', 20.00),
(3, 2, '19473', 'iPhone X', 'Cellphone', 850.00),
(4, 2, '19038', 'Mac', 'Laptop', 1500.00),
(5, 3, '49385', 'Coach Tote', 'Pocketbook', 200.00),
(6, 3, '49205', 'Single Fold', 'Wallet', 80.00),
(7, 4, '32343', 'Black Premium', 'Pack of Pens', 10.00),
(8, 4, '32452', 'Yellow', 'Highlighters', 5.00),
(9, 5, '86545', 'All Terrain', 'Backpack', 75.00),
(10, 5, '86302', 'Classroom Case', 'Pen Holder', 40.00),
(11, 6, '01294', 'Mini-Logo', 'Long Sleeve Shirt', 60.00),
(12, 6, '01274', 'Surfer Special', 'T Shirt', 35.00),
(13, 7, '72352', 'Spectre', 'Laptop', 1300.00),
(14, 7, '72356', 'Bluetooth Copper', 'Mouse', 40.00),
(15, 8, '11428', 'Studio', 'Headphones', 100.00),
(16, 8, '11103', 'Music Stream', 'Subscription Service', 100.00),
(17, 9, '66392', 'Surface', 'Laptop', 1400.00),
(18, 9, '66093', 'windows', 'Cellphone', 750.00),
(19, 10, '00123', 'Box Logo', 'Long Sleeve Shirt', 65.00),
(20, 10, '00159', 'Skatewear', 'T Shirt', 40.00)

SET IDENTITY_INSERT JD.Products OFF;

SET IDENTITY_INSERT JD.Warehouse ON;

INSERT INTO JD.Warehouse (WarehouseID, Line1, Line2, City, State, ZipCode, Phone, EmailAddress) VALUES
(1, '64 Winding Wat St', NULL, 'Glastonbury', 'CT', '07003', '2039575738', 'CT@warehouse.com'),
(2, '201 Southampton St', NULL, 'Canonsburg', 'PA', '15317', '3945385739', 'PA@warehouse.com'),
(3, '665 James Dr', NULL, 'Mc Lean', 'VA', '22101', '3948539383', 'VA@warehouse.com'),
(4, '966 Westport St', NULL, 'Auburndale', 'FL', '33823', '0395737825', 'FL@warehouse.com'),
(5, '20 N. Madison Drive', NULL, 'Ashtabula', 'OH', '44004', '3948576657', 'OH@warehouse.com'),
(6, '3 West Wayne Dr', NULL, 'Cedar Falls', 'IA', '50613', '39456723954', 'IA@warehouse.com'),
(7, '20 NW Newcastle Street', NULL, 'Morton Grove', 'IL', '60053', '1039485738', 'IL@warehouse.com'),
(8, '7483 Laurel St', NULL, 'Richardson', 'TX', '75080', '0594827384', 'TX@warehouse.com'),
(9, '849 King St', NULL, 'Tucson', 'AZ', '85718', '3948573829', 'AZ@warehouse.com'),
(10, '58 South Oxford St', NULL, 'Seattle', 'WA', '98144', '9583728402', 'WA@warehouse.com')

SET IDENTITY_INSERT JD.Warehouse OFF;

SET IDENTITY_INSERT JD.OrderStatus ON;

INSERT INTO JD.OrderStatus (StatusID, StatusName) VALUES
(1, 'Ready'),
(2, 'Returned'),
(3, 'Shipped'),
(4, 'Delivered')

SET IDENTITY_INSERT JD.OrderStatus OFF;

SET IDENTITY_INSERT JD.ShippingService ON;

INSERT INTO JD.ShippingService (ShipViaID, ServiceName, CostOfService) VALUES
(1, 'USPS', 5.00),
(2, 'UPS', 7.00),
(3, 'FedEx', 15.00)

SET IDENTITY_INSERT JD.ShippingService OFF;

SET IDENTITY_INSERT JD.Orders ON;

INSERT INTO JD.Orders (OrderID, CustomerID, StatusID, OrderDate, TotalAmount, ShipViaID, ShipAddressID, ShipAmount, ExpectShipDate, ShipDate, BillAddressID) VALUES
(1, 4, 2, '2019-2-7', 155.00, 1, 5, 23.00, '2019-2-10', '2019-2-11', 5),
(2, 7, 1, '2019-3-10', 1400.00, 2, 9, 15.00, '2019-3-17', NULL, 8), 
(3, 13, 4, '2019-5-16', 310.00, 3, 17, 35.00, '2019-5-16', '2019-5-19', 15),
(4, 9, 4, '2019-5-18', 200.00, 1, 11, 10.00, '2019-5-21', '2019-5-21', 10),
(5, 1, 3, '2019-5-22', 60.00, 2, 1, 7.00, '2019-5-24', '2019-5-24', 1),
(6, 15, 3, '2019-6-20', 950.00, 3, 20, 38.00, '2019-6-27', '2019-7-1', 17),
(7, 1, 1, '2019-8-27', 2150.00, 1, 1, 23.00, '2019-9-4', NULL, 1),
(8, 8, 4, '2019-9-25', 90.00, 2, 10, 15.00, '2019-10-2', '2019-10-5', 9),
(9, 12, 1, '2019-12-11', 160.00, 3, 16, 43.00, '2019-12-18', NULL, 14),
(10, 2, 1, '2019-12-19', 1460.00, 1, 3, 33.00, '2019-12-26', NULL, 12)

SET IDENTITY_INSERT JD.Orders OFF;

SET IDENTITY_INSERT JD.OrderItems ON;

INSERT INTO JD.OrderItems (ItemID, OrderID, ProductID, ItemPrice, Quantity) VALUES
(1, 1, 1, 40.00, 2),
(2, 1, 9, 75.00, 1),
(3, 2, 17, 1400.00, 1),
(4, 3, 6, 80.00, 1),
(5, 3, 19, 65.00, 3),
(6, 3, 12, 35.00, 1),
(7, 4, 5, 200.00, 1),
(8, 5, 2, 20.00, 3),
(9, 6, 3, 850.00, 1),
(10, 6, 15, 100.00, 1),
(11, 7, 18, 750.00, 1),
(12, 7, 17, 1400.00, 1),
(13, 8, 7, 10.00, 4),
(14, 8, 8, 5.00, 2),
(15, 8, 10, 40.00, 1),
(16, 9, 11, 60.00, 1),
(17, 9, 16, 100.00, 1),
(18, 10, 13, 1300.00, 1),
(19, 10, 14, 40.00, 2),
(20, 10, 20, 40.00, 2)

SET IDENTITY_INSERT JD.OrderItems OFF;

SET IDENTITY_INSERT JD.Reviews ON;

INSERT INTO JD.Reviews (ReviewID, CustomerID, ProductID, OrderID, ReviewDate, Score, Text) VALUES
(1, 13, 12, 3, '2019-5-24', 5, 'Best T Shirt I have ever owned!'),
(2, 13, 6, 3, '2019-5-23', 3, 'Nice, but nothing special'),
(3, 9, 5, 4, '2019-5-22', 4, NULL),
(4, 8, 7, 8, '2019-10-1', 5, 'So great I got 4!'),
(5, 8, 10, 8, '2019-10-2', 5, 'Light weight and Durable')

SET IDENTITY_INSERT JD.Reviews OFF;

INSERT INTO JD.Wishlist (CustomerID, ProductID, DateAdded) VALUES
(12, 7, '2019-1-16'),
(15, 16, '2019-2-24'),
(10, 8, '2019-3-22'),
(9, 6, '2019-4-07'),
(1, 12, '2019-4-20'),
(7, 9, '2019-4-27'),
(14, 13, '2019-6-16'),
(3, 1, '2019-7-29'),
(5, 15, '2019-9-30'),
(4, 10, '2019-10-15')

INSERT INTO JD.Storage (WareHouseID, ProductID, ProductName, ProductInStock, ProductOut, ProductReturned) VALUES
(1, 3, 'iPhone X', 4, 1, 0),
(1, 18, 'windows', 2, 1, 0),
(1, 4, 'Mac', 2, 0, 2),
(2, 1, 'Wide Mouth 32 oz', 3, 2, 0),
(2, 2, '20 oz Thermos', 1, 3, 0),
(3, 19, 'Box Logo', 1, 4, 0),
(3, 20, 'Skatewear', 8, 3, 5),
(3, 11, 'Mini-Logo', 3, 7, 0),
(3, 12, 'Surfer Special', 5, 2, 0),
(4, 5, 'Coach Tote', 5, 6, 2),
(4, 6, 'Single Fold', 4, 7, 0),
(5, 7, 'Black Premium', 3, 5, 0),
(5, 8, 'Yellow', 1, 2, 0),
(5, 9, 'All Terrain', 6, 13, 0),
(5, 10, 'Classroom Case', 6, 3, 3),
(6, 13, 'Spectre', 4, 5, 0),
(6, 17, 'Surface', 5, 6, 0),
(7, 14, 'Bluetooth Copper', 2, 8, 1),
(7, 15, 'Studio', 4, 6, 0),
(7, 16, 'Music Subscription', 10, 4, 0),
(8, 19, 'Box Logo', 2, 2, 1),
(8, 6, 'Single Fold', 5, 5, 0),
(8, 13, 'Spectre', 3, 6, 0),
(9, 4, 'Mac', 6, 3, 0),
(9, 2, '20 oz Thermos', 5, 5, 2),
(9, 10, 'Classroom Case', 4, 3, 0),
(10, 9, 'All Terrain', 6, 7, 0),
(10, 5, 'Coach Tote', 3, 9, 0),
(10, 17, 'Surface', 8, 3, 0)

SET IDENTITY_INSERT JD.Distance ON;

INSERT INTO JD.Distance(DistanceID, RouteDistance, DaysToShip, CostOfDistance) VALUES
(1, 'Within the ZIP Code', 2, 0.00),
(2, 'Adjacent ZIP Code', 3, 5.00),
(3, 'Multiple Zip Codes Away', 7, 8.00),
(4, 'Cross Country', 10, 15.00)

SET IDENTITY_INSERT JD.Distance OFF;

INSERT INTO JD.ShippingFare (ShipZipCode, WarehouseZipCode, ShipViaID, DistanceID, ShipAmount) VALUES
('21113', '15317', 1, 2, 10.00),
('21113', '44004', 1, 3, 13.00),
('20705', '50613', 2, 3, 15.00),
('27603', '22101', 3, 1, 15.00),
('27603', '33823', 3, 2, 20.00),
('20814', '33823', 1, 2, 10.00),
('11949', '15317', 2, 1, 7.00),
('08302', '07003', 3, 1, 15.00),
('08302', '60053', 3, 3, 23.00),
('11949', '07003', 1, 2, 10.00),
('11949', '50613', 1, 3, 13.00),
('01604', '44004', 2, 3, 15.00),
('50265', '22101', 3, 3, 23.00),
('50265', '60053', 3, 2, 20.00),
('33442', '50613', 1, 3, 13.00),
('33442', '60053', 1, 2, 10.00),
('33442', '22101', 1, 2, 10.00)
GO
/****** Trigger Creation  ******/
IF OBJECT_ID ('JD.Warehouse_INSERT_UPDATE') IS NOT NULL
	DROP TRIGGER JD.Warehouse_INSERT_UPDATE
GO

CREATE TRIGGER JD.Warehouse_INSERT_UPDATE
	ON JD.Warehouse
	AFTER INSERT, UPDATE
AS
	UPDATE JD.Warehouse
	SET State = UPPER(State)
	WHERE WarehouseID IN (SELECT WarehouseID FROM Inserted);
GO	

IF OBJECT_ID ('JD.Supplier_INSERT_UPDATE') IS NOT NULL
	DROP TRIGGER JD.Supplier_INSERT_UPDATE
GO

CREATE TRIGGER JD.Supplier_INSERT_UPDATE
	ON JD.Suppliers
	AFTER INSERT, UPDATE
AS
	UPDATE JD.Suppliers
	SET State = UPPER(State)
	WHERE SupplierID IN (SELECT SupplierID FROM Inserted);
GO

IF OBJECT_ID ('JD.CustomerBillingAddress_INSERT_UPDATE') IS NOT NULL
	DROP TRIGGER JD.CustomerBillingAddress_INSERT_UPDATE
GO

CREATE TRIGGER JD.CustomerBillingAddress_INSERT_UPDATE
	ON JD.CustomerBillingAddress
	AFTER INSERT, UPDATE
AS
	UPDATE JD.CustomerBillingAddress
	SET State = UPPER(State)
	WHERE BillAddressID IN (SELECT BillAddressID FROM Inserted);
GO

IF OBJECT_ID ('JD.CustomerShippingAddress_INSERT_UPDATE') IS NOT NULL
	DROP TRIGGER JD.CustomerShippingAddress_INSERT_UPDATE
GO

CREATE TRIGGER JD.CustomerShippingAddress_INSERT_UPDATE
	ON JD.CustomerShippingAddress
	AFTER INSERT, UPDATE
AS
	UPDATE JD.CustomerShippingAddress
	SET State = UPPER(State)
	WHERE ShipAddressID IN (SELECT ShipAddressID FROM Inserted);
GO

IF OBJECT_ID ('JD.Orders_INSERT') IS NOT NULL
	DROP TRIGGER JD.Orders_INSERT
GO

CREATE TRIGGER JD.Orders_INSERT
	ON JD.Orders
	AFTER INSERT
AS
	BEGIN
	   IF EXISTS
	     (SELECT *
		  FROM JD.Orders JOIN
				(SELECT JD.OrderItems.OrderID, SUM(Quantity*ItemPrice) AS SumOfOrder
				FROM JD.OrderItems
				GROUP BY JD.OrderItems.OrderID) AS OrderTotal
			ON JD.Orders.OrderID = OrderTotal.OrderID
		  WHERE (Orders.TotalAmount <> OrderTotal.OrderID))
		  BEGIN
			;
			THROW 50001, 'Order Totals differ in OrderItems and Orders table', 1;
		    ROLLBACK TRAN;
		  END;
	END;

/****** Security Section  ******/
CREATE LOGIN JohnDamaro WITH PASSWORD = 'Cuse#2020',
	DEFAULT_DATABASE = Competitor,
	CHECK_EXPIRATION = ON;

CREATE LOGIN LibbyKretzing WITH PASSWORD = 'Junior#2021',
	DEFAULT_DATABASE = Competitor,
	CHECK_EXPIRATION = ON;

CREATE LOGIN DanKenney WITH PASSWORD = 'Mass#TB12',
	DEFAULT_DATABASE = Competitor,
	CHECK_EXPIRATION = ON;

CREATE LOGIN BenJeffries WITH PASSWORD = 'Marine@$$',
	DEFAULT_DATABASE = Competitor,
	CHECK_EXPIRATION = ON;

IF USER_ID ('JohnDamaro') IS NOT NULL
	DROP USER JohnDamaro

CREATE USER JohnDamaro FOR LOGIN JohnDamaro
	WITH DEFAULT_SCHEMA = JD;

IF USER_ID ('LibbyKretzing') IS NOT NULL
	DROP USER LibbyKretzing

CREATE USER LibbyKretzing FOR LOGIN LibbyKretzing
	WITH DEFAULT_SCHEMA = JD;

IF USER_ID ('DanKenney') IS NOT NULL
	DROP USER DanKenney

CREATE USER DanKenney FOR LOGIN DanKenney
	WITH DEFAULT_SCHEMA = JD;

IF USER_ID ('BenJeffries') IS NOT NULL
	DROP USER BenJeffries

CREATE USER BenJeffries FOR LOGIN BenJeffries
	WITH DEFAULT_SCHEMA = JD;