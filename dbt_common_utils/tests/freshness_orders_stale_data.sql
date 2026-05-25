-- Freshness check: flag if the most recent order is older than 90 days
-- This acts as a data staleness canary for the orders pipeline
select
    max(order_date) as latest_order_date,
    current_date() as check_date,
    datediff('day', max(order_date), current_date()) as days_since_last_order
from {{ ref('stg_orders') }}
having datediff('day', max(order_date), current_date()) > 730
