-- Data-quality check: events before user registration
-- Returns events whose timestamp is earlier than the user's recorded signup date.
-- Expected result: zero rows. Investigate timezone handling, identity merges, and backfills.

SELECT
    e.event_id,
    e.user_id,
    e.event_name,
    e.event_timestamp,
    u.signup_date,
    e.event_source,
    e.event_timestamp - u.signup_date::timestamp AS time_difference
FROM events e
JOIN users u USING (user_id)
WHERE e.event_timestamp < u.signup_date::timestamp
ORDER BY e.event_timestamp, e.event_id;
