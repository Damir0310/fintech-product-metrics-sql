-- Behavioral and revenue segments
-- Business question: How can users be grouped for lifecycle messaging and analysis?
-- Segments users by payment value, cancellation, and recency relative to the dataset end.
WITH reference AS (
    SELECT MAX(event_timestamp) AS max_event_at FROM events
), revenue AS (
    SELECT user_id,
           SUM(CASE WHEN payment_status = 'success' THEN amount_usd WHEN payment_status = 'refunded' THEN -amount_usd ELSE 0 END) AS net_revenue
    FROM payments GROUP BY user_id
), activity AS (
    SELECT user_id, MAX(event_timestamp) AS last_event_at
    FROM events GROUP BY user_id
), lifecycle AS (
    SELECT
        u.user_id,
        EXISTS (SELECT 1 FROM subscriptions s WHERE s.user_id = u.user_id AND s.canceled_at IS NOT NULL) AS ever_canceled,
        EXISTS (SELECT 1 FROM events e WHERE e.user_id = u.user_id AND e.event_name = 'reactivated') AS reactivated
    FROM users u
), features AS (
    SELECT u.user_id,
           COALESCE(r.net_revenue, 0) AS net_revenue,
           a.last_event_at,
           l.ever_canceled,
           l.reactivated
    FROM users u
    LEFT JOIN revenue r USING (user_id)
    LEFT JOIN activity a USING (user_id)
    JOIN lifecycle l USING (user_id)
)
SELECT
    CASE
        WHEN net_revenue = 0 AND last_event_at >= max_event_at - INTERVAL '30 days' THEN 'active_free'
        WHEN net_revenue = 0 THEN 'inactive_free'
        WHEN reactivated THEN 'reactivated_payer'
        WHEN ever_canceled THEN 'churned_payer'
        WHEN net_revenue >= 120 THEN 'high_value_active'
        WHEN last_event_at < max_event_at - INTERVAL '60 days' THEN 'at_risk_payer'
        ELSE 'active_payer'
    END AS user_segment,
    COUNT(*) AS users,
    ROUND(AVG(net_revenue), 2) AS avg_net_revenue_usd
FROM features CROSS JOIN reference
GROUP BY 1 ORDER BY users DESC;
