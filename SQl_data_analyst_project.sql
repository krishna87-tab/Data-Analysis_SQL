
-- Monthly sales trend analysis.
-- Tracks revenue, customer count, order quantity, and month-over-month sales growth.

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
    ROUND(100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY order_month)) / NULLIF(LAG(total_sales) OVER (ORDER BY order_month), 0),2)
    AS monthly_growth_percentage
    
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

-- Product performance analysis
-- Compares yearly product sales against average sales and previous-year sales

WITH yearly_product_sales AS (
    SELECT
        YEAR(fs.order_date) AS order_year,
        dp.product_name,
        SUM(fs.sales_amount) AS current_sales
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products AS dp
        ON fs.product_key = dp.product_key
    WHERE fs.order_date IS NOT NULL
    GROUP BY
        YEAR(fs.order_date),
        dp.product_name
)

SELECT
    order_year,
    product_name,
    current_sales,

    AVG(current_sales) OVER ( PARTITION BY product_name ) AS avg_sales,

    current_sales - AVG(current_sales) OVER ( PARTITION BY product_name ) AS diff_from_avg,

    CASE
    
    WHEN current_sales > AVG(current_sales) OVER ( PARTITION BY product_name )
    THEN 'Above Average'
    
    WHEN current_sales < AVG(current_sales) OVER ( PARTITION BY product_name )
    THEN 'Below Average'
    
    ELSE 'Average'
    END AS avg_performance,

    LAG(current_sales) OVER ( PARTITION BY product_name ORDER BY order_year ) AS previous_year_sales,

    current_sales - LAG(current_sales) OVER ( PARTITION BY product_name ORDER BY order_year ) AS diff_from_previous_year,

    CASE
    
    WHEN current_sales > LAG(current_sales) OVER ( PARTITION BY product_name ORDER BY order_year )
    THEN 'Increasing Sales'
    
    WHEN current_sales < LAG(current_sales) OVER ( PARTITION BY product_name ORDER BY order_year )
    THEN 'Decreasing Sales'
    
    ELSE 'No Change'
    END AS sales_change
    
FROM yearly_product_sales
ORDER BY
    product_name,
    order_year;

-- Part-to-whole analysis
-- Calculates each product category's contribution to total sales

WITH category_sales AS (
    SELECT
        COALESCE(dp.category, 'Unknown') AS category,
        SUM(fs.sales_amount) AS total_sales
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products AS dp
        ON fs.product_key = dp.product_key
    WHERE fs.order_date IS NOT NULL
    GROUP BY COALESCE(dp.category, 'Unknown')
)

SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_total_sales,
    ROUND( 100.0 * total_sales / NULLIF(SUM(total_sales) OVER (), 0),2) AS percentage_of_total_sales
    
FROM category_sales
ORDER BY total_sales DESC;

-- Product cost segmentation
-- Segments products into cost ranges and calculates product distribution

WITH product_segments AS (
    SELECT
        product_key, product_name, cost,
        CASE
            WHEN cost IS NULL THEN 'Unknown'
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost >= 100 AND cost < 500 THEN '100-499'
            WHEN cost >= 500 AND cost < 1000 THEN '500-999'
            ELSE '1000 and Above'
        END AS cost_range,
        CASE
            WHEN cost IS NULL THEN 5
            WHEN cost < 100 THEN 1
            WHEN cost >= 100 AND cost < 500 THEN 2
            WHEN cost >= 500 AND cost < 1000 THEN 3
            ELSE 4
        END AS sort_order
    FROM gold.dim_products
)

SELECT
    cost_range,
    COUNT(product_key) AS total_products,
    ROUND( 100.0 * COUNT(product_key) / SUM(COUNT(product_key)) OVER (),2 ) AS percentage_of_products
FROM product_segments
GROUP BY
    cost_range,
    sort_order
ORDER BY sort_order;

-- Customer segmentation analysis
-- Groups customers by lifespan and total spending behavior

WITH customer_spending AS (
    SELECT
        customer_key,
        SUM(sales_amount) AS total_spent,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_months
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY customer_key
),

customer_segments AS (
    SELECT 
    customer_key, total_spent, lifespan_months,
    CASE
    WHEN lifespan_months >= 12 AND total_spent > 5000 THEN 'VIP'
    WHEN lifespan_months >= 12 AND total_spent <= 5000 THEN 'Regular'
    ELSE 'New'
    END AS customer_segment
    
    FROM customer_spending
)

SELECT
    customer_segment,
    COUNT(DISTINCT customer_key) AS total_customers,
    ROUND( 100.0 * COUNT(DISTINCT customer_key) / SUM(COUNT(DISTINCT customer_key)) OVER (), 2 ) AS percentage_of_customers
    
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- Customer report
-- Consolidates key customer demographics, purchase behavior, and value metrics

WITH base_query AS (
    SELECT
        fs.order_number,
        fs.product_key,
        fs.order_date,
        fs.sales_amount,
        fs.quantity,
        dc.customer_key,
        dc.customer_number,
        DATEDIFF(YEAR, dc.birthdate, GETDATE()) AS age,
        CONCAT(dc.first_name, ' ', dc.last_name) AS customer_name
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_customers AS dc
        ON fs.customer_key = dc.customer_key
    WHERE fs.order_date IS NOT NULL
),

customer_summary AS (
    SELECT
        customer_key,
        customer_number,
        age,
        customer_name,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_months
    FROM base_query
    GROUP BY
        customer_key,
        customer_number,
        age,
        customer_name
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,

    CASE
        WHEN lifespan_months >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan_months >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_months,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan_months,

    CASE
        WHEN total_orders = 0 THEN 0
        ELSE ROUND(1.0 * total_sales / total_orders, 2)
    END AS avg_order_value,

    CASE
        WHEN lifespan_months = 0 THEN total_sales
        ELSE ROUND(1.0 * total_sales / lifespan_months, 2)
    END AS avg_monthly_spend
FROM customer_summary;

-- Product report
-- Consolidates key product performance metrics and revenue behavior

WITH product_base AS (
    SELECT
        fs.order_number,
        fs.product_key,
        fs.order_date,
        fs.sales_amount,
        fs.quantity,
        dp.cost,
        dp.category,
        dp.subcategory,
        dp.product_number,
        dp.product_name
    FROM gold.fact_sales AS fs
    LEFT JOIN gold.dim_products AS dp
        ON fs.product_key = dp.product_key
    WHERE fs.order_date IS NOT NULL
),

product_summary AS (
    SELECT
        product_key,
        product_number,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_months,
        COUNT(DISTINCT order_number) AS total_orders,
        MAX(order_date) AS last_sale_date,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND( AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 2 ) AS avg_selling_price
    
    FROM product_base
    GROUP BY
        product_key, product_number,
        product_name, category,
        subcategory, cost
)

SELECT
    product_key,
    product_number,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_months,
    total_sales,

    CASE
        WHEN total_sales > 50000 THEN 'High Performer'
        WHEN total_sales >= 10000 THEN 'Mid Range'
        ELSE 'Low Performer'
    END AS product_segment,

    lifespan_months,
    total_orders,
    total_quantity,
    avg_selling_price,

    CASE
        WHEN total_orders = 0 THEN 0
        ELSE ROUND(1.0 * total_sales / total_orders, 2)
    END AS avg_order_revenue,

    CASE
        WHEN lifespan_months = 0 THEN total_sales
        ELSE ROUND(1.0 * total_sales / lifespan_months, 2)
    END AS avg_monthly_revenue
FROM product_summary
ORDER BY total_sales DESC;
