-- Anomaly detection: flag customers whose lifetime_revenue exceeds
-- 3 standard deviations from the mean, indicating potential data anomalies
select
    customer_id,
    lifetime_revenue,
    avg_revenue,
    stddev_revenue,
    (lifetime_revenue - avg_revenue) / nullif(stddev_revenue, 0) as z_score
from (
    select
        customer_id,
        lifetime_revenue,
        avg(lifetime_revenue) over () as avg_revenue,
        stddev(lifetime_revenue) over () as stddev_revenue
    from {{ ref('dim_customers') }}
    where lifetime_revenue is not null
) stats
where abs((lifetime_revenue - avg_revenue) / nullif(stddev_revenue, 0)) > 3
