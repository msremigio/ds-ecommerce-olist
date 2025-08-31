WITH
obs_window_orders_raw_table AS(
SELECT
    orders.order_id
    ,orders.customer_id
    ,orders.order_status
    ,orders.order_purchase_timestamp
    ,COALESCE(orders.order_approved_at, orders.order_purchase_timestamp) AS order_approved_at
    ,orders.order_delivered_carrier_date
    ,orders.order_delivered_customer_date
    ,orders.order_estimated_delivery_date
    ,customers.customer_unique_id
    ,order_items.seller_id
    ,order_items.product_id
    ,order_items.price
    ,order_items.freight_value
    ,order_reviews.review_score  
FROM
    orders
LEFT JOIN customers ON (orders.customer_id = customers.customer_id)
LEFT JOIN order_items ON (orders.order_id = order_items.order_id)
LEFT JOIN order_reviews ON (orders.order_id = order_reviews.order_id)
WHERE
    orders.order_status = 'delivered'
    AND orders.order_approved_at BETWEEN '{date}' AND DATE('{date}', '+6 month')
),
obs_window_aggr_sellers AS(
SELECT
    seller_id
    ,COUNT(order_id) AS sales_count
    ,COUNT(DISTINCT order_id) AS distinct_sales_count
    ,COUNT(DISTINCT product_id) AS distinct_products_sold
    ,COUNT(DISTINCT customer_unique_id) AS distinct_customers_count
    ,(COUNT(order_id) - COUNT(DISTINCT customer_unique_id)) AS repeat_customers_sales
    ,SUM(price) AS sales_revenue
    ,MAX(price) AS most_expensive_product_sold
    ,MIN(price) AS least_expensive_product_sold    
    ,SUM(price)/COUNT(DISTINCT order_id) AS avg_order_value
    ,AVG(price) AS avg_item_value
    ,AVG(DISTINCT price) AS avg_product_price
    ,MIN(order_approved_at) AS first_sale_date
    ,MAX(order_approved_at) AS last_sale_date
    ,(julianday('{date}', '+6 month', '-1 day') - julianday(DATE(MIN(order_approved_at)))) AS days_since_first_sale
    ,MIN(CEIL((julianday('{date}', '+6 month', '-1 second') - julianday(MIN(order_approved_at)))/30.0), 6.0) AS months_since_first_sale
    ,(julianday('{date}', '+6 month', '-1 day') - julianday(DATE(MAX(order_approved_at)))) AS days_since_last_sale
    ,MIN(CEIL((julianday('{date}', '+6 month', '-1 second') - julianday(MAX(order_approved_at)))/30.0), 6.0) AS months_since_last_sale
    ,(julianday(DATE(MAX(order_approved_at))) - julianday(DATE(MIN(order_approved_at)))) AS days_between_first_last_sale
    ,CEIL((julianday(MAX(order_approved_at)) - julianday(MIN(order_approved_at)))/30.0) AS months_between_first_last_sale
    ,COUNT(DISTINCT STRFTIME('%m', order_approved_at)) AS distinct_month_sales_count
    ,SUM(price)/MIN(CEIL((julianday('{date}', '+6 month', '-1 second') - julianday(MIN(order_approved_at)))/30.0), 6.0) AS avg_monthly_revenue
    ,SUM(price)/COUNT(DISTINCT STRFTIME('%m', order_approved_at)) AS avg_monthly_sales_revenue
    ,COUNT(DISTINCT STRFTIME('%m', order_approved_at))/MIN(CEIL((julianday('{date}', '+6 month', '-1 second') - julianday(MIN(order_approved_at)))/30.0), 6.0) AS mothly_sales_proportion
    ,AVG(review_score) AS avg_review_score
    ,AVG(freight_value) AS avg_freight_price
    ,(COUNT(DISTINCT customer_unique_id)/1.0)/COUNT(order_id) AS distinct_customers_sales_proportion
    ,SUM(price)/COUNT(DISTINCT customer_unique_id) AS distinct_customer_avg_revenue
    ,(COUNT(product_id)/1.0)/COUNT(DISTINCT order_id) AS avg_products_sold_per_order
FROM
    obs_window_orders_raw_table
GROUP BY
    seller_id
),
obs_window_sellers_product_category AS(
SELECT
    order_items.seller_id
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'bed_bath_table') AS cat_bed_bath_table
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'health_beauty') AS cat_health_beauty 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'sports_leisure') AS cat_sports_leisure 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'furniture_decor') AS cat_furniture_decor 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'computers_accessories') AS cat_computers_accessories 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'housewares') AS cat_housewares 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'watches_gifts') AS cat_watches_gifts 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'telephony') AS cat_telephony 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'garden_tools') AS cat_garden_tools 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'auto') AS cat_auto 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'toys') AS cat_toys 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'cool_stuff') AS cat_cool_stuff 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'perfumery') AS cat_perfumery 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'baby') AS cat_baby 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'electronics') AS cat_electronics 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'stationery') AS cat_stationery 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'fashion_bags_accessories') AS cat_fashion_bags_accessories 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'pet_shop') AS cat_pet_shop 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'office_furniture') AS cat_office_furniture 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english IS NULL) AS cat_NULL 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'consoles_games') AS cat_consoles_games 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'luggage_accessories') AS cat_luggage_accessories 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'construction_tools_construction') AS cat_construction_tools_construction 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'home_appliances') AS cat_home_appliances 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'musical_instruments') AS cat_musical_instruments 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'small_appliances') AS cat_small_appliances 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'home_construction') AS cat_home_construction 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'books_general_interest') AS cat_books_general_interest 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'food') AS cat_food 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'furniture_living_room') AS cat_furniture_living_room 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'home_confort') AS cat_home_confort 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'drinks') AS cat_drinks 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'audio') AS cat_audio 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'market_place') AS cat_market_place 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'construction_tools_lights') AS cat_construction_tools_lights 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'air_conditioning') AS cat_air_conditioning 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'kitchen_dining_laundry_garden_furniture') AS cat_kitchen_dining_laundry_garden_furniture 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'food_drink') AS cat_food_drink 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'industry_commerce_and_business') AS cat_industry_commerce_and_business 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'books_technical') AS cat_books_technical 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'fixed_telephony') AS cat_fixed_telephony 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'fashion_shoes') AS cat_fashion_shoes 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'home_appliances_2') AS cat_home_appliances_2 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'costruction_tools_garden') AS cat_costruction_tools_garden 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'agro_industry_and_commerce') AS cat_agro_industry_and_commerce 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'art') AS cat_art 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'computers') AS cat_computers 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'signaling_and_security') AS cat_signaling_and_security 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'construction_tools_safety') AS cat_construction_tools_safety 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'christmas_supplies') AS cat_christmas_supplies 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'fashion_male_clothing') AS cat_fashion_male_clothing 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'fashion_underwear_beach') AS cat_fashion_underwear_beach 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'furniture_bedroom') AS cat_furniture_bedroom 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'costruction_tools_tools') AS cat_costruction_tools_tools 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'tablets_printing_image') AS cat_tablets_printing_image 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'small_appliances_home_oven_and_coffee') AS cat_small_appliances_home_oven_and_coffee 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'cine_photo') AS cat_cine_photo 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'dvds_blu_ray') AS cat_dvds_blu_ray 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'books_imported') AS cat_books_imported 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'fashio_female_clothing') AS cat_fashio_female_clothing 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'party_supplies') AS cat_party_supplies 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'diapers_and_hygiene') AS cat_diapers_and_hygiene 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'music') AS cat_music 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'furniture_mattress_and_upholstery') AS cat_furniture_mattress_and_upholstery 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'flowers') AS cat_flowers 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'home_comfort_2') AS cat_home_comfort_2 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'fashion_sport') AS cat_fashion_sport 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'arts_and_craftmanship') AS cat_arts_and_craftmanship 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'la_cuisine') AS cat_la_cuisine 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'cds_dvds_musicals') AS cat_cds_dvds_musicals 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'fashion_childrens_clothes') AS cat_fashion_childrens_clothes 
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'security_and_services') AS cat_security_and_services  
FROM
    products
