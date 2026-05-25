-- Anomaly detection: flag if revenue margin_pct is negative,
-- which could indicate pricing errors or data corruption
select
    order_year,
    order_month,
    segment,
    channel,
    gross_revenue,
    total_margin,
    margin_pct
from {{ ref('fct_revenue') }}
where margin_pct < 0
