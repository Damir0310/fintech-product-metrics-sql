-- Average revenue per paid user (ARPU)
-- Business question: How much net revenue does a paying user generate each month?
-- Divides monthly net revenue by distinct users with a successful charge in that month.
SELECT
    DATE_TRUNC('month', payment_date)::date AS revenue_month,
    COUNT(DISTINCT user_id) FILTER (WHERE payment_status = 'success') AS paid_users,
    ROUND(SUM(CASE WHEN payment_status = 'success' THEN amount_usd WHEN payment_status = 'refunded' THEN -amount_usd ELSE 0 END), 2) AS net_revenue_usd,
    ROUND(SUM(CASE WHEN payment_status = 'success' THEN amount_usd WHEN payment_status = 'refunded' THEN -amount_usd ELSE 0 END)
          / NULLIF(COUNT(DISTINCT user_id) FILTER (WHERE payment_status = 'success'), 0), 2) AS arpu_usd
FROM payments GROUP BY 1 ORDER BY 1;
