-- Plan performance summary
-- Business question: How do plans compare on adoption, value, failures, and cancellation?
-- Produces one decision-oriented scorecard at subscription-plan level.
SELECT
    s.plan_name,
    COUNT(DISTINCT s.subscription_id) AS subscriptions,
    COUNT(DISTINCT s.user_id) FILTER (WHERE p.payment_status = 'success') AS paid_users,
    ROUND(COALESCE(SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END), 0), 2) AS net_revenue_usd,
    ROUND(100.0 * COUNT(DISTINCT s.subscription_id) FILTER (WHERE s.canceled_at IS NOT NULL) / COUNT(DISTINCT s.subscription_id), 2) AS cancellation_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE p.payment_status = 'failed')
          / NULLIF(COUNT(*) FILTER (WHERE p.payment_status IN ('success', 'failed')), 0), 2) AS payment_failure_pct
FROM subscriptions s LEFT JOIN payments p USING (subscription_id)
GROUP BY s.plan_name ORDER BY net_revenue_usd DESC;
