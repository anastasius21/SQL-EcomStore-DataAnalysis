-- List all customers and their total number of orders.
SELECT c.customer_name, c.customer_id, COUNT(o.order_id)
FROM cust c LEFT JOIN orders o on c.customer_id = o.customer_id
GROUP BY c.customer_id;


-- Which product has been ordered the most by quantity?

SELECT product_category, COUNT(product_category) as SalesProd FROM orders GROUP BY product_category ORDER BY SalesProd DESC ;

-- Find the total revenue generated from each product category.

SELECT product_category, SUM(order_amount)
FROM orders GROUP BY product_category;

-- List customers who signed up in 2023.

SELECT customer_id, customer_name, city, signup_date FROM cust 
WHERE signup_date LIKE '%2023%';

-- What is the average order value (AOV) per customer?
SELECT AVG(ord) FROM( SELECT o.customer_id, AVG(order_amount) as ord FROM orders o GROUP BY o.customer_id);


-- List the top 5 customers who spent the most.
-- (Join customers and orders. Use SUM(quantity × price).)

SELECT c.customer_name, o.customer_id, SUM(o.order_amount) AS ord 
FROM orders o INNER JOIN cust c WHERE o.customer_id  = c.customer_id  GROUP BY o.customer_id ORDER BY ord DESC LIMIT 5;


-- List the names of customers who have never placed an order.

SELECT c.customer_name FROM cust c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE o.order_amount IS NULL;


-- For each city, what is the total revenue generated?

SELECT c.city as area , SUM(o.order_amount) as revenue 
FROM cust c INNER JOIN orders o ON c.customer_id = o.customer_id 
GROUP BY area ORDER BY revenue DESC;


-- Find all orders where the product belongs to a category that earned more than $5,000 in total revenue.


WITH high_revenue_categories AS
(
SELECT product_category, SUM(order_amount) as revenue
FROM orders
GROUP BY product_category
HAVING revenue > 5000
)
SELECT *
FROM orders o INNER JOIN cust c ON c.customer_id = o.customer_id
WHERE o.product_category IN (SELECT product_category FROM high_revenue_categories);






-- Get the most recent order (date and product) placed by each customer.



WITH latest_order AS
(
SELECT product_category, order_amount, customer_id, order_date,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER by order_date DESC) AS rn FROM orders
)
SELECT l.order_date, l.product_category, l.customer_id, l.order_amount, c.customer_name, c.city FROM latest_order l INNER JOIN cust c
ON l.customer_id = c.customer_id WHERE l.rn=1;





-- Assign a rank to each customer based on total amount spent (highest first).



SELECT c.customer_name , o.customer_id, COALESCE(SUM(o.order_amount),0) as total_amount,
RANK() OVER (ORDER BY COALESCE(SUM(o.order_amount),0) DESC) as ranking
FROM orders o INNER JOIN cust c ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name
ORDER BY total_amount DESC;


-- For each category, show the most and least expensive product sold.

SELECT * FROM cust;
SELECT * FROM orders;

WITH expense AS 
(
SELECT order_id, product_category, MAX(order_amount) as expensive
FROM orders GROUP BY product_category
),
cheapest AS
(
SELECT order_id, product_category, MIN(order_amount) 
as cheap FROM orders GROUP BY product_category
)
SELECT e.order_id as ex_id, e.product_category as ex_prod, e.expensive
as ex_amount c.order_id as ch_id, c.product_category 
as ch_prod, c.expensive as ch_amount FROM expense e FULL JOIN cheapest c;






-- For each customer, display their order history along with a running total of amount spent.


SELECT * FROM cust;
SELECT * FROM orders;


SELECT o.order_date ,c.customer_name ,o.customer_id,c.city,o.order_amount, SUM(o.order_amount) 
OVER (PARTITION BY o.customer_id ORDER BY o.order_date) as total FROM orders o
INNER JOIN cust c ON o.customer_id = c.customer_id
ORDER BY o.customer_id, o.order_date;




-- Find the average number of orders per customer.



WITH orders_count AS 
(
SELECT COUNT(customer_id) as abc
FROM orders GROUP BY customer_id
),
customers_count AS
(
SELECT DISTINCT customer_id as xyz FROM orders
)
SELECT COUNT(xyz) FROM customers_count;


SELECT 1.0 * COUNT(*)/COUNT(DISTINCT customer_id) FROM orders;
-- OR
SELECT CAST(COUNT(*) AS REAL )/ COUNT(DISTINCT customer_id) FROM orders; 



-- What is the total revenue generated per month?


SELECT STRFTIME('%Y-%m', order_date) as year_month, SUM(order_amount) FROM orders
GROUP BY year_month ORDER BY year_month;



-- Group customers into segments based on revenue:
-- Less than $500 → 'Low'
-- $500–$1000 → 'Medium'
-- $1000+ → 'High'


SELECT * FROM cust;
SELECT * FROM orders;

SELECT customer_id, SUM(order_amount) as revenue,
CASE WHEN SUM(order_amount) < 500 THEN 'LOW'
WHEN SUM(order_amount) BETWEEN 500 AND 1000 THEN 'MEDIUM'
WHEN SUM(order_amount) > 1000 THEN 'HIGH' END AS segments
FROM orders GROUP BY customer_id ORDER BY revenue desc;




-- 🧠 Advanced / Case / Analysis


-- Create a new column order_size that classifies each order as:
-- Small (quantity ≤ 2)
-- Medium (3–5)
-- Large (>5)



-- Find repeat customers (customers who ordered more than once).


SELECT * FROM cust;
SELECT * FROM orders;


SELECT c.customer_name, o.customer_id,c.city , COUNT(o.customer_id) as Repeat_Orders FROM orders o INNER JOIN
cust c ON o.customer_id = c.customer_id GROUP BY o.customer_id HAVING Repeat_Orders > 1 ORDER BY Repeat_Orders DESC;





-- Find the month with the highest sales.


SELECT * FROM cust;
SELECT * FROM orders;


SELECT DISTINCT STRFTIME('%Y-%m', order_date) as month, SUM(order_amount) as sales
FROM orders GROUP BY month ORDER BY sales DESC;



-- What % of total revenue comes from the top 10% of customers by spending?


WITH spending AS
(
SELECT customer_id, SUM(order_amount) as spent,
NTILE(10) OVER (ORDER BY SUM(order_amount) DESC) as spent_per
FROM orders GROUP BY customer_id
),
revenue AS
(
SELECT SUM(order_amount) as total FROM orders
)
SELECT SUM((s.spent/r.total)) * 100 FROM spending s, revenue r WHERE spent_per =1 ;



