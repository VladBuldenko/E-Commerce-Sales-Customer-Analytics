-- TODO 
-- 7) Duplicate / weird “order” identifiers
-- 8) Customer ID format check (since it came as text like 17850.0)
-- 9) Top countries (quick business sanity)#
-- 10) Revenue sanity (quick check; not final KPI yet)

SELECT
  invoice_no,
  stock_code,
  description,
  quantity,
  invoice_date,
  unit_price,
  customer_id,
  country
FROM staging.raw_online_retail
Order by invoice_date DESC
LIMIT 20;

-- Create the copy of the origin table
CREATE TABLE staging.raw_online_retail_cleaned AS
SELECT *
FROM staging.raw_online_retail;
LIMIT 20;




-- 1. Preview all rows that have a NULL
SELECT
  invoice_no,
  stock_code,
  description,
  quantity,
  invoice_date,
  unit_price,
  customer_id,
  country
FROM staging.raw_online_retail_cleaned
WHERE invoice_no IS NULL
    OR stock_code IS NULL
    OR description IS NULL
    OR quantity IS NULL
    OR invoice_date IS NULL
    OR unit_price IS NULL
    OR customer_id IS NULL
    OR country IS NULL;

-- Remove the rows identified above.
DELETE FROM staging.raw_online_retail_cleaned
WHERE invoice_no IS NULL
    OR stock_code IS NULL
    OR description IS NULL
    OR quantity IS NULL
    OR invoice_date IS NULL
    OR unit_price IS NULL
    OR customer_id IS NULL
    OR country IS NULL;

-- 2. Identify item-level returns using negative quantities
-- Purpose: understand return volume and impact on revenue calculations
SELECT
  invoice_no,
  stock_code,
  description,
  quantity,
  invoice_date,
  unit_price,
  customer_id,
  country
FROM staging.raw_online_retail_cleaned
WHERE
    quantity < 0       
    OR unit_price < 0   
    OR unit_price = 0;

DELETE FROM staging.raw_online_retail_cleaned
WHERE quantity < 0       
    OR unit_price < 0   
    OR unit_price = 0;

SELECT count(*) from staging.raw_online_retail_cleaned;

-- Check Canceled invoices from the origin table
SELECT count(Distinct invoice_no) as cancelled_invoices
FROM staging.raw_online_retail
WHERE invoice_no like 'C%';

-- Check how many cancelled invoices exist in raw data
-- Purpose: identify invoice-level cancellations that must be excluded from revenue KPIs
SELECT count(Distinct invoice_no) as cancelled_invoices
FROM staging.raw_online_retail_cleaned
WHERE invoice_no like 'C%';

-- Validate quantity range to detect extreme or invalid values
-- Purpose: prevent outliers from distorting sales KPIs
SELECT MIN (quantity) as min_quantity,
        MAX (quantity) as max_quantity
FROM staging.raw_online_retail;

-- Validate unit price range for data quality issues
-- Purpose: ensure prices are realistic before calculating revenue
SELECT
    MIN(unit_price) AS min_unit_price,
    MAX(unit_price) AS max_unit_price
FROM staging.raw_online_retail;

-- Confirm invoice date range and correct timestamp parsing
-- Purpose: ensure time-based analysis (monthly KPIs) is reliable
SELECT
    MIN(invoice_date) AS earliest_invoice_date,
    MAX(invoice_date) AS latest_invoice_date
FROM staging.raw_online_retail;


-- TODO 
-- WHAT: Counts distinct invoice numbers
-- WHY: Confirms order-level granularity
-- Result: One number = total unique orders.
SELECT COUNT(Distinct invoice_no) as distinct_invoices
from staging.raw_online_retail;

-- WHAT: Counts rows per invoice
-- WHY: Detects unusually large or suspicious orders
-- RESULT: Invoices with the most line items
SELECT invoice_no, COUNT(*) as line_items
FROM staging.raw_online_retail
Group by invoice_no
Order by line_items DESC
LIMIT 20;

-- WHAT: Finds identical rows appearing multiple times
-- WHY: Duplicates inflate quantities and revenue
-- RESULT: Rows that should be deduplicated
SELECT invoice_no,
       stock_code,
       quantity,
       unit_price,
       invoice_date,
       customer_id,
       country,
       COUNT(*) as duplicate_rows
FROM staging.raw_online_retail
Group By invoice_no,
         stock_code,
         quantity,
         unit_price,
         invoice_date,
         customer_id,
         country
HAVING COUNT(*) > 1
Order By duplicate_rows DESC
Limit 20;

-- WHAT: Counts NULL or empty invoice numbers
-- WHY: Missing IDs break order modeling
-- RESULT: Number of problematic rows
SELECT sum (
  Case When invoice_no is null or invoice_no=''
  then 1
  else 0
  end
) as missing_invoice_no 
FROM staging.raw_online_retail;

-- WHAT: Separates cancellations from normal orders
-- WHY: Cancellations affect KPIs
-- RESULT: Count of normal vs cancelled invoices
SELECT Case 
        When invoice_no like 'C%' then 'canceletion'
        Else 'normal'
      End as invoice_type,
      COUNT(Distinct invoice_no) as invoices
