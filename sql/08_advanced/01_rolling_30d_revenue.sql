-- ============================================================
-- 01 Rolling 30-Day Successful Payment Revenue
-- ============================================================
-- Business question:
-- How much successful payment revenue has the product generated
-- over the most recent 30-day window for each calendar date?
--
-- What this query calculates:
-- - daily successful payment revenue
-- - rolling 30-day successful payment revenue
-- - day-over-day change in the rolling revenue value
--
-- Notes:
-- Refunds and failed payments are excluded because this query focuses
-- specifically on successful payment revenue.

WITH date_bounds AS (
    SELECT
        MIN(payment_date)::date AS start_date,
        MAX(payment_date)::date AS end_date
    FROM payments
), date_spine AS (
    SELECT
        GENERATE_SERIES(start_date, end_date, INTERVAL '1 day')::date AS revenue_date
    FROM date_bounds
), daily_revenue AS (
    SELECT
        payment_date::date AS revenue_date,
        SUM(amount_usd) AS successful_revenue_usd
    FROM payments
    WHERE payment_status = 'success'
    GROUP BY payment_date::date
), rolling_revenue AS (
    SELECT
        ds.revenue_date,
        COALESCE(dr.successful_revenue_usd, 0) AS daily_successful_revenue_usd,
        SUM(COALESCE(dr.successful_revenue_usd, 0)) OVER (
            ORDER BY ds.revenue_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS rolling_30d_successful_revenue_usd
    FROM date_spine AS ds
    LEFT JOIN daily_revenue AS dr
        ON ds.revenue_date = dr.revenue_date
)
SELECT
    revenue_date,
    ROUND(daily_successful_revenue_usd, 2) AS daily_successful_revenue_usd,
    ROUND(rolling_30d_successful_revenue_usd, 2) AS rolling_30d_successful_revenue_usd,
    ROUND(
        rolling_30d_successful_revenue_usd
        - LAG(rolling_30d_successful_revenue_usd) OVER (ORDER BY revenue_date),
        2
    ) AS rolling_30d_revenue_change_usd
FROM rolling_revenue
ORDER BY revenue_date;
