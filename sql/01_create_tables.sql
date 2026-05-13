-- ============================================================
-- 01_create_tables.sql
-- Raw layer: load CSVs into DuckDB tables
-- ============================================================

create or replace table raw_customers as
    select * from read_csv_auto('data/customers.csv');

create or replace table raw_products as
    select * from read_csv_auto('data/products.csv');

create or replace table raw_orders as
    select * from read_csv_auto('data/orders.csv');

create or replace table raw_order_items as
    select * from read_csv_auto('data/order_items.csv');   