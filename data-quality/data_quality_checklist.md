# Data-quality checklist

Use this checklist before a metric release, experiment readout, or investigation of an unexpected change. Record the query date, data window, owner, and any accepted exception.

## Users

- [ ] `user_id` is unique and non-null.
- [ ] Every acquisition channel key resolves to `acquisition_channels`.
- [ ] Signup dates fall inside the intended observation window.
- [ ] Country, device, language, and age-group values use documented categories.
- [ ] The approved test-user or internal-user registry is available and versioned.
- [ ] Test users are excluded consistently from customer metrics.

## Payments

- [ ] `payment_id` is unique and non-null.
- [ ] Every payment resolves to a valid user and subscription.
- [ ] The payment user owns the referenced subscription.
- [ ] Duplicate payment attempts have been investigated.
- [ ] Failed attempts have a failure reason; non-failed rows do not.
- [ ] Refunds match an earlier successful charge and reduce net revenue.
- [ ] Successful charges generate `payment_success` events on the same date.
- [ ] Failed attempts generate `payment_failed` events on the same date.
- [ ] Payment provider and currency values use documented categories.
- [ ] Recovery matching cannot reuse one successful payment for multiple failure episodes.

## Subscriptions

- [ ] `subscription_id` is unique and belongs to a valid user.
- [ ] Trial end is not earlier than trial start.
- [ ] Subscription start is not earlier than user signup.
- [ ] Canceled subscriptions have a cancellation date and reason.
- [ ] Cancellation does not precede subscription start.
- [ ] Active paid subscriptions have successful payment evidence.
- [ ] Successful payments fall inside a valid active or reactivated lifecycle.
- [ ] Upgrade, downgrade, cancellation, and reactivation ordering is plausible.
- [ ] Plan names and statuses use documented categories.

## Events

- [ ] `event_id` is unique and belongs to a valid user.
- [ ] Every user has exactly one signup event.
- [ ] No event occurs before registration.
- [ ] Event timestamps use a consistent timezone convention.
- [ ] Event names and sources use documented categories.
- [ ] Instrumentation coverage is stable across reporting dates and user segments.
- [ ] Duplicate client retries do not inflate event-based metrics.
- [ ] Billing events reconcile to payment and subscription records.

## Experiments

- [ ] Every randomized unit has exactly one assignment per experiment.
- [ ] Variant labels match the experiment specification.
- [ ] Allocation is close to the planned ratio; sample-ratio mismatch is investigated.
- [ ] Eligibility is evaluated before assignment.
- [ ] Assignment precedes treatment delivery and outcome events.
- [ ] Control and test groups receive equivalent instrumentation.
- [ ] The full outcome window has elapsed for every included unit.
- [ ] Known test users and conflicting experiment exposures are excluded.
- [ ] Primary, secondary, and guardrail metrics use the same assignment population unless documented otherwise.
- [ ] Refunds, cancellations, duplicate payments, and support events are handled consistently across variants.
- [ ] Segment cuts meet minimum sample requirements and are labeled exploratory when appropriate.
- [ ] Data-quality exceptions are resolved or documented before the decision meeting.

## Sign-off record

| Field | Value |
|---|---|
| Dataset or reporting window | |
| Check run timestamp | |
| Analyst | |
| Failed checks | |
| Accepted exceptions | |
| Metric impact | |
| Final status | Ready / Blocked / Ready with documented exceptions |
