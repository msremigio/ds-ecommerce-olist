WITH
features_store_table AS(
SELECT
    *
FROM
    features_store
WHERE
    obs_window_start_date <= (SELECT DATE(MAX(features_store.obs_window_start_date), '-3 month') FROM features_store)
),
flag_model AS(
SELECT DISTINCT
    DATE(COALESCE(orders.order_approved_at, orders.order_purchase_timestamp), 'start of month') AS dt_sale
    ,order_items.seller_id
FROM
    orders
LEFT JOIN order_items ON (orders.order_id = order_items.order_id)
WHERE
    orders.order_status = 'delivered'
)
SELECT
    features_store_table.*
    ,MAX(CASE WHEN flag_model.seller_id IS NULL THEN 1 ELSE 0 END) AS flag_model
FROM
    features_store_table
LEFT JOIN flag_model ON (features_store_table.seller_id = flag_model.seller_id AND (flag_model.dt_sale BETWEEN DATE(features_store_table.obs_window_start_date, '+6 month') AND DATE(features_store_table.obs_window_start_date, '+8 month')))
GROUP BY
    1=1
    ,features_store_table.obs_window_start_date
    ,features_store_table.obs_window_end_date
    ,features_store_table.seller_id;