SELECT
    *
FROM
    order_items;

-- Get total order value (price + freight value)
SELECT
    order_items.order_id
    ,SUM(order_items.price + order_items.freight_value) AS total_order_value
FROM
    order_items
GROUP BY
    order_items.order_id
ORDER BY
    order_items.order_id;

-- Get most ordered products info
SELECT
    order_items.product_id
    ,COUNT(*) AS ordered_quantity
    ,MAX(order_items.price) AS max_unit_price
    ,MIN(order_items.price) AS min_unit_price
    ,AVG(order_items.price) AS avg_unit_price
    ,SUM(order_items.price) AS total_ordered_value
    ,MAX(order_items.freight_value) AS max_unit_freight_value
    ,MIN(order_items.freight_value) AS min_unit_freight_value
    ,AVG(order_items.freight_value) AS avg_unit_freight_value
    ,SUM(order_items.freight_value) AS total_ordered_freight_value
FROM
    order_items
GROUP BY
    order_items.product_id
ORDER BY
    ordered_quantity DESC;

-- Get most successful sellers info
SELECT
    order_items.seller_id
    ,COUNT(*) AS total_itens_sold
    ,COUNT(DISTINCT order_items.order_id) AS distinct_sale_orders
    ,COUNT(DISTINCT order_items.product_id) AS distinct_products_sold
    ,SUM(order_items.price) AS total_value_sold
    ,SUM(order_items.freight_value) AS total_freight_value
FROM
    order_items
GROUP BY
    order_items.seller_id
ORDER BY
    total_itens_sold DESC;