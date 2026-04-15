/* Title: New vs. Returning Visitor Analysis
Description: This query segments users into 'First-time Visitors' and 'Returning Visitors' 
to compare their revenue contribution and engagement.
Goal: To evaluate customer loyalty and the effectiveness of retention vs. acquisition strategies.
*/

WITH visitor_data AS (
  SELECT  
    -- Segmenting visitors based on their visit number
    CASE
      WHEN visitNumber = 1 THEN 'First-time Visitor'
      ELSE 'Returning Visitor'
    END AS visitor_type,
    SUM(IFNULL(totals.transactionRevenue / 1000000, 0)) AS total_revenue,
    COUNT(visitId) AS number_of_visits
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  -- Analysis for August 2017
  WHERE _TABLE_SUFFIX BETWEEN '20170801' AND '20170831'
  GROUP BY visitor_type
)

SELECT 
  visitor_type,
  number_of_visits,
  ROUND(total_revenue, 2) AS total_revenue,
  -- Calculating Average Revenue per Visit (RPV)
  ROUND(SAFE_DIVIDE(total_revenue, number_of_visits), 2) AS avg_revenue_per_visit
FROM visitor_data
ORDER BY total_revenue DESC;
