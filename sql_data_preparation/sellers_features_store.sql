-- Check orders volume per YYYY-MM
SELECT
    STRFTIME('%Y-%m', orders.order_approved_at) AS order_approved_at_month
    ,COUNT(orders.order_id) AS delivered_order_count
FROM
    orders
WHERE
    orders.order_status = 'delivered'
GROUP BY
    order_approved_at_month;

-- Check the YYYY-MM of the 'delivered' orders that don't have 'order_aproved_at' value
SELECT
    orders.order_purchase_timestamp
    ,orders.order_approved_at
FROM
    orders
WHERE
    orders.order_status = 'delivered'
    AND orders.order_approved_at IS NULL;

/*
    CONSIDERING WE HAVE A LOW VOLUME IN THE FIRST 3 MONTHS OF DATA (2016-09 TO 2016-12),
    LET'S DEFINE OUR FIRST COHORT/OBSERVATION WINDOW STARTING AT 2017-01-01.

    AS WE'RE ANALYSING E-COMMERCE DATA AND THE DATA VOLUME IS NOT BIG, I BELIEVE A 6 MONTH
    OBSERVATION WINDOW + A MONTHLY COHORT IS REASONABLE TO START WITH.

    ** POSSIBLE MATURED COHORTS **
    1. 2017-01-01 -> 2017-06-30
    2. 2017-02-01 -> 2017-07-31
    3. 2017-03-01 -> 2017-08-31
    4. 2017-04-01 -> 2017-09-30
    5. 2017-05-01 -> 2017-10-31
    6. 2017-06-01 -> 2017-11-30
    7. 2017-07-01 -> 2017-12-31
    8. 2017-08-01 -> 2018-01-31 
    9. 2017-09-01 -> 2018-02-28
    10. 2017-10-01 -> 2018-03-31
    11. 2017-11-01 -> 2018-04-30
    12. 2017-12-01 -> 2018-05-31
    13. 2018-01-01 -> 2018-06-30
    14. 2018-02-01 -> 2018-07-31
    15. 2018-03-01 -> 2018-08-31 
*/
-- Observation windows
SELECT
    DATE(MIN(orders.order_approved_at), 'start of month') AS obs_window_start_date
    ,DATE(MIN(orders.order_approved_at), 'start of month', '+6 month', '-1 day') AS obs_window_end_date
FROM
    orders
WHERE
    orders.order_status = 'delivered'
    AND orders.order_approved_at BETWEEN '2017-01-01' AND '2017-07-01'    

-- Sellers features store for the first cohort 
WITH
obs_window_orders_raw_table AS(
SELECT
    orders.order_id
    ,orders.customer_id
    ,orders.order_status
    ,orders.order_purchase_timestamp
    ,COALESCE(orders.order_approved_at, orders.order_purchase_timestamp) AS order_approved_at
    ,orders.order_delivered_carrier_date
    ,orders.order_delivered_customer_date
    ,orders.order_estimated_delivery_date
    ,customers.customer_unique_id
    ,order_items.seller_id
    ,order_items.product_id
    ,order_items.price
    ,order_reviews.review_score  
FROM
    orders
LEFT JOIN customers ON (orders.customer_id = customers.customer_id)
LEFT JOIN order_items ON (orders.order_id = order_items.order_id)
LEFT JOIN order_reviews ON (orders.order_id = order_reviews.order_id)
WHERE
    orders.order_status = 'delivered'
    AND orders.order_approved_at BETWEEN '2017-01-01' AND '2017-07-01'
),
obs_window_aggr_sellers AS(
SELECT
    seller_id
    ,COUNT(order_id) AS sales_count
    ,COUNT(DISTINCT order_id) AS distinct_sales_count
    ,COUNT(DISTINCT product_id) AS distinct_products_sold
    ,COUNT(DISTINCT customer_unique_id) AS distinct_customers_count
    ,(COUNT(order_id) - COUNT(DISTINCT customer_unique_id)) AS repeat_customers_sales
    ,SUM(price) AS sales_revenue
    ,MAX(price) AS most_expensive_product_sold
    ,MIN(price) AS least_expensive_product_sold    
    ,SUM(price)/COUNT(DISTINCT order_id) AS avg_order_value
    ,AVG(price) AS avg_item_value
    ,AVG(DISTINCT price) AS avg_product_price
    -- ,MIN(order_approved_at) AS first_sale_date
    -- ,MAX(order_approved_at) AS last_sale_date
    ,(julianday('2017-07-01', '-1 day') - julianday(DATE(MIN(order_approved_at)))) AS days_since_first_sale
    ,MIN(CEIL((julianday('2017-07-01 00:00:00', '-1 second') - julianday(MIN(order_approved_at)))/30.0), 6.0) AS months_since_first_sale
    ,(julianday('2017-07-01', '-1 day') - julianday(DATE(MAX(order_approved_at)))) AS days_since_last_sale
    ,MIN(CEIL((julianday('2017-07-01 00:00:00', '-1 second') - julianday(MAX(order_approved_at)))/30.0), 6.0) AS months_since_last_sale
    ,(julianday(DATE(MAX(order_approved_at))) - julianday(DATE(MIN(order_approved_at)))) AS days_between_first_last_sale
    ,CEIL((julianday(DATE(MAX(order_approved_at))) - julianday(DATE(MIN(order_approved_at))))/30.0) AS months_between_first_last_sale
    ,COUNT(DISTINCT STRFTIME('%m', order_approved_at)) AS distinct_month_sales_count
    ,SUM(price)/MIN(CEIL((julianday('2017-07-01 00:00:00', '-1 second') - julianday(MIN(order_approved_at)))/30.0), 6.0) AS avg_monthly_revenue
    ,SUM(price)/COUNT(DISTINCT STRFTIME('%m', order_approved_at)) AS avg_monthly_sales_revenue
    ,COUNT(DISTINCT STRFTIME('%m', order_approved_at))/MIN(CEIL((julianday('2017-07-01 00:00:00', '-1 second') - julianday(MIN(order_approved_at)))/30.0), 6.0) AS mothly_sales_proportion
FROM
    obs_window_orders_raw_table
GROUP BY
    seller_id
)
SELECT
    *
FROM
    obs_window_aggr_sellers;