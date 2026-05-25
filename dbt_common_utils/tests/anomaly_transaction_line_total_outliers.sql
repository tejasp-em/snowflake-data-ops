-- Anomaly detection: flag if any single order's line_total exceeds
-- 3 standard deviations from the mean, indicating potential data issues
select
    transaction_id,
    line_total,
    avg_line_total,
    stddev_line_total,
    (line_total - avg_line_total) / nullif(stddev_line_total, 0) as z_score
from (
    select
        transaction_id,
        line_total,
        avg(line_total) over () as avg_line_total,
        stddev(line_total) over () as stddev_line_total
    from {{ ref('stg_transactions') }}
) stats
where abs((line_total - avg_line_total) / nullif(stddev_line_total, 0)) > 3