FROM staging.raw_online_retail
Group By invoice_type
Order By invoices DESC;

-- WHAT: Classifies customer_id values into format-based categories.
-- WHY: To verify whether customer_id is safe for joins and numeric casting.
-- RESULT: Shows how many rows fall into each customer_id format category.
SELECT 
    CASE 
      WHEN customer_id IS NULL OR customer_id = '' THEN 'missing_or_empty'
      WHEN customer_id ~ '^[0-9]+$' THEN 'Whole Number'
      WHEN customer_id ~ '^[0-9]+\.[0-9]+$' THEN 'Decimal' -- Fixed: used \.
      WHEN customer_id ~ '[A-Za-z]' THEN 'Contains Letters'
      ELSE 'Special Characters/Other' 
    END AS customer_id_status,
    COUNT(*) AS record_count -- Added this to see the scale of the issue
FROM staging.raw_online_retail
GROUP BY customer_id_status
ORDER BY record_count DESC;

-- 9) Top countries (quick business sanity)#
SELECT country, count(*) as country_distribution
FROM staging.raw_online_retail
Group By country
Order By country_distribution DESC;

-- 10) Revenue sanity (quick check; not final KPI yet)
-- WHAT: Calculates raw revenue using quantity and price values.
-- WHY: Verifies that monetary calculations behave logically.
-- RESULT: Returns preliminary revenue figures for sanity validation.

-- Check total revenue, positive and begative revenue values
SELECT sum(quantity * unit_price) as total_revenue
FROM staging.raw_online_retail;

SELECT sum(quantity * unit_price) as negative_total_revenue
FROM staging.raw_online_retail
WHERE quantity < 0;

SELECT sum(quantity * unit_price) as revenue_without_returns
FROM staging.raw_online_retail
WHERE quantity > 0;

-- Check extreme single-line revenue values
SELECT 
    MAX(quantity * unit_price) as max_single_revenue,
    MIN(quantity * unit_price) as min_single_revenue
FROM staging.raw_online_retail;

-- Check for impossible prices
SELECT
    COUNT(*) AS rows_with_invalid_price
FROM staging.raw_online_retail
WHERE unit_price <= 0;

-- Revenue by time
SELECT invoice_date,
    sum(quantity * unit_price) as daily_revenue
FROM staging.raw_online_retail
GROUP BY invoice_date
ORDER BY invoice_date
Limit 20;


-- 11) Returns impact analysis
-- WHAT: Analyzes rows representing returns (e.g. negative quantities).
-- WHY: Understands how returns affect revenue and order counts.
-- RESULT: Shows the scale and impact of returned transactions.


-- whether returns are a rare exception or a frequent event.
SELECT
    COUNT(*) AS return_rows,
    (SELECT COUNT(*) FROM staging.raw_online_retail) AS total_rows
FROM staging.raw_online_retail
WHERE quantity < 0;

SELECT sum(quantity * unit_price) as negative_total_revenue
FROM staging.raw_online_retail
WHERE quantity < 0;

SELECT distinct invoice_no as unique_canceled_transaction
FROM staging.raw_online_retail
WHERE invoice_no like 'C%';

-- WHAT: Calculates the percentage of orders that contain at least one return line.
-- WHY: Shows how common returns are at the order level (penetration rate).
-- RESULT: One number = % of orders affected by returns.

-- Calculate return penetration
SELECT
    100.0 * COUNT(DISTINCT CASE WHEN quantity < 0 THEN invoice_no END)
          / COUNT(DISTINCT invoice_no) AS pct_orders_with_returns
FROM staging.raw_online_retail;

SELECT
    invoice_no,
    SUM(quantity * unit_price) AS return_revenue
FROM staging.raw_online_retail
WHERE quantity < 0
GROUP BY invoice_no
ORDER BY return_revenue ASC
LIMIT 20;

SELECT
    stock_code,
    description,
    SUM(quantity) AS total_return_qty
FROM staging.raw_online_retail
WHERE quantity < 0
GROUP BY stock_code, description
ORDER BY total_return_qty ASC
LIMIT 20;

-- 12) Cancellation analysis
-- WHAT: Separates cancelled entities from normal ones.
-- WHY: Prevents cancelled transactions from polluting KPIs.
-- RESULT: Returns counts of cancelled versus completed entities.

-- 13) Cleaning rule definition
-- WHAT: Defines explicit data cleaning and transformation rules.
-- WHY: Ensures cleaning decisions are consistent and explainable.
-- RESULT: A documented set of rules applied in the clean layer.

-- 14) Post-cleaning validation
-- WHAT: Re-validates data after cleaning and transformations.
-- WHY: Confirms no critical data was lost or corrupted.
-- RESULT: Clean dataset verified for analytical use.

-- 15) Ready for analysis / BI
-- WHAT: Confirms the dataset is analysis- and BI-ready.
-- WHY: Ensures KPIs and dashboards are built on trusted data.
-- RESULT: Clean, validated data ready for reporting.