{{ config(materialized='table') }}

select
  customer_id,
  lower(email) as email,
  signup_date,
  first_name,
  last_name,
  country,
  industry,
  acquisition_channel
from {{ ref('stg_customers') }}
