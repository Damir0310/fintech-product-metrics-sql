-- Observed LTV by plan
-- Business question: Which plan has the strongest realized customer value?
-- Calculates net revenue per distinct paid user for subscriptions on each plan.
WITH subscription_value AS (
    SELECT s.plan_name, s.user_id,
           SUM(CASE WHEN p.payment_status = 'success' THEN p.amount_usd WHEN p.payment_status = 'refunded' THEN -p.amount_usd ELSE 0 END) AS net_revenue
    FROM subscriptions s JOIN payments p USING (subscription_id)
    GROUP BY s.plan_name, s.user_id
)
SELECT plan_name, COUNT(*) AS paid_users,
       ROUND(AVG(net_revenue), 2) AS observed_ltv_usd,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY net_revenue)::numeric, 2) AS median_ltv_usd
FROM subscription_value GROUP BY plan_name ORDER BY observed_ltv_usd DESC;
