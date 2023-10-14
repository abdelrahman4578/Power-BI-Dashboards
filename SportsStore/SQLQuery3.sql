SELECT * FROM orders

-- 1. KPIs for Total revenue, Profit, #orders, profit margin	  

SELECT 
	ROUND(SUM(revenue),2) AS total_revenue,
	ROUND(SUM(profit),2) AS total_profit,
	COUNT(*) AS total_orders,
	ROUND(SUM(profit)/SUM(revenue)*100.0,2) AS profit_margiin
FROM 
	orders

-- 2. Total revenue, Profit, #orders, profit margin for each sport

SELECT 
	sport,
	ROUND(SUM(revenue),2) AS total_revenue,
	ROUND(SUM(profit),2) AS total_profit,
	COUNT(*) AS total_orders,
	ROUND(SUM(profit)/SUM(revenue)*100.0,2) AS profit_margiin
FROM 
	orders
WHERE sport IS NOT NULL
GROUP BY 
	sport
ORDER BY   
	profit_margiin DESC

-- 3. Number of customer ratings and the average rating

SELECT 
	(SELECT COUNT(*) FROM orders WHERE rating IS NOT NULL) AS number_of_reviews,
	ROUND(AVG(rating),2) AS average_rating
FROM 
	orders

-- 4. Number of people for each rating and it's revenue, profit, profit_margin

SELECT 
	rating,
	COUNT(rating) AS number_of_each_rating,
	ROUND(SUM(revenue),2) AS total_revenue,
	ROUND(SUM(profit),2) AS total_profit,
	ROUND(SUM(profit)/SUM(revenue)*100.0,2) AS  profit_margiin
FROM 
	orders
WHERE 
	rating IS NOT NULL
GROUP BY 
	rating
ORDER BY 
	rating DESC

-- 5. State revenue, profit and profit margin

SELECT 
	C.State,
	ROW_NUMBER() OVER(ORDER BY ROUND(SUM(O.revenue),2) DESC) AS revenue_rank,
	ROUND(SUM(O.revenue),2) AS total_revenue,
	ROW_NUMBER() OVER(ORDER BY ROUND(SUM(O.profit),2) DESC) AS profit_rank,
	ROUND(SUM(O.profit),2) AS total_profit,
	ROW_NUMBER() OVER(ORDER BY ROUND(SUM(O.profit)/SUM(O.revenue)*100.0,2) DESC) AS margin_rank,
	ROUND(SUM(O.profit)/SUM(O.revenue)*100.0,2) AS profit_margin
FROM 
	orders O
JOIN 
	customers C
ON 
	O.customer_id=C.customer_id
GROUP BY 
	C.State
ORDER BY 
	margin_rank 

-- 6. Monthly Profits

WITH monthly_profit AS(
SELECT 
	MONTH(date) AS month,
	ROUND(SUM(profit),2) AS total_profit
FROM
	orders
GROUP BY 
	MONTH(date))
SELECT 
	month,
	total_profit,
	LAG(total_profit) OVER(ORDER BY month) AS previous_month_profit,
	total_profit-LAG(total_profit) OVER(ORDER BY month) AS profit_difference
FROM 
	monthly_profit
WHERE month IS NOT NULL
ORDER BY
	month