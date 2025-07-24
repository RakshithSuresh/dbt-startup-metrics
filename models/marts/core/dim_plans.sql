{{ config(materialized = 'view') }}

select distinct
  lower(plan) as plan,
  count(*) over (partition by lower(plan)) as plan_usage_count
from {{ ref('stg_subscriptions') }}
