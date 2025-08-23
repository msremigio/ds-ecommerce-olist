SELECT
   *
FROM
    products;

SELECT
   *
FROM
    product_category_name_translation;

-- Category names in PTBR and ENUS    
SELECT
   products.*
   ,product_category_name_translation.product_category_name_english
FROM
    products
LEFT JOIN product_category_name_translation ON products.product_category_name = product_category_name_translation.product_category_name;

-- Get number of distinct product categories
SELECT
    COUNT(DISTINCT products.product_category_name) AS distinct_categories_count
FROM
    products;

-- Get number of products per category
SELECT
    products.product_category_name
    ,COUNT(*) AS products_per_category_count
    ,COUNT(DISTINCT products.product_id) AS distinct_products_per_category_count 
FROM
    products
GROUP BY
    products.product_category_name
ORDER BY
    products_per_category_count DESC;