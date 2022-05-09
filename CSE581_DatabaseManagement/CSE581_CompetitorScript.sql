/*
John D'Amaro
12/7/19
CSE 581 - Project 2
*/

USE Competitor
GO

/****** Business Reports  ******/

IF OBJECT_ID('JD.TotalExpenditureReport') IS NOT NULL
	DROP VIEW JD.TotalExpenditureReport;
GO

CREATE VIEW JD.TotalExpenditureReport AS
	SELECT JD.Customers.CustomerID, 
		   SUM(TotalAmount + ShipAmount) TotalExpenditure, 
		   SUM(Quantity) AS NumberofProducts
	FROM JD.Customers 
	    JOIN JD.Orders ON JD.Customers.CustomerID = JD.Orders.CustomerID
		JOIN JD.OrderItems ON JD.Orders.OrderID = JD.OrderItems.OrderID
	GROUP BY (JD.Customers.CustomerID)
GO

SELECT * FROM JD.TotalExpenditureReport
GO

IF OBJECT_ID('JD.ProductReviews') IS NOT NULL
	DROP VIEW JD.ProductReviews;
GO

CREATE VIEW JD.ProductReviews AS
	SELECT JD.Suppliers.Name, ProductCode, Score, ISNULL(Text, 'Review not added') AS Description
	FROM JD.Suppliers
	    JOIN JD.Products ON JD.Suppliers.SupplierID = JD.Products.SupplierID
		JOIN JD.Reviews ON JD.Products.ProductID = JD.Reviews.ProductID
GO

SELECT * FROM JD.ProductReviews
GO

IF OBJECT_ID('JD.OrdersPerRegion') IS NOT NULL
	DROP VIEW JD.OrdersPerRegion;
GO

CREATE VIEW JD.OrdersPerRegion AS
	SELECT LEFT(ZipCode,1) + 'XXXX' AS ZIPCodeRegion, SUM(Quantity) QuantityOfProducts
	FROM JD.OrderItems
	    JOIN JD.Orders ON JD.OrderItems.OrderID = JD.Orders.OrderID
		JOIN JD.Customers ON JD.Orders.CustomerID = JD.Customers.CustomerID
		JOIN JD.CustomerShippingAddress ON JD.Customers.CustomerID = JD.CustomerShippingAddress.CustomerID
	GROUP BY LEFT(ZipCode,1) + 'XXXX'
GO

SELECT * FROM JD.OrdersPerRegion
GO

IF OBJECT_ID('JD.InventoryReport') IS NOT NULL
	DROP VIEW JD.InventoryReport;
GO

CREATE VIEW JD.InventoryReport AS
	SELECT JD.Storage.ProductName, Name AS CompanyName, ProductInStock, 
		   JD.Warehouse.City + ', ' + JD.Warehouse.State + ' ' + JD.Warehouse.ZipCode AS WarehouseLocation
	FROM JD.Suppliers
	    JOIN JD.Products ON JD.Suppliers.SupplierID = JD.Products.SupplierID
		JOIN JD.Storage ON JD.Products.ProductID = JD.Storage.ProductID
		JOIN JD.Warehouse ON JD.Storage.WarehouseID = JD.Warehouse.WarehouseID
GO

SELECT * FROM JD.InventoryReport
GO

/****** Performance & Efficiency  ******/

IF OBJECT_ID('JD.spNewCustomer') IS NOT NULL
	DROP PROC JD.spNewCustomer;
GO

CREATE PROC JD.spNewCustomer
	@FirstName VARCHAR(60) = NULL, @LastName VARCHAR(60) = NULL, 
	@UserName VARCHAR(60) = NULL, @EmailAddress VARCHAR(255) = NULL
AS
	IF @FirstName IS NULL
		THROW 50001, 'Must include First Name', 1;
	IF @LastName IS NULL
		THROW 50001, 'Must include Last Name', 1;
	IF @UserName IS NULL
		THROW 50001, 'Must include User Name', 1;
	IF @EmailAddress IS NULL
		THROW 50001, 'Must include Email Address', 1;

INSERT JD.Customers
VALUES (@FirstName, @LastName, @UserName, @EmailAddress);
RETURN @@IDENTITY;

