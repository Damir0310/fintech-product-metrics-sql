-- Data-quality check: duplicate payment attempts
-- Returns payment groups that share the same business fields but have multiple payment IDs.
-- Expected result: zero rows. Investigate provider retries and ingestion idempotency before removing anything.

WITH duplicate_groups AS (
    SELECT
        user_id,
        subscription_id,
        payment_date,
        amount_usd,
        currency,
        payment_status,
        payment_provider,
        failure_reason,
        COUNT(*) AS duplicate_count,
        ARRAY_AGG(payment_id ORDER BY payment_id) AS payment_ids
    FROM payments
    GROUP BY
        user_id,
        subscription_id,
        payment_date,
        amount_usd,
        currency,
        payment_status,
        payment_provider,
        failure_reason
    HAVING COUNT(*) > 1
)
SELECT
    user_id,
    subscription_id,
    payment_date,
    amount_usd,
    currency,
    payment_status,
    payment_provider,
    failure_reason,
    duplicate_count,
    payment_ids
FROM duplicate_groups
ORDER BY payment_date, subscription_id, payment_ids;
