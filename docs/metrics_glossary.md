# Metrics glossary

Metric definitions are product decisions expressed in SQL. This glossary records the definition used in this repository so results can be reproduced and challenged constructively.

## Definition summary

| Metric | Numerator | Denominator or base | Reporting grain | Main caveat |
|---|---|---|---|---|
| Trial start rate | Users with a `trial_started` event | Registered users | Overall, channel, or country | Event instrumentation must be complete |
| Trial-to-paid conversion | Trial users with a later successful payment | Users who started a trial | Overall | Recent trials may not have had time to convert |
| Net revenue | Successful charge value less refunded value | Not applicable | Payment month or segment | It is collected cash-flow logic, not accounting recognition |
| MRR | Monthly-normalized value of active paid subscriptions | Active paid subscriptions | Month-end snapshot | Uses first successful charge as the subscription value |
| ARR | MRR multiplied by 12 | Not applicable | Month-end snapshot | Run rate, not annual booked revenue |
| ARPU | Monthly net revenue | Users with a successful payment that month | Payment month | Billing cadence affects the paying-user base |
| Gross churn | Cancellations during the month | Paid subscriptions active at month start | Calendar month | Reactivation is reported separately |
| Paid retention | Cohort users active at a later month end | First-payment cohort | Cohort month | Later cohorts have shorter observation windows |
| Payment success rate | Successful attempts | Successful plus failed attempts | Payment month/provider | Refunds are excluded from attempts |
| Recovery rate | Failures followed by a matching success within seven days | Failed attempts | Overall | Matching uses subscription and amount |
| Observed LTV | Net revenue in the available window | Acquired users or paying users | User segment | Historical observation, not a forecast |

## MRR

Monthly recurring revenue is a month-end state metric. Each paid subscription active at the end of a reporting month contributes its monthly-normalized value:

- monthly plan: first successful charge divided by `1`;
- quarterly plan: first successful charge divided by `3`;
- yearly plan: first successful charge divided by `12`.

The snapshot includes modeled reactivations after the reactivation date. It does not treat the total charges collected in a month as MRR.

## ARR

Annual recurring revenue is the annualized run rate calculated as `MRR * 12`. It is not annual booked revenue, cash collected, or accounting revenue.

## ARPU

Average revenue per paid user is monthly net revenue divided by distinct users with a successful payment in that month. Refunds reduce the numerator. This is a payment-month measure, so yearly billing can make monthly ARPU volatile.

## LTV

Lifetime value is the net revenue attributable to a user during the observed dataset window. Queries report both value per acquired user and value per payer. It is an **observed LTV**, not a prediction of future cash flow, gross margin, or contribution profit.

## Churn rate

Monthly gross subscription churn is cancellations during a month divided by paid subscriptions active at the beginning of that month. A subscription must have at least one successful payment to enter the paid base. Reactivation is reported separately and does not offset the cancellation numerator.

## Retention

Retention asks whether an eligible user remains active after a defined starting point.

- Signup-cohort retention uses any recorded lifecycle event as activity.
- Paid-user retention uses active subscription state at later month ends.
- Country comparison uses active subscription state 90 days after first payment and excludes users without a complete 90-day observation window.

These definitions are intentionally separate because product activity and commercial retention answer different questions.

## Cohort analysis

Cohort analysis groups users by a shared starting period, such as signup month or first-payment month, then compares behavior at month 0, month 1, and later. Month numbers represent lifecycle age rather than calendar performance. Recent cohorts are right-censored and should not be compared with mature cohorts at unavailable ages.

## Trial-to-paid conversion

Trial-to-paid conversion is the percentage of users who started a trial and later recorded at least one successful payment. A failed attempt alone does not count. The related signup-to-paid metric uses all registered users as its denominator.

## Payment success rate

Payment success rate is successful charge attempts divided by successful plus failed attempts. Refund rows are excluded because they are outcomes of earlier successful charges, not new attempts.

## Failed payment rate

Failed payment rate is failed attempts divided by successful plus failed attempts. The attempted amount associated with failures is described as **value at risk**. It is not automatically lost revenue because some attempts recover.

## Reactivation rate

Reactivation rate is users with a reactivation event after cancellation divided by users with a cancellation event. It measures observed return behavior and does not erase the earlier gross churn event.

## Interpreting segmented metrics

Channel, country, provider, and plan comparisons are descriptive. Before acting on a difference, check sample size, observation-window maturity, acquisition mix, billing cadence, and whether the metric is user-weighted or transaction-weighted.
