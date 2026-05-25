{{
    config(
        schema='intermediate',
        materialized='view'
    )
}}

select
    {{ generate_surrogate_key(['o.order_id', 't.transaction_id']) }} as order_line_sk,
    o.order_id,
    o.customer_id,
    t.transaction_id,
    t.product_id,
    o.order_date,
    o.order_year,
    o.order_month,
    o.order_quarter,
    o.status,
    o.channel,
    o.currency_code,
    o.is_weekend_order,
    t.quantity,
    t.unit_price,
    t.discount_amount,
    t.tax_amount,
    t.line_total,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost_price,
    (t.quantity * p.cost_price) as line_cost,
    t.line_total - (t.quantity * p.cost_price) as line_margin,
    c.first_name || ' ' || c.last_name as customer_name,
    c.country,
    c.segment
from {{ ref('stg_orders') }} o
inner join {{ ref('stg_transactions') }} t
    on o.order_id = t.order_id
inner join {{ ref('stg_products') }} p
    on t.product_id = p.product_id
inner join {{ ref('stg_customers') }} c
    on o.customer_id = c.customer_id
