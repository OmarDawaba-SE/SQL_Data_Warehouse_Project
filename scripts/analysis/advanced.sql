USE DataWarehouse
--Change over-time analysis
  
SELECT 
	YEAR(order_date) OrderYear
	,SUM(sales_amount) TotalSales
	,COUNT(Distinct Customer_key) TotalCustomers
	,SUM(quantity) TotalItems
FROM gold.fact_sales
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

--cumulative analysis

SELECT 
	*
	,SUM(total_sales_per_year) OVER(ORDER BY order_year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)  cumulative_sales_amount
FROM(
	SELECT 
		DATEPART(YEAR,order_date) order_year
		,SUM(sales_amount) total_sales_per_year
	FROM gold.fact_sales
	WHERE DATEPART(YEAR,order_date) IS NOT NULL
	GROUP BY DATEPART(YEAR,order_date))t

--Performance analysis

SELECT 
	*
	,SUM(total_sales_per_year) OVER(ORDER BY order_year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)  cumulative_sales_amount
	,total_sales_per_year - LAG(total_sales_per_year) OVER(PARTITION BY category ORDER BY order_year) AS Preformance_with_last_year
	,avg_sales_per_year - LAG(avg_sales_per_year) OVER(PARTITION BY category ORDER BY order_year) AS AvgPreformance_with_last_year
FROM(
	SELECT
		dp.category
		,DATEPART(YEAR,order_date) order_year
		,SUM(sales_amount) total_sales_per_year
		,AVG(sales_amount) avg_sales_per_year
	FROM gold.fact_sales fs
	LEFT JOIN gold.dm_products dp
	ON fs.product_key = dp.product_key
	WHERE DATEPART(YEAR,order_date) IS NOT NULL
	GROUP BY dp.category,DATEPART(YEAR,order_date))t


--same with CTE

WITH cte AS(
SELECT
		dp.category
		,DATEPART(YEAR,order_date) order_year
		,SUM(sales_amount) total_sales_per_year
		,AVG(sales_amount) avg_sales_per_year
	FROM gold.fact_sales fs
	LEFT JOIN gold.dm_products dp
	ON fs.product_key = dp.product_key
	WHERE DATEPART(YEAR,order_date) IS NOT NULL
	GROUP BY dp.category,DATEPART(YEAR,order_date)
)

SELECT 
	order_year
	,total_sales_per_year
	,avg_sales_per_year
	,SUM(total_sales_per_year) OVER(ORDER BY order_year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)  cumulative_sales_amount
	,total_sales_per_year - LAG(total_sales_per_year) OVER(PARTITION BY category ORDER BY order_year) AS Preformance_with_last_year
	,avg_sales_per_year - LAG(avg_sales_per_year) OVER(PARTITION BY category ORDER BY order_year) AS AvgPreformance_with_last_year
FROM cte;

--Part to whole (proportion)
--Which category contribute the most to overall sales

WITH contributeCTE AS( 
	SELECT 
		p.category AS category
		,SUM(s.sales_amount) AS total_item_sales
		,SUM(s.quantity) AS item_quantity
	FROM gold.fact_sales s 
	LEFT JOIN gold.dm_products p 
	ON s.product_key = p.product_key
	GROUP BY p.category),
contributeCTE2 AS(
	SELECT 
		category
		,total_item_sales
		,item_quantity
		,SUM(total_item_sales) OVER() AS overall_sales
	FROM contributeCTE)

SELECT 
	*
	,CONCAT(ROUND(CAST(total_item_sales AS FLOAT) / CAST(overall_sales AS FLOAT) * 100,2), ' %') AS contribute
FROM contributeCTE2
ORDER BY total_item_sales DESC;


--DATA Segmentation 
--segment products into cost ranges and count how many products fall into each segment

WITH segmentcte AS(
	SELECT
		p.category AS category
		,SUM(p.product_cost) total_cost
		,SUM(COALESCE(s.price,0)) total_price
		,SUM(COALESCE(s.sales_amount,0)) total_sales
	FROM gold.dm_products p
	LEFT JOIN gold.fact_sales s
	ON s.product_key = p.product_key
	WHERE p.category IS NOT NULL
	GROUP BY p.category)
SELECT 
	category
	,CASE WHEN total_cost > 300000 THEN 'High'
	WHEN total_cost > 200000 THEN 'Medium'
	ELSE 'Low' END AS segmentation
FROM segmentcte
ORDER BY total_cost DESC;
