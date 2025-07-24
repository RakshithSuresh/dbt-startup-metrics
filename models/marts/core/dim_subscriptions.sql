{{ config(materialized = 'view') }}

select
  subscription_id,
  customer_id,
  lower(plan) as plan,
    status,
  start_date,
  end_date,
  monthly_revenue,
  date_diff(coalesce(end_date, current_date), start_date, day) as subscription_duration_days
from {{ ref('stg_subscriptions') }}
