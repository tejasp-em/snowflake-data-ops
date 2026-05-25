{{
    config(
        schema='staging'
    )
}}

select
    transaction_id,
    order_id,
    product_id,
    quantity,
    {{ cents_to_dollars('unit_price_cents') }} as unit_price,
    {{ cents_to_dollars('discount_cents') }} as discount_amount,
    {{ cents_to_dollars('tax_cents') }} as tax_amount,
    ({{ cents_to_dollars('unit_price_cents') }} * quantity)
        - {{ cents_to_dollars('discount_cents') }}
        + {{ cents_to_dollars('tax_cents') }} as line_total,
    {{ current_timestamp_utc() }} as _loaded_at
from {{ source('raw', 'raw_transactions') }}
