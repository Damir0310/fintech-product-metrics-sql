-- Time to activation
-- Business question: How long does it take users to move from signup to trial and first payment?
-- Reports median and 90th-percentile conversion time for users who reach each milestone.
WITH trial_milestones AS (
    SELECT user_id, MIN(event_timestamp) AS trial_started_at
    FROM events
    WHERE event_name = 'trial_started'
    GROUP BY user_id
), payment_milestones AS (
    SELECT user_id, MIN(payment_date) AS first_paid_at
    FROM payments
    WHERE payment_status = 'success'
    GROUP BY user_id
), durations AS (
    SELECT
        u.user_id,
        EXTRACT(EPOCH FROM (t.trial_started_at - u.signup_date::timestamp)) / 86400.0 AS days_to_trial,
        p.first_paid_at - u.signup_date AS days_to_first_payment
    FROM users u
    LEFT JOIN trial_milestones t USING (user_id)
    LEFT JOIN payment_milestones p USING (user_id)
)
SELECT
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_to_trial)::numeric, 2) AS median_days_to_trial,
    ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY days_to_trial)::numeric, 2) AS p90_days_to_trial,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_to_first_payment)::numeric, 2) AS median_days_to_first_payment,
    ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY days_to_first_payment)::numeric, 2) AS p90_days_to_first_payment
FROM durations;
