📊 Online Retail Sales Analysis - SQL Portfolio Project
A comprehensive SQL-based analysis of online retail transactions, uncovering revenue trends, product performance patterns, and customer behavior insights using advanced MySQL queries and window functions.

🎯 Project Overview
This project analyzes transactional data from an online retail store spanning December 2010 to January 2011, covering 1,054 customers across 38 countries with total revenue of £1.09 million. The analysis reveals critical business insights about geographic concentration, product performance disparities, and revenue trends.

📁 Dataset
> Source: Online Retail Transaction Data
> Time Period: December 2010 - January 2011
> Records: ~500K+ transactions
> Geography: 38 countries
> Key Fields: InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country

🔍 Analysis Components
--> Data Cleaning & Preparation : 
1. Created isolated copy of raw data following best practices
2. Handled mixed date formats (MM/DD/YYYY and DD-MM-YYYY)
3. Converted text-based dates to proper DATETIME format
4. Managed NULL values and data quality issues

--> Revenue Performance Analysis
1. Total revenue calculation
2. Year-over-Year (YoY) revenue growth
3. Month-over-Month (MoM) revenue trends
4. Revenue distribution by country/region
5. Geographic concentration analysis

---> Product Performance Analysis
1. Top-selling products (by quantity and revenue)
2. Underperforming products identification
3. Product performance by country
4. Unsold inventory analysis
5. Product return rate analysis
6. Revenue contribution percentage by product

--> Customer Behavior Analysis
1. Customer distribution by region
2. Average revenue per customer
3. Purchase frequency analysis
4. Top customers identification


🛠️ Technical Skills Demonstrated
SQL Techniques Used:
Window Functions: LAG(), LEAD(), RANK(), DENSE_RANK(), ROW_NUMBER()
Common Table Expressions (CTEs): Multi-level CTEs for complex analysis
Aggregate Functions: SUM(), COUNT(), AVG(), MIN(), MAX()
Date Functions: YEAR(), MONTH(), DATE_FORMAT(), STR_TO_DATE()
Conditional Logic: CASE WHEN statements for data categorization
Joins: CROSS JOIN for percentage calculations
Partitioning: PARTITION BY for grouped window operations
Data Quality: Handling NULL values, negative quantities, and edge cases

📈 Key Findings
Revenue Insights
🇬🇧 90.15% of revenue comes from the United Kingdom
📉 68% MoM decline from December 2010 to January 2011
🌍 37 countries represent untapped growth opportunities

Product Insights
🏆 Top 0.53% of products drive majority of sales
📦 25.63% of products are slow-movers
💰 Product 22423 alone generates 3.06% of total revenue
🔄 0.04% product return rate with Product 22617 being highest

Customer Insights
💵 Average revenue per customer: £1,034.32 (high-value customers)
👥 961 out of 1,054 customers (91%) are UK-based
🎯 Significant customer concentration risk

🚀 Business Recommendations
Immediate Actions:
Investigate Revenue Decline: Determine if 68% drop is seasonal or structural
Optimize Product Portfolio: Discontinue slow-movers, focus on proven performers
Quality Control: Address high returns for specific products (e.g., 22617)

Strategic Priorities:
Geographic Diversification: Reduce 90% UK dependency through international expansion
Inventory Management: Implement data-driven forecasting to reduce dead stock
Customer Segmentation: Leverage high AOV (£1,034) with targeted retention programs


Database: MySQL 8.0+
SQL Concepts: Window Functions, CTEs, Subqueries, Joins
Analysis: Descriptive Statistics, Trend Analysis, Performance Metrics

💡 Learning Outcomes
Through this project, I demonstrated:
✅ Advanced SQL query optimization techniques
✅ Business acumen in retail analytics
✅ Data storytelling and insight generation
✅ Best practices in data cleaning and preparation
✅ Strategic thinking for business recommendations

🎓 Use Cases
This analysis framework can be applied to:
E-commerce performance monitoring
Inventory optimization
Customer segmentation
Market expansion strategy
Product portfolio management

📞 Connect With Me
LinkedIn: https://www.linkedin.com/in/navaneethan18/
Email: navaneethan1810@gmail.com
