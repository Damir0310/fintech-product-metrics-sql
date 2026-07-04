# Anomaly examples

These examples show how a small data defect can produce a plausible but incorrect product story.

## Duplicate payments causing a revenue spike

**Scenario:** A provider webhook is retried, and the ingestion process inserts the same successful payment twice with different `payment_id` values.

**Metric distortion:** Gross revenue, net revenue, payer LTV, and provider success counts increase even though only one charge occurred. A daily chart may suggest a campaign or pricing improvement.

**Detection:** Group payment rows by their business fields rather than primary key. Run [`sql/duplicate_payments.sql`](sql/duplicate_payments.sql).

**Response:** Confirm the provider transaction identity in the source system, repair ingestion idempotency, quantify historical overstatement, and restate affected metrics if needed.

## Refunded payments inflating MRR

**Scenario:** A revenue model includes both `success` and `refunded` rows as positive amounts.

**Metric distortion:** Net revenue and any MRR input based on payment value are overstated. Plans with higher refund rates may appear more valuable instead of less valuable.

**Detection:** Reconcile every refund to an earlier success and verify that the refund contributes a negative adjustment. Run [`sql/refunded_payments_counted_as_revenue.sql`](sql/refunded_payments_counted_as_revenue.sql).

**Response:** Use explicit signed `CASE` logic, test gross-minus-refunds reconciliation, and keep refund rate as a separate guardrail.

## Test users affecting conversion

**Scenario:** Internal test accounts repeatedly start trials and complete successful payments while validating product changes.

**Metric distortion:** Trial-to-paid conversion rises, payment success looks unusually strong, and experiment groups can become imbalanced if internal users cluster in one variant.

**Detection:** Join metric populations to a maintained test-user registry. Run [`sql/test_users_in_revenue.sql`](sql/test_users_in_revenue.sql) after connecting its registry CTE.

**Response:** Create a governed user classification, apply it consistently across metrics, and avoid ad hoc username or email-pattern filters when a registry is available.

## Failed payments not activating subscriptions

**Scenario:** Subscription status changes to `active` when a payment attempt is created rather than when it succeeds.

**Metric distortion:** Active subscribers, MRR, and paid retention increase; payment success falls; the churn denominator includes users who never paid.

**Detection:** Find active subscriptions without a successful payment. Run [`sql/active_subscription_without_successful_payment.sql`](sql/active_subscription_without_successful_payment.sql).

**Response:** Align activation state with confirmed payment outcomes or an explicitly documented grace-period rule. Backfill incorrect statuses before recomputing metrics.

## Events before registration

**Scenario:** Client device time, timezone conversion, identity merging, or a late backfill places trial or payment events before the stored signup date.

**Metric distortion:** Time-to-activation becomes negative, cohort assignment can shift, and funnel stages appear out of order.

**Detection:** Compare every event timestamp with the user's registration date. Run [`sql/events_before_registration.sql`](sql/events_before_registration.sql).

**Response:** Identify whether the source is timezone handling, identity resolution, or backfill logic. Preserve raw timestamps, correct the transformation, and rerun affected cohorts.

## Investigation principle

Do not delete suspicious rows simply because a check returns them. Confirm the source-system truth, document the decision, and make the smallest correction that restores the intended business grain.
