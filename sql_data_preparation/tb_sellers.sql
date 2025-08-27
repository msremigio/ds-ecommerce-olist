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

-- Get sellers states and leads won
SELECT
    sellers.seller_id
    ,MAX(sellers.seller_state) AS seller_state
    ,COUNT(leads_closed.mql_id) AS leads_won_count
FROM
    sellers
LEFT JOIN leads_closed ON (sellers.seller_id = leads_closed.seller_id) AND leads_closed.won_date BETWEEN '2017-01-01' AND '2017-07-01'
GROUP BY
    sellers.seller_id;