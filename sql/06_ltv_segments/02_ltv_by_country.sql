-- Observed LTV by country
-- Business question: Which markets produce the highest lifetime value per acquired user?
-- Aggregates each user's net successful charges less refunds, including zero-value users.
WITH user_value AS (
    SELECT u.user_id, u.country,
           COALESCE(SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END), 0) AS net_revenue
    FROM users u LEFT JOIN payments p USING (user_id)
    GROUP BY u.user_id, u.country
)
SELECT country, COUNT(*) AS acquired_users,
       ROUND(AVG(net_revenue), 2) AS observed_ltv_per_acquired_user_usd,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY net_revenue)::numeric, 2) AS median_user_value_usd
FROM user_value GROUP BY country ORDER BY observed_ltv_per_acquired_user_usd DESC;
