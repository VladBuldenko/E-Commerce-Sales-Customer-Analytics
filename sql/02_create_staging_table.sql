CREATE TABLE if NOT EXISTS staging.raw_online_retail(
    invoice_no   TEXT,
    stock_code   TEXT,
    description   TEXT,
    quantity    INTEGER,
    invoice_date   TIMESTAMP,
    unit_price   NUMERIC(10, 2),
    customer_id TEXT,
    country    TEXT
);

COPY staging.raw_online_retail
FROM '/Users/home/Desktop/Data Analytics Portfolio/E-Commerce-Sales-Customer-Analytics/data/raw/online_retail.csv'
DELIMITER ','
CSV HEADER;