------------------------------------------------------
-- 2022-2024 Sales And Training Engagement Analysis --
------------------------------------------------------

-- Notes: As this is an company project, this show the methodology of data analytics without showing the details of internal data


-- Top 5 Accounts by Year-over-Year Sales Growth (2022–2024)
-- Description: Identify the top 5 accounts by total growth in opportunities from 2022 to 2024

# Annual total sales by accounts
WITH sales_by_year AS (
  SELECT 
    account_name, 
    EXTRACT(YEAR FROM sale_date) AS year, 
    SUM(sale_amount) AS total_sales
  FROM sales_data
  WHERE sale_date BETWEEN '2022-01-01' AND '2024-12-31'
  GROUP BY account_name, year
),

# Compare sales growth for each year  
ranked_accounts AS (
  SELECT 
    account_name,
    MAX(CASE WHEN year = 2022 THEN total_sales ELSE 0 END) AS sales_2022,
    MAX(CASE WHEN year = 2023 THEN total_sales ELSE 0 END) AS sales_2023,
    MAX(CASE WHEN year = 2024 THEN total_sales ELSE 0 END) AS sales_2024
  FROM sales_by_year
  GROUP BY account_name
),

# Determine the growth rate
growth_rate AS (
  SELECT *,
    ROUND(100 * (sales_2024 - sales_2023) / NULLIF(sales_2023, 0), 2) AS growth_2024,
    ROUND(100 * (sales_2023 - sales_2022) / NULLIF(sales_2022, 0), 2) AS growth_2023
  FROM ranked_accounts
)

# Determine top 5 growth accounts
SELECT *
FROM growth_rate
ORDER BY growth_2024 DESC
LIMIT 5
;


-- Numbers of Training and Opportunities per Accounts

# Count the number of opportunities and training session and see the correlation
SELECT
    a.account_name,
    COUNT(DISTINCT t.training_id) AS training_sessions,
    COUNT(DISTINCT o.opportunity_id) AS opportunity_count
FROM account a
LEFT JOIN training t
ON a.account_id = t.account_id
LEFT JOIN opportunity o
ON a.account_id = o.account_id
WHERE t.training_date BETWEEN '2022-01-01' AND '2024-12-31'
AND opportunity_date BETWEEN '2022-01-01' AND '2024-12-31'
GROUP BY a.account_name
ORDER BY opportunity_count DESC, training_sessions DESC
;


-- Training Topic Effectiveness

# Find out which training topic is effective and generate the most opportunities
SELECT 
    t.topic,
    COUNT(DISTINCT t.training_id) AS training_sessions,
    COUNT(DISTINCT o.opportunity_id) AS opportunity_count,
    ROUND(COUNT(DISTINCT o.opportunity_id) / NULLIF(COUNT(DISTINCT t.training_id), 0), 2) AS opportunity_per_training
FROM training t
LEFT JOIN opportunity o
ON t.account_id = o.account_id
AND o.oppotunity_date >= t.training_date
WHERE t.training_date BETWEEN '2022-01-01' AND '2024-12-31'
GROUP BY t.topic
ORDER BY opportunity_per_training DESC, opportunity_count DESC, training_sessions DESC
;