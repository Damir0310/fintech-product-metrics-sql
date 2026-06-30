-- Signup cohort retention
-- Business question: Do newer signup cohorts continue engaging with the product?
-- Measures the share of a signup cohort with any event in each later calendar month.
WITH cohorts AS (
    SELECT user_id, DATE_TRUNC('month', signup_date)::date AS cohort_month
    FROM users
), activity AS (
    SELECT DISTINCT user_id, DATE_TRUNC('month', event_timestamp)::date AS activity_month
    FROM events
), cohort_activity AS (
    SELECT
        c.cohort_month,
        ((DATE_PART('year', a.activity_month) - DATE_PART('year', c.cohort_month)) * 12
          + DATE_PART('month', a.activity_month) - DATE_PART('month', c.cohort_month))::int AS month_number,
        COUNT(DISTINCT c.user_id) AS retained_users
    FROM cohorts c JOIN activity a USING (user_id)
    WHERE a.activity_month >= c.cohort_month
    GROUP BY 1, 2
), cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS cohort_size FROM cohorts GROUP BY 1
)
SELECT ca.cohort_month, ca.month_number, cs.cohort_size, ca.retained_users,
       ROUND(100.0 * ca.retained_users / cs.cohort_size, 2) AS retention_pct
FROM cohort_activity ca JOIN cohort_sizes cs USING (cohort_month)
ORDER BY ca.cohort_month, ca.month_number;
