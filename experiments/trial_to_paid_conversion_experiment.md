# Trial-to-paid conversion reminder experiment

## Problem

Some users reach the end of a 14-day trial without completing a paid subscription. They may have intended to continue but did not notice the expiration date, did not understand the next billing step, or postponed the decision until the trial had already ended.

## Hypothesis

If eligible trial users receive a concise reminder 24 hours before trial expiration, then trial-to-paid conversion within seven days of trial end will increase because users have a timely opportunity to review the plan, payment method, and renewal terms.

## Target segment

- Users with an active trial and a known `trial_ended_at` value
- Assignment at least 24 hours before trial expiration
- No successful subscription payment before assignment
- One assignment per user
- Exclude known test users and users already enrolled in a conflicting onboarding message test

The randomization unit is the user. The primary observation window ends seven days after the scheduled trial end.

## Control group

Users receive the existing trial experience with no additional 24-hour reminder.

## Test group

Users receive one reminder approximately 24 hours before `trial_ended_at`. The message states the expiration time, selected plan, expected charge, and a direct route to review payment details. Delivery should respect the user's existing communication settings.

## Primary metric

**Seven-day trial-to-paid conversion rate**

- Numerator: assigned users with a successful payment after assignment and no later than seven days after `trial_ended_at`
- Denominator: all eligible assigned users whose full outcome window has elapsed
- Unit: user

Analyze by assigned group, not by whether the reminder was successfully opened.

## Secondary metrics

- Successful payment within 24 hours of the reminder
- Time from trial end to first successful payment
- Net revenue within 30 days of trial end
- Reminder delivery and open rate, when delivery data is available
- Conversion by plan, country, device, and acquisition channel as exploratory cuts

## Guardrail metrics

- Payment failure rate during the seven-day outcome window
- Refund rate within 30 days of first payment
- Cancellation within 30 days of first payment
- Support contacts within seven days of assignment
- Notification opt-out or complaint rate

## SQL analysis

Use [`sql/conversion_by_group.sql`](sql/conversion_by_group.sql) for the primary comparison and [`sql/guardrail_metrics.sql`](sql/guardrail_metrics.sql) for shared safety measures. The lab SQL creates deterministic groups because the sample schema does not contain assignment delivery data.

## Decision rules

- Roll out when the conversion lift is practically meaningful, the uncertainty interval is compatible with the pre-agreed threshold, and no guardrail shows material harm.
- Iterate when conversion improves but support contacts or payment failures suggest message or checkout friction.
- Stop when conversion does not improve meaningfully or a customer-experience guardrail deteriorates.
- Extend only when the pre-calculated sample or seven-day maturity requirement has not been reached.

## Risks and interpretation

- Users assigned too close to expiration may not receive a full 24-hour treatment.
- Payment timing can be influenced by plan and provider mix.
- Delivery failures dilute the intention-to-treat result but should not trigger reassignment.
- Recent users must be excluded until their seven-day conversion window is complete.
- Segment results are exploratory unless they were included in the original analysis plan.

## Expected business impact

A successful reminder could convert more users without changing price or trial length. Business impact should be estimated from incremental converters, their observed net revenue, message delivery cost, and any increase in refunds or support demand.

## Required Data Quality Checks Before Analysis

- [ ] One assignment per user and no user in both groups
- [ ] Assignment at least 24 hours before scheduled trial end
- [ ] No successful payment before assignment
- [ ] Full seven-day outcome window for every included user
- [ ] Successful payments belong to the assigned user and subscription
- [ ] Duplicate payments do not create duplicate converters
- [ ] Refunds are excluded from conversion and subtracted from revenue
- [ ] Trial dates are valid and occur after registration
- [ ] Control and test groups have comparable event and payment coverage
- [ ] Known test users are excluded using the same rule in both groups
