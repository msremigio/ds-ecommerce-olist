SELECT
    *
FROM
    order_reviews;

-- Check if there is more than one review to the same order
SELECT
    COUNT(*) AS reviews_count
    ,COUNT(DISTINCT order_reviews.order_id) distinct_orders
FROM
    order_reviews;

-- Get the number of reviews per order and the average score
SELECT
    order_reviews.order_id
    ,COUNT(*) AS reviews_count
    ,AVG(order_reviews.review_score) AS avg_order_review_score
FROM
    order_reviews
GROUP BY
    order_reviews.order_id
ORDER BY
    reviews_count DESC;