-- Paid user retention
-- Business question: After the first payment, what share of users pays again in later months?
-- Cohorts users by first successful-payment month and measures repeat-payment activity.
WITH first_paid AS (
    SELECT user_id, DATE_TRUNC('month', MIN(payment_date))::date AS paid_cohort
    FROM payments WHERE payment_status = 'success' GROUP BY user_id
), paid_months AS (
    SELECT DISTINCT user_id, DATE_TRUNC('month', payment_date)::date AS paid_month
    FROM payments WHERE payment_status = 'success'
), retention AS (
    SELECT
        f.paid_cohort,
        ((DATE_PART('year', p.paid_month) - DATE_PART('year', f.paid_cohort)) * 12
          + DATE_PART('month', p.paid_month) - DATE_PART('month', f.paid_cohort))::int AS month_number,
        COUNT(DISTINCT f.user_id) AS retained_paid_users
    FROM first_paid f JOIN paid_months p USING (user_id)
    GROUP BY 1, 2
), cohort_sizes AS (
    SELECT paid_cohort, COUNT(*) AS cohort_size
    FROM first_paid GROUP BY paid_cohort
)
SELECT r.paid_cohort, r.month_number, c.cohort_size, r.retained_paid_users,
       ROUND(100.0 * r.retained_paid_users / c.cohort_size, 2) AS paid_retention_pct
FROM retention r JOIN cohort_sizes c USING (paid_cohort)
ORDER BY paid_cohort, month_number;
