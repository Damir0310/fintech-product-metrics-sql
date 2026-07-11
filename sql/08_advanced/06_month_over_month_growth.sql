-- ============================================================
-- 06 Month-Over-Month Growth
-- ============================================================
-- Business question:
-- How are core product and revenue metrics changing month over
-- month?
--
-- What this query calculates:
-- Month-over-month growth for:
-- - signups
-- - successful payment revenue
-- - active paid subscriptions
-- - churned subscriptions
--
-- Notes:
-- Active paid subscriptions are approximated from subscription
-- lifecycle dates and successful payment history. This is suitable
-- for this synthetic dataset, but a production warehouse would often
-- use a daily subscription status snapshot table.

WITH month_bounds AS (
    SELECT
        DATE_TRUNC(
            'month',
            LEAST(
                (SELECT MIN(signup_date) FROM users),
                (SELECT MIN(started_at) FROM subscriptions),
                (SELECT MIN(payment_date) FROM payments)
            )
        )::date AS start_month,
        DATE_TRUNC(
            'month',
            GREATEST(
                (SELECT MAX(signup_date) FROM users),
                (SELECT MAX(started_at) FROM subscriptions),
                (SELECT MAX(payment_date) FROM payments),
                (SELECT MAX(canceled_at) FROM subscriptions)
            )
        )::date AS end_month
), month_spine AS (
    SELECT
        GENERATE_SERIES(start_month, end_month, INTERVAL '1 month')::date AS month_start
    FROM month_bounds
), monthly_signups AS (
    SELECT
        DATE_TRUNC('month', signup_date)::date AS month_start,
        COUNT(*) AS signups
    FROM users
    GROUP BY DATE_TRUNC('month', signup_date)::date
), monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', payment_date)::date AS month_start,
        SUM(amount_usd) AS successful_payment_revenue_usd
    FROM payments
    WHERE payment_status = 'success'
    GROUP BY DATE_TRUNC('month', payment_date)::date
), paid_subscriptions AS (
    SELECT DISTINCT
        s.subscription_id,
        s.started_at,
        s.canceled_at
    FROM subscriptions AS s
    JOIN payments AS p
        ON s.subscription_id = p.subscription_id
    WHERE p.payment_status = 'success'
), monthly_active_subscriptions AS (
    SELECT
        ms.month_start,
        COUNT(ps.subscription_id) AS active_paid_subscriptions
    FROM month_spine AS ms
    LEFT JOIN paid_subscriptions AS ps
        ON ps.started_at < ms.month_start + INTERVAL '1 month'
       AND (
           ps.canceled_at IS NULL
           OR ps.canceled_at >= ms.month_start
       )
    GROUP BY ms.month_start
), monthly_churn AS (
    SELECT
        DATE_TRUNC('month', canceled_at)::date AS month_start,
        COUNT(*) AS churned_subscriptions
    FROM subscriptions
    WHERE status = 'canceled'
      AND canceled_at IS NOT NULL
    GROUP BY DATE_TRUNC('month', canceled_at)::date
), monthly_metrics AS (
    SELECT
        ms.month_start,
        COALESCE(s.signups, 0) AS signups,
        COALESCE(r.successful_payment_revenue_usd, 0) AS successful_payment_revenue_usd,
        COALESCE(a.active_paid_subscriptions, 0) AS active_paid_subscriptions,
        COALESCE(c.churned_subscriptions, 0) AS churned_subscriptions
    FROM month_spine AS ms
    LEFT JOIN monthly_signups AS s
        ON ms.month_start = s.month_start
    LEFT JOIN monthly_revenue AS r
        ON ms.month_start = r.month_start
    LEFT JOIN monthly_active_subscriptions AS a
        ON ms.month_start = a.month_start
    LEFT JOIN monthly_churn AS c
        ON ms.month_start = c.month_start
), metrics_with_lag AS (
    SELECT
        month_start,
        signups,
        successful_payment_revenue_usd,
        active_paid_subscriptions,
        churned_subscriptions,
        LAG(signups) OVER (ORDER BY month_start) AS previous_month_signups,
        LAG(successful_payment_revenue_usd) OVER (ORDER BY month_start) AS previous_month_revenue_usd,
        LAG(active_paid_subscriptions) OVER (ORDER BY month_start) AS previous_month_active_subscriptions,
        LAG(churned_subscriptions) OVER (ORDER BY month_start) AS previous_month_churned_subscriptions
    FROM monthly_metrics
)
SELECT
    month_start,
    signups,
    previous_month_signups,
    ROUND(100.0 * (signups - previous_month_signups) / NULLIF(previous_month_signups, 0), 2) AS signup_mom_growth_pct,
    ROUND(successful_payment_revenue_usd, 2) AS successful_payment_revenue_usd,
    ROUND(previous_month_revenue_usd, 2) AS previous_month_revenue_usd,
    ROUND(
        100.0 * (successful_payment_revenue_usd - previous_month_revenue_usd)
        / NULLIF(previous_month_revenue_usd, 0),
        2
    ) AS revenue_mom_growth_pct,
    active_paid_subscriptions,
    previous_month_active_subscriptions,
    ROUND(
        100.0 * (active_paid_subscriptions - previous_month_active_subscriptions)
        / NULLIF(previous_month_active_subscriptions, 0),
        2
    ) AS active_subscription_mom_growth_pct,
    churned_subscriptions,
    previous_month_churned_subscriptions,
    ROUND(
        100.0 * (churned_subscriptions - previous_month_churned_subscriptions)
        / NULLIF(previous_month_churned_subscriptions, 0),
        2
    ) AS churned_subscription_mom_growth_pct
FROM metrics_with_lag
ORDER BY month_start;
