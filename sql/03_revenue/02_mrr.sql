-- Month-end monthly recurring revenue (MRR)
-- Business question: What recurring revenue is represented by paid subscriptions active at each month end?
-- Normalizes the first successful charge by plan term and applies it to each active month-end snapshot.
WITH reporting_months AS (
    SELECT GENERATE_SERIES(
        DATE_TRUNC('month', MIN(payment_date)),
        DATE_TRUNC('month', MAX(payment_date)),
        INTERVAL '1 month'
    )::date AS month_start
    FROM payments
), first_success AS (
    SELECT DISTINCT ON (subscription_id)
        subscription_id,
        amount_usd
    FROM payments
    WHERE payment_status = 'success'
    ORDER BY subscription_id, payment_date, payment_id
), reactivations AS (
    SELECT user_id, MIN(event_timestamp)::date AS reactivated_at
    FROM events
    WHERE event_name = 'reactivated'
    GROUP BY user_id
), paid_subscriptions AS (
    SELECT
        s.subscription_id,
        s.user_id,
        s.started_at,
        s.canceled_at,
        r.reactivated_at,
        fs.amount_usd / CASE s.plan_name
            WHEN 'monthly' THEN 1
            WHEN 'quarterly' THEN 3
            WHEN 'yearly' THEN 12
        END AS mrr_usd
    FROM subscriptions s
    JOIN first_success fs USING (subscription_id)
    LEFT JOIN reactivations r USING (user_id)
)
SELECT
    m.month_start AS snapshot_month,
    COUNT(p.subscription_id) AS active_paid_subscriptions,
    ROUND(COALESCE(SUM(p.mrr_usd), 0), 2) AS mrr_usd
FROM reporting_months m
LEFT JOIN paid_subscriptions p
    ON p.started_at < m.month_start + INTERVAL '1 month'
   AND (
       p.canceled_at IS NULL
       OR p.canceled_at >= m.month_start + INTERVAL '1 month'
       OR p.reactivated_at < m.month_start + INTERVAL '1 month'
   )
GROUP BY m.month_start
ORDER BY m.month_start;
