-- Trial start rate
-- Business question: What percentage of registered users start a trial?
-- Counts each user once and identifies trial starts from lifecycle events.
SELECT
    COUNT(*) AS signed_up_users,
    COUNT(*) FILTER (WHERE EXISTS (
        SELECT 1 FROM events e WHERE e.user_id = u.user_id AND e.event_name = 'trial_started'
    )) AS trial_users,
    ROUND(100.0 * COUNT(*) FILTER (WHERE EXISTS (
        SELECT 1 FROM events e WHERE e.user_id = u.user_id AND e.event_name = 'trial_started'
    )) / NULLIF(COUNT(*), 0), 2) AS trial_start_rate_pct
FROM users u;
