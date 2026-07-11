-- ============================================================
-- 03 Churn Risk Segments
-- ============================================================
-- Business question:
-- Which users show signals that may indicate higher churn risk?
--
-- What this query calculates:
-- A simple rules-based churn risk segment using:
-- - failed payment history
-- - recent successful payment activity
-- - latest subscription plan type
-- - cancellation history
-- - support contact events
-- - user lifetime since signup
--
-- Notes:
-- This is not a predictive model. It is a transparent SQL heuristic
-- that can help prioritize deeper investigation.

WITH analysis_anchor AS (
    SELECT
        GREATEST(
            (SELECT MAX(signup_date) FROM users),
            (SELECT MAX(started_at) FROM subscriptions),
            (SELECT MAX(payment_date) FROM payments),
            (SELECT MAX(event_timestamp)::date FROM events)
        ) AS analysis_date
), latest_subscription AS (
    SELECT
        subscription_id,
        user_id,
        plan_name,
        status,
        started_at,
        canceled_at,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY started_at DESC, subscription_id DESC
        ) AS subscription_recency_rank
    FROM subscriptions
), user_payment_signals AS (
    SELECT
        u.user_id,
        COUNT(p.payment_id) FILTER (WHERE p.payment_status = 'failed') AS failed_payment_count,
        COUNT(p.payment_id) FILTER (
            WHERE p.payment_status = 'failed'
              AND p.payment_date >= aa.analysis_date - INTERVAL '90 days'
        ) AS failed_payments_last_90d,
        MAX(p.payment_date) FILTER (WHERE p.payment_status = 'success') AS last_successful_payment_date
    FROM users AS u
    CROSS JOIN analysis_anchor AS aa
    LEFT JOIN payments AS p
        ON u.user_id = p.user_id
    GROUP BY u.user_id
), user_event_signals AS (
    SELECT
        u.user_id,
        COUNT(e.event_id) FILTER (WHERE e.event_name = 'support_contacted') AS support_contact_count,
        COUNT(e.event_id) FILTER (
            WHERE e.event_name = 'support_contacted'
              AND e.event_timestamp::date >= aa.analysis_date - INTERVAL '90 days'
        ) AS support_contacts_last_90d
    FROM users AS u
    CROSS JOIN analysis_anchor AS aa
    LEFT JOIN events AS e
        ON u.user_id = e.user_id
    GROUP BY u.user_id
), user_subscription_signals AS (
    SELECT
        u.user_id,
        COALESCE(ls.plan_name, 'no_plan') AS latest_plan_name,
        COALESCE(ls.status, 'no_subscription') AS latest_subscription_status,
        COUNT(s.subscription_id) FILTER (
            WHERE s.status = 'canceled'
               OR s.canceled_at IS NOT NULL
        ) AS canceled_subscription_count
    FROM users AS u
    LEFT JOIN latest_subscription AS ls
        ON u.user_id = ls.user_id
       AND ls.subscription_recency_rank = 1
    LEFT JOIN subscriptions AS s
        ON u.user_id = s.user_id
    GROUP BY
        u.user_id,
        ls.plan_name,
        ls.status
), scored_users AS (
    SELECT
        u.user_id,
        u.signup_date,
        aa.analysis_date,
        aa.analysis_date - u.signup_date AS user_lifetime_days,
        ups.failed_payment_count,
        ups.failed_payments_last_90d,
        ups.last_successful_payment_date,
        ues.support_contact_count,
        ues.support_contacts_last_90d,
        uss.latest_plan_name,
        uss.latest_subscription_status,
        uss.canceled_subscription_count,
        (
            CASE WHEN ups.failed_payments_last_90d >= 2 THEN 3 ELSE 0 END
            + CASE WHEN ups.failed_payment_count >= 3 THEN 2 ELSE 0 END
            + CASE
                WHEN ups.last_successful_payment_date IS NULL THEN 2
                WHEN ups.last_successful_payment_date < aa.analysis_date - INTERVAL '60 days' THEN 2
                ELSE 0
              END
            + CASE WHEN uss.latest_plan_name = 'monthly' THEN 1 ELSE 0 END
            + CASE WHEN uss.canceled_subscription_count > 0 THEN 3 ELSE 0 END
            + CASE WHEN ues.support_contacts_last_90d >= 2 THEN 1 ELSE 0 END
            + CASE WHEN aa.analysis_date - u.signup_date <= 30 THEN 1 ELSE 0 END
        ) AS churn_risk_score
    FROM users AS u
    CROSS JOIN analysis_anchor AS aa
    LEFT JOIN user_payment_signals AS ups
        ON u.user_id = ups.user_id
    LEFT JOIN user_event_signals AS ues
        ON u.user_id = ues.user_id
    LEFT JOIN user_subscription_signals AS uss
        ON u.user_id = uss.user_id
)
SELECT
    user_id,
    signup_date,
    user_lifetime_days,
    latest_plan_name,
    latest_subscription_status,
    failed_payment_count,
    failed_payments_last_90d,
    last_successful_payment_date,
    support_contact_count,
    support_contacts_last_90d,
    canceled_subscription_count,
    churn_risk_score,
    CASE
        WHEN churn_risk_score >= 6 THEN 'high_risk'
        WHEN churn_risk_score >= 3 THEN 'medium_risk'
        ELSE 'low_risk'
    END AS churn_risk_segment
FROM scored_users
ORDER BY churn_risk_score DESC, failed_payments_last_90d DESC, user_id;
