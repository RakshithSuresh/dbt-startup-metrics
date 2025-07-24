

{{ config(
    materialized = 'view',
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
        date_trunc(month_date, month) as month,
        c.acquisition_channel,
        c.country
    from subscriptions s
    left join {{ ref('dim_customers') }} c
      on s.customer_id = c.customer_id,
    unnest(generate_date_array(s.start_date, s.end_date, interval 1 month)) as month_date
)

select
    subscription_id,
    customer_id,
    month,
    monthly_revenue,
    monthly_revenue as mrr,
    acquisition_channel,
    country
from month_grain