LEFT JOIN product_category_name_translation ON products.product_category_name = product_category_name_translation.product_category_name
LEFT JOIN order_items ON products.product_id = order_items.product_id
LEFT JOIN orders ON (order_items.order_id = orders.order_id)
WHERE
    orders.order_status = 'delivered'
    AND orders.order_approved_at BETWEEN '{date}' AND DATE('{date}', '+6 month')
GROUP BY
    order_items.seller_id    
),
obs_window_sellers_states_and_leads AS(
SELECT
    sellers.seller_id
    ,MAX(sellers.seller_state) AS seller_state
    ,COUNT(leads_closed.mql_id) AS leads_won_count
FROM
    sellers
LEFT JOIN leads_closed ON (sellers.seller_id = leads_closed.seller_id) AND leads_closed.won_date BETWEEN '{date}' AND DATE('{date}', '+6 month')
GROUP BY
    sellers.seller_id   
),
obs_window_sellers_oders_deliveries AS(
SELECT
    order_items.seller_id
    ,orders.order_id
    ,orders.order_estimated_delivery_date
    ,orders.order_delivered_customer_date
FROM
    orders
LEFT JOIN customers ON (orders.customer_id = customers.customer_id)
LEFT JOIN order_items ON (orders.order_id = order_items.order_id)
LEFT JOIN order_reviews ON (orders.order_id = order_reviews.order_id)
WHERE
    orders.order_status = 'delivered'
    AND orders.order_approved_at BETWEEN '{date}' AND DATE('{date}', '+6 month')
GROUP BY
    order_items.seller_id
    ,orders.order_id
),
obs_window_aggr_sellers_delayed_orders AS(
SELECT
    seller_id
    ,SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS delayed_orders_count
    ,(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END)/1.0)/COUNT(DISTINCT order_id) AS delayed_orders_proportion
