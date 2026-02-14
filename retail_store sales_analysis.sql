-- Retail store sales analysis
Use online_retail_store;


-- 1. Data cleaning & Quality check
-- Creating duplicate table. #Rule1 : Never touch raw data
CREATE TABLE online_retail_copy AS
SELECT *
FROM online_retail;

-- Creating new column named as invoice_date and converting text format date column to actual date column
ALTER TABLE online_retail_copy
ADD COLUMN invoice_date DATETIME;

UPDATE online_retail_copy
SET invoice_date = CASE 
	WHEN InvoiceDate LIKE '%/%' THEN STR_TO_DATE(InvoiceDate,'%m/%d/%Y %k:%i')
	WHEN InvoiceDate LIKE '%-%' THEN STR_TO_DATE(InvoiceDate,'%m-%d-%Y %H:%i')
	ELSE NULL
	END;
    
ALTER TABLE online_retail_copy DROP COLUMN InvoiceDate;

-- Analysis begins

-- revenue performance analysis
-- Total revenue
SELECT ROUND(SUM(quantity*UnitPrice),2) AS total_revenue FROM online_retail_copy;

-- retail store performance by YOY growth.
-- probably the YOY and MOM revenue growth percentage(-68%) will be same and negative because it only have two months of data
WITH revenue_by_year AS(
SELECT YEAR(invoice_date) AS month_year,
	   SUM(quantity*UnitPrice) AS revenue
FROM online_retail_copy
GROUP BY YEAR(invoice_date)
)
SELECT month_year,
       revenue,
       ROUND(LAG(revenue,1) OVER(ORDER BY month_year)) AS previous_year_revenue,
       ROUND(revenue - LAG(revenue,1) OVER(ORDER BY month_year)) AS YoY,
	   ROUND(
       (revenue - LAG(revenue,1) OVER(ORDER BY month_year))/
       LAG(revenue,1) OVER(ORDER BY month_year)*100
       ) AS yoy_revenue_growth_percentage
FROM revenue_by_year
ORDER BY month_year;

-- MOM growth revenue growth
WITH revenue_by_month AS(
SELECT DATE_FORMAT(invoice_date,'%Y-%m-01') AS month_date,
       SUM(quantity*UnitPrice) AS total_revenue
FROM online_retail_copy
GROUP BY month_date
)
SELECT month_date,
       total_revenue,
       ROUND(LAG(total_revenue,1) OVER(ORDER BY month_date),2) AS previous_month_revenue,
       ROUND(total_revenue - LAG(total_revenue,1) OVER(ORDER BY month_date),2) AS month_revenue_difference,
       ROUND(
       (total_revenue - LAG(total_revenue,1) OVER(ORDER BY month_date))/
       LAG(total_revenue,1) OVER(ORDER BY month_date)*100
       ) AS revenue_growth_percentage
FROM revenue_by_month
ORDER BY month_date;

-- revenue by region
-- In total revenue 90.15% revenue generated in United Kingdom becuase that where store have most customers and most logistic distributor fot their products.
WITH tot_revenue_by_region AS(
SELECT Country,
       ROUND(SUM(Quantity*Unitprice),2) AS revenue_region
FROM online_retail_copy
GROUP BY Country
),
overall_revenue AS(
SELECT SUM(quantity*UnitPrice) AS total_revenue
FROM online_retail_copy
)

SELECT Country,
       revenue_region,
       ROUND(revenue_region * 100.0 / total_revenue,2) AS revenue_percentage_country
FROM tot_revenue_by_region AS r
CROSS JOIN overall_revenue AS o;

-- Total sales by hour
-- 15th hour is peak hour because most of the sales and products were sold that particular hour becuase.
WITH hours_orders_sales AS(
SELECT HOUR(invoice_date) AS hour_of_day,
	   COUNT(DISTINCT InvoiceNo) AS total_orders,
       SUM(Quantity) AS total_items_sold,
       ROUND(SUM(Quantity*UnitPrice),2) AS total_sales
FROM online_retail_copy
GROUP BY HOUR(invoice_date)
)

SELECT hour_of_day,
       total_orders,
       total_sales,
       RANK() OVER(ORDER BY total_sales DESC) AS revenue_rank,
       RANK() OVER(ORDER BY total_orders DESC) AS orders_rank
FROM hours_orders_sales;

-- product performing sales analysis

-- Top quanitity sold products = top 15 sold products
-- Least quantity sold products = least 10 sold products

