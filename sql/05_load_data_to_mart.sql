/* WHY: Create a unique product catalog.
LOGIC: TRIM removes accidental spaces. GROUP BY ensures each StockCode + Description pair is unique.
RESULT: Each product gets exactly one ID (product_key) in mart.dim_products.
*/
INSERT INTO mart.dim_products (stock_code, description)
SELECT 
    TRIM(stock_code), 
    TRIM(description)
FROM staging.raw_online_retail
WHERE stock_code IS NOT NULL 
  AND description IS NOT NULL
GROUP BY TRIM(stock_code), TRIM(description);

/* WHY: Create a unique customer list.
LOGIC: GROUP BY customer_id ensures one row per client. MIN(country) picks one country if duplicates exist.
RESULT: Prevents "row multiplication" in the fact table caused by duplicate customer IDs.
*/
INSERT INTO mart.dim_customers (customer_id, country)
SELECT customer_id, MIN(country) 
FROM staging.raw_online_retail
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

/* WHY: Assemble the final fact table.
LOGIC: Link staging transactions to dimensions. We use a double JOIN (Code AND Description) for 100% accuracy.
RESULT: A optimized fact table using numeric keys (ID) instead of slow text strings.
*/
INSERT INTO mart.fct_sales (date_id, product_key, customer_key, invoice_no, quantity, unit_price)
SELECT 
    stg.invoice_date,
    p.product_key,
    c.customer_key,
    stg.invoice_no,
    stg.quantity,
    stg.unit_price
FROM staging.raw_online_retail stg
LEFT JOIN mart.dim_products p 
    ON TRIM(stg.stock_code) = p.stock_code 
    AND TRIM(stg.description) = p.description
LEFT JOIN mart.dim_customers c 
    ON stg.customer_id = c.customer_id;