# Metrics glossary

Each metric is defined as used in this project. Different products may choose different eligibility rules, time windows, or accounting treatments.

## MRR

Monthly recurring revenue is the monthly-normalized value of successful recurring charges. Monthly charges retain their full value; quarterly charges are divided by three; yearly charges are divided by twelve. This repository calls the result **collected MRR** because it is based on payments rather than a contractual subscription schedule.

## ARR

Annual recurring revenue is the annualized run rate calculated as `MRR × 12`. It is not the same as annual booked or recognized revenue.

## ARPU

Average revenue per paid user is monthly net revenue divided by distinct users with a successful payment in that month. Refunds reduce the numerator.

## LTV

Lifetime value is the net revenue attributable to a user during the observed dataset window. Queries report this by channel, country, and plan. It is an **observed LTV**, not a prediction of future cash flows or margin.

## Churn rate

Monthly gross subscription churn is cancellations during a month divided by paid subscriptions active at the beginning of that month. Reactivation is reported separately and does not offset gross churn.

## Retention

Retention measures whether an eligible user remains active in a later period. The project uses both event-based product retention and successful-payment-based paid retention; every query states its activity definition.

## Cohort analysis

Cohort analysis groups users by a shared starting period, such as signup month or first-payment month, then compares behavior at month 0, month 1, and later. This separates lifecycle effects from calendar growth.

## Trial-to-paid conversion

The percentage of users who started a trial and later recorded at least one successful payment. A failed attempt alone does not count as conversion.

## Payment success rate

Successful charge attempts divided by successful plus failed attempts. Refund rows are excluded because they are outcomes after a charge rather than new attempts.

## Failed payment rate

Failed charge attempts divided by successful plus failed attempts. The associated attempted amount is described as value at risk, not automatically lost revenue.

## Reactivation rate

The percentage of users with a cancellation event who later recorded a reactivation event. The reactivation timestamp must be after cancellation.
