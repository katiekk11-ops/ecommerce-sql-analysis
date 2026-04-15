/* Title: Conversion Rate Analysis by Country
Description: This query calculates the Conversion Rate and Total Revenue 
broken down by geographic location for July 2017.
Goal: To identify which countries show the highest purchase intent and 
evaluate regional market efficiency.
*/

WITH country_data AS (
  SELECT
    geoNetwork.country AS country,
    COUNT(visitId) AS visits,
    SUM(totals.transactions) AS transactions,
    -- Normalizing revenue from micros
    SUM(totals.transactionRevenue)/1000000 AS revenue
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
  GROUP BY geoNetwork.country
)

SELECT
  country,
  -- Handling NULLs for countries with no revenue
  IFNULL(ROUND(revenue, 2), 0) AS total_revenue,
  -- Calculating Conversion Rate: (transactions / visits) * 100
  IFNULL(ROUND((transactions / visits) * 100, 2), 0) AS conversion_rate
FROM country_data
-- Sorting by the most efficient countries first
ORDER BY conversion_rate DESC;
