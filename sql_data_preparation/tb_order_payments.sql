SELECT
    *
FROM
    order_payments;

-- Get total payment value by order id
SELECT
    order_payments.order_id
    ,SUM(order_payments.payment_value) AS total_payment_value
FROM
    order_payments
GROUP BY
    order_payments.order_id
ORDER BY
    order_payments.order_id;

-- Get most used 'payment_type'
SELECT
    order_payments.payment_type
    ,COUNT(*) AS quantity
FROM
    order_payments
GROUP BY
    order_payments.payment_type
ORDER BY
    quantity DESC;

-- Get total payment value by 'payment_type'
SELECT
    order_payments.payment_type
    ,SUM(order_payments.payment_value) AS total_payment_value
FROM
    order_payments
GROUP BY
    order_payments.payment_type
ORDER BY
    total_payment_value DESC;