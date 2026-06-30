-- Revenue by country
-- Business question: Which markets contribute the most net revenue and revenue per user?
-- Attributes payment value to the user's signup country.
SELECT
    u.country,
    COUNT(DISTINCT u.user_id) AS acquired_users,
    COUNT(DISTINCT p.user_id) FILTER (WHERE p.payment_status = 'success') AS paid_users,
    ROUND(COALESCE(SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END), 0), 2) AS net_revenue_usd,
    ROUND(COALESCE(SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END), 0) / COUNT(DISTINCT u.user_id), 2) AS revenue_per_acquired_user_usd
FROM users u LEFT JOIN payments p USING (user_id)
GROUP BY u.country ORDER BY net_revenue_usd DESC;
