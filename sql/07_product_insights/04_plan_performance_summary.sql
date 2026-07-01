-- Plan performance summary
-- Business question: How do paid plans compare on adoption, value, payment reliability, and cancellation?
-- Restricts subscription-level rates to subscriptions with at least one successful payment.
WITH payment_metrics AS (
    SELECT
        subscription_id,
        SUM(
            CASE
                WHEN payment_status = 'success' THEN amount_usd
                WHEN payment_status = 'refunded' THEN -amount_usd
                ELSE 0
            END
        ) AS net_revenue_usd,
        COUNT(*) FILTER (WHERE payment_status IN ('success', 'failed')) AS attempts,
        COUNT(*) FILTER (WHERE payment_status = 'failed') AS failures,
        BOOL_OR(payment_status = 'success') AS became_paid
    FROM payments
    GROUP BY subscription_id
), paid_subscriptions AS (
    SELECT
        s.subscription_id,
        s.plan_name,
        s.canceled_at,
        p.net_revenue_usd,
        p.attempts,
        p.failures
    FROM subscriptions s
    JOIN payment_metrics p USING (subscription_id)
    WHERE p.became_paid
)
SELECT
    plan_name,
    COUNT(*) AS paid_subscriptions,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS paid_plan_mix_pct,
    ROUND(SUM(net_revenue_usd), 2) AS net_revenue_usd,
    ROUND(AVG(net_revenue_usd), 2) AS observed_revenue_per_paid_subscription_usd,
    ROUND(100.0 * COUNT(*) FILTER (WHERE canceled_at IS NOT NULL) / COUNT(*), 2) AS ever_canceled_pct,
    ROUND(100.0 * SUM(failures) / NULLIF(SUM(attempts), 0), 2) AS payment_failure_pct
FROM paid_subscriptions
GROUP BY plan_name
ORDER BY net_revenue_usd DESC;
