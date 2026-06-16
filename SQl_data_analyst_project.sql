
##Monthly sales trend analysis
##Tracks revenue, customer count, order quantity, and month-over-month sales growth

WITH monthly_sales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) AS total_quantity
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
)

SELECT
    order_month,
    total_sales,
    total_customers,
    total_quantity,
    LAG(total_sales) OVER (ORDER BY order_month) AS previous_month_sales,
    total_sales - LAG(total_sales) OVER (ORDER BY order_month) AS sales_change,
    ROUND(
        100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY order_month))
        / NULLIF(LAG(total_sales) OVER (ORDER BY order_month), 0),
        2
    ) AS monthly_growth_percentage
FROM monthly_sales
ORDER BY order_month;

## Cumulative sales analysis
## Calculates monthly sales, running total sales, and moving average price over time

WITH monthly_sales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
)

SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales,
    AVG(avg_price) OVER (
        ORDER BY order_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_month_moving_avg_price
FROM monthly_sales
ORDER BY order_month;

-- Performance Analsysis
-- Current Meassure - Target Measure
-- Yearly performance of products by comparing their sales to both 
-- the average sales performance of the product and the previous years sales

with cte_year as
(select 
year(a.[order_date] ) as order_year,
b.[product_name],
sum([sales_amount]) as current_sales

from
[gold].[fact_sales] a
left join
[gold].[dim_products] b
on a.product_key = b.product_key

where [order_date] is not null

group by
year(a.[order_date] ),
b.[product_name])

SELECT 
order_year,
[product_name],
current_sales,

avg(current_sales) over(partition by [product_name]) as avg_sales,
current_sales - avg(current_sales) over(partition by [product_name]) as diff_avg,

case when
current_sales - avg(current_sales) over(partition by [product_name]) > 0 then 'Above Average'

when
current_sales - avg(current_sales) over(partition by [product_name]) < 0 then 'Below Average'
else 'Avg'
end avg_change,

-- Year-over-Year analysis

lag(current_sales) over (partition by [product_name] order by order_year) as py_sales,
current_sales - lag(current_sales) over (partition by [product_name] order by order_year) as diff_py,

case when
current_sales - lag(current_sales) over (partition by [product_name] order by order_year) > 0 then 'Increasing_sales'

when
current_sales - lag(current_sales) over (partition by [product_name] order by order_year) < 0 then 'Decerasing_sales'
else 'No_change'
end sales_change

FROM cte_year
order by 
[product_name],
order_year;


-- Part-to-Whole Analysis


with cte_category_sales as(
select 
category,
sum([sales_amount]) as total_sales

from 
[gold].[fact_sales] a
left join
[gold].[dim_products] b

on a.product_key = b.product_key
group by category)

select 
category,
total_sales,
sum(total_sales) over() overall_sales,
concat(round((cast (total_sales as float)/sum(total_sales) over())* 100,2),'%') as percentage_of_total
 
from cte_category_sales
order by total_sales desc;

-- Data Segmentation
-- Segment products into cost ranges and count how
-- many products fall into each segment


with cte_product_segment as (
select 
[product_key],
[product_name],
[cost],

case 
when [cost] < 100 then 'Below 100'
when [cost] between 100 and 500 then '100-500'
when [cost] between 500 and 1000 then '500-1000'
else 'Above 1000'
end as cost_range

from
[gold].[dim_products])

select 
cost_range,
count([product_key]) as total_products

from 
cte_product_segment
group by cost_range
order by total_products desc;

-- Group customers into three segments based on the spending behaviour
-- VIp: With atleast 12 months historyand spending over $5000
-- Regular: With atleat 12 months history but spending $5000 or less
-- New: Customers with lifespan less than 12 months
-- Find total number of customers each group


with cte_customer_spending as (
select 
a.[customer_key],
sum([sales_amount]) as total_spent,
min(order_date) as first_order,
max(order_date) as last_order,
DATEDIFF(MONTH,min(order_date),max(order_date)) as lifespan

from 
[gold].[fact_sales] a
left join
[gold].[dim_customers] b
on a.customer_key = b.customer_key

group by
a.[customer_key]),

cte_customer_segment as 
(select
[customer_key],
case 
when lifespan > 12 and total_spent > 5000 then 'VIP'
when lifespan >= 12 and total_spent <= 5000 then 'Regular'
else 'New'
end as customer_segment
from 
cte_customer_spending)

select 
customer_segment,
COUNT([customer_key]) as total_customers

from 
cte_customer_segment

group by customer_segment
order by total_customers desc;

-- Customer report
-- It consolidates key customer metrics and behaviours

with cte_base_query as (
select 
a.[order_number],
a.[product_key],
a.[order_date],
a.[sales_amount],
a.[quantity],
b.[customer_key],
b.[customer_number],

DATEDIFF(YEAR,b.[birthdate], GETDATE()) as age,
CONCAT(b.[first_name], ' ', b.[last_name]) as customer_name

from 
[gold].[fact_sales] a
left join
[gold].[dim_customers] b
on a.customer_key = b.customer_key

where order_date is not null),

cte_customer_segmentation as (

select 

customer_key,
customer_number,
age,
customer_name,
count(distinct order_number ) as total_orders,
sum(sales_amount) as total_sales,
sum([quantity]) as total_quantity,
count(distinct [product_key]) as total_products,
max(order_date) as last_order_date,
DATEDIFF(MONTH,min(order_date),max(order_date)) as lifespan

from
cte_base_query

group by 
customer_key,
customer_number,
age,
customer_name
)

select
customer_key,
customer_number,
customer_name,
age,
case
when age < 20 then 'Under 20'
when age between 20 and 29 then'20-29'
when age between 30 and 39 then '30-39'
when age between 40 and 49 then '40-49'
else '50 and above'
end as age_group,

case 
when lifespan > 12 and total_sales > 5000 then 'VIP'
when lifespan >= 12 and total_sales <= 5000 then 'Regular'
else 'New'
end as customer_segment,
last_order_date,
DATEDIFF(MONTH,last_order_date,GETDATE()) as recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,

total_sales/total_orders as avg_order_value,
case when total_orders = 0 then 0
else total_sales/total_orders 
end as avg_order_value,

case when lifespan = 0 then total_sales
else total_sales/lifespan
end as avg_monthly_spent

from cte_customer_segmentation;

-- Product Report

with cte_product as 
(select 
a.[order_number],
a.[product_key],
a.[order_date],
a.[sales_amount],
a.[quantity],
b.[cost],
b.[category],
b.[subcategory],
b.[product_number],
b.product_name

from
[gold].[fact_sales] a
left join
[gold].[dim_products] b
on a.product_key = b.product_key
where order_date is Not Null
),

product_aggregation as (

select
[product_key],
[category],
[subcategory],
[cost],

DATEDIFF(MONTH,min([order_date]),max([order_date])) as lifespan,
count(distinct  [order_number]) as total_orders,
count(distinct [product_number]) as total_products,
max(order_date) as last_sale_date,
sum(sales_amount) as total_sales,
sum([quantity]) as total_quantity,

round(avg(cast([sales_amount] as float)/nullif([quantity],0)),1) as avg_selling_price

from 
cte_product

group by 
[product_key],
[category],
[subcategory],
[cost])

select 
[product_key],
[category],
[subcategory],
[cost],
last_sale_date,
total_sales,

DATEDIFF(MONTH,last_sale_date, GETDATE()) as recency_in_months,
case

when total_sales > 50000 then 'High-Performer'
when total_sales >= 50000 then 'Mid-range'
else 'Low-Performer'
end as product_segment,
lifespan,
total_orders,
total_products,
total_quantity,
avg_selling_price,
case
when total_orders = 0 then 0
else total_sales/total_orders
end as avg_order_revenue,
case
when lifespan = 0 then total_sales
else total_sales/lifespan
end as avg_monthly_revenue

from 
product_aggregation
