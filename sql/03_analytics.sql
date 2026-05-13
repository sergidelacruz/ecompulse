-- ============================================================
-- 03_analytics.sql
-- Analytics layer: answer business questions
-- ============================================================

--Business question → grain → columns needed → tables to join → edge cases to protect

-- ====== 1. WHICH PRODUCTS MAKE THE MOST MONEY? (One row per product) ====== 

-- Which product? → product_id, product_name, category
-- How much did it sell? → total_revenue = sum of quantity × unit_price
-- What did it cost? → total_cost = sum of quantity × cost_price
-- How many units? → units_sold
-- What's the profit? → gross_profit = revenue - cost
-- What's the margin? → margin_pct = profit / revenue × 100

/*Tables needed: order_items has quantities and prices, 
    products has names and costs, 
    orders has status to filter only completed.

Edge cases: only count completed orders — returned and cancelled orders never generated real revenue.*/  

create or replace table revenue_by_product as
    with order_revenue as (
        select
            oi.product_id,
            p.product_name,
            p.category,
            SUM(oi.quantity * oi.unit_price) as total_revenue,
            SUM(oi.quantity * p.cost_price) as total_cost,
            SUM(oi.quantity) as units_sold
        from stg_order_items oi
        inner join stg_products p on oi.product_id = p.product_id
        inner join stg_orders o on oi.order_id = o.order_id
        where o.status = 'completed'
        group by oi.product_id, p.product_name, p.category
    )
    select 
        *,
        round(total_revenue - total_cost, 2) as gross_profit,
        round((total_revenue - total_cost) / total_revenue * 100, 2) as margin_pct
    from order_revenue;

-- ======  2. WHICH CUSTOMERS HAVE HIGH RETURN RATES? (One row per customer) ====== 

-- Who is the customer? → customer_id, city, country, segment
-- How active are they? → total_orders
-- How many completed? → completed_orders
-- How many returned? → returned_orders
-- What's the return rate? → return_rate_pct = returned / total × 100

-- Tables needed: customers has identity and location, orders has status per order. Join on customer_id.

-- Edge cases: LEFT JOIN keeps customers with zero orders,
-- NULLIF turns zero into NULL. A customer with zero orders would break the division

create or replace table customer_segments as
    with customer_stats as (
        select
            c.customer_id,
            c.city,
            c.country,
            c.segment,
            count(o.order_id) as total_orders,
            sum(case when o.status = 'returned' then 1 else 0 end) as returned_orders,
            sum(case when o.status = 'completed' then 1 else 0 end) as completed_orders
        from stg_customers c
        left join stg_orders o on c.customer_id = o.customer_id 
        group by c.customer_id, c.city, c.country, c.segment
)
select 
    *,
    round(returned_orders * 100.0 / nullif(total_orders, 0), 2) as return_rate_pct 
from customer_stats;

-- ====== HOW IS REVENUE TRENDING MONTH BY MONTH? (One row per month) ====== 

-- Which month? → month
-- How many orders? → total_orders
-- How much revenue? → total_revenue
-- How many unique buyers? → unique_customers

-- Tables needed: orders has dates and status, order_items has the revenue per line. Join on order_id.
-- Edge cases: Only completed orders count for revenue. DATE_TRUNC('month', order_date) rounds every date down to the first of its month

create or replace table monthly_trend as 
    select
        date_trunc('month', o.order_date) as month,
        count(o.order_id) as total_orders,
        sum(oi.quantity * oi.unit_price) as total_revenue,
        count(distinct o.customer_id) as unique_customers
    from stg_orders o
    inner join stg_order_items oi on o.order_id = oi.order_id
    where o.status = 'completed'
    group by date_trunc('month', o.order_date)
    order by month;