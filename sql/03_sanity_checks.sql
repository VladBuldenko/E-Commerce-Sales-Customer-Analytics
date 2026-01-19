
/* ---------------------------------------------------------------------------
1) Dataset preview
WHAT: Show a small sample of recent records
WHY: Quickly understand structure, formatting, and typical values
--------------------------------------------------------------------------- */
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
ORDER BY invoice_date DESC
LIMIT 20;

/* ---------------------------------------------------------------------------
2) Dataset size & granularity
WHAT: Count total rows and distinct business keys
WHY: Understand scale and confirm line-item vs order-level grain
--------------------------------------------------------------------------- */
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT invoice_no) AS distinct_invoices,
    COUNT(DISTINCT customer_id) AS distinct_customers,
    COUNT(DISTINCT stock_code) AS distinct_products
FROM staging.raw_online_retail;

/* ---------------------------------------------------------------------------
3) Time coverage validation
WHAT: Check earliest and latest invoice dates
WHY: Ensure dataset covers expected time period for analysis
--------------------------------------------------------------------------- */
SELECT
    MIN(invoice_date) AS earliest_invoice_date,
    MAX(invoice_date) AS latest_invoice_date
FROM staging.raw_online_retail;

/* ---------------------------------------------------------------------------
4) Missing values in key columns
WHAT: Count NULL or empty values in business-critical fields
WHY: Missing keys break joins, aggregations, and BI slicing
--------------------------------------------------------------------------- */
SELECT
    SUM(CASE WHEN invoice_no IS NULL OR invoice_no = '' THEN 1 ELSE 0 END) AS missing_invoice_no,
    SUM(CASE WHEN stock_code IS NULL OR stock_code = '' THEN 1 ELSE 0 END) AS missing_stock_code,
    SUM(CASE WHEN description IS NULL OR description = '' THEN 1 ELSE 0 END) AS missing_description,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) AS missing_invoice_date,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS missing_unit_price,
    SUM(CASE WHEN customer_id IS NULL OR customer_id = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN country IS NULL OR country = '' THEN 1 ELSE 0 END) AS missing_country
FROM staging.raw_online_retail;

/* ---------------------------------------------------------------------------
5) Order-level integrity
WHAT: Count number of line items per invoice
WHY: Detect unusually large or suspicious orders
--------------------------------------------------------------------------- */
SELECT
    invoice_no,
    COUNT(*) AS line_items
FROM staging.raw_online_retail
GROUP BY invoice_no
ORDER BY line_items DESC
LIMIT 20;

/* ---------------------------------------------------------------------------
6) Duplicate row detection
WHAT: Identify fully identical rows appearing multiple times
WHY: Duplicates inflate quantities and revenue metrics
--------------------------------------------------------------------------- */
SELECT
    invoice_no,
    stock_code,
    quantity,
    unit_price,
    invoice_date,
    customer_id,
    country,
    COUNT(*) AS duplicate_rows
FROM staging.raw_online_retail
GROUP BY
    invoice_no,
    stock_code,
    quantity,
    unit_price,
    invoice_date,
    customer_id,
    country
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC
LIMIT 20;

/* ---------------------------------------------------------------------------
7) Numeric range validation
WHAT: Check min/max for quantity and unit_price
WHY: Detect invalid or extreme values early
--------------------------------------------------------------------------- */
SELECT
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    MIN(unit_price) AS min_unit_price,
    MAX(unit_price) AS max_unit_price
FROM staging.raw_online_retail;

/* ---------------------------------------------------------------------------
8) Customer ID format profiling
WHAT: Classify customer_id values by format
WHY: Ensure customer_id is safe for joins and casting
--------------------------------------------------------------------------- */
SELECT
    CASE
        WHEN customer_id IS NULL OR customer_id = '' THEN 'missing_or_empty'
        WHEN customer_id ~ '^[0-9]+$' THEN 'whole_number'
        WHEN customer_id ~ '^[0-9]+\.[0-9]+$' THEN 'decimal_like'
        WHEN customer_id ~ '[A-Za-z]' THEN 'contains_letters'
        ELSE 'special_or_other'
    END AS customer_id_status,
    COUNT(*) AS record_count
FROM staging.raw_online_retail
GROUP BY customer_id_status
ORDER BY record_count DESC;

/* ---------------------------------------------------------------------------
9) Cancellations detection
WHAT: Split invoices into cancelled vs normal
WHY: Cancelled orders must not pollute sales KPIs
--------------------------------------------------------------------------- */
SELECT
    CASE
        WHEN invoice_no LIKE 'C%' THEN 'cancellation'
        ELSE 'normal'
    END AS invoice_type,
    COUNT(DISTINCT invoice_no) AS invoices
FROM staging.raw_online_retail
GROUP BY invoice_type
ORDER BY invoices DESC;

/* ---------------------------------------------------------------------------
10) Returns detection
WHAT: Identify rows with negative quantities
WHY: Returns reduce revenue and affect order metrics
--------------------------------------------------------------------------- */
SELECT
    COUNT(*) AS return_rows,
    COUNT(DISTINCT invoice_no) AS invoices_with_returns
FROM staging.raw_online_retail
WHERE quantity < 0;

/* ---------------------------------------------------------------------------
11) Revenue sanity checks
WHAT: Calculate total, positive, and negative revenue
WHY: Validate financial logic before defining KPIs
--------------------------------------------------------------------------- */
SELECT
    SUM(quantity * unit_price) AS total_revenue_net,
    SUM(CASE WHEN quantity > 0 THEN quantity * unit_price ELSE 0 END) AS positive_revenue,
    SUM(CASE WHEN quantity < 0 THEN quantity * unit_price ELSE 0 END) AS negative_revenue
FROM staging.raw_online_retail;

/* ---------------------------------------------------------------------------
12) Extreme single-line revenue values
WHAT: Identify max/min revenue per line item
WHY: Detect outliers that could distort aggregations
--------------------------------------------------------------------------- */
SELECT
    MAX(quantity * unit_price) AS max_single_line_revenue,
    MIN(quantity * unit_price) AS min_single_line_revenue
FROM staging.raw_online_retail;

/* ---------------------------------------------------------------------------
13) Geographic distribution sanity
WHAT: Top countries by transaction volume
WHY: Quick business plausibility check
--------------------------------------------------------------------------- */
SELECT
    country,
    COUNT(*) AS transaction_rows
FROM staging.raw_online_retail
GROUP BY country
ORDER BY transaction_rows DESC;

/* ---------------------------------------------------------------------------
14) Time-based revenue sample
WHAT: Aggregate revenue by day (sample output)
WHY: Validate timestamp parsing and detect obvious spikes
--------------------------------------------------------------------------- */
SELECT
    DATE(invoice_date) AS day,
    SUM(quantity * unit_price) AS daily_revenue
FROM staging.raw_online_retail
GROUP BY DATE(invoice_date)
ORDER BY day
LIMIT 20;
