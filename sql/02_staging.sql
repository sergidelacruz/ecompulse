-- ============================================================
-- 02_staging.sql
-- Staging layer: clean, cast types, rename columns
-- ============================================================

CREATE OR REPLACE VIEW stg_customers AS
    SELECT
        customer_id,
        city,
        country,
        segment,
        CAST(signup_date AS DATE) AS signup_date
    FROM raw_customers;

CREATE OR REPLACE VIEW stg_orders AS
    SELECT
        order_id,
        customer_id,
        CAST(order_date AS DATE) AS order_date,
        status
    FROM raw_orders;
    
create or replace view stg_products as
    select
        product_id,
        product_name,
        category,
        CAST(unit_price as decimal(10,2)) as unit_price,
        CAST(cost_price as decimal(10,2)) as cost_price
    from raw_products;

create or replace view stg_order_items as
    select
        order_id,
        product_id,
        quantity,
        CAST(unit_price as decimal(10,2)) as unit_price
    from raw_order_items;