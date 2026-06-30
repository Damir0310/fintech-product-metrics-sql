-- Reactivation rate
-- Business question: How often do canceled users return?
-- A reactivation counts only when its event occurs after the user's cancellation event.
WITH canceled_users AS (
    SELECT user_id, MIN(event_timestamp) AS canceled_at
    FROM events WHERE event_name = 'subscription_canceled' GROUP BY user_id
), flags AS (
    SELECT c.user_id,
           EXISTS (SELECT 1 FROM events e WHERE e.user_id = c.user_id AND e.event_name = 'reactivated' AND e.event_timestamp > c.canceled_at) AS reactivated
    FROM canceled_users c
)
SELECT
    COUNT(*) AS canceled_users,
    COUNT(*) FILTER (WHERE reactivated) AS reactivated_users,
    ROUND(100.0 * COUNT(*) FILTER (WHERE reactivated) / NULLIF(COUNT(*), 0), 2) AS reactivation_rate_pct
FROM flags;
