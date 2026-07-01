-- Payment failures and churn
-- Business question: Are users with failed payments more likely to cancel?
-- Splits paid users by failure exposure and compares cancellation rates; this is association, not causation.
WITH paid_users AS (
    SELECT DISTINCT user_id FROM payments WHERE payment_status = 'success'
), user_flags AS (
    SELECT
        u.user_id,
        EXISTS (SELECT 1 FROM payments p WHERE p.user_id = u.user_id AND p.payment_status = 'failed') AS had_failure,
        EXISTS (SELECT 1 FROM subscriptions s WHERE s.user_id = u.user_id AND s.canceled_at IS NOT NULL) AS canceled
    FROM paid_users u
)
SELECT
    CASE WHEN had_failure THEN 'had_failed_payment' ELSE 'no_failed_payment' END AS payment_segment,
    COUNT(*) AS paid_users,
    COUNT(*) FILTER (WHERE canceled) AS canceled_users,
    ROUND(100.0 * COUNT(*) FILTER (WHERE canceled) / COUNT(*), 2) AS churned_user_pct
FROM user_flags GROUP BY had_failure ORDER BY had_failure DESC;
