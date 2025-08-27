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

-- Get most ordered products categories
SELECT
    product_category_name_translation.product_category_name_english
    ,COUNT(*) AS orders_count
FROM
    products
LEFT JOIN product_category_name_translation ON products.product_category_name = product_category_name_translation.product_category_name
LEFT JOIN order_items ON products.product_id = order_items.product_id
GROUP BY
    product_category_name_translation.product_category_name_english
ORDER BY
    orders_count DESC;


-- Get number of products sold per category for each seller
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
    ,COUNT(*) FILTER (WHERE product_category_name_translation.product_category_name_english = 'NULL') AS cat_NULL 
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
GROUP BY
    order_items.seller_id;





