-- Annual recurring revenue (ARR)
-- Business question: What annual run rate is implied by monthly-normalized charges?
-- Calculates collected MRR and multiplies it by 12; this is a run-rate metric, not booked revenue.
WITH mrr AS (
    SELECT
        DATE_TRUNC('month', p.payment_date)::date AS revenue_month,
        SUM(p.amount_usd / CASE s.plan_name WHEN 'monthly' THEN 1 WHEN 'quarterly' THEN 3 ELSE 12 END) AS mrr_usd
    FROM payments p JOIN subscriptions s USING (subscription_id)
    WHERE p.payment_status = 'success'
    GROUP BY 1
)
SELECT revenue_month, ROUND(mrr_usd, 2) AS mrr_usd, ROUND(mrr_usd * 12, 2) AS arr_run_rate_usd
FROM mrr ORDER BY revenue_month;
