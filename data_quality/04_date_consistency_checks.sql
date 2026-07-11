-- ============================================================
-- 04 Date Consistency Checks
-- ============================================================
-- Purpose:
-- Validate that lifecycle dates occur in a believable sequence.
-- Invalid dates can distort activation, conversion, churn,
-- retention, cohort, and payment timing analysis.
--
-- Expected use:
-- Each query returns suspicious rows that should be investigated.
-- In a clean dataset, these checks should normally return zero rows.

-- Subscriptions started before the user signed up.
SELECT
    s.subscription_id,
    s.user_id,
    u.signup_date,
    s.started_at
FROM subscriptions AS s
JOIN users AS u
    ON s.user_id = u.user_id
WHERE s.started_at < u.signup_date;

-- Cancellations dated earlier than subscription start.
SELECT
    subscription_id,
    user_id,
    started_at,
    canceled_at,
    status
FROM subscriptions
WHERE canceled_at IS NOT NULL
  AND canceled_at < started_at;

-- Trial end dated earlier than trial start.
SELECT
    subscription_id,
    user_id,
    trial_started_at,
    trial_ended_at
FROM subscriptions
WHERE trial_started_at IS NOT NULL
  AND trial_ended_at IS NOT NULL
  AND trial_ended_at < trial_started_at;

-- Payments recorded before subscription start.
SELECT
    p.payment_id,
    p.user_id,
    p.subscription_id,
    p.payment_date,
    s.started_at
FROM payments AS p
JOIN subscriptions AS s
    ON p.subscription_id = s.subscription_id
WHERE p.payment_date < s.started_at;

-- Events recorded before user signup.
SELECT
    e.event_id,
    e.user_id,
    e.event_name,
    e.event_timestamp,
    u.signup_date
FROM events AS e
JOIN users AS u
    ON e.user_id = u.user_id
WHERE e.event_timestamp::date < u.signup_date;

-- Cancellation date present when subscription status is not canceled.
SELECT
    subscription_id,
    user_id,
    status,
    started_at,
    canceled_at
FROM subscriptions
WHERE canceled_at IS NOT NULL
  AND status <> 'canceled';

-- Canceled subscription missing a cancellation date.
SELECT
    subscription_id,
    user_id,
    status,
    started_at,
    canceled_at
FROM subscriptions
WHERE status = 'canceled'
  AND canceled_at IS NULL;
