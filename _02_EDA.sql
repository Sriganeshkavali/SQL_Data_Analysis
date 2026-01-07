
SELECT 
	YEAR(order_date) as order_year,
	MONTH(order_date) as order_month,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date)

SELECT 
	DATETRUNC(month,order_date) as order_year,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(month,order_date)
ORDER BY DATETRUNC(month,order_date)

SELECT 
	FORMAT(order_date,'yyy-MMM') as order_year,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY FORMAT(order_date,'yyy-MMM') 
ORDER BY FORMAT(order_date,'yyy-MMM') 

-- How many customers were added each year
SELECT 
	DATETRUNC(year,create_date) AS create_year,
	COUNT(customer_key) AS total_customer
FROM gold.dim_customers
GROUP BY DATETRUNC(year,create_date)
ORDER BY DATETRUNC(YEAR,create_date)
