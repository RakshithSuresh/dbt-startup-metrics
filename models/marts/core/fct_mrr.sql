-- Track monthly recurring revenue per customer subscription. This will be used for LTV, churn, and other KPIs.

{{ config(
    materialized = 'incremental',
    unique_key = ['subscription_id', 'month']
) }}

with subscriptions as (
    select
        subscription_id,
        customer_id,
        start_date,
        coalesce(end_date, current_date()) as end_date,
        monthly_revenue
    from {{ ref('stg_subscriptions') }}
),

month_grain as (
    select
        s.subscription_id,
        s.customer_id,
        s.monthly_revenue,
        date_trunc(month_date, month) as month
    from subscriptions s,
    unnest(generate_date_array(s.start_date, s.end_date, interval 1 month)) as month_date
)

select
    subscription_id,
    customer_id,
    month,
    monthly_revenue,
    monthly_revenue as mrr
from month_grain
