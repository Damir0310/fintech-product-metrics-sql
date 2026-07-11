-- ============================================================
-- 02 User Lifetime Revenue Rank
-- ============================================================
-- Business question:
-- Which users contribute the most lifetime revenue, and how can
-- they be grouped into practical value tiers?
--
-- What this query calculates:
-- - net lifetime revenue per user
-- - revenue rank across the full user base
-- - cumulative revenue contribution
-- - value tier classification:
--   top_1_percent, top_5_percent, high_value, regular, low_value
--
-- Notes:
-- Successful payments add revenue and refunded payments subtract it.
-- Failed payments do not contribute to lifetime revenue.

WITH user_revenue AS (
    SELECT
        u.user_id,
        u.signup_date,
        u.country,
        u.acquisition_channel_id,
        COALESCE(
            SUM(
                CASE
                    WHEN p.payment_status = 'success' THEN p.amount_usd
                    WHEN p.payment_status = 'refunded' THEN -p.amount_usd
                    ELSE 0
                END
            ),
            0
        ) AS lifetime_revenue_usd
    FROM users AS u
    LEFT JOIN payments AS p
        ON u.user_id = p.user_id
    GROUP BY
        u.user_id,
        u.signup_date,
        u.country,
        u.acquisition_channel_id
), ranked_users AS (
    SELECT
        user_id,
        signup_date,
        country,
        acquisition_channel_id,
        lifetime_revenue_usd,
        RANK() OVER (ORDER BY lifetime_revenue_usd DESC, user_id) AS revenue_rank,
        CUME_DIST() OVER (ORDER BY lifetime_revenue_usd DESC, user_id) AS revenue_percentile_from_top,
        SUM(lifetime_revenue_usd) OVER (
            ORDER BY lifetime_revenue_usd DESC, user_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue_usd,
        SUM(lifetime_revenue_usd) OVER () AS total_revenue_usd
    FROM user_revenue
)
SELECT
    user_id,
    signup_date,
    country,
    acquisition_channel_id,
    ROUND(lifetime_revenue_usd, 2) AS lifetime_revenue_usd,
    revenue_rank,
    ROUND((100.0 * revenue_percentile_from_top)::numeric, 2) AS revenue_percentile_from_top,
    CASE
        WHEN revenue_percentile_from_top <= 0.01 THEN 'top_1_percent'
        WHEN revenue_percentile_from_top <= 0.05 THEN 'top_5_percent'
        WHEN lifetime_revenue_usd >= 100 THEN 'high_value'
        WHEN lifetime_revenue_usd > 0 THEN 'regular'
        ELSE 'low_value'
    END AS revenue_tier,
    ROUND(cumulative_revenue_usd, 2) AS cumulative_revenue_usd,
    ROUND(100.0 * cumulative_revenue_usd / NULLIF(total_revenue_usd, 0), 2) AS cumulative_revenue_pct
FROM ranked_users
ORDER BY revenue_rank, user_id;
