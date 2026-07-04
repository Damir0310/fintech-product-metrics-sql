-- Data-quality check: active subscriptions without successful payment evidence
-- Returns active subscriptions that have never recorded a successful charge.
-- Expected result: zero rows unless the product has a documented free or grace-period state.

SELECT
    s.subscription_id,
    s.user_id,
    s.plan_name,
    s.status,
    s.started_at,
    s.trial_started_at,
    s.trial_ended_at
FROM subscriptions s
WHERE s.status = 'active'
  AND NOT EXISTS (
      SELECT 1
      FROM payments p
      WHERE p.subscription_id = s.subscription_id
        AND p.user_id = s.user_id
        AND p.payment_status = 'success'
        AND p.payment_date >= s.started_at
  )
ORDER BY s.started_at, s.subscription_id;
