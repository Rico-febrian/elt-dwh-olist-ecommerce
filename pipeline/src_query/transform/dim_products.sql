--
--- Query for load data and handling new data (upsert) from staging schema into final schema in DWH
--

INSERT INTO final.dim_products(
    product_id,
    product_nk,
    product_category_name,
    product_category_name_english,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    current_flag
)

SELECT
    p.id as product_id,
    p.product_id as product_nk,
    p.product_category_name,
    pc.product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    'current' AS current_flag -- Assign "current" for new records if there is a cahnge in product category
FROM
    stg.products p
JOIN
    stg.product_category_name_translation pc
ON 
    p.product_category_name = pc.product_category_name

-- Handle new data
ON CONFLICT(product_id)
DO UPDATE SET
    product_nk = EXCLUDED.product_nk,
    product_category_name = EXCLUDED.product_category_name,
    product_category_name_english = EXCLUDED.product_category_name_english,
    product_name_lenght = EXCLUDED.product_name_lenght,
    product_description_lenght = EXCLUDED.product_description_lenght,
    product_photos_qty = EXCLUDED.product_photos_qty,
    product_weight_g = EXCLUDED.product_weight_g,
    product_length_cm = EXCLUDED.product_length_cm,
    product_height_cm = EXCLUDED.product_height_cm,
    product_width_cm = EXCLUDED.product_width_cm,
    
    -- Handle current_flag for SCD type 2 on product category
    current_flag = CASE WHEN
                        final.dim_products.current_flag = 'current' 
                        AND (
                            final.dim_products.product_category_name <> EXCLUDED.product_category_name
                            OR final.dim_products.product_category_name_english <> EXCLUDED.product_category_name_english
                            )                  
                    THEN
                        'expired' -- Mark previous records as "expired" if there is a change in product category
                    END,

    -- Handle updated timestamp
    updated_at = CASE WHEN
                        final.dim_products.product_nk <> EXCLUDED.product_nk
                        OR final.dim_products.product_category_name <> EXCLUDED.product_category_name
                        OR final.dim_products.product_category_name_english <> EXCLUDED.product_category_name_english
                        OR final.dim_products.product_name_lenght <> EXCLUDED.product_name_lenght
                        OR final.dim_products.product_description_lenght <> EXCLUDED.product_description_lenght
                        OR final.dim_products.product_photos_qty <> EXCLUDED.product_photos_qty
                        OR final.dim_products.product_weight_g <> EXCLUDED.product_weight_g
                        OR final.dim_products.product_length_cm <> EXCLUDED.product_length_cm
                        OR final.dim_products.product_height_cm <> EXCLUDED.product_height_cm
                        OR final.dim_products.product_width_cm <> EXCLUDED.product_width_cm
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        final.dim_products.updated_at
                END;