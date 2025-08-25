SELECT
    *
FROM
    customers;

-- Get number of distinct 'customer_id' and 'customer_unique_id' ---> Every order generates a new 'customer_id', so both tables have the same rows count
SELECT
    COUNT(DISTINCT customers.customer_id) AS customers_id_count
    ,COUNT(DISTINCT customers.customer_unique_id) AS customers_unique_id_count
FROM
    customers;

-- The column 'customer_id' is actually an identifier of the number of orders made
SELECT
    customers.customer_id
    ,COUNT(*) AS count_number
FROM
    customers
GROUP BY
    customers.customer_id
ORDER BY
    count_number DESC;

-- The column 'customer_unique_id' is the factual identifier of a distinct customer
SELECT
    customers.customer_unique_id
    ,COUNT(*) AS count_number
FROM
    customers
GROUP BY
    customers.customer_unique_id
ORDER BY
    count_number DESC;    
