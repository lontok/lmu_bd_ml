# List customers and the dates they placed an order, sorted in order date sequence
SELECT customers.CustFirstName, customers.CustLastName, orders.OrderDate
FROM mysql.sales_orders.customers
JOIN mysql.sales_orders.orders
  ON customers.CustomerID = orders.CustomerID
ORDER BY orders.OrderDate;

# Show me customers and employees who have the same last name
SELECT customers.CustFirstName, customers.CustLastName, employees.EmpFirstName, employees.EmpLastName
FROM mysql.sales_orders.customers
JOIN mysql.sales_orders.employees
  ON customers.CustLastName = employees.EmpLastName;

# Show me customers and employees who live in the same city
SELECT customers.CustFirstName, customers.CustLastName, employees.EmpFirstName, employees.EmpLastName, employees.EmpCity
FROM mysql.sales_orders.customers
JOIN mysql.sales_orders.employees
ON customers.CustCity = employees.EmpCity;

# List employees and the customers for whom they booked an order
SELECT employees.EmpFirstName, employees.EmpLastName, customers.CustFirstName, customers.CustLastName
FROM mysql.sales_orders.employees
JOIN mysql.sales_orders.orders
  ON employees.EmployeeID = orders.EmployeeID
JOIN mysql.sales_orders.customers
  ON customers.CustomerID = Orders.CustomerID;

# Display all orders, the products in each order, and the amount owed for each product, in order number sequence
SELECT orders.OrderNumber,
  orders.OrderDate,
  order_details.ProductNumber,
  products.ProductName,
  order_details.QuotedPrice,
  order_details.QuantityOrdered,
  order_details.QuotedPrice * Order_Details.QuantityOrdered AS AmountOwed
FROM mysql.sales_orders.orders
JOIN mysql.sales_orders.order_details
  ON orders.OrderNumber = order_details.OrderNumber
JOIN mysql.sales_orders.products
  ON products.ProductNumber = order_details.ProductNumber
ORDER BY orders.OrderNumber;

# Show me the vendors and the products they supply to us for products that cost less than $100
SELECT vendors.VendName, products.ProductName, product_Vendors.WholesalePrice
FROM mysql.sales_orders.vendors
JOIN mysql.sales_orders.product_vendors
  ON vendors.VendorID = product_vendors.VendorID
JOIN mysql.sales_orders.products
  ON products.ProductNumber = product_vendors.ProductNumber
WHERE product_vendors.WholesalePrice < 100;

############
# LEFT JOINS
############

# Display customers who have a sales rep (employees) in the same ZIP Code
SELECT customers.CustomerID, customers.CustFirstName, customers.CustLastName, customers.CustZipCode, employees.EmpZipCode
FROM mysql.sales_orders.customers
JOIN mysql.sales_orders.employees
  ON customers.CustZipCode = employees.EmpZipCode;

# Display customers who do not have a sales rep (employees) in the same ZIP Code
SELECT customers.CustomerID, customers.CustFirstName, customers.CustLastName, customers.CustZipCode, employees.EmpZipCode
FROM mysql.sales_orders.customers
LEFT JOIN mysql.sales_orders.employees
  ON customers.CustZipCode = employees.EmpZipCode
WHERE employees.EmployeeID IS NULL;

# List all products and the dates for any orders
SELECT products.ProductNumber, products.ProductName, OD.OrderDate
FROM mysql.sales_orders.products
LEFT JOIN
  (SELECT DISTINCT order_details.ProductNumber, orders.OrderDate
  FROM mysql.sales_orders.orders
  JOIN mysql.sales_orders.order_details
    ON orders.OrderNumber = order_details.OrderNumber) OD
  ON Products.ProductNumber = OD.ProductNumber;

# Are there any products that have never been ordered?
SELECT products.ProductNumber, products.ProductName, OD.OrderDate
FROM mysql.sales_orders.products
LEFT JOIN
  (SELECT DISTINCT order_details.ProductNumber, orders.OrderDate
  FROM mysql.sales_orders.orders
  JOIN mysql.sales_orders.order_details
    ON orders.OrderNumber = order_details.OrderNumber) OD
  ON Products.ProductNumber = OD.ProductNumber
WHERE OD.OrderDate IS NULL;

# Show me customers who have never ordered a helmet
SELECT customers.CustomerID, customers.CustFirstName, customers.CustLastName
FROM mysql.sales_orders.customers
LEFT JOIN
  (SELECT orders.CustomerID, products.ProductName
  FROM mysql.sales_orders.orders
  JOIN mysql.sales_orders.order_details
    ON orders.OrderNumber = order_details.OrderNumber
  JOIN mysql.sales_orders.products
    ON order_details.ProductNumber = products.ProductNumber
  WHERE products.ProductName LIKE '%Helmet%') helmet_orders

  ON customers.CustomerID = helmet_orders.CustomerID

WHERE helmet_orders.CustomerID IS NULL;

############
# SUBQUERIES
############

# How many orders were booked by employees from Texas?
SELECT COUNT(*)
FROM mysql.sales_orders.orders
WHERE EmployeeID IN
  ( SELECT EmployeeID
    FROM mysql.sales_orders.employees
    WHERE EmpState = 'TX');

# How would you rewrite the SQL with a JOIN?
SELECT COUNT(*)
FROM mysql.sales_orders.orders
JOIN mysql.sales_orders.employees
  ON  orders.EmployeeID = employees.EmployeeID
WHERE EmpState = 'TX';

# What products have never been ordered?
SELECT products.ProductName
FROM mysql.sales_orders.products
WHERE products.ProductNumber NOT IN
  (SELECT order_details.ProductNumber FROM mysql.sales_orders.order_details);

# Display products and the latest date each product was ordered
SELECT products.ProductNumber, products.ProductName,
  ( SELECT MAX(orders.OrderDate)
    FROM mysql.sales_orders.orders
    JOIN mysql.sales_orders.order_details
      ON orders.OrderNumber = order_details.OrderNumber
    WHERE order_details.ProductNumber = products.ProductNumber) AS last_order
FROM mysql.sales_orders.products;

# Display products and the latest date each product was ordered only for products that have been ordered
SELECT products.ProductNumber, products.ProductName, MAX(orders.OrderDate)
FROM mysql.sales_orders.orders
JOIN mysql.sales_orders.order_details
  ON orders.OrderNumber = order_details.OrderNumber
JOIN mysql.sales_orders.products
  ON order_details.ProductNumber = products.ProductNumber
GROUP BY products.ProductNumber, products.ProductName;

# List customers who ordered bikes
SELECT customers.CustomerID, customers.CustFirstName, customers.CustLastName
FROM mysql.sales_orders.customers
WHERE customers.CustomerID IN
  ( SELECT orders.CustomerID
    FROM mysql.sales_orders.orders
    JOIN mysql.sales_orders.order_details
      ON orders.OrderNumber = order_details.OrderNumber
    JOIN mysql.sales_orders.products
      ON products.ProductNumber = order_details.ProductNumber
    JOIN mysql.sales_orders.categories
      ON categories.CategoryID = products.CategoryID
    WHERE categories.CategoryDescription = 'Bikes');