BEGIN TRY
	DECLARE @CustomerID INT
	EXEC @CustomerID = JD.spNewCustomer
		 @FirstName = 'Libby',
		 @LastName = 'Kretzing',
		 @UserName = 'LKretzing',
		 @EmailAddress = 'LKretzing@gmail.com';
	PRINT 'New Customer Added';
	PRINT 'New Customer: ' + @FirstName + ' ' + @LastName;
END TRY
BEGIN CATCH
	PRINT 'New Customer information entered incorrectly';
END CATCH
GO

IF OBJECT_ID('JD.spNewReview') IS NOT NULL
	DROP PROC JD.spNewReview;
GO

CREATE PROC JD.spNewReview
	@CustomerID INT, @ProductID INT, @OrderID INT,
	@ReviewDate SMALLDATETIME, @Score INT, @Text TEXT
AS

IF      EXISTS(SELECT * FROM JD.Customers WHERE CustomerID = @CustomerID)
    AND EXISTS(SELECT * FROM JD.Products WHERE ProductID = @ProductID)
    AND EXISTS(SELECT * FROM JD.Orders WHERE OrderID = @OrderID)
	INSERT JD.Reviews
	VALUES(@CustomerID, @ProductID, @OrderID, @ReviewDate, @Score, @Text)
ELSE
	THROW 50001, 'Incorrect review information',1; 

BEGIN TRY
	EXEC spNewReview 
		1, 17, 7, '2019-12-7', 5, 'Best computer Ive ever owned';
END TRY
BEGIN CATCH
	IF ERROR_MESSAGE() > 50001
		PRINT CONVERT(varchar,ERROR_MESSAGE());
END CATCH
GO

SELECT * FROM JD.Reviews

/****** Transactions  ******/

/****** New Order  ******/
DECLARE @OrderID int
DECLARE @OrderItemID int

BEGIN TRY
	BEGIN TRAN;
	SET @OrderID = @@IDENTITY
	INSERT JD.Orders(OrderID, CustomerID, StatusID, OrderDate, TotalAmount, 
					 ShipViaID, ShipAddressID, ShipAmount, ExpectShipDate, ShipDate, BillAddressID)
		VALUES(@OrderID, 7, 1, '2019-12-7', 35.00, 1, 9, 10.00, '2019-12-18', NULL, 8);
	SET @OrderItemID = @@IDENTITY
	INSERT JD.OrderItems
		VALUES(@OrderItemID, @OrderID, 12, 35.00, 1);
	COMMIT TRAN;
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH

/****** Shipping Cost  ******/
DECLARE @ShipZip int
DECLARE @WarehouseZip int
DECLARE @DistanceID int
DECLARE @DaysToShip int
DECLARE @CostOfDistance money
DECLARE @CostOfService money


BEGIN TRY
	BEGIN TRAN
	SET @ShipZip = (SELECT ZIPCode FROM JD.CustomerShippingAddress WHERE CustomerID = 1)
	SET @WarehouseZip = (SELECT ZIPCode FROM JD.Warehouse WHERE WarehouseID = 5)
		IF ABS(CONVERT(int,(LEFT(@ShipZip,1)) - CONVERT(int,LEFT(@WarehouseZip,1)))) = 0
			SET @DistanceID = 1;
		ELSE
			IF ABS(CONVERT(int,(LEFT(@ShipZip,1)) - CONVERT(int,LEFT(@WarehouseZip,1)))) = 1
				SET @DistanceID = 2;
			ELSE
				IF ABS(CONVERT(int,(LEFT(@ShipZip,1)) - CONVERT(int,LEFT(@WarehouseZip,1)))) = 2
					SET @DistanceID = 3;
				ELSE
					IF ABS(CONVERT(int,(LEFT(@ShipZip,1)) - CONVERT(int,LEFT(@WarehouseZip,1)))) >= 3
						SET @DistanceID = 4;
	SET @DaysToShip =
	(SELECT DaysToShip
	FROM JD.Distance
	WHERE DistanceID = @DistanceID)

	SET @CostOfDistance =
	(SELECT CostOfDistance
	FROM JD.Distance
	WHERE DistanceID = @DistanceID)

	SET @CostOfService =
	(SELECT CostOfService
	FROM JD.ShippingService
	WHERE ShipViaID = 2)

	INSERT JD.ShippingFare
		VALUES(2, @DistanceID, @ShipZip, @WarehouseZip, @CostOfDistance+@CostOfService)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH
