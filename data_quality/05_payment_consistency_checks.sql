-- ============================================================
-- 05 Payment Consistency Checks
-- ============================================================
-- Purpose:
-- Validate that billing records and payment-related events are
-- logically consistent. These checks protect revenue, MRR, ARR,
-- LTV, payment success rate, failed payment rate, and churn analysis.
--
-- Expected use:
-- Most checks return suspicious rows that should be investigated.
-- Refunded payments are listed for review because they may require
-- special handling in revenue recognition.

-- Successful payments with non-positive amount.
SELECT
    payment_id,
    user_id,
    subscription_id,
    payment_date,
    amount_usd,
    payment_status
FROM payments
WHERE payment_status = 'success'
  AND amount_usd <= 0;

-- Failed payments without a failure reason.
SELECT
    payment_id,
    user_id,
    subscription_id,
    payment_date,
    payment_status,
    failure_reason
FROM payments
WHERE payment_status = 'failed'
  AND failure_reason IS NULL;

-- Payments with a missing provider.
SELECT
    payment_id,
    user_id,
    subscription_id,
    payment_date,
    payment_status,
    payment_provider
FROM payments
WHERE payment_provider IS NULL;

-- Refunded payments that need revenue treatment review.
SELECT
    payment_id,
    user_id,
    subscription_id,
    payment_date,
    amount_usd,
    payment_status,
    payment_provider
FROM payments
WHERE payment_status = 'refunded';

-- payment_success events without a matching successful payment
-- for the same user on the same calendar date.
SELECT
    e.event_id,
    e.user_id,
    e.event_name,
    e.event_timestamp
FROM events AS e
WHERE e.event_name = 'payment_success'
  AND NOT EXISTS (
      SELECT 1
      FROM payments AS p
      WHERE p.user_id = e.user_id
        AND p.payment_status = 'success'
        AND p.payment_date = e.event_timestamp::date
  );

-- payment_failed events without a matching failed payment
-- for the same user on the same calendar date.
SELECT
    e.event_id,
    e.user_id,
    e.event_name,
    e.event_timestamp
FROM events AS e
WHERE e.event_name = 'payment_failed'
  AND NOT EXISTS (
      SELECT 1
      FROM payments AS p
      WHERE p.user_id = e.user_id
        AND p.payment_status = 'failed'
        AND p.payment_date = e.event_timestamp::date
  );
