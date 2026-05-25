{{
    config(
        schema='marts_markets',
        materialized='table'
    )
}}

select
    {{ generate_surrogate_key(['p.product_id']) }} as product_sk,
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.unit_price as list_price,
    p.cost_price,
    p.launch_date,
    p.is_active,
    datediff('day', p.launch_date, current_date()) as days_since_launch,
    {{ current_timestamp_utc() }} as _updated_at
from {{ ref('stg_products') }} p
