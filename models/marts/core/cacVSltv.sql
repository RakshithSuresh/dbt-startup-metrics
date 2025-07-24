{{ config(materialized = 'view') }}

-- Aggregate LTV monthly
with ltv_monthly as (
    select
        format_date('%Y-%m', first_subscription) as month,
        sum(total_ltv) as total_ltv
    from {{ ref('fct_ltv') }}
    group by 1
),

-- Aggregate CAC monthly
cac_monthly as (
    select
        format_date('%Y-%m', month) as month,
        sum(total_spend) as total_spend,
        sum(new_customers) as new_customers,
        round(sum(total_spend) / nullif(sum(new_customers), 0), 2) as cac
    from {{ ref('fct_cac') }}
    group by 1
)

-- Join both
select
    coalesce(cac.month, ltv.month) as month,
    cac.total_spend,
    cac.new_customers,
    cac.cac,
    ltv.total_ltv,
    round(ltv.total_ltv / nullif(cac.total_spend, 0), 2) as ltv_to_cac_ratio
from cac_monthly cac
full outer join ltv_monthly ltv
  on cac.month = ltv.month
order by month
