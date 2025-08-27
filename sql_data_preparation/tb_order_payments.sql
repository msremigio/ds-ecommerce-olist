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


--
SELECT
    order_items.seller_id
    ,COUNT(DISTINCT order_items.order_id) FILTER (WHERE order_payments.payment_type = 'credit_card') AS payment_type_credit_card
    ,COUNT(DISTINCT order_items.order_id) FILTER (WHERE order_payments.payment_type = 'boleto') AS payment_type_boleto
    ,COUNT(DISTINCT order_items.order_id) FILTER (WHERE order_payments.payment_type = 'voucher') AS payment_type_voucher
    ,COUNT(DISTINCT order_items.order_id) FILTER (WHERE order_payments.payment_type = 'debit_card') AS payment_type_debit_card
    ,COUNT(DISTINCT order_items.order_id) FILTER (WHERE order_payments.payment_type = 'not_defined') AS payment_type_not_defined
FROM
    order_items
LEFT JOIN order_payments ON order_items.order_id = order_payments.order_id
GROUP BY
    order_items.seller_id;




