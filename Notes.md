# Project Notes – European Online Retail Analytics (PostgreSQL + Power BI)

These are my personal notes about the project, PostgreSQL, and all related concepts.  
This file is for ME (not for HR 😄) – to remember what I’m doing and why.

---

## 1. Project Overview

**Project name:**  
European Online Retail Analytics (PostgreSQL + Power BI)

**Goal:**  
Build a realistic data analytics project using a European e-commerce dataset.  
I will:

- Design a relational database in **PostgreSQL**
- Load and transform real transaction data
- Write **SQL queries** to analyze sales and customer behavior
- Build an **interactive Power BI dashboard**
- Document everything in GitHub for recruiters (especially in Germany)

**Why this is good for job hunting in Germany:**

- Uses **real e-commerce data**, relevant for retail, e-commerce, logistics, fintech
- Uses **PostgreSQL**, which is very common in European tech/startup companies
- Uses **SQL + BI**, a typical skill combo for Data Analyst / BI roles
- Shows end-to-end skills: from raw data → database → analysis → dashboard

---

## 2. Dataset

**Dataset:** Online Retail (UCI / Kaggle version – European online store)

Typical columns (one big CSV):

- `InvoiceNo` – invoice / order ID
- `StockCode` – product ID
- `Description` – product name
- `Quantity` – number of units
- `InvoiceDate` – date and time of transaction
- `UnitPrice` – price per unit
- `CustomerID` – customer identifier
- `Country` – customer country (UK + EU countries)

**Important notes:**

- Raw dataset is **flat** (one huge table).
- I will **normalize it** into multiple relational tables:
  - `orders`
  - `order_items`
  - `customers`
  - `products`
- This shows real **data modeling & SQL skills**, not just playing with one CSV.

**File location in project:**

