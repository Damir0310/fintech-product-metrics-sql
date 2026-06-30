-- Monthly signups
-- Business question: Which months drove growth, and how quickly did signups change?
-- Calculates monthly signups, cumulative users, and month-over-month growth.
WITH monthly AS (
    SELECT DATE_TRUNC('month', signup_date)::date AS signup_month, COUNT(*) AS signups
    FROM users GROUP BY 1
), compared AS (
    SELECT *, LAG(signups) OVER (ORDER BY signup_month) AS prior_month_signups
    FROM monthly
)
SELECT
    signup_month,
    signups,
    SUM(signups) OVER (ORDER BY signup_month) AS cumulative_users,
    ROUND(100.0 * (signups - prior_month_signups) / NULLIF(prior_month_signups, 0), 2) AS mom_growth_pct
FROM compared ORDER BY signup_month;
