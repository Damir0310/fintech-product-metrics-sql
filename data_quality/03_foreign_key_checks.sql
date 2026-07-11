-- ============================================================
-- 03 Foreign Key Consistency Checks
-- ============================================================
-- Purpose:
-- Identify records that cannot be linked to their parent entity.
-- Broken relationships can distort funnel metrics, revenue
-- attribution, cohort analysis, and channel performance.
--
-- Expected use:
-- Each query returns suspicious rows that should be investigated.
-- In a clean dataset, these checks should normally return zero rows.

-- Subscriptions without matching users.
SELECT
    s.subscription_id,
    s.user_id,
    s.plan_name,
    s.status,
    s.started_at
FROM subscriptions AS s
LEFT JOIN users AS u
    ON s.user_id = u.user_id
WHERE u.user_id IS NULL;

-- Payments without matching users.
SELECT
    p.payment_id,
    p.user_id,
    p.subscription_id,
    p.payment_date,
    p.payment_status
FROM payments AS p
LEFT JOIN users AS u
    ON p.user_id = u.user_id
WHERE u.user_id IS NULL;

-- Payments without matching subscriptions.
SELECT
    p.payment_id,
    p.user_id,
    p.subscription_id,
    p.payment_date,
    p.payment_status
FROM payments AS p
LEFT JOIN subscriptions AS s
    ON p.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL;

-- Events without matching users.
SELECT
    e.event_id,
    e.user_id,
    e.event_name,
    e.event_timestamp
FROM events AS e
LEFT JOIN users AS u
    ON e.user_id = u.user_id
WHERE u.user_id IS NULL;

-- Users assigned to acquisition channels that do not exist.
SELECT
    u.user_id,
    u.signup_date,
    u.acquisition_channel_id
FROM users AS u
LEFT JOIN acquisition_channels AS ac
    ON u.acquisition_channel_id = ac.acquisition_channel_id
WHERE ac.acquisition_channel_id IS NULL;
