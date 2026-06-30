-- Activation by channel
-- Business question: Which acquisition channels create activated paid users?
-- Compares signup-to-trial and signup-to-paid conversion by channel.
WITH user_flags AS (
    SELECT
        u.user_id,
        u.acquisition_channel_id,
        EXISTS (SELECT 1 FROM events e WHERE e.user_id = u.user_id AND e.event_name = 'trial_started') AS started_trial,
        EXISTS (SELECT 1 FROM payments p WHERE p.user_id = u.user_id AND p.payment_status = 'success') AS became_paid
    FROM users u
)
SELECT
    c.channel_name,
    COUNT(*) AS signups,
    ROUND(100.0 * COUNT(*) FILTER (WHERE started_trial) / COUNT(*), 2) AS trial_start_rate_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE became_paid) / COUNT(*), 2) AS signup_to_paid_pct
FROM user_flags f JOIN acquisition_channels c USING (acquisition_channel_id)
GROUP BY c.channel_name ORDER BY signup_to_paid_pct DESC;
