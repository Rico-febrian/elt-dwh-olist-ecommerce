-- Data Warehouse Final Schema

-- Create UUID extension if not exist yet
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the schema if not exist yet
CREATE SCHEMA IF NOT EXISTS final AUTHORIZATION postgres;

------------------------------------------------------------------------------------------

-- CREATE DIMENSION TABLES

--
-- Name: dim_geolocation; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.dim_geolocation (
    geolocation_id uuid default uuid_generate_v4(),
    geolocation_zip_code_prefix integer NOT NULL,
    geolocation_lat real,
    geolocation_lng real,
    geolocation_city text,
    geolocation_state text,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: dim_customer; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.dim_customers (
    customer_id uuid default uuid_generate_v4(),
    customer_nk text NOT NULL,
    customer_unique_id text,
    geolocation_id uuid,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: dim_sellers; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.dim_sellers (
    seller_id uuid default uuid_generate_v4(),
    seller_nk text NOT NULL,
    geolocation_id uuid,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: dim_products; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.dim_products (
    product_id uuid default uuid_generate_v4(),
    product_nk text NOT NULL,
    product_category_name text,
    product_category_name_english text,
    product_name_lenght real,
    product_description_lenght real,
    product_photos_qty real,
    product_weight_g real,
    product_length_cm real,
    product_height_cm real,
    product_width_cm real,
    current_flag text default 'current',
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: dim_order_status; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.dim_order_status (
    order_status_id uuid default uuid_generate_v4(),
    order_status text NOT NULL
);

--
-- Name: dim_payment_types; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.dim_payment_types (
    payment_type_id uuid default uuid_generate_v4(),
    payment_type text NOT NULL
);

--
-- Name: dim_date; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.dim_date(
    date_id              	 INT NOT null,
    date_actual              DATE NOT NULL,
    day_suffix               VARCHAR(4) NOT NULL,
    day_name                 VARCHAR(9) NOT NULL,
    day_of_year              INT NOT NULL,
    week_of_month            INT NOT NULL,
    week_of_year             INT NOT NULL,
    week_of_year_iso         CHAR(10) NOT NULL,
    month_actual             INT NOT NULL,
    month_name               VARCHAR(9) NOT NULL,
    month_name_abbreviated   CHAR(3) NOT NULL,
    quarter_actual           INT NOT NULL,
    quarter_name             VARCHAR(9) NOT NULL,
    year_actual              INT NOT NULL,
    first_day_of_week        DATE NOT NULL,
    last_day_of_week         DATE NOT NULL,
    first_day_of_month       DATE NOT NULL,
    last_day_of_month        DATE NOT NULL,
    first_day_of_quarter     DATE NOT NULL,
    last_day_of_quarter      DATE NOT NULL,
    first_day_of_year        DATE NOT NULL,
    last_day_of_year         DATE NOT NULL,
    mmyyyy                   CHAR(6) NOT NULL,
    mmddyyyy                 CHAR(10) NOT NULL,
    weekend_indr             VARCHAR(20) NOT NULL
);

------------------------------------------------------------------------------------------

-- CREATE FACT TABLES

--
-- Name: fct_orders; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.fct_orders (
	order_id uuid default uuid_generate_v4(),
    dd_order_id text NOT NULL,
	product_id uuid,
	customer_id uuid,
    seller_id uuid,
    order_status_id uuid,
	order_date int,
    total_quantity int,
	total_price real,
    total_freight real,
    total_amount real,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: fct_daily_orders; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.fct_daily_orders (
	order_date int,
	product_id uuid,
    customer_id uuid,
    seller_id uuid,
    total_order int,
    total_quantity int,
	total_amount real,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: fct_order_payments; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.fct_order_payments (
	payment_id uuid default uuid_generate_v4(),
	order_id uuid,
    customer_id uuid,
    payment_type_id uuid,
    payment_date int,
    payment_sequential int,
    payment_installments int,
    payment_value real,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: fct_order_delivery; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.fct_order_delivery (
	delivery_id uuid default uuid_generate_v4(),
    order_id uuid,
	customer_id uuid,
    seller_id uuid,
	order_received_date int,
    process_date int,
    success_date int,
    estimated_date int,
    day_process int,
    day_success int,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: fct_customer_reviews; Type: TABLE; Schema: final; Owner: postgres
--

CREATE TABLE final.fct_customer_reviews (
	review_id uuid default uuid_generate_v4(),
    dd_review_id text NOT NULL,
	customer_id uuid,
    seller_id uuid,
    product_id uuid,
	review_date int,
    review_score int,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

------------------------------------------------------------------------------------------

-- ADD PRIMARY KEY FOR EACH DIMENSION TABLES

--
-- Name: dim_geolocation geolocation_pk; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.dim_geolocation
    ADD CONSTRAINT geolocation_pk PRIMARY KEY (geolocation_id);

--
-- Name: dim_customers pk_customers; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.dim_customers
    ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);

--
-- Name: dim_sellers pk_sellers; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.dim_sellers
    ADD CONSTRAINT pk_sellers PRIMARY KEY (seller_id);

--
-- Name: dim_products pk_products; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.dim_products
    ADD CONSTRAINT pk_products PRIMARY KEY (product_id);

--
-- Name: dim_order_status pk_order_status; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.dim_order_status
    ADD CONSTRAINT pk_order_status PRIMARY KEY (order_status_id);

--
-- Name: dim_payment_types pk_payment_types; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.dim_payment_types
    ADD CONSTRAINT pk_payment_types PRIMARY KEY (payment_type_id);

--
-- Name: dim_date pk_date; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.dim_date
    ADD CONSTRAINT pk_date PRIMARY KEY (date_id);

------------------------------------------------------------------------------------------

-- ADD PRIMARY KEY FOR EACH FACT TABLES

--
-- Name: fct_orders pk_fct_orders; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_orders
    ADD CONSTRAINT pk_fct_orders PRIMARY KEY (order_id);

--
-- Name: fct_daily_orders pk_fct_daily_orders; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_daily_orders
    ADD CONSTRAINT pk_fct_daily_orders PRIMARY KEY (order_date, product_id, customer_id, seller_id);

--
-- Name: fct_order_payments pk_fct_order_payments; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_payments
    ADD CONSTRAINT pk_fct_order_payments PRIMARY KEY (payment_id, order_id, customer_id, payment_type_id, payment_date);

--
-- Name: fct_order_delivery pk_fct_order_delivery; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_delivery
    ADD CONSTRAINT pk_fct_order_delivery PRIMARY KEY (delivery_id, customer_id, seller_id, order_received_date);

--
-- Name: fct_customer_reviews pk_fct_customer_reviews; Type: CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_customer_reviews
    ADD CONSTRAINT pk_fct_customer_reviews PRIMARY KEY (review_id, dd_review_id, customer_id, seller_id, product_id, review_date);

------------------------------------------------------------------------------------------

-- ADD UNIQUE CONSTRAINTS TO ORDERS FACT TABLE

ALTER TABLE final.fct_orders
ADD CONSTRAINT fct_order_unique UNIQUE (order_id, dd_order_id, product_id, customer_id, seller_id, order_status_id, order_date);

------------------------------------------------------------------------------------------

-- ADD FOREIGN KEY FOR DIMENSION TABLE (CREATE A RELATION)

--
-- Name: dim_customers fk_cust_geolocation; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.dim_customers
    ADD CONSTRAINT fk_cust_geolocation FOREIGN KEY (geolocation_id) REFERENCES final.dim_geolocation(geolocation_id);

--
-- Name: dim_sellers fk_sellers_geolocation; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.dim_sellers
    ADD CONSTRAINT fk_sellers_geolocation FOREIGN KEY (geolocation_id) REFERENCES final.dim_geolocation(geolocation_id);

------------------------------------------------------------------------------------------

-- ADD FOREIGN KEY FOR FACT TABLE (CREATE A RELATION)


-- FACT ORDERS

--
-- Name: fct_orders fk_orders_products; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_orders
    ADD CONSTRAINT fk_orders_products FOREIGN KEY (product_id) REFERENCES final.dim_products(product_id);

--
-- Name: fct_orders fk_orders_customers; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_orders
    ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES final.dim_customers(customer_id);

--
-- Name: fct_orders fk_orders_sellers; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_orders
    ADD CONSTRAINT fk_orders_sellers FOREIGN KEY (seller_id) REFERENCES final.dim_sellers(seller_id);

--
-- Name: fct_orders fk_orders_odstatus; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_orders
    ADD CONSTRAINT fk_orders_odstatus FOREIGN KEY (order_status_id) REFERENCES final.dim_order_status(order_status_id);

--
-- Name: fct_orders fk_orders_date; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_orders
    ADD CONSTRAINT fk_orders_date FOREIGN KEY (order_date) REFERENCES final.dim_date(date_id);

------------------------------------------------------------------------------------------

-- FACT DAILY ORDERS

--
-- Name: fct_daily_orders fk_daily_orders_products; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_daily_orders
    ADD CONSTRAINT fk_daily_orders_products FOREIGN KEY (product_id) REFERENCES final.dim_products(product_id);

--
-- Name: fct_daily_orders fk_daily_orders_sellers; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_daily_orders
    ADD CONSTRAINT fk_daily_orders_sellers FOREIGN KEY (seller_id) REFERENCES final.dim_sellers(seller_id);

--
-- Name: fct_daily_orders fk_daily_orders_date; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_daily_orders
    ADD CONSTRAINT fk_daily_orders_date FOREIGN KEY (order_date) REFERENCES final.dim_date(date_id);

------------------------------------------------------------------------------------------

-- FACT ORDER PAYMENTS

--
-- Name: fct_order_payments fk_payments_orders; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_payments
    ADD CONSTRAINT fk_payments_orders FOREIGN KEY (order_id) REFERENCES final.fct_orders(order_id);

--
-- Name: fct_order_payments fk_payments_customers; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_payments
    ADD CONSTRAINT fk_payments_customers FOREIGN KEY (customer_id) REFERENCES final.dim_customers(customer_id);

--
-- Name: fct_order_payments fk_payments_ptypes; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_payments
    ADD CONSTRAINT fk_payments_ptypes FOREIGN KEY (payment_type_id) REFERENCES final.dim_payment_types(payment_type_id);   
   
--
-- Name: fct_order_payments fk_payments_date; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_payments
    ADD CONSTRAINT fk_payments_date FOREIGN KEY (payment_date) REFERENCES final.dim_date(date_id);

------------------------------------------------------------------------------------------

-- FACT ORDER DELIVERY

--
-- Name: fct_order_delivery fk_delivery_fctorders; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_delivery
    ADD CONSTRAINT fk_delivery_fctorders FOREIGN KEY (order_id) REFERENCES final.fct_orders(order_id);

--
-- Name: fct_order_delivery fk_delivery_customers; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_delivery
    ADD CONSTRAINT fk_delivery_customers FOREIGN KEY (customer_id) REFERENCES final.dim_customers(customer_id);

--
-- Name: fct_order_delivery fk_delivery_sellers; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_delivery
    ADD CONSTRAINT fk_delivery_sellers FOREIGN KEY (seller_id) REFERENCES final.dim_sellers(seller_id);

--
-- Name: fct_order_delivery fk_delivery_received; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_delivery
    ADD CONSTRAINT fk_delivery_received FOREIGN KEY (order_received_date) REFERENCES final.dim_date(date_id);

--
-- Name: fct_order_delivery fk_delivery_process; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_delivery
    ADD CONSTRAINT fk_delivery_process FOREIGN KEY (process_date) REFERENCES final.dim_date(date_id);

--
-- Name: fct_order_delivery fk_delivery_success; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_delivery
    ADD CONSTRAINT fk_delivery_success FOREIGN KEY (success_date) REFERENCES final.dim_date(date_id);

--
-- Name: fct_order_delivery fk_delivery_estimated; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_order_delivery
    ADD CONSTRAINT fk_delivery_estimated FOREIGN KEY (estimated_date) REFERENCES final.dim_date(date_id);

------------------------------------------------------------------------------------------

-- FACT CUSTOMER REVIEWS

--
-- Name: fct_customer_reviews fk_review_customers; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_customer_reviews
    ADD CONSTRAINT fk_review_customers FOREIGN KEY (customer_id) REFERENCES final.dim_customers(customer_id);

--
-- Name: fct_customer_reviews fk_review_sellers; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_customer_reviews
    ADD CONSTRAINT fk_review_sellers FOREIGN KEY (seller_id) REFERENCES final.dim_sellers(seller_id);

--
-- Name: fct_customer_reviews fk_review_products; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_customer_reviews
    ADD CONSTRAINT fk_review_products FOREIGN KEY (product_id) REFERENCES final.dim_products(product_id);

--
-- Name: fct_customer_reviews fk_review_date; Type: FK CONSTRAINT; Schema: final; Owner: postgres
--

ALTER TABLE ONLY final.fct_customer_reviews
    ADD CONSTRAINT fk_review_date FOREIGN KEY (review_date) REFERENCES final.dim_date(date_id);

------------------------------------------------------------------------------------------

-- CREATE INDEX FOR FACT TABLES

-- fct_orders index
CREATE UNIQUE INDEX idx_unique_fct_orders ON final.fct_orders (order_id, dd_order_id, product_id, customer_id, seller_id, order_status_id, order_date);

-- fct_daily_orders index
CREATE UNIQUE INDEX idx_unique_fct_daily_orders ON final.fct_daily_orders (order_date, product_id, customer_id, seller_id);

-- fct_order_payments index
CREATE UNIQUE INDEX idx_unique_fct_order_payments ON final.fct_order_payments (payment_id, order_id, customer_id, payment_type_id, payment_date);

-- fct_order_delivery index
CREATE UNIQUE INDEX idx_unique_fct_order_delivery ON final.fct_order_delivery (delivery_id, order_id, customer_id, seller_id, order_received_date);

-- fct_customer_reviews index 
CREATE UNIQUE INDEX idx_unique_fct_customer_reviews ON final.fct_customer_reviews (review_id, dd_review_id, customer_id, seller_id, product_id);

------------------------------------------------------------------------------------------

-- POPULATING DATA FOR GENERATED DIMENSION TABLES

-- Populating for staging order status dimension 
INSERT INTO final.dim_order_status (order_status)
VALUES 
    ('approved'),
    ('canceled'),
    ('created'),
    ('delivered'),
    ('invoiced'),
    ('processing'),
    ('shipped'),
    ('unavailable');

-- Populating for staging payment types dimension 
INSERT INTO final.dim_payment_types (payment_type)
VALUES 
    ('boleto'),
    ('credit_card'),
    ('debit_card'),
    ('not_defined'),
    ('voucher');

-- Populating for staging date dimension 
INSERT INTO final.dim_date
SELECT TO_CHAR(datum, 'yyyymmdd')::INT AS date_id,
       datum AS date_actual,
       TO_CHAR(datum, 'fmDDth') AS day_suffix,
       TO_CHAR(datum, 'TMDay') AS day_name,
       EXTRACT(DOY FROM datum) AS day_of_year,
       TO_CHAR(datum, 'W')::INT AS week_of_month,
       EXTRACT(WEEK FROM datum) AS week_of_year,
       EXTRACT(ISOYEAR FROM datum) || TO_CHAR(datum, '"-W"IW') AS week_of_year_iso,
       EXTRACT(MONTH FROM datum) AS month_actual,
       TO_CHAR(datum, 'TMMonth') AS month_name,
       TO_CHAR(datum, 'Mon') AS month_name_abbreviated,
       EXTRACT(QUARTER FROM datum) AS quarter_actual,
       CASE
           WHEN EXTRACT(QUARTER FROM datum) = 1 THEN 'First'
           WHEN EXTRACT(QUARTER FROM datum) = 2 THEN 'Second'
           WHEN EXTRACT(QUARTER FROM datum) = 3 THEN 'Third'
           WHEN EXTRACT(QUARTER FROM datum) = 4 THEN 'Fourth'
           END AS quarter_name,
       EXTRACT(YEAR FROM datum) AS year_actual,
       datum + (1 - EXTRACT(ISODOW FROM datum))::INT AS first_day_of_week,
       datum + (7 - EXTRACT(ISODOW FROM datum))::INT AS last_day_of_week,
       datum + (1 - EXTRACT(DAY FROM datum))::INT AS first_day_of_month,
       (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE AS last_day_of_month,
       DATE_TRUNC('quarter', datum)::DATE AS first_day_of_quarter,
       (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter,
       TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') AS first_day_of_year,
       TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') AS last_day_of_year,
       TO_CHAR(datum, 'mmyyyy') AS mmyyyy,
       TO_CHAR(datum, 'mmddyyyy') AS mmddyyyy,
       CASE
           WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN 'weekend'
           ELSE 'weekday'
           END AS weekend_indr
FROM (SELECT '1998-01-01'::DATE + SEQUENCE.DAY AS datum
      FROM GENERATE_SERIES(0, 29219) AS SEQUENCE (DAY)
      GROUP BY SEQUENCE.DAY) DQ
ORDER BY 1;