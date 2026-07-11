-- ============================================================
-- 01 Null Checks
-- ============================================================
-- Purpose:
-- Identify missing values in required business fields across the
-- product analytics model. These checks protect core metrics such
-- as signup growth, conversion, revenue, churn, retention, and
-- payment success rate.
--
-- Expected use:
-- Each query returns rows that should be reviewed. In a clean
-- dataset, these checks should normally return zero rows.

-- Users with missing required attributes.
SELECT
    user_id,
    signup_date,
    country,
    acquisition_channel_id,
    device_type,
    language,
    age_group
FROM users
WHERE user_id IS NULL
   OR signup_date IS NULL
   OR country IS NULL
   OR acquisition_channel_id IS NULL
   OR device_type IS NULL
   OR language IS NULL
   OR age_group IS NULL;

-- Subscriptions with missing required lifecycle fields.
SELECT
    subscription_id,
    user_id,
    plan_name,
    status,
    started_at,
    canceled_at,
    cancellation_reason,
    trial_started_at,
    trial_ended_at
FROM subscriptions
WHERE subscription_id IS NULL
   OR user_id IS NULL
   OR plan_name IS NULL
   OR status IS NULL
   OR started_at IS NULL;

-- Payments with missing required billing fields.
SELECT
    payment_id,
    user_id,
    subscription_id,
    payment_date,
    amount_usd,
    currency,
    payment_status,
    payment_provider,
    failure_reason
FROM payments
WHERE payment_id IS NULL
   OR user_id IS NULL
   OR subscription_id IS NULL
   OR payment_date IS NULL
   OR amount_usd IS NULL
   OR currency IS NULL
   OR payment_status IS NULL
   OR payment_provider IS NULL;

-- Events with missing required behavioral fields.
SELECT
    event_id,
    user_id,
    event_name,
    event_timestamp,
    event_source
FROM events
WHERE event_id IS NULL
   OR user_id IS NULL
   OR event_name IS NULL
   OR event_timestamp IS NULL
   OR event_source IS NULL;

-- Acquisition channels with missing required classification fields.
SELECT
    acquisition_channel_id,
    channel_name,
    channel_type,
    paid_or_organic
FROM acquisition_channels
WHERE acquisition_channel_id IS NULL
   OR channel_name IS NULL
   OR channel_type IS NULL
   OR paid_or_organic IS NULL;
