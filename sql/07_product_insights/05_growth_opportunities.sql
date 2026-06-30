-- Growth opportunities
-- Business question: Which channel-country segments have scale but below-average monetization?
-- Flags segments with at least 50 users and revenue per signup below the overall average.
WITH user_value AS (
    SELECT u.user_id, u.country, u.acquisition_channel_id,
           COALESCE(SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END), 0) AS net_revenue
    FROM users u LEFT JOIN payments p USING (user_id)
    GROUP BY u.user_id, u.country, u.acquisition_channel_id
), benchmark AS (
    SELECT AVG(net_revenue) AS overall_revenue_per_signup FROM user_value
)
SELECT v.country, c.channel_name, COUNT(*) AS signups,
       ROUND(100.0 * COUNT(*) FILTER (WHERE v.net_revenue > 0) / COUNT(*), 2) AS paid_conversion_pct,
       ROUND(AVG(v.net_revenue), 2) AS revenue_per_signup_usd,
       ROUND(b.overall_revenue_per_signup, 2) AS overall_benchmark_usd,
       ROUND((b.overall_revenue_per_signup - AVG(v.net_revenue)) * COUNT(*), 2) AS modeled_revenue_upside_usd
FROM user_value v
JOIN acquisition_channels c USING (acquisition_channel_id)
CROSS JOIN benchmark b
GROUP BY v.country, c.channel_name, b.overall_revenue_per_signup
HAVING COUNT(*) >= 50 AND AVG(v.net_revenue) < b.overall_revenue_per_signup
ORDER BY modeled_revenue_upside_usd DESC;
