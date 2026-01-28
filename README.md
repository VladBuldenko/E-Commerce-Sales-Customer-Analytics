📊 E-Commerce Sales & Customer Analytics (PostgreSQL + Power BI)
📌 Project Overview

https://www.kaggle.com/datasets/ulrikthygepedersen/online-retail-dataset

This project demonstrates an end-to-end data analytics workflow using a realistic European e-commerce dataset.
The goal is to show how raw transactional data can be ingested, validated, transformed, and prepared for business analysis and visualization.

The project is designed as a portfolio case study for Data Analyst roles and focuses on:

SQL (PostgreSQL)

data quality checks

analytical data modeling

preparation for BI tools (Power BI)

🎯 Business Scenario

A European e-commerce company wants to understand:

sales performance over time

customer purchasing behavior

product demand

returns and cancellations

geographic distribution of sales

Raw transaction data is delivered as a CSV export from an operational system.
As a Data Analyst, my task is to ingest the data into a database, validate it, and prepare clean analytical tables that can be used for reporting and dashboards.

🗂 Dataset

Source: Public “Online Retail” dataset (European transactions)
Time period: 2010–2011
Granularity: Invoice line items
Volume: ~541,000 rows

Key fields include:

Invoice number

Product code and description

Quantity

Invoice timestamp

Unit price

Customer ID

Country

The dataset contains real-world issues such as:

missing customer IDs

negative quantities (returns)

cancellations (invoice numbers starting with C)

inconsistent numeric formatting

🏗 Project Structure
E-Commerce-Sales-Customer-Analytics/
│
├── data/
│   ├── raw/            # Original CSV dataset (unchanged)
│   ├── interim/        # Reserved for intermediate data (future)
│   └── processed/      # Reserved for cleaned data (future)
│
├── sql/
│   ├── 01_create_schema.sql
│   ├── 02_create_staging_table.sql
│   ├── 03_sanity_checks.sql
│   └── 04_transformations.sql   # (planned)
│
├── notebooks/          # Optional exploratory analysis
│
├── visualisation/      # Power BI files (planned)
│
├── README.md
├── Notes.md            # Personal learning notes
├── requirements.txt
└── .gitignore

🧱 Database Design
🔹 Database

PostgreSQL

🔹 Schemas

staging — raw data ingestion

mart — clean analytical tables (planned)

📥 Data Ingestion (Staging Layer)

Raw CSV data is loaded into a staging table:

staging.raw_online_retail

Design principles:

mirrors the CSV structure 1:1

flexible data types to accept dirty data

no primary keys or constraints

safe re-loading using TRUNCATE + COPY

This approach reflects real ETL pipelines used in production systems.

✅ Data Validation & Sanity Checks

After loading, several checks are performed:

row count validation (detect duplicate loads)

preview of sample rows

NULL analysis of key fields

date range validation

detection of returns (negative quantities)

detection of cancellations (invoice_no LIKE 'C%')

basic distribution checks for prices and quantities

These checks ensure data correctness before building analytical models.

🧠 Analytical Modeling (Mart Layer – Planned)

The next step is transforming raw data into business-ready tables:

Planned tables:

mart.orders — one row per invoice

mart.order_items — one row per product per invoice

mart.customers — unique customers

mart.products — unique products

This star-schema-like model supports efficient BI queries and Power BI dashboards.

📊 Visualization (Power BI – Planned)

Planned dashboards include:

monthly sales and revenue trends

top products and categories

customer repeat behavior

geographic sales distribution

impact of returns and cancellations

🛠 Tools & Technologies

PostgreSQL — relational database

SQL — data ingestion, validation, transformation

VS Code — development environment

Power BI — data visualization (planned)

Git & GitHub — version control

👤 Author
Vladyslav Buldenko

📊 E-Commerce Sales & Customer Analytics

(PostgreSQL + Power BI)

📌 Project Overview

This project demonstrates an end-to-end data analytics workflow using a realistic European e-commerce transactional dataset.

The goal is to show how raw operational data can be:

ingested into a relational database

validated through structured data quality checks

transformed into analytical-ready tables

prepared for business reporting and visualization

The project is designed as a portfolio case study for Data Analyst roles, with a strong focus on:

SQL (PostgreSQL)

