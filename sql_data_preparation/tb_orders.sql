-- Active: 1755824425005@@127.0.0.1@3306
-- Check table `orders` columns and data 
SELECT 
    *
FROM
    orders;

-- Get MIN and MAX 'order_approved_at' of 'delivered' orders
SELECT
    MIN(orders.order_approved_at) AS first_order_approved_at
    ,MAX(orders.order_approved_at) AS last_order_approved_at
FROM
    orders;

-- Get number of 'delivered' orders by customer ---> Must relate to 'customer_unique_id' to see how many orders per customer
SELECT 
    orders.customer_id
    ,COUNT(orders.order_id) AS delivered_order_count
FROM
    orders
WHERE
    orders.order_status = 'delivered'
GROUP BY
    orders.customer_id
ORDER BY
    delivered_order_count DESC;

-- Get the number of delivered orders by 'order_status'
SELECT
    orders.order_status
    ,COUNT(orders.order_id) AS order_count_by_status
FROM
    orders
GROUP BY
    orders.order_status
ORDER BY
    order_count_by_status DESC;

-- Get the number of 'delivered' orders by 'order_approved_at' year-month (YYYY-MM)
SELECT
    STRFTIME('%Y-%m', orders.order_approved_at) AS order_approved_at_month
    ,COUNT(orders.order_id) AS delivered_order_count
FROM
    orders
WHERE
    orders.order_status = 'delivered'
GROUP BY
    order_approved_at_month;

-- List all 'delivered' orders replacing the NULL values in 'order_approved_at' with 'order_purchase_timestamp' (A delivered order must have been approved at some point)
SELECT
    orders.order_id
    ,orders.customer_id
    ,orders.order_status
    ,orders.order_purchase_timestamp
    ,COALESCE(orders.order_approved_at, orders.order_purchase_timestamp) AS order_approved_at
    ,orders.order_delivered_carrier_date
    ,orders.order_delivered_customer_date
    ,orders.order_estimated_delivery_date  
FROM
    orders
WHERE
    orders.order_status = 'delivered';