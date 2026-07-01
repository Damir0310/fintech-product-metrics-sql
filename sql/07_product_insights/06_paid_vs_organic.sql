-- Paid versus organic acquisition
-- Business question: How do paid and organic acquisition compare on activation and realized value?
-- Builds user-level outcomes before aggregating to avoid payment-row inflation.
WITH user_revenue AS (
    SELECT
        user_id,
        SUM(
            CASE
                WHEN payment_status = 'success' THEN amount_usd
                WHEN payment_status = 'refunded' THEN -amount_usd
                ELSE 0
            END
        ) AS net_revenue_usd,
        BOOL_OR(payment_status = 'success') AS became_paid
    FROM payments
    GROUP BY user_id
), user_outcomes AS (
    SELECT
        u.user_id,
        c.paid_or_organic,
        EXISTS (
            SELECT 1
            FROM events e
            WHERE e.user_id = u.user_id
              AND e.event_name = 'trial_started'
        ) AS started_trial,
        COALESCE(r.became_paid, false) AS became_paid,
        COALESCE(r.net_revenue_usd, 0) AS net_revenue_usd
    FROM users u
    JOIN acquisition_channels c USING (acquisition_channel_id)
    LEFT JOIN user_revenue r USING (user_id)
)
SELECT
    paid_or_organic,
    COUNT(*) AS signups,
    ROUND(100.0 * COUNT(*) FILTER (WHERE started_trial) / COUNT(*), 2) AS trial_start_rate_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE became_paid) / COUNT(*), 2) AS signup_to_paid_pct,
    ROUND(AVG(net_revenue_usd), 2) AS observed_revenue_per_signup_usd,
    ROUND(AVG(net_revenue_usd) FILTER (WHERE became_paid), 2) AS observed_revenue_per_payer_usd
FROM user_outcomes
GROUP BY paid_or_organic
ORDER BY observed_revenue_per_signup_usd DESC;
