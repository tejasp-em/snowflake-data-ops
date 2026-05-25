-- Anomaly detection: flag if any month's order count deviates more than
-- 3 standard deviations from the overall monthly average
select
    order_year,
    order_month,
    monthly_orders,
    avg_monthly_orders,
    stddev_monthly_orders,
    (monthly_orders - avg_monthly_orders) / nullif(stddev_monthly_orders, 0) as z_score
from (
    select
        order_year,
        order_month,
        count(*) as monthly_orders,
        avg(count(*)) over () as avg_monthly_orders,
        stddev(count(*)) over () as stddev_monthly_orders
    from {{ ref('stg_orders') }}
    group by order_year, order_month
) stats
where abs((monthly_orders - avg_monthly_orders) / nullif(stddev_monthly_orders, 0)) > 3