```text
data/raw/OnlineRetail.csv

3. Tech Stack

Database: PostgreSQL (local, via Postgres.app on macOS)

SQL Client:

psql in terminal

possibly VS Code PostgreSQL extension

BI Tool: Power BI (on Windows) – will connect to PostgreSQL

Code Editor: VS Code

Version control: Git + GitHub

(Optional) Python + Jupyter for quick exploration

4. Project File Structure

Project root (example):

European-Online-Retail-Analytics/
│
├── data/
│   ├── raw/
│   │   └── OnlineRetail.csv
│   ├── interim/
│   └── processed/
│
├── sql/
│   ├── 01_create_schema.sql
│   ├── 02_create_tables.sql
│   ├── 03_load_data.sql
│   ├── 04_data_cleaning.sql
│   ├── 05_transform_normalized.sql
│   ├── 06_analysis_queries.sql
│   └── 07_views_and_kpis.sql
│
├── database/
│   ├── schema_diagram.png
│   ├── data_dictionary.xlsx
│   └── metadata.md
│
├── powerbi/
│   ├── European_Retail_Dashboard.pbix
│   └── dashboard_screenshots/
│
├── docs/
│   ├── project_notes.md   <-- THIS FILE
│   ├── project_overview.md
│   ├── sql_explained.md
│   └── dashboard_storytelling.md
│
├── notebooks/ (optional)
├── README.md
└── .gitignore

5. PostgreSQL – Core Concepts (for my brain)
5.1 Hierarchy

Server – PostgreSQL instance (like a building)

Database – one project or application (like a company in the building)

Schema – logical folder/namespace inside database (like a department)

Table – like an Excel sheet in that department

Row – one record (one order, one customer)

Column – a field/attribute (order_date, amount, etc.)

Full name of a table:

schema_name.table_name
e.g. mart.orders or staging.raw_transactions

5.2 What is a schema?

Schema = folder inside a database.

I will use schemas to separate layers:

staging – raw data (as it came from CSV)

mart – clean, modeled data ready for BI

Commands:

CREATE SCHEMA staging;
CREATE SCHEMA mart;


Example tables:

staging.raw_transactions

mart.orders

mart.order_items

mart.customers

mart.products

Why this is important (for interviews):

Shows I understand data warehouse layers (staging/core/mart).

Makes my project look like a real company’s data platform.

5.3 Creating the project database

Connect (once psql works):

psql -h localhost -p 5432 -d postgres


Create new database:

CREATE DATABASE retail_analytics;


Switch to it:

\c retail_analytics


Now all further tables/schemas will live inside retail_analytics.

6. Data Model for This Project
6.1 Logical tables

From OnlineRetail.csv → I will derive:

1) mart.orders

order_id (from InvoiceNo)

customer_id

invoice_date

country

2) mart.order_items

order_item_id (surrogate key, SERIAL)

order_id

product_id

quantity

unit_price

line_total = quantity * unit_price

3) mart.customers

customer_id

country

(later maybe: RFM scores, segments, etc.)

4) mart.products

product_id (StockCode)

description

6.2 Typical SQL to create these tables (conceptual)
CREATE TABLE mart.orders (
    order_id     VARCHAR(20) PRIMARY KEY,
    customer_id  VARCHAR(20),
    invoice_date TIMESTAMP,
    country      VARCHAR(50)
);

CREATE TABLE mart.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id      VARCHAR(20),
    product_id    VARCHAR(20),
    quantity      INT,
    unit_price    NUMERIC(10,2),
    line_total    NUMERIC(12,2)
);

CREATE TABLE mart.customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    country     VARCHAR(50)
);

CREATE TABLE mart.products (
    product_id   VARCHAR(20) PRIMARY KEY,
    description  TEXT
);


Later I’ll add constraints and indexes.

7. Workflow – Step by Step (for me)
Step 1 – Dataset

 Download ZIP from Kaggle

 Extract OnlineRetail.csv into data/raw/

Step 2 – PostgreSQL setup

 Install Postgres.app (macOS)

 Install command-line tools (psql)

 Test psql --version

 Connect: psql -h localhost -p 5432 -d postgres

 Create DB: CREATE DATABASE retail_analytics;

 Connect to DB: \c retail_analytics

Step 3 – Create schemas

 CREATE SCHEMA staging;

 CREATE SCHEMA mart;

Step 4 – Staging table & load raw CSV

 Create staging.raw_transactions table that matches CSV columns

 Use COPY to load data from data/raw/OnlineRetail.csv

Step 5 – Normalize data into mart tables

 Insert unique orders into mart.orders

 Insert unique customers into mart.customers

 Insert unique products into mart.products

 Insert item-level data into mart.order_items with line_total

Step 6 – Analysis SQL

Write queries for:

 Monthly revenue & order count

 Top countries by revenue (focus on DE / EU)

 Top products by revenue & quantity

 Average order value

 Customer metrics:

repeat customers vs one-time

 Returns (negative quantities)

Step 7 – Power BI

 Connect Power BI ↔ PostgreSQL

 Import mart.* tables

 Define relationships

 Create measures (Total Revenue, AOV, etc.)

 Build 3–4 report pages:

Overview

Products

Customers/Countries

Returns / anomalies

Step 8 – Documentation & GitHub

 Clean up README.md

 Add screenshots of Power BI dashboard

 Push to GitHub

 Maybe add short project summary for CV/LinkedIn

8. PostgreSQL – Interview-Oriented Notes
Concepts I should be able to explain:

What is PostgreSQL?

A relational database system (RDBMS) used to store & query structured data with SQL.

What is a schema?

A namespace / folder inside a database grouping tables, views, etc.

Why use schemas (staging, mart) for analytics?

To separate raw data from clean, modeled data.

To manage permissions.

To avoid name conflicts and keep structure clear.

What is a primary key?

A column (or set) that uniquely identifies each row and cannot be NULL.

What is a foreign key?

A column in one table that references a primary key in another table, enforcing relationships.

Difference: INNER JOIN vs LEFT JOIN

INNER: only matching rows in both tables.

LEFT: all rows from left table, plus matches if they exist (else NULLs).

Why normalize data?

Remove duplicates, ensure consistency, better structure.

For analytics, sometimes denormalize later (in marts or views) for performance.

What is a VIEW?

A saved SELECT query you can query like a table (doesn’t store data itself).

9. Ideas for Future Improvements

Add RFM analysis (Recency, Frequency, Monetary) for customers.

Calculate churn or customer lifetime value (CLV).

Add window functions (e.g., revenue by month vs previous month).

Experiment with materialized views for heavy aggregations.

Use Python to export some features to a ML model (optional).

10. My Personal Checklist / Progress

 PostgreSQL installed & psql works

 retail_analytics database created

 staging and mart schemas created

 Raw CSV table + data loaded

 Normalized tables created

 First successful analysis queries

 Power BI dashboard connected

 Screenshots + README updated

 Project pushed to GitHub

 Practice explaining project out loud (for interviews)