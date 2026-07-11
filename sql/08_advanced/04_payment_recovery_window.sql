-- ============================================================
-- 04 Payment Recovery Window
-- ============================================================
-- Business question:
-- When a payment fails, how often does the user later recover with
-- a successful payment, how long does recovery take, and which
-- payment providers recover best?
--
-- What this query calculates:
-- - failed payment attempts
-- - recovered failed payment attempts
-- - recovery rate
-- - average days to recovery
-- - recovered revenue
-- - recovery metrics by payment provider
--
-- Notes:
-- A failed payment is considered recovered when the same user has a
-- later successful payment for the same subscription.

WITH failed_attempts AS (
    SELECT
        payment_id AS failed_payment_id,
        user_id,
        subscription_id,
        payment_date AS failed_payment_date,
        payment_provider,
        failure_reason
    FROM payments
    WHERE payment_status = 'failed'
), recovery_matches AS (
    SELECT
        fa.failed_payment_id,
        fa.user_id,
        fa.subscription_id,
        fa.failed_payment_date,
        fa.payment_provider,
        fa.failure_reason,
        recovered.payment_id AS recovered_payment_id,
        recovered.payment_date AS recovered_payment_date,
        recovered.amount_usd AS recovered_amount_usd,
        recovered.payment_date - fa.failed_payment_date AS days_to_recovery
    FROM failed_attempts AS fa
    LEFT JOIN LATERAL (
        SELECT
            p.payment_id,
            p.payment_date,
            p.amount_usd
        FROM payments AS p
        WHERE p.user_id = fa.user_id
          AND p.subscription_id = fa.subscription_id
          AND p.payment_status = 'success'
          AND p.payment_date > fa.failed_payment_date
        ORDER BY p.payment_date, p.payment_id
        LIMIT 1
    ) AS recovered
        ON TRUE
), provider_metrics AS (
    SELECT
        payment_provider,
        COUNT(*) AS failed_payment_attempts,
        COUNT(recovered_payment_id) AS recovered_payment_attempts,
        AVG(days_to_recovery) FILTER (WHERE recovered_payment_id IS NOT NULL) AS avg_days_to_recovery,
        SUM(recovered_amount_usd) FILTER (WHERE recovered_payment_id IS NOT NULL) AS recovered_revenue_usd
    FROM recovery_matches
    GROUP BY payment_provider
), overall_metrics AS (
    SELECT
        'all_providers'::varchar(30) AS payment_provider,
        COUNT(*) AS failed_payment_attempts,
        COUNT(recovered_payment_id) AS recovered_payment_attempts,
        AVG(days_to_recovery) FILTER (WHERE recovered_payment_id IS NOT NULL) AS avg_days_to_recovery,
        SUM(recovered_amount_usd) FILTER (WHERE recovered_payment_id IS NOT NULL) AS recovered_revenue_usd
    FROM recovery_matches
)
SELECT
    payment_provider,
    failed_payment_attempts,
    recovered_payment_attempts,
    ROUND(100.0 * recovered_payment_attempts / NULLIF(failed_payment_attempts, 0), 2) AS recovery_rate_pct,
    ROUND(avg_days_to_recovery, 2) AS avg_days_to_recovery,
    ROUND(COALESCE(recovered_revenue_usd, 0), 2) AS recovered_revenue_usd
FROM overall_metrics

UNION ALL

SELECT
    payment_provider,
    failed_payment_attempts,
    recovered_payment_attempts,
    ROUND(100.0 * recovered_payment_attempts / NULLIF(failed_payment_attempts, 0), 2) AS recovery_rate_pct,
    ROUND(avg_days_to_recovery, 2) AS avg_days_to_recovery,
    ROUND(COALESCE(recovered_revenue_usd, 0), 2) AS recovered_revenue_usd
FROM provider_metrics
ORDER BY payment_provider;
