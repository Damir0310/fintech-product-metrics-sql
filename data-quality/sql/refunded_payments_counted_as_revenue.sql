-- Data-quality check: refund rows at risk of being counted as positive revenue
-- Returns refunds that unsafe SUM(amount_usd) logic would add instead of subtract.
-- Expected result: review rows may exist because refunds are legitimate; every row must be a negative net-revenue adjustment.

WITH refund_reconciliation AS (
    SELECT
        r.payment_id AS refund_payment_id,
        r.user_id,
        r.subscription_id,
        r.payment_date AS refund_date,
        r.amount_usd,
        r.payment_provider,
        (
            SELECT MAX(s.payment_id)
            FROM payments s
            WHERE s.subscription_id = r.subscription_id
              AND s.user_id = r.user_id
              AND s.payment_status = 'success'
              AND s.amount_usd = r.amount_usd
              AND s.payment_date <= r.payment_date
        ) AS prior_success_payment_id
    FROM payments r
    WHERE r.payment_status = 'refunded'
)
SELECT
    refund_payment_id,
    user_id,
    subscription_id,
    refund_date,
    amount_usd AS unsafe_positive_revenue_usd,
    -amount_usd AS correct_net_revenue_adjustment_usd,
    payment_provider,
    prior_success_payment_id,
    CASE
        WHEN prior_success_payment_id IS NULL THEN 'missing_prior_success'
        ELSE 'must_be_subtracted_from_net_revenue'
    END AS investigation_reason
FROM refund_reconciliation
ORDER BY refund_date, refund_payment_id;
