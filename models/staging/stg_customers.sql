-- models/staging/stg_customers.sql

with source as (

    select * 
    from `startup-metrics-dashboard.google_sheets.customers`

),

renamed as (

    select
        customer_id,
        lower(email) as email,
        parse_date('%Y-%m-%d', signup_date) as signup_date,
        split(name, ' ')[safe_offset(0)] as first_name,
        split(name, ' ')[safe_offset(1)] as last_name,
        lower(trim(country)) as country,
        lower(trim(industry_)) as industry,
        lower(trim(acquisition_channel)) as acquisition_channel
    from source

)

select * from renamed