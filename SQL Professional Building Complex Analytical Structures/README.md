Mini‑Project: Business SQL (CTE + Window Functions + Segmentation)

A concise, reproducible recap of this week’s practice. The goal was to translate theory into hands‑on SQL using a tiny business dataset (customers, products, orders, order_items) and to answer practical questions with CTEs, window functions, and simple segmentation.

TL;DR

Focus: short, business‑oriented SQL tasks that reinforce theory: CTEs, window functions (rank, cumulative sums, partitions), RFM segmentation, cohorts, ABC/Pareto, and churn risk.

Engine: written for MySQL 8+ (portable to PostgreSQL/SQLite with minor syntax tweaks).

Outcome: a clear set of queries + outputs that can seed dashboards or stakeholder updates.

Dataset (toy, CSV-based)

Four small tables covering Jan–Mar 2025:

customers: customer_id, name, city, signup_date, acquisition_channel

products: product_id, product_name, category, list_price

orders: order_id, customer_id, order_date, order_channel

order_items: order_id, product_id, quantity, unit_price

Notes

orders has no product_id; join path is orders → order_items → products.

Monetary fields derived as quantity * unit_price.

Exercises & Theory Mapping
1) 30‑Day Revenue by Channel × Category (CTE + Aggregation)

Question: In the last 30 days (to 2025‑03‑31), which order_channel × product category drove more revenue?

Technique: CTE recent_orders (time filter) → join to order_items and products → SUM(quantity*unit_price) → GROUP BY channel, category.

Theory tie‑in: CTEs for logical scoping and readability; clean business aggregation.

Key result (sample): Web‑Subscription led (~107.99), followed by Store‑Service (~30.00), App‑Subscription (~19.99), Web‑AddOn (~18.00).

2) Monthly Customer Ranking (Window: RANK + Cumulative + % of Month)

Question: Within each month, who are the top customers and what is their cumulative contribution?

Technique: derive YYYY‑MM month; aggregate revenue per customer×month; apply RANK() and cumulative SUM() OVER (PARTITION BY month ORDER BY total DESC); compute % of month.

Theory tie‑in: Window functions to compare rows within a partition without collapsing detail.

Key result (sample): ties handled with RANK(); monthly totals: Jan 73.97, Feb 144.97, Mar 204.97.

3) Simple RFM (2×2) Segmentation (CTEs + CASE)

Question: Who are our Champions, Promising, Loyal, At Risk as of 2025‑03‑31?

Technique: CTE aggregates per customer → compute Recency (days since last order), Frequency (#orders), Monetary (total spend) → rule‑based labels via CASE.

Theory tie‑in: turn descriptive stats into actionable segments.

Key result (sample): several Champions with recent multi‑order activity; At Risk if last purchase >45 days and low frequency.

4) First‑Purchase Cohorts & Repeat

Question: For cohorts defined by first purchase month, how many repeat in the same month and in +1 month?

Technique: compute first_month per customer; join all their orders; flag repeat in same month and in first_month + 1; aggregate by first_month.

Theory tie‑in: Cohort analysis links acquisition timing with retention behavior.

Key result (sample): Jan cohort size=3, repeat+1 ≈ 0.67; Feb cohort size=4, repeat+1 ≈ 0.50; Mar cohort size=1, repeat+1=0.

5) Product ABC (Pareto) via Window Cumulative

Question: Which products are A/B/C by cumulative revenue contribution?

Technique: revenue per product; cumulative share with SUM() OVER (ORDER BY revenue DESC); thresholds A ≤70%, B ≤90%, C >90%.

Theory tie‑in: Pareto for prioritization (focus, pricing, promos, inventory).

Key result (sample): P003 and P002 cover >50%; P006/P004 push to ~84%; P001/P005 complete tail.

6) Quick Churn Risk (>45 days without purchase)

Question: Who hasn’t purchased in >45 days as of 2025‑03‑31?

Technique: last order per customer; DATEDIFF(cutoff, last_order_date) > 45; include acquisition_channel for outreach.

Theory tie‑in: simple leading indicator for retention actions.

Key result (sample): C004 flagged (57 days, channel: Ads).

How to Reproduce (MySQL 8+)

Create tables for the four entities (simple types: INT/VARCHAR/DATE/DECIMAL).

Load CSVs into each table.

(Optional) Create a view v_order_totals(order_id, order_total) as SUM(quantity*unit_price) per order.

Run each exercise query (E1–E6). Consider saving them as views for quick reuse.

Portability

PostgreSQL: replace DATE_FORMAT with TO_CHAR, DATEDIFF with AGE or date math; casting rules differ slightly.

SQLite: use strftime for month keys; window functions require v3.25+; pay attention to date strings.