data quality & EDA

analytical data modeling

preparation for BI tools (Power BI)

🎯 Business Scenario

A European e-commerce company wants to better understand:

sales performance over time

customer purchasing behavior

product demand patterns

the impact of returns and cancellations

geographic distribution of sales

Raw transaction data is delivered as a CSV export from an operational system.

As a Data Analyst, my responsibility is to:

ingest the data into a database

validate and explore data quality issues

define cleaning and transformation rules

prepare analytical tables for dashboards and KPIs

🧠 Business Questions & Hypotheses

After completing initial EDA and data validation, the analysis is driven by business-oriented hypotheses.

These hypotheses define what questions the dashboards are intended to answer.

Core Business Hypotheses

Sales are concentrated in a small number of countries

Question: Which countries generate the majority of sales and revenue?

A small number of products drive most of the revenue

Question: Do top products or categories follow an 80/20 pattern?

Large orders have a disproportionate impact on revenue

Question: How much revenue comes from bulk or high-line-item orders?

Returns and cancellations significantly reduce net revenue

Question: What is the revenue impact of returns and cancelled invoices?

Sales show clear seasonality over time

Question: Are there monthly or seasonal peaks in sales activity?

Repeat customers generate higher lifetime value

Question: Do returning customers place more or higher-value orders?

Each hypothesis maps directly to:

SQL queries in the analytical layer

metrics used in Power BI

specific dashboard visualizations

🗂 Dataset

Source: Public Online Retail dataset (European transactions)
Time period: 2010–2011
Granularity: Invoice line items
Volume: ~541,000 rows

Key fields

Invoice number

Product code and description

Quantity

Invoice timestamp

Unit price

Customer ID

Country

Real-world data issues present

missing customer IDs

negative quantities (returns)

cancellations (invoice numbers starting with C)

inconsistent numeric formatting

🏗 Project Structure
E-Commerce-Sales-Customer-Analytics/
│
├── data/
│   ├── raw/            # Original CSV dataset (unchanged)
│   ├── interim/        # Reserved for intermediate data (future)
│   └── processed/      # Reserved for cleaned data (future)
│
├── sql/
│   ├── 01_create_schema.sql
│   ├── 02_create_staging_table.sql
│   ├── 03_sanity_checks.sql
│   └── 04_transformations.sql   # (planned)
│
├── notebooks/          # Optional exploratory analysis
│
├── visualisation/      # Power BI files (planned)
│
├── README.md
├── Notes.md            # Personal learning notes
├── requirements.txt
└── .gitignore

🧱 Database Design
🔹 Database

PostgreSQL

🔹 Schemas

staging — raw data ingestion

mart — clean analytical tables (planned)

📥 Data Ingestion (Staging Layer)

Raw CSV data is loaded into:

staging.raw_online_retail

Design principles

mirrors the CSV structure 1:1

flexible data types to accept dirty data

no primary keys or constraints

safe re-loading using TRUNCATE + COPY

This approach reflects real ETL pipelines used in production systems.

✅ Data Validation & Sanity Checks

- After ingestion, structured EDA checks are performed:
- row count validation (detect duplicate loads)
- preview of sample rows
- NULL analysis of key fields
- date range validation
- detection of returns (negative quantities)
- detection of cancellations (invoice_no LIKE 'C%')
- distribution checks for prices, quantities, and countries

🧠 Analytical Modeling (Mart Layer – Planned)

Raw data is transformed into business-ready analytical tables.

Planned tables:

- mart.orders — one row per invoice
- mart.order_items — one row per product per invoice
- mart.customers — unique customers
- mart.products — unique products
- This star-schema-like structure supports:
- efficient SQL analytics
- scalable BI queries
- Power BI dashboards

📊 Visualization (Power BI – Planned)

Planned dashboards include:

- Monthly sales & revenue trends
- Top products and categories
- Repeat vs one-time customer behavior
- Geographic sales distribution
- Impact of returns and cancellations
- Each dashboard ties back to the business hypotheses defined above.

🛠 Tools & Technologies

- PostgreSQL — relational database
- SQL — ingestion, validation, transformation
- VS Code — development environment
- Power BI — data visualization
- Git & GitHub — version control

👤 Author
Vladyslav Buldenko