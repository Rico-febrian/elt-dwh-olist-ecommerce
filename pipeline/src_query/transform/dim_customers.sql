--
--- Query for load data and handling new data (upsert) from staging schema into final schema in DWH
--

INSERT INTO final.dim_customers(
    customer_id,
    customer_nk,
    customer_unique_id,
    geolocation_id
)

SELECT
    c.id as customer_id,
    c.customer_id as customer_nk,
    c.customer_unique_id,
    g.geolocation_id
FROM
    stg.customers c
JOIN 
    final.dim_geolocation g
ON
    c.customer_zip_code_prefix = g.geolocation_zip_code_prefix

-- Handle new data
ON CONFLICT(customer_id)
DO UPDATE SET
    customer_nk = EXCLUDED.customer_nk,
    customer_unique_id = EXCLUDED.customer_unique_id,
    geolocation_id = EXCLUDED.geolocation_id,

    -- Handle updated timestamp
    updated_at = CASE WHEN
                        final.dim_customers.customer_nk <> EXCLUDED.customer_nk
                        OR final.dim_customers.customer_unique_id <> EXCLUDED.customer_unique_id
                        OR final.dim_customers.geolocation_id <> EXCLUDED.geolocation_id
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        final.dim_customers.updated_at
                END;