-- Channels with high churn
-- Business question: Which acquisition sources bring paid users who cancel most often?
-- Uses ever-canceled status among users with at least one successful payment.
WITH paid_user_flags AS (
    SELECT
        u.user_id, u.acquisition_channel_id,
        EXISTS (SELECT 1 FROM subscriptions s WHERE s.user_id = u.user_id AND s.canceled_at IS NOT NULL) AS canceled
    FROM users u
    WHERE EXISTS (SELECT 1 FROM payments p WHERE p.user_id = u.user_id AND p.payment_status = 'success')
)
SELECT c.channel_name, COUNT(*) AS paid_users,
       COUNT(*) FILTER (WHERE canceled) AS canceled_users,
       ROUND(100.0 * COUNT(*) FILTER (WHERE canceled) / COUNT(*), 2) AS churned_user_pct
FROM paid_user_flags f JOIN acquisition_channels c USING (acquisition_channel_id)
GROUP BY c.channel_name HAVING COUNT(*) >= 30
ORDER BY churned_user_pct DESC;
