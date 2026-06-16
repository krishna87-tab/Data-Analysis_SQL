# sales-customer-product-bi-analysis-sql

Advanced Analytical SQL for Sales, Customers & Product Performance

## Project Overview

This project focuses on analyzing sales, customer, and product performance using SQL Server.  
The goal is to transform raw sales data into meaningful business insights through SQL queries, 
aggregations, joins, CTEs, window functions, and segmentation logic.

## Tools Used

- SQL Server
- SQL Server Management Studio
- T-SQL
- Business Intelligence Concepts

## Business Objecttive Flowchart

![Alt text](https://github.com/krishna87-tab/Data-Analysis_SQL/blob/4d102692de9bd70f309bd530cada9bc95a927d7b/BPF.png)

It covers:

Time-series analysis

Cumulative and moving averages

Performance benchmarking

YoY comparisons

Segmentation

Customer lifetime value behaviors

Product profitability & lifecycle

This project reflects real-world BI responsibilities across Finance, Sales, and Operations analytics.

## Business Narrative

A retail e-commerce company wants a unified BI solution to:

Track performance across categories, products, and customers

Identify profitable vs underperforming segments

Understand growth, decline, and seasonality trends

Build monthly and annual KPIs

Segment customers for targeted marketing

Improve inventory, pricing, and promotion strategies

The SQL solution below enables leadership to answer questions such as:

Which months show the highest sales? Are we seasonal?

Which customers are VIP, Regular, or New?

Which product categories drive most revenue?

Which products are declining in performance?

How much revenue comes from each customer segment?

Are we improving YoY, or declining?

These insights feed BI dashboards (Power BI, Fabric Warehouse, etc.) for decision-making.

Data Sources
Fact Table

gold.fact_sales
Contains sales transactions, dates, amounts, quantities, and customer/product keys.

Dimension Tables

gold.dim_products
Product metadata, pricing, categories, cost.

gold.dim_customers
Customer demographics, birthdates, customer IDs.

## Project Components
## Key Analysis Performed

### 1. Change Over Time Analysis

Analyzed monthly sales trends to understand how revenue, customer count, and quantity sold changed over time.

Key metrics:

- Total sales
- Total customers
- Total quantity sold
- Monthly sales trend

---

### 2. Cumulative Sales Analysis

Calculated running total sales and moving averages to understand long-term sales growth patterns.

Key metrics:

- Monthly sales
- Running total sales
- Moving average price or sales

---

### 3. Product Performance Analysis

Compared yearly product sales against each product’s average sales performance and previous year sales.

Key techniques used:

- CTEs
- Window functions
- `AVG() OVER()`
- `LAG() OVER()`
- Year-over-year comparison
- Performance classification

---

### 4. Year-over-Year Analysis

Measured product sales changes compared to the previous year.

Products were classified as:

- Increasing Sales
- Decreasing Sales
- No Change

---

### 5. Part-to-Whole Analysis

Calculated each product category’s contribution to total sales.

Key metrics:

- Category sales
- Overall sales
- Percentage contribution to total sales

This helps identify which categories generate the highest revenue share.

---

### 6. Product Cost Segmentation

Segmented products into cost ranges to understand product distribution across pricing tiers.

Segments include:

- Below 100
- 100-499
- 500-999
- 1000 and Above

---

### 7. Customer Segmentation

Grouped customers based on spending behavior and customer lifespan.

Customer segments:

- VIP: Customers with at least 12 months of history and spending above 5000
- Regular: Customers with at least 12 months of history and spending 5000 or less
- New: Customers with less than 12 months of history

---

### 8. Customer Report

Created a customer-level report that consolidates customer demographics and purchasing behavior.

Included metrics:

- Customer name
- Age group
- Customer segment
- Last order date
- Recency in months
- Total orders
- Total sales
- Total quantity purchased
- Total products purchased
- Average order value
- Average monthly spend

---

### 9. Product Report

Created a product-level report to evaluate product performance and revenue behavior.

Included metrics:

- Product name
- Category
- Subcategory
- Cost
- Last sale date
- Recency in months
- Product segment
- Total sales
- Total orders
- Total quantity sold
- Average selling price
- Average order revenue
- Average monthly revenue

Product segments:

- High Performer
- Mid Range
- Low Performer

## SQL Concepts Used

This project demonstrates the following SQL skills:

- Joins
- Common Table Expressions
- Aggregations
- Window functions
- LAG()
- AVG() OVER()
- SUM() OVER()
- CASE statements
- Date functions
- Customer segmentation
- Product segmentation
- Year-over-year analysis
- Running totals
- Part-to-whole analysis
- Business reporting logic


## Business Value

This project simulates real-world business intelligence reporting by converting transactional sales data into useful insights for decision-making.

The analysis can help stakeholders:

- Monitor sales trends
- Identify high-performing products
- Understand customer behavior
- Track revenue growth
- Find declining product performance
- Segment customers for targeted business strategies
- Measure product and category contribution to revenue

## Project Outcome

The final output includes a set of SQL queries and analytical reports that can support dashboard development in tools such as Power BI, Tableau, or Excel.

This project demonstrates the ability to use SQL for business analysis, reporting, and performance tracking.

Krishna Kamal Gogoi 

Business Operations Analyst

Power BI || SQL Server || DAX || dbt || Snowflake || Google Big Query || Microsoft Fabric 
