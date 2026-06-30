-- Users by country
-- Business question: Where is the user base concentrated?
-- Calculates user count, share, and first/last signup for each country.
SELECT
    country,
    COUNT(*) AS users,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS user_share_pct,
    MIN(signup_date) AS first_signup,
    MAX(signup_date) AS latest_signup
FROM users
GROUP BY country
ORDER BY users DESC;
