/* =============================================================================
DESCRIPTION: Final Analytics and Data Validation.
WHY: To ensure the Star Schema is accurate and provide business insights.
=============================================================================
*/

/* ---------------------------------------------------------------------------
1) Integrity Validation (Row Counts)
WHY: Verify that no sales transactions were lost during the JOIN process.
EXPECTATION: Difference should be 0.
--------------------------------------------------------------------------- */
SELECT  
   (SELECT count(*) FROM staging.raw_online_retail) AS source_count,
   (SELECT count(*) FROM mart.fct_sales) AS mart_count,
   (SELECT count(*) FROM staging.raw_online_retail) - (SELECT count(*) FROM mart.fct_sales) AS difference;

/* ---------------------------------------------------------------------------
2) Revenue Validation
WHY: Ensure that the total monetary value remains consistent.
EXPECTATION: Revenue difference should be 0.
--------------------------------------------------------------------------- */
WITH revenue_calc AS (
    SELECT 
        (SELECT SUM(quantity * unit_price) FROM staging.raw_online_retail) AS source_revenue,
        (SELECT SUM(quantity * unit_price) FROM mart.fct_sales) AS mart_revenue
)
SELECT 
    source_revenue,
    mart_revenue,
    ROUND((source_revenue - mart_revenue)::numeric, 2) AS revenue_diff
FROM revenue_calc;

/* ---------------------------------------------------------------------------
3) Data Quality Check (NULL Keys)
WHY: Ensure that our COALESCE logic in step 05 worked. 
EXPECTATION: Both should be 0 now (because we use customer_key = 0 for Unknown).
--------------------------------------------------------------------------- */
SELECT 
    count(*) FILTER (WHERE product_key IS NULL) AS null_product_key,
    count(*) FILTER (WHERE customer_key IS NULL) AS null_customer_key
FROM mart.fct_sales;

/* ---------------------------------------------------------------------------
4) Create Analytical View
WHY: A flattened reporting layer for BI tools (like Power BI).
--------------------------------------------------------------------------- */
CREATE OR REPLACE VIEW mart.v_sales_performance AS
SELECT 
    fct.invoice_no,
    fct.date_id AS sale_date,
    fct.quantity,
    fct.unit_price AS unit_price_gbp,
    prd.description AS product_name,
    cts.country,
    ROUND((fct.quantity * fct.unit_price)::numeric, 2) AS total_revenue_gbp
FROM mart.fct_sales AS fct
LEFT JOIN mart.dim_products AS prd ON fct.product_key = prd.product_key
LEFT JOIN mart.dim_customers AS cts ON fct.customer_key = cts.customer_key;

/* ---------------------------------------------------------------------------
5) Business Insights: Top 10 Products
--------------------------------------------------------------------------- */
SELECT 
    product_name,
    SUM(total_revenue_gbp) AS total_revenue_gbp
FROM mart.v_sales_performance
GROUP BY product_name
ORDER BY total_revenue_gbp DESC
LIMIT 10;

/* ---------------------------------------------------------------------------
6) Business Insights: Average Order Value (AOV) by Country
WHY: Identify the most profitable markets.
--------------------------------------------------------------------------- */
WITH country_stats AS (
    SELECT 
        country,
        SUM(total_revenue_gbp) AS total_revenue,
        COUNT(DISTINCT invoice_no) AS total_orders
    FROM mart.v_sales_performance
    WHERE country IS NOT NULL
    GROUP BY country
)
SELECT 
    country,
    total_revenue,
    total_orders,
    ROUND((total_revenue / total_orders)::numeric, 2) AS average_order_value
FROM country_stats
WHERE total_orders > 5 -- Filtering out outliers
ORDER BY average_order_value DESC;


/* =============================================================================
   FINAL PROJECT AUDIT: Verifying Data Integrity and Quality
   =============================================================================
*/

-- 1. ROW COUNT CHECK (Must be 0)
-- Goal: Ensure no transactions were lost or duplicated.
SELECT 
    (SELECT COUNT(*) FROM staging.raw_online_retail) AS staging_rows,
    (SELECT COUNT(*) FROM mart.fct_sales) AS mart_rows,
    (SELECT COUNT(*) FROM staging.raw_online_retail) - (SELECT COUNT(*) FROM mart.fct_sales) AS row_difference;

-- 2. REVENUE INTEGRITY (Must be 0.00)
-- Goal: Verify the total money is exactly the same after all transformations.
SELECT 
    ROUND(ABS(
        (SELECT SUM(quantity * unit_price) FROM staging.raw_online_retail) - 
        (SELECT SUM(total_revenue_gbp) FROM mart.v_sales_performance)
    )::numeric, 2) AS revenue_drift;

-- 3. THE "UNKNOWN" FALLBACK CHECK (Expect 135,080)
-- Goal: Prove that the NULL customers were successfully rescued and mapped to ID 0.
SELECT COUNT(*) AS rescued_anonymous_sales
FROM mart.fct_sales
WHERE customer_key = 0;

-- 4. NULL KEYS CHECK (Must be 0)
-- Goal: Ensure there are NO "orphaned" sales that won't show up in reports.
SELECT COUNT(*) AS orphaned_sales
FROM mart.fct_sales
WHERE product_key IS NULL OR customer_key IS NULL;

-- 5. PRODUCT UNIQUENESS CHECK (Must be 0)
-- Goal: Ensure 1 Stock Code = 1 Product Key (Fixes the 647 duplicates issue).
SELECT COUNT(*) AS duplicate_stock_codes
FROM (
    SELECT stock_code FROM mart.dim_products GROUP BY stock_code HAVING COUNT(*) > 1
) AS dupes;