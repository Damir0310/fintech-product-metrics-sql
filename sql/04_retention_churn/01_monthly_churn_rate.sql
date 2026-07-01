-- Monthly gross subscription churn
-- Business question: What share of the paid base cancels each month?
-- Divides cancellation events by paid subscriptions active at the start of each dynamically generated month.
WITH reporting_months AS (
    SELECT GENERATE_SERIES(
        DATE_TRUNC('month', MIN(payment_date)),
        DATE_TRUNC('month', MAX(payment_date)),
        INTERVAL '1 month'
    )::date AS month_start
    FROM payments
), paid_subscriptions AS (
    SELECT s.subscription_id, s.user_id, s.started_at, s.canceled_at
    FROM subscriptions s
    WHERE EXISTS (
        SELECT 1
        FROM payments p
        WHERE p.subscription_id = s.subscription_id
          AND p.payment_status = 'success'
    )
), reactivations AS (
    SELECT user_id, MIN(event_timestamp)::date AS reactivated_at
    FROM events
    WHERE event_name = 'reactivated'
    GROUP BY user_id
), monthly AS (
    SELECT
        m.month_start,
        COUNT(p.subscription_id) FILTER (
            WHERE p.started_at < m.month_start
              AND (
                  p.canceled_at IS NULL
                  OR p.canceled_at >= m.month_start
                  OR r.reactivated_at < m.month_start
              )
        ) AS opening_paid_subscriptions,
        COUNT(p.subscription_id) FILTER (
            WHERE p.canceled_at >= m.month_start
              AND p.canceled_at < m.month_start + INTERVAL '1 month'
        ) AS cancellations
    FROM reporting_months m
    CROSS JOIN paid_subscriptions p
    LEFT JOIN reactivations r USING (user_id)
    GROUP BY m.month_start
)
SELECT
    month_start,
    opening_paid_subscriptions,
    cancellations,
    ROUND(100.0 * cancellations / NULLIF(opening_paid_subscriptions, 0), 2) AS churn_rate_pct
FROM monthly
ORDER BY month_start;
