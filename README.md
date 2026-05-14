# EcomPulse — E-commerce Sales Analytics

![SQL](https://img.shields.io/badge/SQL-DuckDB-yellow)
![Python](https://img.shields.io/badge/Python-3.12-blue)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-orange)
![Domain](https://img.shields.io/badge/Domain-E--commerce-green)
![Data](https://img.shields.io/badge/Data-Synthetic-lightgrey)

> **Which customers are churning? Which products drive profit? Where is revenue heading?**
> An end-to-end analytics pipeline that turns raw e-commerce data into actionable business intelligence.

---

## The Business Problem

An e-commerce company sells across 5 product categories to 200 customers in 10 European cities. The business team is flying blind:

- They don't know which product categories generate the most margin
- They can't identify customers with abnormal return rates before it hurts revenue
- They have no visibility on whether revenue is trending up or down month by month

**EcomPulse solves this.** A fully automated pipeline ingests, transforms, and delivers a 3-page Power BI dashboard that answers all three questions in seconds.

---

## What This Project Demonstrates

| Skill | Implementation |
|---|---|
| Python data generation | Realistic synthetic data with seeded risk patterns |
| SQL analytics layer | CTEs, window functions, LEFT JOINs, NULL safety |
| Pipeline orchestration | `run_pipeline.py` executes all layers in order |
| Dimensional thinking | Grain design, aggregation logic, edge case handling |
| Business intelligence | 3-page Power BI dashboard with conditional formatting |
| Data storytelling | Every visual answers one specific business question |

---

## Architecture

```
generate_data.py          Python — generates 4 CSV source files
       │
       ▼
01_create_tables.sql      Raw layer    — loads CSVs into DuckDB
02_staging.sql            Staging layer — cleans, casts, standardizes
03_analytics.sql          Analytics layer — answers business questions
04_outputs.sql            Output layer  — exports CSVs for Power BI
       │
       ▼
Power BI Dashboard        3 pages — Revenue, Customers, Trend
```

---

## The Data Model

```
customers ──────────────────────────────┐
  customer_id (PK)                       │
  city, country, segment                 │
  signup_date                            │
                                         ▼
products ──────────── order_items ◄──── orders
  product_id (PK)       order_id (FK)    order_id (PK)
  product_name          product_id (FK)  customer_id (FK)
  category              quantity         order_date
  unit_price            unit_price       status
  cost_price
```

`order_items` is the bridge table — the only place where customers, orders, and products meet. All revenue calculations flow through it.

---

## The Dashboard

### Page 1 — Revenue Overview
*"Which product categories make the most money?"*

- Bar chart of revenue by category, sorted descending
- KPI cards: Total Revenue, Units Sold, Avg Margin %

### Page 2 — Customer Segments
*"Which customers have abnormal return rates?"*

- Customer table with conditional formatting — high return rates highlighted in red
- Customers 1, 2, 3 are seeded with elevated return rates to simulate real-world risk signals
- Donut charts: B2B vs B2C split by customers and orders
- Bar chart: average return rate by segment
- Slicers: filter by segment and city

### Page 3 — Monthly Trend
*"Is revenue growing or declining?"*

- Dual-axis line chart: revenue and unique customers by month
- Peaks visible in March and October, dips in April and August

---

## Key Design Decisions

**1. Seeded risk patterns in the data**
Customers 1, 2, and 3 are intentionally generated with 60% return rates using weighted random sampling — `random.choices(STATUSES, weights=[30, 60, 10])`. This simulates a real-world scenario where a small subset of customers disproportionately drives return costs.

**2. LEFT JOIN for customer coverage**
`customer_segments` uses `LEFT JOIN` instead of `INNER JOIN` so customers with zero orders still appear in the output. An `INNER JOIN` would silently drop them — a common analytical mistake that hides churn signals.

**3. NULLIF for division safety**
`return_rate_pct` uses `NULLIF(total_orders, 0)` to avoid division by zero for customers with no orders. Without this, the pipeline crashes on edge cases.

**4. CTE-based analytics layer**
All analytics tables use CTEs to separate the calculation logic from the aggregation logic. Each step is readable independently — easier to debug, easier to extend.

**5. Idempotent pipeline**
Every SQL file uses `CREATE OR REPLACE` — the pipeline can be re-run safely at any time without duplicating data or throwing errors.

---

## How to Run

**Requirements**
```bash
python3 --version   # 3.9 or higher
pip install pandas duckdb
```

**Setup**
```bash
git clone https://github.com/yourusername/ecompulse.git
cd ecompulse
python3 -m venv venv
source venv/bin/activate
pip install pandas duckdb
```

**Run the full pipeline**
```bash
# Step 1 — Generate source data
python3 generate_data.py

# Step 2 — Run SQL pipeline (raw → staging → analytics → outputs)
python3 run_pipeline.py
```

**Expected output**
```
EcomPulse Pipeline
========================================
[1/4] Loading raw tables...
[2/4] Creating staging views...
[3/4] Creating analytics tables...
[4/4] Exporting output CSVs...
Pipeline complete.
```

**Step 3 — Open Power BI**

Load the 3 files from `outputs/` into Power BI Desktop:
- `revenue_by_product.csv`
- `customer_segments.csv`
- `monthly_trend.csv`

> **Note for non-English Windows:** When loading CSVs, set locale to English (United States) in Transform Data to ensure decimal points are read correctly.

---

## Project Structure

```
ecompulse/
├── generate_data.py          Data generation — 4 CSV source files
├── run_pipeline.py           Pipeline orchestrator
├── data/
│   ├── customers.csv         200 customers across 10 European cities
│   ├── products.csv          50 products across 5 categories
│   ├── orders.csv            2,000 orders (2023–2024)
│   └── order_items.csv       ~4,500 line items
├── sql/
│   ├── 01_create_tables.sql  Raw layer
│   ├── 02_staging.sql        Staging layer
│   ├── 03_analytics.sql      Analytics layer
│   └── 04_outputs.sql        Output layer
├── outputs/
│   ├── revenue_by_product.csv
│   ├── customer_segments.csv
│   └── monthly_trend.csv
└── powerbi/
    └── ecompulse.pbix        Power BI dashboard (3 pages)
```

---

## Tech Stack

![Python](https://img.shields.io/badge/Python-3.12-blue)
![DuckDB](https://img.shields.io/badge/DuckDB-SQL-yellow)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-orange)

- **Python** — data generation with `pandas` and `random`
- **DuckDB** — local SQL engine, fully compatible with PostgreSQL and Snowflake syntax
- **SQL** — CTEs, aggregations, LEFT JOINs, NULLIF, DATE_TRUNC
- **Power BI** — conditional formatting, slicers, dual-axis charts

---

## Possible Extensions

- Connect Power BI directly to DuckDB via ODBC (remove CSV export step)
- Add a Snowflake layer to replace DuckDB for cloud-scale processing
- Schedule the pipeline with a cron job or Airflow DAG
- Add dbt models to replace the manual SQL files
- Expand to 100k+ rows to demonstrate query performance

---

## Author

**Sergi de la Cruz Núñez**
[LinkedIn](https://linkedin.com/in/sergidelacruz) · sergidelacruz1994@gmail.com
