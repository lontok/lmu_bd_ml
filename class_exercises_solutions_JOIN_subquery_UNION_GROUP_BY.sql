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

############
# UNION
############

# Build a single mailing list that consists of the name, address, city, state, and ZIP Code for customers, employees, and vendors
#you must add a WHERE clause to each of the embedded SELECT statements
# Using a relative column number to specify the sort b/c column names may not be the same
SELECT CONCAT(customers.CustFirstName, ' ', customers.CustLastName) AS customer_full_name, customers.CustStreetAddress, customers.CustCity, customers.CustState, customers.CustZipCode, 'customer' AS row_id
FROM mysql.sales_orders.customers
WHERE customers.CustState = 'TX'
UNION
SELECT CONCAT(employees.EmpFirstName, ' ', Employees.EmpLastName) AS employee_full_name, employees.EmpStreetAddress, employees.EmpCity, employees.EmpState, employees.EmpZipCode, 'employee' AS row_id
FROM mysql.sales_orders.employees
WHERE employees.EmpState = 'TX'
UNION
SELECT vendors.VendName, vendors.VendStreetAddress, vendors.VendCity, vendors.VendState, vendors.VendZipCode, 'vendor' AS row_id
FROM mysql.sales_orders.vendors
WHERE vendors.VendState = 'TX'
ORDER BY 4;

# List the customers who ordered a helmet together with the vendors who provide helmets
# LIKE is case sensitive in Presto
SELECT CONCAT(customers.CustFirstName, ' ', customers.CustLastName) AS customer_full_name, products.ProductName, 'customer' AS row_id
FROM mysql.sales_orders.customers
JOIN mysql.sales_orders.orders
  ON customers.CustomerID = orders.CustomerID
JOIN mysql.sales_orders.order_details
  ON orders.OrderNumber = order_details.OrderNumber
JOIN mysql.sales_orders.products
  ON products.ProductNumber = order_details.ProductNumber
WHERE products.ProductName LIKE '%Helmet%'
UNION
SELECT vendors.VendName, products.ProductName, 'vendor' AS row_id
FROM mysql.sales_orders.vendors
JOIN mysql.sales_orders.product_vendors
  ON vendors.VendorID = product_vendors.VendorID
JOIN mysql.sales_orders.products
  ON products.ProductNumber = product_vendors.ProductNumber
WHERE products.ProductName LIKE '%Helmet%';



############
# GROUP BY
############

# Show me each vendor and the average by vendor of the number of days to deliver products

SELECT vendors.VendName, AVG(product_vendors.DaysToDeliver) AS avg_days_to_deliver
FROM mysql.sales_orders.vendors
JOIN mysql.sales_orders.product_vendors
  ON vendors.VendorID = product_vendors.VendorID
GROUP BY vendors.VendName;

# Display for each product the product name and the total sales sorted by the product name
SELECT products.ProductName, SUM(order_details.QuotedPrice * order_details.QuantityOrdered) AS total_sales
FROM mysql.sales_orders.products
JOIN mysql.sales_orders.order_details
  ON products.ProductNumber = order_details.ProductNumber
GROUP BY products.ProductName;

# List all vendors and the number of products sold by each. Sort the results by the count of products sold in descending order.
SELECT vendors.VendName, COUNT(product_vendors.ProductNumber) AS product_count
FROM mysql.sales_orders.vendors
JOIN mysql.sales_orders.product_vendors
  ON vendors.VendorID = product_vendors.VendorID
GROUP BY vendors.VendName
ORDER BY product_count DESC;


############
# GROUP BY HAVING
############

# Show me each vendor and the average by vendor of the number of days to deliver products that are greater than the average delivery days for all vendors
# run for having filter > 5 w/o subquery
# test subquery first
SELECT Vendors.VendName, AVG(Product_Vendors.DaysToDeliver) AS avg_delivery
FROM mysql.sales_orders.vendors
JOIN mysql.sales_orders.product_vendors
  ON vendors.VendorID = product_vendors.VendorID
GROUP BY vendors.VendName
HAVING AVG(product_vendors.DaysToDeliver) > (SELECT AVG(DaysToDeliver) FROM mysql.sales_orders.product_vendors);

# How many orders are for only one product?
# run subquery first and include COUNT(*) in the SELECT
SELECT COUNT(*) AS single_item_order_count
FROM (SELECT order_details.OrderNumber
      FROM mysql.sales_orders.Order_Details
      GROUP BY order_details.OrderNumber
      HAVING COUNT(*) = 1) single_item_orders;

# Display for each product the product name and the total sales that is greater than the average of sales for all products in that category
# Hint: To calculate the comparison value, you must first SUM the sales for each product within a category and then AVG those sums by category
-- SELECT products.ProductName, SUM(order_details.QuotedPrice * order_details.QuantityOrdered) AS total_sales
-- FROM mysql.sales_orders.products
-- JOIN mysql.sales_orders.order_details
--   ON products.ProductNumber = order_details.ProductNumber
-- GROUP BY products.CategoryID, products.ProductName
-- HAVING (SUM(order_details.QuotedPrice * order_details.QuantityOrdered) >
--   ( SELECT AVG(category_sum)
--     FROM
--     ( SELECT p2.CategoryID, SUM(od2.QuotedPrice * od2.QuantityOrdered) AS category_sum
--      FROM mysql.sales_orders.products AS p2
--      JOIN mysql.sales_orders.order_details AS od2
--        ON p2.ProductNumber = od2.ProductNumber
--      GROUP BY p2.CategoryID, p2.ProductNumber
--    ) AS cs
--      WHERE cs.CategoryID = products.CategoryID
--      GROUP BY CategoryID
--    )
--  );
