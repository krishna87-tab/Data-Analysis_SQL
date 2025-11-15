Holistic Business Intelligence Using SQL

Advanced Analytical SQL for Sales, Customers & Product Performance

📌 1. Project Overview

This project demonstrates an end-to-end SQL-based analytics solution designed to support business decision-making across Sales, Customers, and Product performance. The goal is to simulate how a BI Analyst uses SQL to build insights for dashboards, KPIs, and executive reporting.
![Alt text]()
It covers:

Time-series analysis

Cumulative and moving averages

Performance benchmarking

YoY comparisons

Segmentation

Customer lifetime value behaviors

Product profitability & lifecycle

This project reflects real-world BI responsibilities across Finance, Sales, and Operations analytics.

🏢 2. Business Narrative

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

🗂️ 3. Data Sources
Fact Table

gold.fact_sales
Contains sales transactions, dates, amounts, quantities, and customer/product keys.

Dimension Tables

gold.dim_products
Product metadata, pricing, categories, cost.

gold.dim_customers
Customer demographics, birthdates, customer IDs.

🧱 4. Project Components
A. Change Over Time (Trend Analysis)

Purpose:
✔ Understand how revenue evolves month-over-month
✔ Identify seasonality
✔ Track customer & quantity trends

Key outputs:

Monthly sales

Year & month level KPIs

Number of active customers

Product quantity trends

Used for: trend dashboards, forecasting, and executive views

B. Cumulative & Moving Averages Analysis

Purpose:
✔ Create cumulative sales (running total)
✔ Calculate moving average (avg price over time)
✔ Support smoothing of volatility

Used for:

Rolling KPIs

Finance dashboards

Growth tracking

C. Performance Analysis (Benchmarking & YoY)

Purpose:
✔ Compare product performance vs:

Their own past performance (YoY)

Average performance of similar products
✔ Classify products as Above Average / Below Average
✔ Identify improving or declining categories

Used for: strategy, pricing, assortment planning

D. Part-to-Whole Analysis (Category Contribution)

Purpose:
✔ Determine which categories drive most revenue
✔ Calculate % contribution
✔ Helps in strategic investment decisions

Used for: Pareto analysis, category dashboards

E. Product Segmentation (Price-Based)

Purpose:
✔ Group products into cost bands
✔ Identify inventory mix (cheap, mid-range, premium)
✔ Useful for pricing strategy

F. Customer Segmentation (VIP | Regular | New)

Purpose:
✔ Classify customers based on:

Spending

Lifespan
✔ Build cohorts for targeted marketing

VIP: >12 months & >$5,000 spend
Regular: >12 months & <$5,000
New: <12 months

Used for:

Retention dashboards

Marketing campaigns

Customer journey analytics

G. Customer Report (Demographics + Behavior)

Purpose:
✔ Build a consolidated customer view
✔ Age groups
✔ Recency metric
✔ Purchase frequency
✔ Average Order Value (AOV)
✔ Monthly spend

Used for: 360° customer insights dashboard

H. Product Report (Lifecycle & Profitability)

Purpose:
✔ Product-level KPI summary
✔ Sales recency
✔ Avg selling price
✔ Revenue and quantity
✔ High / mid / low performer classification

Used for: product management, merchandising, supply chain

🎯 5. Key Business Insights Enabled

This SQL system allows the business to:

✔ Identify high-growth and declining product segments
✔ Quantify customer value & run loyalty strategies
✔ Build retention and reactivation strategies
✔ Spot seasonal revenue patterns
✔ Improve pricing and discount execution
✔ Optimize inventory based on product performance
✔ Track revenue composition across categories
✔ Support Power BI dashboards with robust, cleaned data

This is exactly the type of analysis BI teams deliver in real companies.

🛠️ 6. Technical Highlights
✔ Window functions

LAG()

OVER(PARTITION BY…)

SUM() OVER

AVG() OVER

✔ CTE Layering

Used for clean logic separation:

Base queries

Segmentation

Ranking

Aggregations

✔ Date-based functions

DATETRUNC()

DATEDIFF()

YEAR()

MONTH()

✔ Classifications

Case expressions

Threshold-based segmentation

📊 7. How This Project Fits BI Workflows

This SQL foundation supports:

Power BI dashboards

Fabric Lakehouse → Warehouse transformation

DAX measures

KPI modelling

Data modelling in star schema

Medallion architecture pipelines

You can mention in interviews:

##Personal Note “I designed SQL logic that feeds the semantic model for dashboards, including trend, segmentation, and performance insights.”

⭐⭐ Author

Krishna Kamal Gogoi
Business Intelligence Analyst
Power BI • SQL • DAX • Microsoft Fabric
