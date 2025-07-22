{{ config(
    materialized = 'table'
) }}

with marketing_spend_by_month_channel as (
    select
        format_date('%Y-%m', spend_date) as month,
        channel,
        round(sum(spend), 2) as total_spend
    from {{ ref('stg_marketing_spend') }}
    group by 1, 2
),

new_customers_by_month_channel as (
    select
        format_date('%Y-%m', signup_date) as month,
        acquisition_channel as channel,
        count(distinct customer_id) as new_customers
    from {{ ref('stg_customers') }}
    group by 1, 2
),

cac as (
    select
        ms.month,
        ms.channel,
        ms.total_spend,
        nc.new_customers,
        round(safe_divide(ms.total_spend, nc.new_customers), 2) as cac
    from marketing_spend_by_month_channel ms
    left join new_customers_by_month_channel nc
        on ms.month = nc.month and ms.channel = nc.channel
)

select * from cac
