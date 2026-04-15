/* Title: Traffic Source Performance Analysis
Description: This query calculates total visits, revenue, and bounce rate 
per traffic source for July 2017.
Goal: To identify which traffic sources provide the most volume and engagement.
*/

WITH source_data AS (
  SELECT
    trafficSource.source AS source,
    SUM(totals.bounces) AS bounces,
    SUM(totals.visits) AS visits,
    -- Revenue is divided by 1,000,000 to convert from micros to standard currency
    ROUND(SUM(totals.transactionRevenue/1000000), 0) AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
  GROUP BY source
)

SELECT
  source,
  visits,
  IFNULL(revenue, 0) AS revenue,
  -- Calculating Bounce Rate as a percentage
  ROUND(((bounces/visits)*100), 0) AS bounce_rate
FROM source_data
WHERE visits > 100
ORDER BY revenue DESC;
