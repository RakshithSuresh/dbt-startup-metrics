{{ config(materialized = 'table') }}

SELECT
  ROUND(
    100 * (
      COUNT(fc.customer_id) / (
        SELECT COUNT(sc.customer_id)
        FROM {{ ref('stg_customers') }} AS sc
      )
    ),
    2
  ) AS churn_percent
FROM {{ ref('fct_churn') }} AS fc
