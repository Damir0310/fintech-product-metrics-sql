-- Countries with best 90-day paid retention
-- Business question: Which markets keep eligible paid users active 90 days after first payment?
-- Uses subscription state at a fixed milestone so monthly, quarterly, and yearly plans are comparable.
WITH observation AS (
    SELECT MAX(payment_date) AS observation_end
    FROM payments
), first_paid AS (
    SELECT user_id, MIN(payment_date) AS first_paid_at
    FROM payments
    WHERE payment_status = 'success'
    GROUP BY user_id
), reactivations AS (
    SELECT user_id, MIN(event_timestamp)::date AS reactivated_at
    FROM events
    WHERE event_name = 'reactivated'
    GROUP BY user_id
), eligible_users AS (
    SELECT
        u.user_id,
        u.country,
        f.first_paid_at,
        s.canceled_at,
        r.reactivated_at
    FROM first_paid f
    JOIN users u USING (user_id)
    JOIN subscriptions s USING (user_id)
    LEFT JOIN reactivations r USING (user_id)
    CROSS JOIN observation o
    WHERE f.first_paid_at + 90 <= o.observation_end
)
SELECT
    country,
    COUNT(*) AS eligible_paid_users,
    COUNT(*) FILTER (
        WHERE canceled_at IS NULL
           OR canceled_at > first_paid_at + 90
           OR reactivated_at <= first_paid_at + 90
    ) AS retained_paid_users_90d,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE canceled_at IS NULL
               OR canceled_at > first_paid_at + 90
               OR reactivated_at <= first_paid_at + 90
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS paid_retention_90d_pct
FROM eligible_users
GROUP BY country
ORDER BY paid_retention_90d_pct DESC;
