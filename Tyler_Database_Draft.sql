-- Restaurant Menu and Order Management System

-- creates the database
CREATE DATABASE restaurant_db;

-- selects the database
USE restaurant_db;

-- creates the Employees table
CREATE TABLE Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Position VARCHAR(50) NOT NULL
);

-- creates the Customers table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL
);

-- creates the MenuItems table
CREATE TABLE MenuItems (
    MenuItemID INT AUTO_INCREMENT PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    Price DECIMAL(8,2) NOT NULL,
    Category VARCHAR(50) NOT NULL
);

-- creates the Orders table to track dine in and online orders
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NULL,
    EmployeeID INT NULL,
    OrderDate DATETIME NOT NULL,
    OrderType VARCHAR(20) NOT NULL,
    FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID),
    CONSTRAINT chk_order_type_association
    CHECK (
        (OrderType = 'Dine-In' AND EmployeeID IS NOT NULL)
        OR
        (OrderType = 'Online' AND CustomerID IS NOT NULL)
    )
);

-- Create the OrderItems table to store individual items in each order
CREATE TABLE OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    MenuItemID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(8,2) NOT NULL,

    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    FOREIGN KEY (MenuItemID)
        REFERENCES MenuItems(MenuItemID)
);

-- adds constraints to make sure values are not negative
ALTER TABLE OrderItems
ADD CONSTRAINT chk_positive_quantity
CHECK (Quantity > 0),
ADD CONSTRAINT chk_nonnegative_unit_price
CHECK (UnitPrice >= 0);

-- Prevents negative prices on menu
ALTER TABLE MenuItems
ADD CONSTRAINT chk_nonnegative_menu_price
CHECK (Price >= 0);

-- inserts sample restaurant employees
INSERT INTO Employees (FirstName, LastName, Position)
VALUES
('James', 'Wilson', 'Server'),
('Sarah', 'Johnson', 'Server'),
('Michael', 'Brown', 'Manager'),
('Emily', 'Davis', 'Host'),
('David', 'Martinez', 'Server');

-- inserts sample registered customers
INSERT INTO Customers (FirstName, LastName, Email)
VALUES
('John', 'Smith', 'john.smith@example.com'),
('Jessica', 'Taylor', 'jessica.taylor@example.com'),
('Robert', 'Anderson', 'robert.anderson@example.com'),
('Amanda', 'White', 'amanda.white@example.com'),
('Daniel', 'Thomas', 'daniel.thomas@example.com');

-- inserts sampe menu items
INSERT INTO MenuItems (ItemName, Price, Category)
VALUES
('Ultimate Feast', 39.99, 'Entree'),
('Shrimp Alfredo', 21.99, 'Entree'),
('Caesar Salad', 8.99, 'Appetizer'),
('Cheddar Bay Biscuits', 5.99, 'Side'),
('Soft Drink', 3.49, 'Beverage');

-- Inserts sample dine in and online orders
INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, OrderType)
VALUES
(NULL, 1, '2026-11-15 12:30:00', 'Dine-In'),
(2, NULL, '2026-11-15 13:15:00', 'Online'),
(NULL, 2, '2026-11-16 18:45:00', 'Dine-In'),
(4, 5, '2026-11-16 19:20:00', 'Online'),
(1, 1, '2026-11-17 17:00:00', 'Dine-In');

--inserts sample items purchased in orders
INSERT INTO OrderItems (OrderID, MenuItemID, Quantity, UnitPrice)
VALUES
(1, 1, 2, 39.99),
(1, 5, 2, 3.49),
(2, 2, 1, 21.99),
(2, 4, 1, 5.99),
(3, 1, 1, 39.99),
(4, 3, 2, 8.99),
(4, 5, 2, 3.49),
(5, 2, 2, 21.99);

-- display orders with the employees who had them
SELECT
    Orders.OrderID,
    Orders.OrderDate,
    Orders.OrderType,
    Employees.FirstName,
    Employees.LastName
FROM Orders
LEFT JOIN Employees
    ON Orders.EmployeeID = Employees.EmployeeID;

-- displays menu items sorted from highest to lowest price
SELECT
    ItemName,
    Category,
    Price
FROM MenuItems
ORDER BY Price DESC;

-- display only orders placed online
SELECT
    OrderID,
    CustomerID,
    EmployeeID,
    OrderDate
FROM Orders
WHERE OrderType = 'Online';

-- stored procedure to add a new registered customer
DELIMITER //
CREATE PROCEDURE AddCustomer(
    IN p_FirstName VARCHAR(50),
    IN p_LastName VARCHAR(50),
    IN p_Email VARCHAR(100)
)
BEGIN
    INSERT INTO Customers (FirstName, LastName, Email)
    VALUES (p_FirstName, p_LastName, p_Email);
END //

DELIMITER ;

-- tests the stored procedure by adding a customer
CALL AddCustomer(
    'Rebecca',
    'Miller',
    'rebecca.miller@example.com'
);

SELECT * FROM Customers;

-- stored function that calculate the total price of an order
DELIMITER //

CREATE FUNCTION GetOrderTotal(p_OrderID INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE order_total DECIMAL(10,2);
    SELECT COALESCE(SUM(Quantity * UnitPrice), 0)
    INTO order_total
FROM OrderItems
    WHERE OrderID = p_OrderID;
    RETURN order_total;
END //

DELIMITER ;

-- tests the order total function
SELECT GetOrderTotal(1) AS OrderTotal;