-- Top quanitity sold products
-- Only 0.53% percentage products are top selling products in overall analysis
WITH quantity_sold_product AS(
SELECT StockCode,
       SUM(quantity) AS total_quantity_sold
FROM online_retail_copy
GROUP BY StockCode
),
ranked_stocks AS(
SELECT StockCode,
       total_quantity_sold,
       DENSE_RANK() OVER(ORDER BY total_quantity_sold DESC) AS rnk
FROM quantity_sold_product
)
SELECT ROUND(SUM(CASE WHEN rnk <= 15 THEN 1 ELSE 0 END)*100/COUNT(*),2) AS top_selling_products_percentage
FROM ranked_stocks;


-- Least quantity sold products
-- 25.63% percentage of the product least sold from from the overall products
WITH quantity_sold_product AS(
SELECT StockCode,
       SUM(quantity) AS total_quantity_sold
FROM online_retail_copy
GROUP BY StockCode
HAVING SUM(quantity) > 0
),
ranked_stocks AS(
SELECT StockCode,
       total_quantity_sold,
       DENSE_RANK() OVER(ORDER BY total_quantity_sold ASC) AS rnk
FROM quantity_sold_product
)

SELECT ROUND(SUM(CASE WHEN rnk <= 10 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) AS least_selling_product_percentage
FROM ranked_stocks;


-- top revenue & least revenue product 
-- least revenue = Lest 10 revenue products

-- top renvenue  = Top 15 revenue products
-- In top revenue making products the stock 22423 product made 3.06% percentage from oveall revenue it is the highest revenue generated products.
WITH revenue_products AS(
SELECT StockCode,
       ROUND(SUM(Quantity*UnitPrice),2) AS Total_sales
FROM online_retail_copy
GROUP BY StockCode
),
ranked_products AS(
SELECT StockCode,
       Total_sales,
	   DENSE_RANK() OVER(ORDER BY Total_sales DESC) AS rnk
FROM revenue_products
),
revenue AS(
SELECT SUM(Quantity*UnitPrice) AS overall_revenue
FROM online_retail_copy
)

SELECT rp.StockCode,
       rp.Total_sales,
       ROUND(rp.Total_sales*100.0 / r.overall_revenue,2) AS revenue_percentage_prod
FROM ranked_products AS rp
CROSS JOIN revenue AS r
WHERE rnk <= 15;


-- Least revenue generated products
-- In low performing product by revenue the stocks 79149B, 79151B and 71215 genrated only 0.00004% revenue from overall revenue  and this is the least revenue percentage; 
WITH revenue_products AS(
SELECT StockCode,
       ROUND(SUM(Quantity*UnitPrice),2) AS Total_sales
FROM online_retail_copy
GROUP BY StockCode
HAVING Total_sales > 0
),
ranked_products AS(
SELECT StockCode,
       Total_sales,
	   DENSE_RANK() OVER(ORDER BY Total_sales ASC) AS rnk
FROM revenue_products
),
revenue AS(
SELECT SUM(Quantity*UnitPrice) AS overall_revenue
FROM online_retail_copy
)

SELECT rp.StockCode,
       rp.Total_sales,
       ROUND(rp.Total_sales*100.0 / r.overall_revenue,5) AS revenue_percentage_prod
FROM ranked_products AS rp
CROSS JOIN revenue AS r
WHERE rnk <= 15;

-- Products generated highest revenue in different countries
-- It shows which product generated highest revenue in each country
WITH revenue_stock_country AS(
SELECT StockCode,
       Country,
       ROUND(SUM(Quantity*UnitPrice),2) AS total_revenue
FROM online_retail_copy
GROUP BY StockCode, Country
),
ranked_stocks AS(
SELECT StockCode,
	   Country,
       total_revenue,
       DENSE_RANK() OVER(PARTITION BY country ORDER BY total_revenue DESC) AS rnk
FROM revenue_stock_country
)
SELECT StockCode,
       Country,
	   total_revenue
FROM ranked_stocks
WHERE rnk = 1;

-- It describes products under performing revenue in each country.
WITH revenue_stock_country AS(
SELECT StockCode,
       Country,
       ROUND(SUM(Quantity*UnitPrice),2) AS total_revenue
FROM online_retail_copy
GROUP BY StockCode, Country
HAVING total_revenue > 0
),
ranked_stocks AS(
SELECT StockCode,
	   Country,
       total_revenue,
       DENSE_RANK() OVER(PARTITION BY country ORDER BY total_revenue ASC) AS rnk
FROM revenue_stock_country
)
SELECT StockCode,
       Country,
	   total_revenue
FROM ranked_stocks
WHERE rnk = 1;

-- Product unsold and returned
-- Stock code 85067, 84562A, 85126 and 21011 these products unsold product which aound 0.035% of total proucts.
WITH products_unsold AS(
SELECT StockCode,
       SUM(Quantity) AS unsold_quantity
FROM online_retail_copy
GROUP BY StockCode
HAVING SUM(Quantity) = 0
),
total_products AS (
SELECT COUNT(DISTINCT StockCode) AS total_products
FROM online_retail_copy
)

SELECT COUNT(pu.unsold_quantity)*100.0 / SUM(t.total_products) AS unsold_product_percentage
FROM products_unsold AS pu
CROSS JOIN total_products AS t;



-- Returned products
-- In 0.04% percenage of the products where returned particularly the stockcode 22617 products has returned most.
SELECT StockCode,
       SUM(Quantity) AS return_quantity
FROM online_retail_copy
GROUP BY StockCode
HAVING SUM(Quantity) < 0
ORDER BY return_quantity ASC;

WITH returned_products AS(
SELECT StockCode,
       SUM(Quantity) AS return_quantity
FROM online_retail_copy
GROUP BY StockCode
HAVING SUM(Quantity) < 0
ORDER BY return_quantity ASC
),
total_products AS(
SELECT COUNT(DISTINCT StockCode) AS total_products
FROM online_retail_copy
)

SELECT ROUND(COUNT(r.StockCode)*100.0/SUM(total_products),2) AS returned_prod_percentage
FROM returned_products AS r
CROSS JOIN total_products AS t;


-- from each which product returned most
-- All products 100% of returned products from UK where the place we highest customers on thos returned product StockCode 22617 has returned mostly.
WITH returned_quantity_prod AS(
SELECT StockCode,
       Country,
       SUM(Quantity) AS returned_quantity
FROM online_retail_copy
GROUP BY StockCode,Country
HAVING returned_quantity < 0
),
ranked_returns AS(
SELECT StockCode,
       Country,
	   returned_quantity,
       RANK() OVER(PARTITION BY Country ORDER BY returned_quantity ASC) AS rnk
FROM returned_quantity_prod
)

SELECT StockCode,
       Country,
       returned_quantity,
       rnk
FROM ranked_returns;

-- customer performance analysis
-- Across 1054 customers from different region Uniked Kingdom has a 961 customers and this is the highest customer count becuase that's where store investion more money on advertizing and marketing laso more logistic distributors for their products.
SELECT COUNT(DISTINCT CustomerID) AS total_customers
FROM online_retail_copy;

-- revenue by region 
SELECT Country,
       COUNT(DISTINCT CustomerID) AS customers_count
FROM online_retail_copy
GROUP BY Country
ORDER BY customers_count DESC;

-- customers who bought most of the product.
-- Cutomer.No 17850 bought a highest products.
SELECT CustomerID,
       COUNT(StockCode) AS total_stocks
FROM online_retail_copy
GROUP BY CustomerID;

-- avg sales per customer
WITH total_revenue_customer AS(
SELECT CustomerID,
	   SUM(Quantity*UnitPrice) AS total_revenue
FROM online_retail_copy
GROUP BY CustomerID
)

SELECT ROUND(AVG(total_revenue),2) AS avg_revenue
FROM total_revenue_customer;



-- Findings

-- 1. Revenue perfomance
-- From the total revenue of $10,90,169 United Kingdom has genrated 90% revenue becuase the that's where the store have most customers that's where the store investing more money on Advertising and Marketing for thier store.alter
-- Isreal considered as least revenue generated region which is 0.03%
-- YOY revenue growth was -68% percentage because the dateset only have two months of records.
-- MOM% revenue was droped 68% comparing december 2010 and January 2011 which is big down for the in the begining of the year.

-- 2.Product quantity perfomance
-- Only 0.53% percentage of the products mostly sold and 25.63% of the products were undersold which is huge difference product between most and least sold prodcuts. 
-- The Stockcode:2243 product generated 3.06% revenue generated in overall revenue.
-- Products 79149B,79151B and 71215 generated only 0.00004% revenue.

-- 3.returned products
-- 0.04% percenage of the products where returned particularly on these returned product the certain product 22617 returned most. which means the store have to follow sctrict return policy and focus safety & perfect pakaging.

-- 4.Customer performance analysis
-- Avg sales per customer was $1034.32
-- Across 1054 customers the maximum(961) customers from the United Kingdom.

-- 5. hour sales & orders
-- More revenue and most products were sold on 15th hour of the day.