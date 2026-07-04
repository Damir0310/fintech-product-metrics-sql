-- Data-quality check: successful payments outside a valid subscription lifecycle
-- Returns successes before subscription start or after cancellation without an earlier reactivation.
-- Expected result: zero rows. Review lifecycle timing and payment ownership for every result.

WITH reactivations AS (
    SELECT
        user_id,
        MIN(event_timestamp)::date AS first_reactivated_at
    FROM events
    WHERE event_name = 'reactivated'
    GROUP BY user_id
)
SELECT
    p.payment_id,
    p.user_id,
    p.subscription_id,
    p.payment_date,
    p.amount_usd,
    s.started_at,
    s.canceled_at,
    r.first_reactivated_at,
    CASE
        WHEN p.payment_date < s.started_at THEN 'payment_before_subscription_start'
        WHEN p.payment_date > s.canceled_at
             AND (r.first_reactivated_at IS NULL OR r.first_reactivated_at > p.payment_date)
            THEN 'payment_after_cancellation_without_reactivation'
    END AS investigation_reason
FROM payments p
JOIN subscriptions s
    ON s.subscription_id = p.subscription_id
   AND s.user_id = p.user_id
LEFT JOIN reactivations r USING (user_id)
WHERE p.payment_status = 'success'
  AND (
      p.payment_date < s.started_at
      OR (
          s.canceled_at IS NOT NULL
          AND p.payment_date > s.canceled_at
          AND (r.first_reactivated_at IS NULL OR r.first_reactivated_at > p.payment_date)
      )
  )
ORDER BY p.payment_date, p.payment_id;
