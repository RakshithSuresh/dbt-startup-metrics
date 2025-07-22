{{ config(materialized='view') }}

with source as (
    select * from {{ source('google_sheets', 'subscriptions') }}
),

renamed as (
    select
        cast(subscription_id as int64) as subscription_id,
        cast(customer_id as int64) as customer_id,
        lower(trim(plan)) as plan,
        cast(start_date as date) as start_date,
        cast(end_date as date) as end_date,
        cast(monthly_revenue as numeric) as monthly_revenue,

        -- 👇 Derive subscription status
        case
            when end_date is null then 'active'
            when end_date >= current_date() then 'active'
            else 'cancelled'
        end as status

    from source
)

select * from renamed
