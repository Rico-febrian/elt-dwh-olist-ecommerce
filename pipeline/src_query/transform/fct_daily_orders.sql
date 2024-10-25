--
--- Query for load data and handling new data (upsert) from staging schema into final schema in DWH
--

WITH
    stg_orders AS (
        SELECT * 
        FROM stg.orders
    ),

    stg_order_items AS (
        SELECT *
        FROM stg.order_items
    ),
    
    dim_date AS (
        SELECT * 
        FROM final.dim_date
    ),

    dim_products AS (
        SELECT * 
        FROM final.dim_products
    ),

    dim_customers AS (
        SELECT * 
        FROM final.dim_customers
    ),

    dim_sellers AS (
        SELECT * 
        FROM final.dim_sellers
    ),

    cnt_total_order AS (
        SELECT 
            order_id,
            COUNT(DISTINCT order_id) AS total_order
        FROM stg_order_items
        GROUP BY 1
    ),

    cnt_total_quantity AS (
        SELECT 
            order_id,
            COUNT(order_item_id) AS total_quantity
        FROM stg_order_items
        GROUP BY 1
    ),

    cnt_total_price AS (
        SELECT 
            order_id,
            SUM(price) AS total_price
        FROM stg_order_items
        GROUP BY 1
    ),

    cnt_total_amount AS (
        SELECT
            order_id,
            (SUM(price) + SUM(freight_value)) AS total_amount
        FROM stg_order_items
        GROUP BY 1
    ),

    final_fct_daily_orders AS (
        SELECT
            dd.date_id AS order_date,
            dp.product_id,
            dc.customer_id,
            ds.seller_id,
            COUNT(DISTINCT cto.total_order) AS total_order,
            COUNT(ctq.total_quantity) AS total_quantity,
            SUM(cta.total_amount) AS total_amount

        FROM
            stg_orders o
        JOIN
            stg_order_items oi ON o.order_id = oi.order_id
        JOIN
            dim_products dp ON oi.product_id = dp.product_nk
        JOIN
            dim_customers dc ON o.customer_id = dc.customer_nk
        JOIN
            dim_sellers ds ON oi.seller_id = ds.seller_nk
        JOIN
            dim_date dd ON TO_DATE(o.order_purchase_timestamp, 'YYYY-MM-DD') = dd.date_actual
        JOIN
            cnt_total_order cto ON oi.order_id = cto.order_id
        JOIN
            cnt_total_quantity ctq ON oi.order_id = ctq.order_id
        JOIN
            cnt_total_amount cta ON oi.order_id = cta.order_id
        
        GROUP BY 
            dd.date_id,
            dp.product_id,
            dc.customer_id,
            ds.seller_id
    )

INSERT INTO final.fct_daily_orders(
    order_date,
    product_id,
    customer_id,
    seller_id,
    total_order,
    total_quantity,
    total_amount
)

SELECT * FROM final_fct_daily_orders

-- Handle new data
ON CONFLICT(order_date, product_id, customer_id, seller_id)
DO UPDATE SET
    total_quantity = EXCLUDED.total_quantity,
    total_amount = EXCLUDED.total_amount,

    -- Handle updated timestamp
    updated_at = CASE WHEN
                        final.fct_daily_orders.total_order <> EXCLUDED.total_order
                        OR final.fct_daily_orders.total_quantity <> EXCLUDED.total_quantity
                        OR final.fct_daily_orders.total_amount <> EXCLUDED.total_amount
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        final.fct_daily_orders.updated_at
                END;