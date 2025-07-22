{{ config(materialized='view') }}

with source as (
    select * from {{ source('google_sheets', 'expenses') }}
),

renamed as (
    select
        cast(expense_id as string) as expense_id,
        date as expense_date,
        cast(amount as float64) as amount,
        lower(trim(category)) as category
    from source
)

select * from renamed
