-- Cancellation reasons
-- Business question: Why do customers cancel, and which reasons carry the most lost MRR?
-- Counts cancellations and estimates normalized monthly value by stated reason.
SELECT
    cancellation_reason,
    COUNT(*) AS cancellations,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS cancellation_share_pct,
    ROUND(SUM(CASE plan_name WHEN 'monthly' THEN 12.99 WHEN 'quarterly' THEN 32.99 / 3 ELSE 119.99 / 12 END), 2) AS estimated_mrr_lost_usd
FROM subscriptions
WHERE canceled_at IS NOT NULL
GROUP BY cancellation_reason
ORDER BY cancellations DESC;
