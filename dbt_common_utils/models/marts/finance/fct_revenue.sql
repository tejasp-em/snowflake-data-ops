{{
    config(
        schema='marts_finance',
        materialized='table'
    )
}}

select
    order_year,
    order_quarter,
    order_month,
    segment,
    channel,
    currency_code,
    count(distinct order_id) as total_orders,
    count(distinct customer_id) as unique_customers,
    sum(quantity) as total_units_sold,
    sum(line_total) as gross_revenue,
    sum(discount_amount) as total_discounts,
    sum(tax_amount) as total_tax,
    sum(line_cost) as total_cost,
    sum(line_margin) as total_margin,
    case
        when sum(line_total) > 0
            then round(sum(line_margin) / sum(line_total) * 100, 2)
        else 0
    end as margin_pct
from {{ ref('int_orders_enriched') }}
where status in ('completed', 'pending')
group by 1, 2, 3, 4, 5, 6
