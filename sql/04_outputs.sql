-- ============================================================
-- 04_outputs.sql
-- Outputs layer: transform analytics table into CSVs, ready to dashboarding
-- ============================================================

-- ── Output 1: Revenue by product ──────────────────────────────
-- Powers Page 1 (watchlist table + KPI cards + bar chart)

COPY revenue_by_product TO 'outputs/revenue_by_product.csv' (FORMAT CSV,HEADER TRUE);

COPY customer_segments TO 'outputs/customer_segments.csv' (FORMAT CSV,HEADER TRUE);

COPY monthly_trend TO 'outputs/monthly_trend.csv' (FORMAT CSV,HEADER TRUE);
