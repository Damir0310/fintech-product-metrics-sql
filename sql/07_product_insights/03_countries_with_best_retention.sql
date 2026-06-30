-- Countries with best paid retention
-- Business question: Which markets keep paid users beyond their first charge?
-- Defines retained users as those with successful payments in at least two distinct months.
WITH user_paid_months AS (
    SELECT u.user_id, u.country, COUNT(DISTINCT DATE_TRUNC('month', p.payment_date)) AS paid_months
    FROM users u JOIN payments p USING (user_id)
    WHERE p.payment_status = 'success'
    GROUP BY u.user_id, u.country
)
SELECT country, COUNT(*) AS paid_users,
       COUNT(*) FILTER (WHERE paid_months >= 2) AS retained_paid_users,
       ROUND(100.0 * COUNT(*) FILTER (WHERE paid_months >= 2) / COUNT(*), 2) AS multi_month_retention_pct
FROM user_paid_months GROUP BY country
ORDER BY multi_month_retention_pct DESC;
