-- Data quality checks for the synthetic dataset.
-- Run with: psql -d fintech_metrics -f db/sample_checks.sql
-- Unless a query says otherwise, a healthy result is zero rows or a zero count.

-- 1. Row-count profile. The deterministic seed produces 5,000 users.
SELECT 'acquisition_channels' AS entity, COUNT(*) AS row_count FROM acquisition_channels
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'subscriptions', COUNT(*) FROM subscriptions
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'events', COUNT(*) FROM events
ORDER BY entity;

SELECT COUNT(*) = 5000 AS has_expected_user_count
FROM users;

-- 2. Duplicate identifiers. This query should return no rows.
SELECT 'acquisition_channels' AS entity, acquisition_channel_id::text AS duplicate_id, COUNT(*) AS occurrences
FROM acquisition_channels GROUP BY acquisition_channel_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'users', user_id::text, COUNT(*)
FROM users GROUP BY user_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'subscriptions', subscription_id::text, COUNT(*)
FROM subscriptions GROUP BY subscription_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'payments', payment_id::text, COUNT(*)
FROM payments GROUP BY payment_id HAVING COUNT(*) > 1
UNION ALL
SELECT 'events', event_id::text, COUNT(*)
FROM events GROUP BY event_id HAVING COUNT(*) > 1;

-- 3. Orphaned records and cross-table ownership mismatches.
SELECT COUNT(*) AS users_with_missing_channel
FROM users u
LEFT JOIN acquisition_channels c USING (acquisition_channel_id)
WHERE c.acquisition_channel_id IS NULL;

SELECT COUNT(*) AS subscriptions_with_missing_user
FROM subscriptions s
LEFT JOIN users u USING (user_id)
WHERE u.user_id IS NULL;

SELECT COUNT(*) AS payments_with_missing_user_or_subscription
FROM payments p
LEFT JOIN users u USING (user_id)
LEFT JOIN subscriptions s USING (subscription_id)
WHERE u.user_id IS NULL OR s.subscription_id IS NULL;

SELECT COUNT(*) AS events_with_missing_user
FROM events e
LEFT JOIN users u USING (user_id)
WHERE u.user_id IS NULL;

SELECT COUNT(*) AS payments_with_user_subscription_mismatch
FROM payments p
JOIN subscriptions s USING (subscription_id)
WHERE p.user_id <> s.user_id;

-- 4. Lifecycle chronology and state consistency.
SELECT COUNT(*) AS subscriptions_starting_before_signup
FROM subscriptions s
JOIN users u USING (user_id)
WHERE s.started_at < u.signup_date;

SELECT COUNT(*) AS invalid_trial_ranges
FROM subscriptions
WHERE trial_ended_at < trial_started_at;

SELECT COUNT(*) AS invalid_cancellations
FROM subscriptions
WHERE canceled_at < started_at
   OR (status = 'canceled' AND canceled_at IS NULL)
   OR (canceled_at IS NOT NULL AND cancellation_reason IS NULL);

SELECT COUNT(*) AS invalid_failure_reason_usage
FROM payments
WHERE (payment_status = 'failed' AND failure_reason IS NULL)
   OR (payment_status <> 'failed' AND failure_reason IS NOT NULL);

-- 5. Required lifecycle event coverage.
SELECT COUNT(*) AS users_without_exactly_one_signup_event
FROM (
    SELECT u.user_id
    FROM users u
    LEFT JOIN events e
        ON e.user_id = u.user_id
       AND e.event_name = 'signup'
    GROUP BY u.user_id
    HAVING COUNT(e.event_id) <> 1
) invalid_users;

SELECT COUNT(*) AS failed_payments_without_matching_event
FROM payments p
WHERE p.payment_status = 'failed'
  AND NOT EXISTS (
      SELECT 1
      FROM events e
      WHERE e.user_id = p.user_id
        AND e.event_name = 'payment_failed'
        AND e.event_timestamp::date = p.payment_date
  );

SELECT COUNT(*) AS successful_payments_without_matching_event
FROM payments p
WHERE p.payment_status = 'success'
  AND NOT EXISTS (
      SELECT 1
      FROM events e
      WHERE e.user_id = p.user_id
        AND e.event_name = 'payment_success'
        AND e.event_timestamp::date = p.payment_date
  );

SELECT COUNT(*) AS cancellations_without_matching_event
FROM subscriptions s
WHERE s.canceled_at IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM events e
      WHERE e.user_id = s.user_id
        AND e.event_name = 'subscription_canceled'
        AND e.event_timestamp::date = s.canceled_at
  );

-- 6. Revenue reconciliation. Failures contribute no revenue.
SELECT
    ROUND(COALESCE(SUM(amount_usd) FILTER (WHERE payment_status = 'success'), 0), 2) AS gross_revenue_usd,
    ROUND(COALESCE(SUM(amount_usd) FILTER (WHERE payment_status = 'refunded'), 0), 2) AS refunds_usd,
    ROUND(COALESCE(SUM(
        CASE
            WHEN payment_status = 'success' THEN amount_usd
            WHEN payment_status = 'refunded' THEN -amount_usd
            ELSE 0
        END
    ), 0), 2) AS net_revenue_usd
FROM payments;

SELECT COUNT(*) AS refunds_without_prior_success
FROM payments r
WHERE r.payment_status = 'refunded'
  AND NOT EXISTS (
      SELECT 1
      FROM payments s
      WHERE s.subscription_id = r.subscription_id
        AND s.payment_status = 'success'
        AND s.amount_usd = r.amount_usd
        AND s.payment_date <= r.payment_date
  );
