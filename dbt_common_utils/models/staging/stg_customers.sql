{{
    config(
        schema='staging'
    )
}}

select
    customer_id,
    {{ coalesce_null('first_name') }} as first_name,
    {{ coalesce_null('last_name') }} as last_name,
    {{ coalesce_null('email', "'no-email@placeholder.com'") }} as email,
    {{ coalesce_null('country') }} as country,
    {{ coalesce_null('segment') }} as segment,
    cast(created_at as timestamp_ntz) as created_at,
    {{ current_timestamp_utc() }} as _loaded_at
from {{ source('raw', 'raw_customers') }}
