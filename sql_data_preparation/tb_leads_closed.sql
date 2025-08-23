SELECT
    *
FROM
    leads_qualified;

SELECT
    *
FROM
    leads_closed;

-- Get distinct sellers with leads won
SELECT
    COUNT(DISTINCT leads_closed.seller_id) AS distinct_sellers_with_leads_won_count
FROM
    leads_closed;

-- Get number of won leads per seller
SELECT
    leads_closed.seller_id
    ,COUNT(*) AS leads_won_count
FROM
    leads_closed
GROUP BY
    leads_closed.seller_id
ORDER BY
    leads_won_count DESC;

-- Number of leads won per 'business_segment'
SELECT
    leads_closed.business_segment
    ,COUNT(*) AS leads_won_count
FROM
    leads_closed
GROUP BY
    leads_closed.business_segment
ORDER BY
    leads_won_count DESC;

-- Number of leads won per 'lead_type'
SELECT
    leads_closed.lead_type
    ,COUNT(*) AS leads_won_count
FROM
    leads_closed
GROUP BY
    leads_closed.lead_type
ORDER BY
    leads_won_count DESC;    

-- Number of leads won per 'business_type'
SELECT
    leads_closed.business_type
    ,COUNT(*) AS leads_won_count
FROM
    leads_closed
GROUP BY
    leads_closed.business_type
ORDER BY
    leads_won_count DESC;     