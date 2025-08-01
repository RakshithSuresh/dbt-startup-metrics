with source as (
    select * from {{ source('google_sheets', 'marketing_spend') }}
),

renamed as (
    select
        cast(campaign_id as string) as campaign_id,
        cast(spend as float64) as spend,
        parse_date('%Y-%m-%d', cast(date as string)) as spend_date,
        lower(trim(channel)) as channel
    from source
)

select * from renamed
