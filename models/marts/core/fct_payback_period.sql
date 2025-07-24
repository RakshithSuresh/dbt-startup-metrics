{{ config(
    materialized = 'table'
) }}

with cac as (
    select
        month,
        cac,
        new_customers
    from {{ ref('fct_cac') }}
),

mrr as (
    select
        month,
        sum(mrr) as total_mrr,
        count(distinct customer_id) as active_customers
    from {{ ref('fct_mrr') }}
    group by 1
),

combined as (
    select
        cac.month,
        cac.cac,
        mrr.total_mrr,
        mrr.active_customers,
        safe_divide(mrr.total_mrr, mrr.active_customers) as avg_mrr_per_customer
    from cac
    left join mrr
        on cac.month = mrr.month
),

final as (
    select
        month,
        cac,
        avg_mrr_per_customer,
        round(safe_divide(cac, avg_mrr_per_customer)) as payback_period_months
    from combined
)

select * from final
