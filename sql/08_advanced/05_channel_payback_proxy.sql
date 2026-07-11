-- ============================================================
-- 05 Acquisition Channel Payback Proxy
-- ============================================================
-- Business question:
-- Which acquisition channels appear to bring stronger commercial
-- quality based on conversion, revenue, churn, and LTV proxy?
--
-- What this query calculates:
-- - users acquired by channel
-- - paid conversion rate
-- - total net revenue
-- - average revenue per acquired user
-- - churn rate among paid users
-- - LTV proxy
--
-- Important limitation:
-- This is not true CAC or payback analysis because the synthetic
-- dataset does not include exact marketing spend, campaign costs,
-- sales costs, or contribution margin. It is a channel quality proxy
-- based on user and revenue outcomes only.

WITH user_revenue AS (
    SELECT
        u.user_id,
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
        ) AS net_revenue_usd,
        COUNT(p.payment_id) FILTER (WHERE p.payment_status = 'success') AS successful_payment_count
    FROM users AS u
    LEFT JOIN payments AS p
        ON u.user_id = p.user_id
    GROUP BY
        u.user_id,
        u.acquisition_channel_id
), user_subscription_flags AS (
    SELECT
        u.user_id,
        MAX(
            CASE
                WHEN s.status = 'canceled' OR s.canceled_at IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS has_churned_subscription
    FROM users AS u
    LEFT JOIN subscriptions AS s
        ON u.user_id = s.user_id
    GROUP BY u.user_id
), channel_metrics AS (
    SELECT
        ac.acquisition_channel_id,
        ac.channel_name,
        ac.channel_type,
        ac.paid_or_organic,
        COUNT(ur.user_id) AS users_acquired,
        COUNT(ur.user_id) FILTER (WHERE ur.successful_payment_count > 0) AS paid_users,
        SUM(ur.net_revenue_usd) AS total_net_revenue_usd,
        AVG(ur.net_revenue_usd) AS average_revenue_per_user_usd,
        SUM(
            CASE
                WHEN ur.successful_payment_count > 0 THEN usf.has_churned_subscription
                ELSE 0
            END
        ) AS churned_paid_users
    FROM acquisition_channels AS ac
    LEFT JOIN user_revenue AS ur
        ON ac.acquisition_channel_id = ur.acquisition_channel_id
    LEFT JOIN user_subscription_flags AS usf
        ON ur.user_id = usf.user_id
    GROUP BY
        ac.acquisition_channel_id,
        ac.channel_name,
        ac.channel_type,
        ac.paid_or_organic
), ranked_channels AS (
    SELECT
        acquisition_channel_id,
        channel_name,
        channel_type,
        paid_or_organic,
        users_acquired,
        paid_users,
        total_net_revenue_usd,
        average_revenue_per_user_usd,
        churned_paid_users,
        total_net_revenue_usd / NULLIF(paid_users, 0) AS ltv_proxy_usd,
        RANK() OVER (
            ORDER BY total_net_revenue_usd / NULLIF(paid_users, 0) DESC NULLS LAST
        ) AS ltv_proxy_rank
    FROM channel_metrics
)
SELECT
    acquisition_channel_id,
    channel_name,
    channel_type,
    paid_or_organic,
    users_acquired,
    paid_users,
    ROUND(100.0 * paid_users / NULLIF(users_acquired, 0), 2) AS paid_conversion_rate_pct,
    ROUND(total_net_revenue_usd, 2) AS total_net_revenue_usd,
    ROUND(average_revenue_per_user_usd, 2) AS average_revenue_per_user_usd,
    churned_paid_users,
    ROUND(100.0 * churned_paid_users / NULLIF(paid_users, 0), 2) AS churn_rate_pct,
    ROUND(ltv_proxy_usd, 2) AS ltv_proxy_usd,
    ltv_proxy_rank
FROM ranked_channels
ORDER BY ltv_proxy_rank, total_net_revenue_usd DESC;
