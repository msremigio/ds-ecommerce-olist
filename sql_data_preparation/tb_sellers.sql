SELECT
    *
FROM
    sellers;

-- Get the number of registered sellers, states and cities
SELECT
    COUNT(*) AS sellers_count
    ,COUNT(DISTINCT sellers.seller_id) AS distinct_sellers_count
    ,COUNT(DISTINCT sellers.seller_state) AS distinct_states_count
    ,COUNT(DISTINCT sellers.seller_city) AS distinct_cities_count
FROM
    sellers;

-- Get the number of sellers per state
SELECT
    sellers.seller_state
    ,COUNT(*) AS sellers_count
FROM
    sellers
GROUP BY
    sellers.seller_state
ORDER BY
    sellers_count DESC;