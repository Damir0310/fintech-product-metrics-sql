-- Revenue by acquisition channel
-- Business question: Which acquisition sources produce the most monetization?
-- Attributes each user's lifetime net revenue to their original channel.
SELECT
    c.channel_name,
    c.paid_or_organic,
    COUNT(DISTINCT u.user_id) AS acquired_users,
    COUNT(DISTINCT p.user_id) FILTER (WHERE p.payment_status = 'success') AS paid_users,
    ROUND(COALESCE(SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END), 0), 2) AS net_revenue_usd
FROM users u
JOIN acquisition_channels c USING (acquisition_channel_id)
LEFT JOIN payments p USING (user_id)
GROUP BY c.channel_name, c.paid_or_organic
ORDER BY net_revenue_usd DESC;
