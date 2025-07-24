{{ config(
    materialized = 'view'
) }}

select
    subscription_id,
    customer_id,
    plan,
    date_trunc(end_date, month) as end_month,  -- DATE type for proper filtering/joins
    monthly_revenue
from {{ ref('stg_subscriptions') }}
where end_date is not null
  and status = 'cancelled'
