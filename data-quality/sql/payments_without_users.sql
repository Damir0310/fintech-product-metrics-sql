-- Data-quality check: payments without valid users
-- Returns payment rows whose user_id does not resolve to the users table.
-- Expected result: zero rows. The foreign key should prevent this after schema enforcement.

SELECT
    p.payment_id,
    p.user_id,
    p.subscription_id,
    p.payment_date,
    p.amount_usd,
    p.payment_status,
    p.payment_provider
FROM payments p
LEFT JOIN users u USING (user_id)
WHERE u.user_id IS NULL
ORDER BY p.payment_date, p.payment_id;
