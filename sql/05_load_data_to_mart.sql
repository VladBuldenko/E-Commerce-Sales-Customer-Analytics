/* =============================================================================
DESCRIPTION: Populate the Star Schema tables from the staging layer.
WHY: To fix data integrity issues (NULLs and duplicates) found during stress tests.
LOGIC: 
    1. Clear old data.
    2. Load Dimensions using DISTINCT ON to fix 647 duplicate codes.
    3. Load Fact Table using COALESCE to fix 135,080 missing customers.
=============================================================================
*/

-- 1. Populate Product Dimension
-- WHY: DISTINCT ON ensures "One Stock Code = One Product Key", fixing the 647 duplicates.
INSERT INTO mart.dim_products (stock_code, description)
SELECT DISTINCT ON (TRIM(stock_code)) 
    TRIM(stock_code), 
    TRIM(description)
FROM staging.raw_online_retail
WHERE stock_code IS NOT NULL 
ORDER BY TRIM(stock_code), description DESC;

-- 2. Populate Customer Dimension
-- WHY: We add record 0 to capture those 135,080 "anonymous" sales.
INSERT INTO mart.dim_customers (customer_key, customer_id, country)
VALUES (0, 'Unknown', 'N/A');

INSERT INTO mart.dim_customers (customer_id, country)
SELECT customer_id, MIN(country) 
FROM staging.raw_online_retail
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

-- 3. Populate Sales Fact Table
-- WHY: Joining by stock_code ONLY is safer. 
--      COALESCE ensures that those 135,080 rows map to our "Unknown" record instead of being NULL.
INSERT INTO mart.fct_sales (date_id, product_key, customer_key, invoice_no, quantity, unit_price)
SELECT 
    stg.invoice_date,
    p.product_key,
    COALESCE(c.customer_key, 0) AS customer_key,
    stg.invoice_no,
    stg.quantity,
    stg.unit_price
FROM staging.raw_online_retail stg
-- Join products ONLY by stock_code to avoid mismatches in descriptions
LEFT JOIN mart.dim_products p 
    ON TRIM(stg.stock_code) = p.stock_code
LEFT JOIN mart.dim_customers c 
    ON stg.customer_id = c.customer_id;