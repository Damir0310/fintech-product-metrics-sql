-- Monthly gross subscription churn
-- Business question: What share of the paid base cancels each month?
-- Divides cancellations in a month by subscriptions active at the start of that month.
WITH months AS (
    SELECT GENERATE_SERIES(DATE '2025-01-01', DATE '2025-12-01', INTERVAL '1 month')::date AS month_start
), metrics AS (
    SELECT
        m.month_start,
        COUNT(*) FILTER (
            WHERE s.started_at < m.month_start
              AND (s.canceled_at IS NULL OR s.canceled_at >= m.month_start)
        ) AS opening_paid_subscriptions,
        COUNT(*) FILTER (
            WHERE s.canceled_at >= m.month_start
              AND s.canceled_at < m.month_start + INTERVAL '1 month'
        ) AS cancellations
    FROM months m CROSS JOIN subscriptions s
    WHERE EXISTS (SELECT 1 FROM payments p WHERE p.subscription_id = s.subscription_id AND p.payment_status = 'success')
    GROUP BY m.month_start
)
SELECT *, ROUND(100.0 * cancellations / NULLIF(opening_paid_subscriptions, 0), 2) AS churn_rate_pct
FROM metrics ORDER BY month_start;
