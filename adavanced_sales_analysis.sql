-- PROJECT 3: ADVANCED SALES DATA ANALYSIS
-- MySQL

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS order_line;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO customers VALUES
(1,'Aarav Sharma','Jaipur','2026-01-10'),
(2,'Priya Verma','Delhi','2026-01-15'),
(3,'Rohan Mehta','Mumbai','2026-02-02'),
(4,'Ananya Singh','Jaipur','2026-02-18'),
(5,'Kabir Khan','Pune','2026-03-05'),
(6,'Meera Joshi','Delhi','2026-03-20');

INSERT INTO products VALUES
(101,'Laptop','Electronics',50000),
(102,'Phone','Electronics',30000),
(103,'Mouse','Accessories',500),
(104,'Keyboard','Accessories',1200),
(105,'Office Chair','Furniture',6000),
(106,'Office Desk','Furniture',15000);

INSERT INTO orders VALUES
(1001,1,'2026-04-02','Completed'),
(1002,2,'2026-04-05','Completed'),
(1003,3,'2026-04-10','Completed'),
(1004,1,'2026-05-03','Completed'),
(1005,4,'2026-05-08','Completed'),
(1006,5,'2026-05-12','Cancelled'),
(1007,6,'2026-05-18','Completed'),
(1008,2,'2026-06-02','Completed'),
(1009,3,'2026-06-10','Completed'),
(1010,4,'2026-06-15','Completed'),
(1011,5,'2026-06-20','Completed'),
(1012,1,'2026-06-25','Completed');

INSERT INTO order_items VALUES
(1,1001,101,1),
(2,1001,103,2),
(3,1002,102,1),
(4,1002,104,2),
(5,1003,105,2),
(6,1003,103,1),
(7,1004,102,1),
(8,1004,104,1),
(9,1005,106,1),
(10,1005,105,2),
(11,1006,101,1),
(12,1007,103,5),
(13,1007,104,2),
(14,1008,101,1),
(15,1008,105,1),
(16,1009,102,2),
(17,1009,106,1),
(18,1010,104,3),
(19,1010,103,4),
(20,1011,105,1),
(21,1011,106,1),
(22,1012,101,1),
(23,1012,102,1);
SELECT
    SUM(oi.quantity * p.unit_price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'Completed';
-- Revenue by product category
SELECT
    p.category,
    SUM(oi.quantity * p.unit_price) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY revenue DESC;
-- Monthly revenue analysis
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    SUM(oi.quantity * p.unit_price) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;
-- Customer-wise revenue analysis
SELECT
    c.customer_name,
    c.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * p.unit_price) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY total_revenue DESC;
-- Top-selling products
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * p.unit_price) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY units_sold DESC;
-- Monthly revenue ranking using CTE and window function
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
        SUM(oi.quantity * p.unit_price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    sales_month,
    monthly_revenue,
    RANK() OVER (ORDER BY monthly_revenue DESC) AS revenue_rank
FROM monthly_sales
ORDER BY revenue_rank;
-- Order status analysis
SELECT
    status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY status
ORDER BY total_orders DESC;