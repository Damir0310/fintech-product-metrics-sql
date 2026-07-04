-- Trial reminder experiment: guardrail metrics by assigned group
-- Business question: Does the reminder change payment friction, refunds, cancellation, or support demand?
-- Lab note: group assignment mirrors conversion_by_group.sql and does not represent a real treatment delivery.

WITH observation AS (
    SELECT MAX(payment_date) AS observation_end
    FROM payments
), eligible_trials AS (
    SELECT
        s.user_id,
        s.subscription_id,
        s.trial_ended_at,
        s.trial_ended_at::timestamp - INTERVAL '24 hours' AS assigned_at
    FROM subscriptions s
    CROSS JOIN observation o
    WHERE s.trial_started_at IS NOT NULL
      AND s.trial_ended_at IS NOT NULL
      -- Guardrails use a 30-day window and therefore require more maturity.
      AND s.trial_ended_at + 30 <= o.observation_end
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
), user_guardrails AS (
    SELECT
        a.user_id,
        a.variant,
        COUNT(p.payment_id) FILTER (
            WHERE p.payment_status IN ('success', 'failed')
              AND p.payment_date BETWEEN a.assigned_at::date AND a.trial_ended_at + 30
        ) AS payment_attempts,
        COUNT(p.payment_id) FILTER (
            WHERE p.payment_status = 'failed'
              AND p.payment_date BETWEEN a.assigned_at::date AND a.trial_ended_at + 30
        ) AS failed_attempts,
        BOOL_OR(
            p.payment_status = 'success'
            AND p.payment_date BETWEEN a.assigned_at::date AND a.trial_ended_at + 30
        ) AS converted,
        BOOL_OR(
            p.payment_status = 'refunded'
            AND p.payment_date BETWEEN a.assigned_at::date AND a.trial_ended_at + 30
        ) AS had_refund,
        EXISTS (
            SELECT 1
            FROM subscriptions s
            WHERE s.subscription_id = a.subscription_id
              AND s.canceled_at BETWEEN a.assigned_at::date AND a.trial_ended_at + 30
        ) AS canceled_within_30d,
        EXISTS (
            SELECT 1
            FROM events e
            WHERE e.user_id = a.user_id
              AND e.event_name = 'support_contacted'
              AND e.event_timestamp >= a.assigned_at
              AND e.event_timestamp < a.trial_ended_at::timestamp + INTERVAL '31 days'
        ) AS contacted_support
    FROM assignments a
    LEFT JOIN payments p
        ON p.user_id = a.user_id
       AND p.subscription_id = a.subscription_id
    GROUP BY
        a.user_id,
        a.variant,
        a.subscription_id,
        a.assigned_at,
        a.trial_ended_at
)
SELECT
    variant,
    COUNT(*) AS assigned_users,
    SUM(payment_attempts) AS payment_attempts,
    ROUND(100.0 * SUM(failed_attempts) / NULLIF(SUM(payment_attempts), 0), 2) AS failed_attempt_rate_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE had_refund) / NULLIF(COUNT(*) FILTER (WHERE converted), 0), 2) AS refund_rate_among_converters_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE canceled_within_30d) / NULLIF(COUNT(*), 0), 2) AS cancellation_rate_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE contacted_support) / NULLIF(COUNT(*), 0), 2) AS support_contact_rate_pct
FROM user_guardrails
GROUP BY variant
ORDER BY variant;
