/* 1. Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region. */

Solution: 
SELECT 
	DISTINCT market 
FROM dim_customer 
WHERE region = 'APAC';



/* 2. What is the percentage of unique product increase in 2021 vs. 2020? The
final output contains these fields,
unique_products_2020
unique_products_2021
percentage_chg*/

Solution: 

WITH unique_products_2020 AS (
SELECT 
	COUNT(DISTINCT product_code) AS product_2020 
FROM fact_sales_monthly 
WHERE fiscal_year = 2020), 
unique_products_2021 AS (
SELECT 
	COUNT(DISTINCT product_code) AS product_2021 
FROM fact_sales_monthly 
WHERE fiscal_year = 2021)

SELECT 
	product_2020, 
    	product_2021,
	ROUND((product_2021-product_2020)*100/product_2020,2) AS PERCENT_CHANGE 
FROM unique_products_2020
CROSS JOIN unique_products_2021;


/* 3. Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts. The final output contains 2 fields,
segment
product_count */

Solution: 

SELECT 
	segment, 
    	COUNT(product) AS product_count
FROM dim_product
GROUP BY segment 
ORDER BY product_count desc;

/* 4. Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference
 */

Solution: 
WITH product_count_2020 AS
(SELECT 
	p.segment,
    	COUNT(DISTINCT p.product_code) AS product_count_20 
FROM dim_product p 
JOIN fact_sales_monthly s 
ON  p.product_code = s.product_code 
WHERE fiscal_year= 2020
GROUP BY p.segment),

product_count_2021 AS
(SELECT 
	p.segment, 
    	COUNT(DISTINCT p.product_code) AS product_count_21 
FROM dim_product p
JOIN fact_sales_monthly s 
ON  p.product_code = s.product_code 
WHERE fiscal_year= 2021
GROUP BY p.segment)

SELECT 
	 p20.segment, 
   	 p20.product_count_20,
   	 p21.product_count_21, 
    	(p21.product_count_21-p20.product_count_20) AS Difference 
FROM   product_count_2020 p20 
JOIN  product_count_2021 p21 
ON p20.segment = p21.segment;

/* 5. Get the products that have the highest and lowest manufacturing costs.
The final output should contain these fields,
product_code
product
manufacturing_cost
 */

Solution: 

(SELECT 
	 p.product, 
   	 p.product_code,
    	MAX(m.manufacturing_cost) AS manufacturing_cost  
FROM dim_product p 
JOIN fact_manufacturing_cost m
ON p.product_code = m.product_code      
GROUP BY p.product, p.product_code 
ORDER BY manufacturing_cost DESC
LIMIT 1)

UNION

(SELECT 
	p.product, 
	p.product_code,
    	MIN(m.manufacturing_cost) AS manufacturing_cost  
FROM dim_product p 
JOIN fact_manufacturing_cost m
ON p.product_code = m.product_code      
GROUP BY p.product, p.product_code 
ORDER BY manufacturing_cost 
LIMIT 1)       


/* 6. Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,
customer_code
customer
average_discount_percentage
 */

Solution: 

SELECT
	c.customer_code,
    	c.customer, 
	ROUND(AVG(i.pre_invoice_discount_pct),4) AS average_discount_percentage
FROM dim_customer c JOIN fact_pre_invoice_deductions i
ON c.customer_code = i.customer_code
WHERE i.fiscal_year = 2021 AND c.market = 'INDIA'
GROUP BY c.customer_code, c.customer
ORDER BY  average_discount_percentage DESC 
LIMIT 5;

/* 7. Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount
 */

Solution: 

select 
	MONTHNAME(s.date) AS Month, 
    	s.fiscal_year, 
    	Round(SUM(s.sold_quantity *p.gross_price),2) AS Gross_sales_Amount
FROM fact_sales_monthly s 
Join fact_gross_price p ON s.product_code = p.product_code
JOIN dim_customer c ON  c. customer_code = s.customer_code
WHERE c.customer = 'Atliq Exclusive'
GROUP BY  Month, s.fiscal_year
ORDER BY Gross_sales_Amount DESC;

 
/* 8. In which quarter of 2020, got the maximum total_sold_quantity? The final
output contains these fields sorted by the total_sold_quantity,
Quarter
total_sold_quantity
 */

Solution: 

SELECT 
CASE 
WHEN DATE BETWEEN '2019-09-01' AND '2019-11-01' THEN 'QUARTER 1'
WHEN DATE BETWEEN '2019-12-01' AND '2020-02-01' THEN 'QUARTER 2'
WHEN DATE BETWEEN '2020-03-01' AND '2020-05-01' THEN 'QUARTER 3'
WHEN DATE BETWEEN '2020-06-01' AND '2020-08-01' THEN 'QUARTER 4' 
END AS QN,
	SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY QN;


SELECT 
CASE 
WHEN DATE BETWEEN '2019-09-01' AND '2019-11-01' THEN 'QUARTER 1'
WHEN DATE BETWEEN '2019-12-01' AND '2020-02-01' THEN 'QUARTER 2'
WHEN DATE BETWEEN '2020-03-01' AND '2020-05-01' THEN 'QUARTER 3'
WHEN DATE BETWEEN '2020-06-01' AND '2020-08-01' THEN 'QUARTER 4' 
END AS QN, 
	MONTHNAME(Date) AS month,
	SUM(sold_quantity) AS total_sold_quantity
FROM  fact_sales_monthly
WHERE fiscal_year = 2020
GROUP BY month, qn;

/* 9. Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage
 */

Solution: 

WITH cte AS (
	SELECT c.channel, 
    	ROUND(SUM(s.sold_quantity*p.gross_price),2) AS gross_sales_mln 
FROM fact_sales_monthly s 
JOIN fact_gross_price p 
ON p.product_code = s.product_code
JOIN dim_customer c 
ON c.customer_code = s.customer_code
WHERE s.fiscal_year = 2021
GROUP BY c.channel)

SELECT
	channel, 
    	gross_sales_mln ,  
    	ROUND(gross_sales_mln *100 /SUM(gross_sales_mln) OVER(),2) AS percentage 
FROM cte 
order by percentage DESC;


/*10. Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? The final output contains these
fields,
division
product_code
product
total_sold_quantity
rank_order
 */

Solution: 

WITH cte1 AS (
SELECT 
	p.division, 
	p.product_code, 
    	p.product, 
    	SUM(s.sold_quantity) AS total_sold_quantity
FROM dim_product p 
JOIN fact_sales_monthly s 
ON p.product_code = s.product_code
WHERE s.fiscal_year = 2021
GROUP BY  p.division, p.product_code, p.product),

cte2 AS (
SELECT 
	division, 
    	product_code, 
    	product, 
    	total_sold_quantity, 
    	DENSE_RANK() OVER(PARTITION BY division ORDER BY total_sold_quantity DESC) AS rn 
FROM cte1)

SELECT * FROM cte2 WHERE rn IN (1,2,3);




