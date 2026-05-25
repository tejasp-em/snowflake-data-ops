{{
    config(
        schema='staging'
    )
}}

select
    product_id,
    {{ coalesce_null('product_name') }} as product_name,
    {{ coalesce_null('category') }} as category,
    {{ coalesce_null('subcategory') }} as subcategory,
    {{ cents_to_dollars('unit_price_cents') }} as unit_price,
    {{ cents_to_dollars('cost_price_cents') }} as cost_price,
    cast(launch_date as date) as launch_date,
    is_active,
    {{ current_timestamp_utc() }} as _loaded_at
from {{ source('raw', 'raw_products') }}
