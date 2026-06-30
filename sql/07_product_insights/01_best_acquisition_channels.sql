-- Best acquisition channels
-- Business question: Which channels balance scale, conversion, and customer value?
-- Builds a channel scorecard; the rank is based on observed revenue per acquired user.
WITH user_value AS (
    SELECT u.user_id, u.acquisition_channel_id,
           COALESCE(SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END), 0) AS net_revenue
    FROM users u LEFT JOIN payments p USING (user_id)
    GROUP BY u.user_id, u.acquisition_channel_id
)
SELECT
    c.channel_name,
    c.paid_or_organic,
    COUNT(*) AS signups,
    ROUND(100.0 * COUNT(*) FILTER (WHERE net_revenue > 0) / COUNT(*), 2) AS signup_to_paid_pct,
    ROUND(AVG(net_revenue), 2) AS revenue_per_signup_usd,
    DENSE_RANK() OVER (ORDER BY AVG(net_revenue) DESC) AS value_rank
FROM user_value v JOIN acquisition_channels c USING (acquisition_channel_id)
GROUP BY c.channel_name, c.paid_or_organic
ORDER BY value_rank, signups DESC;
