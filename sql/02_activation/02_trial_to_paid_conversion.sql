-- Trial-to-paid conversion
-- Business question: How often does a trial lead to a successful first payment?
-- Uses each user's first trial and first successful payment after that trial.
WITH trials AS (
    SELECT user_id, MIN(event_timestamp) AS trial_at
    FROM events WHERE event_name = 'trial_started' GROUP BY user_id
), first_paid AS (
    SELECT user_id, MIN(payment_date) AS first_paid_at
    FROM payments WHERE payment_status = 'success' GROUP BY user_id
)
SELECT
    COUNT(*) AS trial_users,
    COUNT(*) FILTER (WHERE first_paid_at >= trial_at::date) AS converted_users,
    ROUND(100.0 * COUNT(*) FILTER (WHERE first_paid_at >= trial_at::date) / NULLIF(COUNT(*), 0), 2) AS trial_to_paid_pct
FROM trials LEFT JOIN first_paid USING (user_id);
