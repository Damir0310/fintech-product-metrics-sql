-- Revenue by plan
-- Business question: Which subscription plan contributes the most revenue?
-- Calculates users, charges, net revenue, and revenue mix by plan.
WITH plan_revenue AS (
    SELECT
        s.plan_name,
        COUNT(DISTINCT p.user_id) FILTER (WHERE p.payment_status = 'success') AS paid_users,
        COUNT(*) FILTER (WHERE p.payment_status = 'success') AS successful_charges,
        SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END) AS net_revenue
    FROM subscriptions s LEFT JOIN payments p USING (subscription_id)
    GROUP BY s.plan_name
)
SELECT *, ROUND(100.0 * net_revenue / NULLIF(SUM(net_revenue) OVER (), 0), 2) AS revenue_share_pct
FROM plan_revenue ORDER BY net_revenue DESC;
