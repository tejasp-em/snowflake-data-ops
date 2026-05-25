{{
    config(
        schema='marts_markets',
        materialized='table'
    )
}}

select
    category,
    subcategory,
    product_name,
    order_year,
    order_quarter,
    order_month,
    channel,
    country,
    count(distinct order_id) as total_orders,
    count(distinct customer_id) as unique_customers,
    sum(quantity) as total_units_sold,
    sum(line_total) as gross_revenue,
    sum(line_margin) as total_margin,
    avg(unit_price) as avg_selling_price,
    avg(discount_amount) as avg_discount,
    case
        when sum(line_total) > 0
            then round(sum(discount_amount) / sum(line_total) * 100, 2)
        else 0
    end as discount_rate_pct
from {{ ref('int_orders_enriched') }}
where status in ('completed', 'pending')
group by 1, 2, 3, 4, 5, 6, 7, 8
