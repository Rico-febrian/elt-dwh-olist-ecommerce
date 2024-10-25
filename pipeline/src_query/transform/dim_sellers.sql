--
--- Query for load data and handling new data (upsert) from staging schema into final schema in DWH
--

INSERT INTO final.dim_sellers(
    seller_id,
    seller_nk,
    geolocation_id
)

SELECT
    s.id AS seller_id,
    s.seller_id AS seller_nk,
    g.geolocation_id
FROM
    stg.sellers s
JOIN
    final.dim_geolocation g
ON
    s.seller_zip_code_prefix = g.geolocation_zip_code_prefix

-- Handle new data
ON CONFLICT(seller_id)
DO UPDATE SET
    seller_nk = EXCLUDED.seller_nk,
    geolocation_id = EXCLUDED.geolocation_id,

    -- Handle updated timestamp
    updated_at = CASE WHEN
                        final.dim_sellers.seller_nk <> EXCLUDED.seller_nk
                        OR final.dim_sellers.geolocation_id <> EXCLUDED.geolocation_id
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        final.dim_sellers.updated_at
                END;