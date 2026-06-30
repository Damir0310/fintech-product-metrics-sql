-- Daily signups
-- Business question: How is user acquisition changing day by day?
-- Calculates new users and a seven-day rolling average.
WITH daily AS (
    SELECT signup_date, COUNT(*) AS signups
    FROM users
    GROUP BY signup_date
)
SELECT
    signup_date,
    signups,
    ROUND(AVG(signups) OVER (ORDER BY signup_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS signups_7d_avg
FROM daily
ORDER BY signup_date;
