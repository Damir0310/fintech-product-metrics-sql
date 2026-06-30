-- Monthly recurring revenue (MRR)
-- Business question: What is the monthly-normalized value of successful recurring charges?
-- Normalizes quarterly and yearly plan charges to monthly equivalents.
WITH normalized AS (
    SELECT
        DATE_TRUNC('month', p.payment_date)::date AS revenue_month,
        CASE s.plan_name
            WHEN 'monthly' THEN p.amount_usd
            WHEN 'quarterly' THEN p.amount_usd / 3.0
            WHEN 'yearly' THEN p.amount_usd / 12.0
        END AS monthly_value
    FROM payments p JOIN subscriptions s USING (subscription_id)
    WHERE p.payment_status = 'success'
)
SELECT revenue_month, ROUND(SUM(monthly_value), 2) AS collected_mrr_usd
FROM normalized GROUP BY revenue_month ORDER BY revenue_month;
