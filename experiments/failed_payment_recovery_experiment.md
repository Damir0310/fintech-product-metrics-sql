# Three-step failed-payment recovery experiment

## Problem

A failed renewal payment can interrupt access, create avoidable cancellation, and reduce collected revenue even when the customer still intends to continue. A single generic failure message may not provide enough context or time to resolve the issue.

## Hypothesis

If users with an eligible failed payment receive a three-step recovery flow, then seven-day payment recovery will increase because each step provides timely information and a clear route to update or retry payment without creating excessive contact pressure.

## Target segment

- First failed renewal attempt for a paid subscription during the experiment period
- Subscription was active immediately before the failure
- No successful recovery before assignment
- Exclude suspected fraud, hard provider blocks, refunded charges, known test users, and users in another payment-message experiment

The randomization unit is the failed-payment episode. A user should not enter the experiment again until the current seven-day episode has closed.

## Control group

Users receive the existing payment-failure handling and retry schedule.

## Test group

The test flow contains three coordinated steps:

1. **Immediate notice:** explain that the payment did not complete, show a safe summary of the reason, and provide a payment-update route.
2. **24-hour reminder:** confirm whether action is still required and restate the service impact without urgency-heavy language.
3. **72-hour final reminder:** provide the final self-service recovery route and explain what happens if payment remains unresolved.

Messages stop immediately after a successful recovery, cancellation, or confirmed support resolution.

## Primary metric

**Seven-day recovered-payment rate**

- Numerator: eligible failed-payment episodes followed by a successful payment for the same subscription and amount within seven days
- Denominator: eligible assigned failed-payment episodes with a complete seven-day outcome window
- Unit: failed-payment episode

## Secondary metrics

- Recovery within 24 and 72 hours
- Recovered value in USD
- Time to successful recovery
- Payment-method update rate, when available
- Active subscription rate 30 days after failure
- Recovery by provider and failure reason

## Guardrail metrics

- Duplicate successful charges
- Refund rate after recovery
- Additional failed attempts per episode
- Cancellation within seven days
- Support contacts and complaint rate
- Notification opt-out rate

## SQL analysis

The episode-matching pattern in [`../sql/05_payments/04_recovered_payments.sql`](../sql/05_payments/04_recovered_payments.sql) provides the recovery foundation. Adapt the group-assignment pattern in [`sql/conversion_by_group.sql`](sql/conversion_by_group.sql) to randomize failure episodes rather than users, and use [`sql/guardrail_metrics.sql`](sql/guardrail_metrics.sql) for shared safety measures.

## Decision rules

- Roll out when seven-day recovery and recovered value improve by the pre-agreed practical threshold without material increases in duplicates, refunds, cancellations, support demand, or opt-outs.
- Iterate when recovery improves but one message step produces unnecessary contact or repeated attempts.
- Stop when the flow creates payment duplication, customer harm, or no meaningful recovery improvement.
- Extend only when the planned number of mature failed-payment episodes has not been reached.

## Risks and interpretation

- Provider and failure-reason mix can strongly affect recoverability.
- Multiple failures from the same user are correlated and should not be treated as independent without adjustment.
- Automatic retries may recover a payment without message influence; randomization separates this background recovery from treatment effect.
- A successful payment with a different amount may represent a plan change rather than recovery.
- Hard failures should not receive repeated messages when recovery is impossible without a new payment method.

## Expected business impact

A successful flow can recover recurring revenue and preserve access for customers who intended to remain subscribed. Estimate impact from incremental recovered value less message cost, additional support effort, refunds, and any increased payment-processing attempts.

## Required Data Quality Checks Before Analysis

- [ ] One assignment per failed-payment episode
- [ ] Failure occurred on a previously paid subscription
- [ ] Assignment occurred after failure and before treatment messages
- [ ] Full seven-day recovery window for all included episodes
- [ ] Recovery matches subscription, user, and amount
- [ ] Duplicate successful payments are identified before calculating recovered value
- [ ] Refunds after recovery are tracked as a guardrail
- [ ] Cancellations and reactivations are chronologically valid
- [ ] Provider and failure reason are populated for failed attempts
- [ ] Known test users and operational test payments are excluded
