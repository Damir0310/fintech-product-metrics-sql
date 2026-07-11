# Failed Payments Case Study

## Problem

Failed payments can create revenue loss even when users still want to use the product. In a subscription business, payment failure is not only a billing issue. It can interrupt access, increase support contact, reduce trust, and raise churn risk.

The business problem is to understand how failed payments affect revenue recovery and whether users with failed payments are more likely to cancel.

## SQL Used

- `sql/05_payments/01_payment_success_rate.sql`
- `sql/05_payments/02_failed_payment_rate.sql`
- `sql/05_payments/03_failed_payments_by_provider.sql`
- `sql/05_payments/04_recovered_payments.sql`
- `sql/05_payments/05_payment_failures_impact_on_churn.sql`
- `sql/08_advanced/04_payment_recovery_window.sql`
- `data_quality/05_payment_consistency_checks.sql`

## Key Findings

Use the referenced SQL to measure:

- the overall payment success rate
- failed payment rate by payment provider
- common failure patterns that may require investigation
- how often failed payments are recovered by later successful payments
- average days to recovery after a failed payment
- recovered revenue from users who later paid successfully
- whether failed payments are associated with higher churn risk

Run the SQL files above to reproduce the results. The dataset includes enough payment lifecycle detail to connect failed charges with recovery, revenue, and churn risk.

## Business Interpretation

Failed payments should be interpreted as a recoverable risk, not only as lost revenue. A failed charge may be caused by insufficient funds, expired card details, provider friction, or timing issues. If the user later completes a successful payment, the business can recover revenue that would otherwise be lost.

Provider-level analysis is important because different payment methods can have different success and recovery patterns. A provider with high failure rates may need better error handling, clearer messaging, or alternative payment prompts.

Failed payments can also act as an early churn signal. If users experience repeated payment failures and do not recover quickly, they may cancel, expire, or disengage.

## Recommended Action

- Monitor failed payment rate and recovery rate by provider.
- Add a structured retry flow after failed payments.
- Send clear payment reminders before access interruption.
- Offer alternative payment methods when a payment fails.
- Track users with repeated failed payments as a churn-risk segment.
- Review refunded payments separately before calculating revenue metrics.
- Use data quality checks to confirm payment events match payment records.

## Expected Impact

A stronger payment recovery process should increase recovered revenue, reduce involuntary churn, improve subscription continuity, and make revenue metrics more reliable. The product team should also gain a clearer view of whether churn is caused by product dissatisfaction or payment friction.
