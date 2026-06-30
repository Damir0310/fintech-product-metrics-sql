-- Users by acquisition channel
-- Business question: Which channels contribute the most registered users?
-- Calculates users and mix share by channel and acquisition type.
SELECT
    c.channel_name,
    c.channel_type,
    c.paid_or_organic,
    COUNT(*) AS users,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS user_share_pct
FROM users u
JOIN acquisition_channels c USING (acquisition_channel_id)
GROUP BY c.channel_name, c.channel_type, c.paid_or_organic
ORDER BY users DESC;
