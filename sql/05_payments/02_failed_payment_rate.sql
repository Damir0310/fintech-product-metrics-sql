-- Failed payment rate
-- Business question: How much payment friction occurs each month?
-- Calculates failed attempts as a share of success-plus-failure attempts.
SELECT
    DATE_TRUNC('month', payment_date)::date AS payment_month,
    COUNT(*) FILTER (WHERE payment_status = 'failed') AS failed_attempts,
    COUNT(*) FILTER (WHERE payment_status IN ('success', 'failed')) AS total_attempts,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_status = 'failed')
          / NULLIF(COUNT(*) FILTER (WHERE payment_status IN ('success', 'failed')), 0), 2) AS failed_payment_rate_pct,
    ROUND(SUM(amount_usd) FILTER (WHERE payment_status = 'failed'), 2) AS value_at_risk_usd
FROM payments GROUP BY 1 ORDER BY 1;
