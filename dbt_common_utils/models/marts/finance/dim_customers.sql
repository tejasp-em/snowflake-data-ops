{{
    config(
        schema='marts_finance',
        materialized='table'
    )
}}

select
    {{ generate_surrogate_key(['c.customer_id']) }} as customer_sk,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.country,
    c.segment,
    c.created_at,
    count(distinct o.order_id) as lifetime_orders,
    sum(o.line_total) as lifetime_revenue,
    sum(o.line_margin) as lifetime_margin,
    min(o.order_date) as first_order_date,
    max(o.order_date) as last_order_date,
    datediff('day', min(o.order_date), max(o.order_date)) as customer_tenure_days,
    {{ current_timestamp_utc() }} as _updated_at
from {{ ref('stg_customers') }} c
left join {{ ref('int_orders_enriched') }} o
    on c.customer_id = o.customer_id
    and o.status in ('completed', 'pending')
group by
    c.customer_id, c.first_name, c.last_name, c.email,
    c.country, c.segment, c.created_at
