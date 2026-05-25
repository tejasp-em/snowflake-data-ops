{{
    config(
        schema='staging'
    )
}}

select
    order_id,
    customer_id,
    cast(order_date as date) as order_date,
    {{ coalesce_null('status') }} as status,
    {{ coalesce_null('channel') }} as channel,
    {{ coalesce_null('currency_code', "'USD'") }} as currency_code,
    {{ is_weekend('order_date') }} as is_weekend_order,
    {{ date_part_extract('year', 'order_date') }} as order_year,
    {{ date_part_extract('month', 'order_date') }} as order_month,
    {{ date_part_extract('quarter', 'order_date') }} as order_quarter,
    {{ current_timestamp_utc() }} as _loaded_at
from {{ source('raw', 'raw_orders') }}
