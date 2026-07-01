-- Daily signups
-- Business question: How is user acquisition changing day by day?
-- Calculates new users and a seven-day rolling average on a complete date spine.
WITH date_spine AS (
    SELECT GENERATE_SERIES(MIN(signup_date), MAX(signup_date), INTERVAL '1 day')::date AS signup_date
    FROM users
), daily AS (
    SELECT
        d.signup_date,
        COUNT(u.user_id) AS signups
    FROM date_spine d
    LEFT JOIN users u USING (signup_date)
    GROUP BY d.signup_date
)
SELECT
    signup_date,
    signups,
    ROUND(AVG(signups) OVER (ORDER BY signup_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS signups_7d_avg
FROM daily
ORDER BY signup_date;
