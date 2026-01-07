--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- DATABASE EXPLORATION
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- explore all objects in the database

SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explore all columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- DIMENSION EXPLORATION
-- IDENTIFYING HOW DATA MAY BE GROUPED OR SEGMENTED WHICH IS USEFUL FOR LATER ANALYSIS 
-- Identifying the unique values (or categories) in each dimension
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

-- explore all countries our customres come from

SELECT DISTINCT country FROM gold.dim_customers

-- explore all categories 'the major divisions'

SELECT DISTINCT category FROM gold.dim_products

SELECT DISTINCT category,subcategory,product_name FROM gold.dim_products
ORDER BY 1 DESC,2,3 

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- DATE EXPLORATION
-- Identify the earliest and latest dates (boundaries)
--Understand the scope of data and the timespan
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- find the date of the first and last order

SELECT 
	MAX(order_date) AS last_order,
	MIN(order_date) AS first_order,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS order_range_months
FROM gold.fact_sales

-- Find Youngest and oldest customer
SELECT MAX(birthdate) AS youngest,
	   MIN(birthdate) AS oldest,
	   DATEDIFF(YEAR,MIN(birthdate),MAX(birthdate)) AS age_diff,
	   DATEDIFF(YEAR,MIN(birthdate),GETDATE()) AS oldest_age,
	   DATEDIFF(YEAR,MAX(birthdate),GETDATE()) AS youngest_age
FROM gold.dim_customers


--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--Measure Exploration
--Calculate the key metric of the business (Big Numbers)
--Highest level of aggregation | Lowest level of details
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- find the total sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales

-- find how many items are sold 
SELECT SUM(quantity) AS total_sales FROM gold.fact_sales

-- find the average selling price 
SELECT AVG(price) AS avg_price FROM gold.fact_sales

-- find the total number of orders
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales

-- find the total number of products
SELECT COUNT(DISTINCT product_key) AS total_products FROM gold.fact_sales

-- find the total number of customers
SELECT COUNT( customer_key) AS total_customers FROM gold.dim_customers

-- find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.dim_customers

--==============================================================================================
--Generating a report that shows all key metrics of the buisness
--==============================================================================================
SELECT 'TOTAL SALES' AS measure_name, SUM(sales_amount) AS Measure_Value FROM gold.fact_sales
UNION ALL
SELECT 'TOTAL QUANTITY', SUM(quantity) FROM gold.fact_sales
UNION ALL 
SELECT 'AVERAGE PRICE', AVG(price) FROM gold.fact_sales
UNION ALL 
SELECT'TOTAL NO ORDERS',COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales
UNION ALL 
SELECT 'TOTAL NO PRODUCTS',COUNT(DISTINCT product_key) AS total_products FROM gold.fact_sales
UNION ALL 
SELECT 'TOTAL NO CUSTOMERS',COUNT( customer_key) AS total_customers FROM gold.dim_customers

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- Find total customers by countries
SELECT 
	country,
	COUNT(customer_key)
FROM gold.dim_customers
GROUP BY country
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- Find total customers by gender
SELECT 
	gender,
	COUNT(customer_key)
FROM gold.dim_customers
GROUP BY gender
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- Find total products by category
SELECT 
	category,
	COUNT(product_key)
FROM gold.dim_products
GROUP BY category
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- What is the average costs in each category?
SELECT 
	category,
	AVG(cost)
FROM gold.dim_products
GROUP BY category
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- What is the total revenue generated for each category?
SELECT 
	p.category,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.category
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- Find total revenue is generated by each customer
SELECT 
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY c.customer_key,c.first_name,c.last_name
ORDER BY total_revenue DESC
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- What is the distribution of sold items across countries?
SELECT 
	c.country,
	SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


--==================================================================================================
--Which 5 products generate the highest ewvenue

SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- USING WINDOW FUNCTION
SELECT * FROM(
	SELECT 
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON p.product_key = f.product_key
	GROUP BY p.product_name) AS t
WHERE rank_products <= 5
--=================================================================================================
--top 5 WORST PERFORMING PRODUCTS IN TERMS OF SALES
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue 
--=============================================================================================================
-- find the top 10 customers who have generated the highest revenue and 3 customers with fewest orders placed
SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales as f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC
--==============================================================================================================
--top 3 CUATOMERS WITH FEWEST ORDERS PLACED
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales as f
LEFT JOIN gold.dim_customers AS c
ON c.customer_key = f.customer_key
GROUP BY 
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_orders

select * from gold.dim_customers
select * from gold.dim_products
select * from gold.fact_sales