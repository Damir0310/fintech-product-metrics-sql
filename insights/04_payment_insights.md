# Payment Insights

## Context

These notes explain how to read payment behavior in the synthetic fintech subscription dataset. Run the SQL queries in `sql/05_payments/`, `data-quality/sql/`, `data_quality/`, and `sql/08_advanced/04_payment_recovery_window.sql` to reproduce exact values.

Payment performance matters because failed charges can reduce revenue, interrupt subscriptions, increase support load, and raise churn risk.

## Key Observations

- Payment success rate should be tracked overall and by payment provider.
- Failed payment rate can reveal operational friction that is not visible in signup or activation metrics.
- Failed payments should be analyzed together with churn because billing friction may lead to involuntary cancellation.
- Recovery rate is important because some failed payments can still become revenue if users successfully pay later.
- Refunded payments should be reviewed separately from successful payments before revenue reporting.

## Business Interpretation

Payment success is part of the product experience. If users want to pay but the payment fails, revenue loss may not reflect low product demand. It may reflect provider issues, insufficient funds, expired cards, payment method mismatch, or retry timing.

Provider-level analysis can reveal whether certain payment methods are more reliable for specific user segments. A provider with high volume but weak success rate may need additional monitoring, while a lower-volume provider with strong success and recovery performance may deserve more visibility in the checkout flow.

Recovered payments are especially useful because they represent revenue that could have been lost. A strong recovery window suggests that retry logic, reminders, or alternative payment methods can protect revenue and reduce churn.

## Recommended Next Steps

- Run payment success and failed payment queries by provider.
- Review failed payment reasons to identify preventable billing friction.
- Measure recovery rate and average days to recovery after failed payments.
- Compare churn among users with and without recent failed payments.
- Treat failed payments as a churn-risk signal in user segmentation.
- Separate refunded payments from successful revenue in MRR, ARR, and LTV analysis.
- Improve retry timing, payment reminders, and alternative payment method prompts where failure rates are high.
