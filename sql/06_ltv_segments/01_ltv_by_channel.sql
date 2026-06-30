-- Observed LTV by acquisition channel
-- Business question: Which channels acquire users with the highest realized lifetime value?
-- Uses net collected revenue per acquired user; this is observed LTV, not a forecast.
WITH user_value AS (
    SELECT u.user_id, u.acquisition_channel_id,
           COALESCE(SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END), 0) AS net_revenue
    FROM users u LEFT JOIN payments p USING (user_id)
    GROUP BY u.user_id, u.acquisition_channel_id
)
SELECT c.channel_name, COUNT(*) AS acquired_users,
       ROUND(AVG(v.net_revenue), 2) AS observed_ltv_per_acquired_user_usd,
       ROUND(AVG(v.net_revenue) FILTER (WHERE v.net_revenue > 0), 2) AS observed_ltv_per_payer_usd
FROM user_value v JOIN acquisition_channels c USING (acquisition_channel_id)
GROUP BY c.channel_name ORDER BY observed_ltv_per_acquired_user_usd DESC;
