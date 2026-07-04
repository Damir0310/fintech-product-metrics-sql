-- Data-quality check: known test users contributing to customer revenue
-- Replace the empty test_user_registry CTE with an approved registry or users.is_test flag.
-- Expected result: zero rows after connecting the registry to the approved production source.

WITH test_user_registry AS (
    -- Example production replacement:
    -- SELECT user_id, classification_reason FROM analytics.test_user_registry
    SELECT
        NULL::bigint AS user_id,
        NULL::text AS classification_reason
    WHERE FALSE
), test_user_revenue AS (
    SELECT
        p.user_id,
        t.classification_reason,
        MIN(p.payment_date) AS first_payment_date,
        MAX(p.payment_date) AS last_payment_date,
        COUNT(*) FILTER (WHERE p.payment_status = 'success') AS successful_payments,
        SUM(
            CASE
                WHEN p.payment_status = 'success' THEN p.amount_usd
                WHEN p.payment_status = 'refunded' THEN -p.amount_usd
                ELSE 0
            END
        ) AS net_revenue_usd
    FROM payments p
    JOIN test_user_registry t USING (user_id)
    GROUP BY p.user_id, t.classification_reason
)
SELECT
    user_id,
    classification_reason,
    first_payment_date,
    last_payment_date,
    successful_payments,
    ROUND(net_revenue_usd, 2) AS net_revenue_usd
FROM test_user_revenue
WHERE successful_payments > 0
   OR net_revenue_usd <> 0
ORDER BY ABS(net_revenue_usd) DESC, user_id;
