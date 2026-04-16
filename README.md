# E-commerce Data Analysis | SQL & BigQuery

## 🎯 Project Overview
This project contains a series of SQL analyses focused on identifying key business performance indicators (KPIs) and customer behavior patterns. I used the **Google Analytics sample dataset** in BigQuery to simulate real-world e-commerce scenarios.

**Key areas of focus:**
* **Traffic Acquisition:** Evaluating source performance by Revenue and Conversion Rate.
* **Customer Behavior:** Analyzing Bounce Rates and engagement.
* **Profitability:** Calculating Average Order Value (AOV) and Revenue per Visit (RPV).

## 🛠️ Technology Stack
* **Database:** Google BigQuery
* **Language:** SQL (Standard SQL)
* **Concepts:** CTEs (Common Table Expressions), Data Aggregation, E-commerce Metrics.

---
*Note: This is a work in progress as I am continuously adding more complex queries to explore deeper business insights.*
---
---

## 📊 Deep Dive: Business Analyses

### 1. New vs. Returning Visitors
This analysis segments users to understand loyalty and the efficiency of customer retention.

<details>
<summary><b>Click to view SQL Query</b></summary>

```sql
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
```

</details>

#### 💡 Key Insights:
**High-Value Retention:** Returning visitors are significantly more profitable. Their **Average Revenue per Visit ($11.16)** is 31x higher than that of first-time visitors ($0.36).

**Strategy:** High focus should be placed on retention marketing, as repeat customers drive the majority of profitability.

---

### 2. Geographic Performance & Conversion
Focuses on identifying high-potential markets and conversion bottlenecks across the globe.

<details>
<summary><b>Click to view SQL Query</b></summary> 

  ```sql
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
```

</details>

#### 💡 Key Insights:
**High-Potential Markets:** Mexico and Germany are significant revenue drivers, yet their **Conversion Rates are notably low (0.13% - 0.28%)**.

**The Opportunity:** Improving the conversion funnel in these high-traffic markets offers a much larger revenue uplift than focusing on smaller, niche markets.

**Efficiency Leader:** The United States remains the most balanced market with high volume and a solid **3.15% CR**.

---

### 3. Traffic Source Efficiency
Evaluating which marketing channels bring the most valuable traffic.

<details>
<summary><b>Click to view SQL Query</b></summary>

  ```sql
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
```

</details>

#### 💡 Key Insights:
**Direct Power:** Direct traffic is the primary winner ($93k+), indicating strong brand awareness.

**Traffic Quality:** While Google organic brings the highest volume, social channels (YouTube, Facebook) show high bounce rates (~65%) and minimal revenue, suggesting a need for better ad targeting.
