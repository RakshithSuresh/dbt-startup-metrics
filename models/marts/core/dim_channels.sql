{{ config(materialized = 'table') }}

select distinct
  lower(acquisition_channel) as channel,
  count(*) over (partition by lower(acquisition_channel)) as user_count
from {{ ref('stg_customers') }}
where acquisition_channel is not null
