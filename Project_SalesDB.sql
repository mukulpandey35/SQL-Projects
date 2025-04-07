-- Create Database
CREATE DATABASE IF NOT EXISTS SalesDB;
USE SalesDB;

-- Customers Table
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(50)
);

-- Products Table
CREATE TABLE IF NOT EXISTS Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL DEFAULT 0
);

-- Orders Table
CREATE TABLE IF NOT EXISTS Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- OrderDetails Table
CREATE TABLE IF NOT EXISTS OrderDetails (
    OrderDetailID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    ProductID INT,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Insert Customers
INSERT INTO Customers (FirstName, LastName, Email, Phone, City, Country) VALUES
('John', 'Doe', 'john.doe@example.com', '1234567890', 'New York', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '2345678901', 'Los Angeles', 'USA'),
('Bob', 'Brown', 'bob.brown@example.com', '3456789012', 'Chicago', 'USA');

-- Insert Products
INSERT INTO Products (ProductName, Category, Price, Stock) VALUES
('Laptop', 'Electronics', 999.99, 50),
('Phone', 'Electronics', 699.99, 100),
('Headphones', 'Accessories', 199.99, 200);

-- Insert Orders
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2025-04-01', 1699.97),
(2, '2025-04-02', 199.99);

-- Insert Order Details
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price) VALUES
(1, 1, 1, 999.99), -- John buys 1 Laptop
(1, 2, 1, 699.99), -- John buys 1 Phone
(2, 3, 1, 199.99); -- Jane buys 1 Headphones

-- Simple Queries
-- Get all customers
SELECT * FROM Customers;

-- List all products with stock < 100
SELECT * FROM Products
WHERE Stock < 100;

-- Find all orders with customer name
SELECT Orders.OrderID, Customers.FirstName, Customers.LastName, Orders.OrderDate, Orders.TotalAmount
FROM Orders
JOIN Customers ON Orders.CustomerID = Customers.CustomerID;

-- Show detailed order information
SELECT Orders.OrderID, Customers.FirstName, Products.ProductName, OrderDetails.Quantity, OrderDetails.Price
FROM OrderDetails
JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
JOIN Customers ON Orders.CustomerID = Customers.CustomerID
JOIN Products ON OrderDetails.ProductID = Products.ProductID;

-- Create View: Customer Orders Summary
CREATE OR REPLACE VIEW CustomerOrders AS
SELECT 
    Customers.FirstName, 
    Customers.LastName, 
    COUNT(Orders.OrderID) AS TotalOrders, 
    IFNULL(SUM(Orders.TotalAmount), 0) AS TotalSpent
FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY Customers.CustomerID;

-- Stored Procedure: Add New Product
DROP PROCEDURE IF EXISTS AddNewProduct;
DELIMITER //
CREATE PROCEDURE AddNewProduct (
    IN p_ProductName VARCHAR(100),
    IN p_Category VARCHAR(50),
    IN p_Price DECIMAL(10,2),
    IN p_Stock INT
)
BEGIN
    INSERT INTO Products (ProductName, Category, Price, Stock)
    VALUES (p_ProductName, p_Category, p_Price, p_Stock);
END //
DELIMITER ;

-- Call the procedure
CALL AddNewProduct('Tablet', 'Electronics', 499.99, 30);

-- Optional: Trigger to Decrease Stock when Order is Inserted
DROP TRIGGER IF EXISTS ReduceStockAfterOrder;
DELIMITER //
CREATE TRIGGER ReduceStockAfterOrder
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    UPDATE Products
    SET Stock = Stock - NEW.Quantity
    WHERE ProductID = NEW.ProductID;
END //
DELIMITER ;

-- Example Queries

-- 1. Get the total number of products in each category
SELECT Category, COUNT(*) AS TotalProducts
FROM Products
GROUP BY Category;

-- 2. Find the top 3 most expensive products
SELECT ProductName, Price
FROM Products
ORDER BY Price DESC
LIMIT 3;

-- 3. List all customers who have placed orders
SELECT DISTINCT Customers.FirstName, Customers.LastName
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

-- 4. Get the total revenue generated from each product
SELECT Products.ProductName, SUM(OrderDetails.Quantity * OrderDetails.Price) AS TotalRevenue
FROM OrderDetails
JOIN Products ON OrderDetails.ProductID = Products.ProductID
GROUP BY Products.ProductID;

-- 5. Find customers who have spent more than $1000
SELECT Customers.FirstName, Customers.LastName, SUM(Orders.TotalAmount) AS TotalSpent
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY Customers.CustomerID
HAVING TotalSpent > 1000;

-- 6. List all orders placed in the last 30 days
SELECT Orders.OrderID, Customers.FirstName, Customers.LastName, Orders.OrderDate, Orders.TotalAmount
FROM Orders
JOIN Customers ON Orders.CustomerID = Customers.CustomerID
WHERE Orders.OrderDate >= CURDATE() - INTERVAL 30 DAY;
