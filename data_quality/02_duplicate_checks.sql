-- ============================================================
-- 02 Duplicate ID Checks
-- ============================================================
-- Purpose:
-- Detect duplicate primary identifiers. Duplicate IDs can cause
-- overcounting, broken joins, inflated revenue, and incorrect
-- lifecycle analysis.
--
-- Expected use:
-- Each query returns duplicated identifiers and the number of
-- rows sharing that identifier. In a clean dataset, these checks
-- should normally return zero rows.

-- Duplicate user IDs.
SELECT
    user_id,
    COUNT(*) AS row_count
FROM users
GROUP BY user_id
HAVING COUNT(*) > 1;

-- Duplicate subscription IDs.
SELECT
    subscription_id,
    COUNT(*) AS row_count
FROM subscriptions
GROUP BY subscription_id
HAVING COUNT(*) > 1;

-- Duplicate payment IDs.
SELECT
    payment_id,
    COUNT(*) AS row_count
FROM payments
GROUP BY payment_id
HAVING COUNT(*) > 1;

-- Duplicate event IDs.
SELECT
    event_id,
    COUNT(*) AS row_count
FROM events
GROUP BY event_id
HAVING COUNT(*) > 1;

-- Duplicate acquisition channel IDs.
SELECT
    acquisition_channel_id,
    COUNT(*) AS row_count
FROM acquisition_channels
GROUP BY acquisition_channel_id
HAVING COUNT(*) > 1;
