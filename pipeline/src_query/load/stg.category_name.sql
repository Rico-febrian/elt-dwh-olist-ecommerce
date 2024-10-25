--
--- Query for load data and handling new data (upsert) from db sources into staging schema in DWH
--

INSERT INTO stg.product_category_name_translation 
    (product_category_name, product_category_name_english) 

SELECT
    product_category_name,
    product_category_name_english

FROM public.product_category_name_translation

-- Handle new data
ON CONFLICT(product_category_name) 
DO UPDATE SET
    product_category_name_english = EXCLUDED.product_category_name_english,

    -- Handle updated timestamp
    updated_at = CASE WHEN 
                        stg.product_category_name_translation.product_category_name_english <> EXCLUDED.product_category_name_english 
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        stg.product_category_name_translation.updated_at
                END;