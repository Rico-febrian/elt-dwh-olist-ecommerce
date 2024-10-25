--
--- Query for load data and handling new data (upsert) from staging schema into final schema in DWH
--

INSERT INTO final.fct_order_payments(
    payment_id,
    order_id,
    customer_id,
    payment_type_id,
    payment_date,
    payment_sequential,
    payment_installments,
    payment_value
)

SELECT
    op.id as payment_id,
    fo.order_id,
    dc.customer_id,
    pt.payment_type_id,
    dd.date_id AS payment_date,
    op.payment_sequential,
    op.payment_installments,
    op.payment_value

FROM
    stg.orders o
JOIN
    stg.order_payments op ON o.order_id = op.order_id
JOIN
    final.dim_customers dc ON o.customer_id = dc.customer_nk
JOIN
    final.dim_payment_types pt ON op.payment_type = pt.payment_type 
JOIN
    final.dim_date dd ON TO_DATE(o.order_purchase_timestamp, 'YYYY-MM-DD') = dd.date_actual
JOIN
    final.fct_orders fo ON o.order_id = fo.dd_order_id

-- Handle new data
ON CONFLICT(payment_id, order_id, customer_id, payment_type_id, payment_date)
DO UPDATE SET
    payment_sequential = EXCLUDED.payment_sequential,
    payment_installments = EXCLUDED.payment_installments,
    payment_value = EXCLUDED.payment_value,

    -- Handle update timestamp
    updated_at = CASE WHEN
                        final.fct_order_payments.payment_sequential <> EXCLUDED.payment_sequential
                        OR final.fct_order_payments.payment_installments <> EXCLUDED.payment_installments
                        OR final.fct_order_payments.payment_value <> EXCLUDED.payment_value
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        final.fct_order_payments.updated_at
                END;