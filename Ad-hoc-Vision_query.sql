/* 1. Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region. */

Solution: 
SELECT 
	DISTINCT market 
FROM dim_customer 
WHERE region = 'APAC';

India
Indonesia
Japan
Pakistan
Philiphines
South Korea
Australia
Newzealand
Bangladesh
China


/* 2. What is the percentage of unique product increase in 2021 vs. 2020? The
final output contains these fields,
unique_products_2020
unique_products_2021
percentage_chg*/

Solution: 
WITH unique_products_2020 AS (
SELECT COUNT(DISTINCT product_code)AS product_2020 FROM fact_sales_monthly WHERE fiscal_year = 2020), 
unique_products_2021 AS 
(SELECT COUNT(DISTINCT product_code) AS product_2021 FROM fact_sales_monthly WHERE fiscal_year = 2021)

SELECT product_2020, product_2021,
 ROUND((product_2021-product_2020)*100/product_2020,2) AS PERCENT_CHANGE FROM unique_products_2020 CROSS JOIN unique_products_2021;

245	334	36.33


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
sort them in descending order of product counts. The final output contains
2 fields,
segment
product_count */

Solution: 

SELECT 
	segment, 
    COUNT(product) AS product_count
FROM dim_product
GROUP BY segment 
ORDER BY product_count desc;

Notebook	129
Accessories	116
Peripherals	84
Desktop	32
Storage	27
Networking	9


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

Accessories	69	103	34
Desktop	7	22	15
Networking	6	9	3
Notebook	92	108	16
Peripherals	59	75	16
Storage	12	17	5

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

AQ HOME Allin1 Gen 2	A6120110206	240.5364
AQ Master wired x1 Ms	A2118150101	0.8920

/* 6. Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,
customer_code
customer
average_discount_percentage
 */

Solution: 

select c.customer_code, c.customer, round(avg(i.pre_invoice_discount_pct),4) as average_discount_percentage
from dim_customer c join fact_pre_invoice_deductions i
on c.customer_code = i.customer_code
where i.fiscal_year = 2021 and c.market = 'INDIA'
group by c.customer_code, c.customer
order by average_discount_percentage desc
limit 5
 

90002009	Flipkart	0.3083
90002006	Viveks	0.3038
90002003	Ezone	0.3028
90002002	Croma	0.3025
90002016	Amazon 	0.2933


/* 7. Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month. This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount

 */

Solution: 

select MONTHNAME(s.date) as Month, s.fiscal_year, Round(SUM(s.sold_quantity *p.gross_price),2) AS Gross_sales_Amount
from fact_sales_monthly s Join 
fact_gross_price p on s.product_code = p.product_code
join dim_customer c on  c. customer_code = s.customer_code
WHERE c.customer = 'Atliq Exclusive'
group by  Month, s.fiscal_year
ORDER BY Gross_sales_Amount DESC

 

November	2021	32247289.79
October	2021	21016218.21
December	2021	20409063.18
January	2021	19570701.71
September	2021	19530271.30
May	2021	19204309.41
March	2021	19149624.92
July	2021	19044968.82
February	2021	15986603.89
June	2021	15457579.66
November	2020	15231894.97
April	2021	11483530.30
August	2021	11324548.34
October	2020	10378637.60
December	2020	9755795.06
January	2020	9584951.94
September	2020	9092670.34
February	2020	8083995.55
August	2020	5638281.83
July	2020	5151815.40
June	2020	3429736.57
May	2020	1586964.48
April	2020	800071.95
March	2020	766976.45



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
 sum(sold_quantity) AS total_sold_quantity
 from  fact_sales_monthly
where fiscal_year = 2020
group by QN


SELECT 
CASE 
WHEN DATE BETWEEN '2019-09-01' AND '2019-11-01' THEN 'QUARTER 1'
WHEN DATE BETWEEN '2019-12-01' AND '2020-02-01' THEN 'QUARTER 2'
WHEN DATE BETWEEN '2020-03-01' AND '2020-05-01' THEN 'QUARTER 3'
WHEN DATE BETWEEN '2020-06-01' AND '2020-08-01' THEN 'QUARTER 4' 
END AS QN, MONTHNAME(Date) as month,
 sum(sold_quantity) AS total_sold_quantity
 from  fact_sales_monthly
where fiscal_year = 2020
group by month,qn

QUARTER 1	7005619
QUARTER 2	6649642
QUARTER 3	2075087
QUARTER 4	5042541




/* 9. Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage

 */

Solution: 

with cte as (
select c.channel, round(sum(s.sold_quantity*p.gross_price),2) AS gross_sales_mln 
from fact_sales_monthly s join fact_gross_price p on p.product_code = s.product_code
join dim_customer c on c.customer_code = s.customer_code
where s.fiscal_year = 2021
group by c.channel)

select channel, gross_sales_mln ,  round(gross_sales_mln *100 /sum(gross_sales_mln) over(),2) as percentage from cte 
order by percentage desc

Distributor	297175879.72	11.31
Direct	406686873.90	15.47
Retailer	1924170397.91	73.22


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

with cte1 as (
select p.division, p.product_code, p.product, sum(s.sold_quantity) AS total_sold_quantity
from  dim_product p join fact_sales_monthly s on p.product_code = s.product_code
where s.fiscal_year = 2021
group by p.division, p.product_code, p.product),
cte2 as (
select division, product_code, product, total_sold_quantity, DENSE_Rank() over(Partition by division order by total_sold_quantity desc)
as rn from cte1)

SELECT * FROM cte2 where rn IN (1,2,3)



N & S	A6720160103	AQ Pen Drive 2 IN 1	701373	1
N & S	A6818160202	AQ Pen Drive DRC	688003	2
N & S	A6819160203	AQ Pen Drive DRC	676245	3
P & A	A2319150302	AQ Gamers Ms	428498	1
P & A	A2520150501	AQ Maxima Ms	419865	2
P & A	A2520150504	AQ Maxima Ms	419471	3
PC	A4218110202	AQ Digit	17434	1
PC	A4319110306	AQ Velocity	17280	2
PC	A4218110208	AQ Digit	17275	3
