-- Recovered payments
-- Business question: How many failed payments are recovered within seven days?
-- Matches each failure to the first later successful charge for the same subscription and amount.
WITH failures AS (
    SELECT payment_id, user_id, subscription_id, payment_date, amount_usd
    FROM payments WHERE payment_status = 'failed'
), recovery AS (
    SELECT f.*,
           (SELECT MIN(s.payment_date) FROM payments s
            WHERE s.subscription_id = f.subscription_id
              AND s.payment_status = 'success'
              AND s.amount_usd = f.amount_usd
              AND s.payment_date > f.payment_date
              AND s.payment_date <= f.payment_date + 7) AS recovered_at
    FROM failures f
)
SELECT
    COUNT(*) AS failed_payments,
    COUNT(*) FILTER (WHERE recovered_at IS NOT NULL) AS recovered_payments,
    ROUND(100.0 * COUNT(*) FILTER (WHERE recovered_at IS NOT NULL) / NULLIF(COUNT(*), 0), 2) AS recovery_rate_pct,
    ROUND(SUM(amount_usd) FILTER (WHERE recovered_at IS NOT NULL), 2) AS recovered_value_usd
FROM recovery;