FROM
    obs_window_sellers_oders_deliveries
GROUP BY
    seller_id    
)
SELECT
    '{date}' AS obs_window_start_date
    ,DATE('{date}', '+6 month', '-1 day') As obs_window_end_date
    ,obs_window_aggr_sellers.*
    ,obs_window_sellers_product_category.cat_bed_bath_table
    ,obs_window_sellers_product_category.cat_health_beauty 
    ,obs_window_sellers_product_category.cat_sports_leisure 
    ,obs_window_sellers_product_category.cat_furniture_decor 
    ,obs_window_sellers_product_category.cat_computers_accessories 
    ,obs_window_sellers_product_category.cat_housewares 
    ,obs_window_sellers_product_category.cat_watches_gifts 
    ,obs_window_sellers_product_category.cat_telephony 
    ,obs_window_sellers_product_category.cat_garden_tools 
    ,obs_window_sellers_product_category.cat_auto 
    ,obs_window_sellers_product_category.cat_toys 
    ,obs_window_sellers_product_category.cat_cool_stuff 
    ,obs_window_sellers_product_category.cat_perfumery 
    ,obs_window_sellers_product_category.cat_baby 
    ,obs_window_sellers_product_category.cat_electronics 
    ,obs_window_sellers_product_category.cat_stationery 
    ,obs_window_sellers_product_category.cat_fashion_bags_accessories 
    ,obs_window_sellers_product_category.cat_pet_shop 
    ,obs_window_sellers_product_category.cat_office_furniture 
    ,obs_window_sellers_product_category.cat_NULL 
    ,obs_window_sellers_product_category.cat_consoles_games 
    ,obs_window_sellers_product_category.cat_luggage_accessories 
    ,obs_window_sellers_product_category.cat_construction_tools_construction 
    ,obs_window_sellers_product_category.cat_home_appliances 
    ,obs_window_sellers_product_category.cat_musical_instruments 
    ,obs_window_sellers_product_category.cat_small_appliances 
    ,obs_window_sellers_product_category.cat_home_construction 
    ,obs_window_sellers_product_category.cat_books_general_interest 
    ,obs_window_sellers_product_category.cat_food 
    ,obs_window_sellers_product_category.cat_furniture_living_room 
    ,obs_window_sellers_product_category.cat_home_confort 
    ,obs_window_sellers_product_category.cat_drinks 
    ,obs_window_sellers_product_category.cat_audio 
    ,obs_window_sellers_product_category.cat_market_place 
    ,obs_window_sellers_product_category.cat_construction_tools_lights 
    ,obs_window_sellers_product_category.cat_air_conditioning 
    ,obs_window_sellers_product_category.cat_kitchen_dining_laundry_garden_furniture 
    ,obs_window_sellers_product_category.cat_food_drink 
    ,obs_window_sellers_product_category.cat_industry_commerce_and_business 
    ,obs_window_sellers_product_category.cat_books_technical 
    ,obs_window_sellers_product_category.cat_fixed_telephony 
    ,obs_window_sellers_product_category.cat_fashion_shoes 
    ,obs_window_sellers_product_category.cat_home_appliances_2 
    ,obs_window_sellers_product_category.cat_costruction_tools_garden 
    ,obs_window_sellers_product_category.cat_agro_industry_and_commerce 
    ,obs_window_sellers_product_category.cat_art 
    ,obs_window_sellers_product_category.cat_computers 
    ,obs_window_sellers_product_category.cat_signaling_and_security 
    ,obs_window_sellers_product_category.cat_construction_tools_safety 
    ,obs_window_sellers_product_category.cat_christmas_supplies 
    ,obs_window_sellers_product_category.cat_fashion_male_clothing 
    ,obs_window_sellers_product_category.cat_fashion_underwear_beach 
    ,obs_window_sellers_product_category.cat_furniture_bedroom 
    ,obs_window_sellers_product_category.cat_costruction_tools_tools 
    ,obs_window_sellers_product_category.cat_tablets_printing_image 
    ,obs_window_sellers_product_category.cat_small_appliances_home_oven_and_coffee 
    ,obs_window_sellers_product_category.cat_cine_photo 
    ,obs_window_sellers_product_category.cat_dvds_blu_ray 
    ,obs_window_sellers_product_category.cat_books_imported 
    ,obs_window_sellers_product_category.cat_fashio_female_clothing 
    ,obs_window_sellers_product_category.cat_party_supplies 
    ,obs_window_sellers_product_category.cat_diapers_and_hygiene 
    ,obs_window_sellers_product_category.cat_music 
    ,obs_window_sellers_product_category.cat_furniture_mattress_and_upholstery 
    ,obs_window_sellers_product_category.cat_flowers 
    ,obs_window_sellers_product_category.cat_home_comfort_2 
    ,obs_window_sellers_product_category.cat_fashion_sport 
    ,obs_window_sellers_product_category.cat_arts_and_craftmanship 
    ,obs_window_sellers_product_category.cat_la_cuisine 
    ,obs_window_sellers_product_category.cat_cds_dvds_musicals 
    ,obs_window_sellers_product_category.cat_fashion_childrens_clothes 
    ,obs_window_sellers_product_category.cat_security_and_services      
    ,obs_window_sellers_states_and_leads.seller_state
    ,obs_window_sellers_states_and_leads.leads_won_count
    ,obs_window_aggr_sellers_delayed_orders.delayed_orders_count
    ,obs_window_aggr_sellers_delayed_orders.delayed_orders_proportion
FROM
    obs_window_aggr_sellers
LEFT JOIN obs_window_sellers_product_category ON obs_window_aggr_sellers.seller_id = obs_window_sellers_product_category.seller_id
LEFT JOIN obs_window_sellers_states_and_leads ON obs_window_aggr_sellers.seller_id = obs_window_sellers_states_and_leads.seller_id
LEFT JOIN obs_window_aggr_sellers_delayed_orders ON obs_window_aggr_sellers.seller_id = obs_window_aggr_sellers_delayed_orders.seller_id;