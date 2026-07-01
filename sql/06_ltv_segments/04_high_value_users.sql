-- High-value users
-- Business question: Who are the top 10% of users by realized net revenue?
-- Ranks paying users by revenue and returns the top decile with context.
WITH user_value AS (
    SELECT p.user_id,
           SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END) AS net_revenue,
           COUNT(*) FILTER (WHERE p.payment_status = 'success') AS successful_payments
    FROM payments p
    GROUP BY p.user_id
    HAVING COUNT(*) FILTER (WHERE p.payment_status = 'success') > 0
), ranked AS (
    SELECT *, NTILE(10) OVER (ORDER BY net_revenue DESC) AS value_decile FROM user_value
)
SELECT r.user_id, u.country, c.channel_name, r.net_revenue, r.successful_payments
FROM ranked r JOIN users u USING (user_id)
JOIN acquisition_channels c USING (acquisition_channel_id)
WHERE value_decile = 1 ORDER BY net_revenue DESC, r.user_id;
