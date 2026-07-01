-- Monthly net revenue
-- Business question: How much gross and net payment revenue does the product collect each month?
-- Successful charges add revenue; refund records subtract it; failures contribute zero.
SELECT
    DATE_TRUNC('month', payment_date)::date AS revenue_month,
    ROUND(SUM(amount_usd) FILTER (WHERE payment_status = 'success'), 2) AS gross_revenue_usd,
    ROUND(COALESCE(SUM(amount_usd) FILTER (WHERE payment_status = 'refunded'), 0), 2) AS refunds_usd,
    ROUND(SUM(CASE WHEN payment_status = 'success' THEN amount_usd WHEN payment_status = 'refunded' THEN -amount_usd ELSE 0 END), 2) AS net_revenue_usd
FROM payments
GROUP BY 1 ORDER BY 1;
