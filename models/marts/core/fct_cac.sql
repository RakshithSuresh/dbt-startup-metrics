
{{ config(materialized='table') }}

with marketing_spend_by_month as (
  select
    cast(date_trunc(spend_date, month) as date) as month,
    sum(spend) as total_spend
  from {{ ref('stg_marketing_spend') }}
  group by 1
),

new_customers_by_month as (
  select
    cast(date_trunc(signup_date, month) as date) as month,
    count(distinct customer_id) as new_customers
  from {{ ref('stg_customers') }}
  group by 1
),

blended_cac as (
  select
    ms.month,
    ms.total_spend,
    nc.new_customers,
    case
      when nc.new_customers = 0 or nc.new_customers is null then null
      else round(ms.total_spend / nc.new_customers, 2)
    end as cac
  from marketing_spend_by_month ms
  left join new_customers_by_month nc
    on ms.month = nc.month
)

select * from blended_cac
