-- Activation by country
-- Business question: In which markets do users activate most effectively?
-- Calculates trial and paid activation rates from all registered users.
WITH user_flags AS (
    SELECT
        u.user_id, u.country,
        BOOL_OR(e.event_name = 'trial_started') AS started_trial,
        EXISTS (SELECT 1 FROM payments p WHERE p.user_id = u.user_id AND p.payment_status = 'success') AS became_paid
    FROM users u LEFT JOIN events e USING (user_id)
    GROUP BY u.user_id, u.country
)
SELECT
    country,
    COUNT(*) AS signups,
    ROUND(100.0 * COUNT(*) FILTER (WHERE started_trial) / COUNT(*), 2) AS trial_start_rate_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE became_paid) / COUNT(*), 2) AS signup_to_paid_pct
FROM user_flags GROUP BY country ORDER BY signup_to_paid_pct DESC;
