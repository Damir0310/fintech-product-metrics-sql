-- Paid user retention
-- Business question: What share of first-payment cohorts still has an active paid subscription at later month ends?
-- Uses subscription state rather than payment frequency, avoiding bias against quarterly and yearly plans.
WITH observation AS (
    SELECT DATE_TRUNC('month', MAX(payment_date))::date AS last_month
    FROM payments
), first_paid AS (
    SELECT user_id, MIN(payment_date) AS first_paid_at
    FROM payments
    WHERE payment_status = 'success'
    GROUP BY user_id
), reactivations AS (
    SELECT user_id, MIN(event_timestamp)::date AS reactivated_at
    FROM events
    WHERE event_name = 'reactivated'
    GROUP BY user_id
), paid_users AS (
    SELECT
        f.user_id,
        DATE_TRUNC('month', f.first_paid_at)::date AS paid_cohort,
        s.started_at,
        s.canceled_at,
        r.reactivated_at
    FROM first_paid f
    JOIN subscriptions s USING (user_id)
    LEFT JOIN reactivations r USING (user_id)
), cohort_months AS (
    SELECT
        p.*,
        month_series.activity_month::date AS activity_month
    FROM paid_users p
    CROSS JOIN observation o
    CROSS JOIN LATERAL GENERATE_SERIES(
        p.paid_cohort,
        o.last_month,
        INTERVAL '1 month'
    ) AS month_series(activity_month)
), retention AS (
    SELECT
        paid_cohort,
        activity_month,
        (
            (DATE_PART('year', activity_month) - DATE_PART('year', paid_cohort)) * 12
            + DATE_PART('month', activity_month) - DATE_PART('month', paid_cohort)
        )::int AS month_number,
        COUNT(*) AS cohort_size,
        COUNT(*) FILTER (
            WHERE started_at < activity_month + INTERVAL '1 month'
              AND (
                  canceled_at IS NULL
                  OR canceled_at >= activity_month + INTERVAL '1 month'
                  OR reactivated_at < activity_month + INTERVAL '1 month'
              )
        ) AS retained_paid_users
    FROM cohort_months
    GROUP BY paid_cohort, activity_month
)
SELECT
    paid_cohort,
    month_number,
    cohort_size,
    retained_paid_users,
    ROUND(100.0 * retained_paid_users / NULLIF(cohort_size, 0), 2) AS paid_retention_pct
FROM retention
ORDER BY paid_cohort, month_number;
