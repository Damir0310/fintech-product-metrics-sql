-- Trial reminder experiment: conversion by assigned group
-- Business question: Does a reminder 24 hours before trial expiration improve seven-day trial-to-paid conversion?
-- Lab note: deterministic hashing creates reproducible groups because the sample schema has no assignment table.
-- In production, replace the assignments CTE with immutable recorded experiment assignments.

WITH observation AS (
    SELECT MAX(payment_date) AS observation_end
    FROM payments
), eligible_trials AS (
    SELECT
        s.user_id,
        s.subscription_id,
        s.trial_started_at,
        s.trial_ended_at,
        s.trial_ended_at::timestamp - INTERVAL '24 hours' AS assigned_at
    FROM subscriptions s
    CROSS JOIN observation o
    WHERE s.trial_started_at IS NOT NULL
      AND s.trial_ended_at IS NOT NULL
      -- Include only trials with a complete seven-day outcome window.
      AND s.trial_ended_at + 7 <= o.observation_end
), assignments AS (
    SELECT
        e.*,
        CASE
            WHEN MOD(ABS(HASHTEXT(e.user_id::text || ':trial_reminder_v1')::bigint), 2) = 0
                THEN 'control'
            ELSE 'reminder_24h'
        END AS variant
    FROM eligible_trials e
    WHERE NOT EXISTS (
        SELECT 1
        FROM payments p
        WHERE p.user_id = e.user_id
          AND p.payment_status = 'success'
          AND p.payment_date < e.assigned_at::date
    )
), user_outcomes AS (
    SELECT
        a.user_id,
        a.variant,
        MIN(p.payment_date) FILTER (
            WHERE p.payment_status = 'success'
              AND p.payment_date >= a.assigned_at::date
              AND p.payment_date <= a.trial_ended_at + 7
        ) AS first_successful_payment_at
    FROM assignments a
    LEFT JOIN payments p
        ON p.user_id = a.user_id
       AND p.subscription_id = a.subscription_id
    GROUP BY a.user_id, a.variant
)
SELECT
    variant,
    COUNT(*) AS assigned_users,
    COUNT(*) FILTER (WHERE first_successful_payment_at IS NOT NULL) AS converted_users,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE first_successful_payment_at IS NOT NULL)
        / NULLIF(COUNT(*), 0),
        2
    ) AS conversion_rate_pct
FROM user_outcomes
GROUP BY variant
ORDER BY variant;
