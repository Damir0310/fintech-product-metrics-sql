-- Dataset validation checks. Healthy results show zero integrity problems.

SELECT 'users' AS entity, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'subscriptions', COUNT(*) FROM subscriptions
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'events', COUNT(*) FROM events;

-- Missing foreign keys.
SELECT COUNT(*) AS users_with_missing_channel
FROM users u LEFT JOIN acquisition_channels c USING (acquisition_channel_id)
WHERE c.acquisition_channel_id IS NULL;

SELECT COUNT(*) AS subscriptions_with_missing_user
FROM subscriptions s LEFT JOIN users u USING (user_id)
WHERE u.user_id IS NULL;

SELECT COUNT(*) AS payments_with_missing_user
FROM payments p LEFT JOIN users u USING (user_id)
WHERE u.user_id IS NULL;

-- Duplicate identifiers: this query should return no rows.
SELECT 'users' AS entity, user_id::text AS duplicate_id, COUNT(*)
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

SELECT COUNT(*) AS payments_without_subscriptions
FROM payments p LEFT JOIN subscriptions s USING (subscription_id)
WHERE s.subscription_id IS NULL;

SELECT COUNT(*) AS users_without_signup_event
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM events e
    WHERE e.user_id = u.user_id AND e.event_name = 'signup'
);

-- Gross, refunds, and net recognized revenue.
SELECT
    ROUND(SUM(amount_usd) FILTER (WHERE payment_status = 'success'), 2) AS gross_revenue_usd,
    ROUND(SUM(amount_usd) FILTER (WHERE payment_status = 'refunded'), 2) AS refunds_usd,
    ROUND(SUM(CASE WHEN payment_status = 'success' THEN amount_usd WHEN payment_status = 'refunded' THEN -amount_usd ELSE 0 END), 2) AS net_revenue_usd
FROM payments;

-- Cross-table consistency checks.
SELECT COUNT(*) AS payments_with_user_subscription_mismatch
FROM payments p JOIN subscriptions s USING (subscription_id)
WHERE p.user_id <> s.user_id;

SELECT COUNT(*) AS failed_payments_without_event
FROM payments p
WHERE p.payment_status = 'failed'
  AND NOT EXISTS (
      SELECT 1 FROM events e
      WHERE e.user_id = p.user_id
        AND e.event_name = 'payment_failed'
        AND e.event_timestamp::date = p.payment_date
  );
