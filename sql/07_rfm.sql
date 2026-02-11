/* RFM CUSTOMER SEGMENTATION
   WHAT: Calculates Recency, Frequency, and Monetary metrics and ranks customers using NTILE(3) window functions.
   WHY: To identify high-value "Champions" and "At Risk" customers for targeted marketing and optimized retention strategies. 
   RESULT: A categorized dataset with RFM scores and business segments (e.g., Loyal, New, Lost) ready for Power BI visualization.
*/
with customer_segment as (
    SELECT 
        customer_key,
        MAX(date_id)::date as last_order_date,
        COUNT(DISTINCT invoice_no) as unique_invoice_no,
        SUM(quantity * unit_price) AS mart_revenue
    FROM mart.fct_sales
    where customer_key <> 0
    GROUP BY customer_key
),

rfm_metrics as (
    SELECT
        customer_key,
        ('2010-12-10'::date - last_order_date) as recency,
        unique_invoice_no,
        mart_revenue
    FROM customer_segment
),

rfm_scores as (
    SELECT
        customer_key,
        NTILE(3) Over (Order By recency DESC) as r_score,
        NTILE(3) Over (Order By unique_invoice_no ASC) as f_score,
        NTILE(3) Over (Order By mart_revenue ASC) as m_score
    FROM rfm_metrics
)
SELECT 
    customer_key,
    r_score,
    f_score,
    m_score,
    (r_score::text || f_score::text || m_score::text) as rfm_code,
    CASE 
        WHEN r_score = 3 AND f_score = 3 THEN 'Champions'
        WHEN r_score = 1 THEN 'At Risk / Lost'
        WHEN f_score = 3 THEN 'Loyal Customers'
        WHEN r_score = 3 AND f_score = 1 THEN 'New Customers'
        ELSE 'Potential Loyalists'
    END as customer_segment
FROM rfm_scores
ORDER BY rfm_code DESC;