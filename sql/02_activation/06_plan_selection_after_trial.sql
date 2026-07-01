-- Plan selection after trial
-- Business question: Which billing terms do converted trial users choose?
-- Restricts the denominator to subscriptions with at least one successful payment.
WITH paid_subscriptions AS (
    SELECT DISTINCT s.subscription_id, s.plan_name
    FROM subscriptions s
    JOIN payments p USING (subscription_id)
    WHERE p.payment_status = 'success'
)
SELECT
    plan_name,
    COUNT(*) AS paid_subscriptions,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS plan_share_pct
FROM paid_subscriptions
GROUP BY plan_name
ORDER BY paid_subscriptions DESC;
