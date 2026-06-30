-- Payment success rate
-- Business question: What share of charge attempts succeeds over time?
-- Excludes refund records because they are outcomes of earlier successful charges, not attempts.
SELECT
    DATE_TRUNC('month', payment_date)::date AS payment_month,
    COUNT(*) FILTER (WHERE payment_status IN ('success', 'failed')) AS attempts,
    COUNT(*) FILTER (WHERE payment_status = 'success') AS successes,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_status = 'success')
          / NULLIF(COUNT(*) FILTER (WHERE payment_status IN ('success', 'failed')), 0), 2) AS success_rate_pct
FROM payments GROUP BY 1 ORDER BY 1;
