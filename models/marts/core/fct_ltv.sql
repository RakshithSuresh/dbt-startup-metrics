{{ config(
    materialized = 'view'
) }}

with base as (
    select
        customer_id,
        subscription_id,
        start_date,
        end_date,
        monthly_revenue,
        status
    from {{ ref('stg_subscriptions') }}
),

ltv_calc as (
    select
        customer_id,
        count(distinct subscription_id) as num_subscriptions,
        min(start_date) as first_subscription,
        max(coalesce(end_date, current_date)) as last_subscription,
        sum(monthly_revenue * (timestamp_diff(coalesce(end_date, current_date), start_date, month))) as total_ltv,
        cast(max(case when status = 'active' then 1 else 0 end) as int64) as is_active
    from base
    group by customer_id
)

select * from ltv_calc
