# Data-quality rules

Each rule maps to a read-only PostgreSQL check. Unless noted otherwise, the expected result is zero rows.

## DQ-01: Payment attempts must not be duplicated

- **Rule:** A payment attempt should appear once at its business grain: user, subscription, date, amount, currency, status, provider, and failure reason.
- **Why it matters:** Duplicate successful rows inflate revenue and payer counts; duplicate failures inflate friction and retry metrics.
- **Related SQL check:** [`sql/duplicate_payments.sql`](sql/duplicate_payments.sql)
- **Expected result:** Zero duplicate groups.
- **Business impact:** False revenue spikes can trigger incorrect growth conclusions, forecasts, or provider investigations.
- **Affected metrics:** Gross revenue, net revenue, ARPU, LTV, payment success rate, failed-payment rate, recovery rate.

## DQ-02: Every payment must reference a valid user

- **Rule:** `payments.user_id` must resolve to exactly one user record.
- **Why it matters:** Orphaned payment rows cannot be attributed to signup cohorts, countries, or acquisition channels.
- **Related SQL check:** [`sql/payments_without_users.sql`](sql/payments_without_users.sql)
- **Expected result:** Zero rows.
- **Business impact:** Revenue can disappear from segment reports while remaining in finance totals, creating unexplained reconciliation gaps.
- **Affected metrics:** Revenue by country/channel, payer conversion, ARPU, LTV, segmentation.

## DQ-03: Refunds must reduce net revenue

- **Rule:** Refunded payment rows must be treated as negative adjustments and must match an earlier successful charge for the same subscription and amount.
- **Why it matters:** Summing successful and refunded rows positively overstates collected value and can inflate recurring-revenue analysis.
- **Related SQL check:** [`sql/refunded_payments_counted_as_revenue.sql`](sql/refunded_payments_counted_as_revenue.sql)
- **Expected result:** The query returns refund rows requiring explicit negative treatment. Every returned row should reconcile to a prior success; unresolved rows are defects.
- **Business impact:** Overstated monetization can make plans or channels appear healthier than they are.
- **Affected metrics:** Net revenue, MRR inputs, ARR run rate, ARPU, observed LTV, recovered value.

## DQ-04: Active subscriptions require payment evidence

- **Rule:** An `active` subscription must have at least one successful payment on or after its paid start.
- **Why it matters:** Active status without payment evidence inflates the paid base and recurring revenue.
- **Related SQL check:** [`sql/active_subscription_without_successful_payment.sql`](sql/active_subscription_without_successful_payment.sql)
- **Expected result:** Zero rows.
- **Business impact:** The product can appear to have more paying customers and lower churn than the payment ledger supports.
- **Affected metrics:** Active paid subscriptions, MRR, ARR, churn denominator, paid retention, payer counts.

## DQ-05: Successful payments must occur inside a valid subscription lifecycle

- **Rule:** A successful charge cannot precede subscription start or occur after cancellation unless a reactivation occurred before the charge.
- **Why it matters:** A valid payment attached to an inactive lifecycle can corrupt retention, recovery, and revenue attribution.
- **Related SQL check:** [`sql/successful_payment_without_active_subscription.sql`](sql/successful_payment_without_active_subscription.sql)
- **Expected result:** Zero rows.
- **Business impact:** Customers may be charged outside the modeled service period, or the subscription state may be stale.
- **Affected metrics:** Net revenue, MRR, paid retention, churn, reactivation, recovery.

## DQ-06: Events cannot precede registration

- **Rule:** A user's event timestamp must not be earlier than `users.signup_date`.
- **Why it matters:** Pre-registration events break funnel ordering and can create negative activation durations.
- **Related SQL check:** [`sql/events_before_registration.sql`](sql/events_before_registration.sql)
- **Expected result:** Zero rows.
- **Business impact:** Onboarding and cohort analysis can assign outcomes to the wrong lifecycle stage or reporting period.
- **Affected metrics:** Signups, activation time, trial start rate, cohort retention, event funnels.

## DQ-07: Test users must not contribute to customer revenue

- **Rule:** Users in the approved test-user registry must contribute no rows to customer revenue analysis.
- **Why it matters:** Internal or automated activity often converts unusually well and may use unrealistic payment patterns.
- **Related SQL check:** [`sql/test_users_in_revenue.sql`](sql/test_users_in_revenue.sql)
- **Expected result:** Zero rows after connecting the registry CTE to the production test-user source.
- **Business impact:** A small test population can distort conversion, revenue, payment reliability, and experiment results.
- **Affected metrics:** Conversion, revenue, ARPU, LTV, payment success, experiment primary and guardrail metrics.

## Responding to a failed rule

For each failure, record:

1. first and last affected timestamps;
2. number of users, subscriptions, payments, or events affected;
3. estimated metric impact;
4. source-system owner;
5. repair or exclusion approach;
6. whether historical outputs require restatement;
7. evidence that the rule passes after remediation.
