-- Referential integrity: flag orphaned transactions where the order_id
-- in stg_transactions does not exist in stg_orders
select
    t.transaction_id,
    t.order_id
from {{ ref('stg_transactions') }} t
left join {{ ref('stg_orders') }} o
    on t.order_id = o.order_id
where o.order_id is null
