-- Failed payments by provider
-- Business question: Which payment providers have the highest failure rates and why?
-- Compares attempt volume and failures; the second result breaks failures down by reason.
SELECT
    payment_provider,
    COUNT(*) FILTER (WHERE payment_status IN ('success', 'failed')) AS attempts,
    COUNT(*) FILTER (WHERE payment_status = 'failed') AS failures,
    ROUND(100.0 * COUNT(*) FILTER (WHERE payment_status = 'failed')
          / NULLIF(COUNT(*) FILTER (WHERE payment_status IN ('success', 'failed')), 0), 2) AS failure_rate_pct
FROM payments GROUP BY payment_provider ORDER BY failure_rate_pct DESC;

SELECT payment_provider, failure_reason, COUNT(*) AS failures
FROM payments WHERE payment_status = 'failed'
GROUP BY payment_provider, failure_reason ORDER BY payment_provider, failures DESC;
