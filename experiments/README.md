# Product experiments

This section connects product problems to testable hypotheses, measurable outcomes, SQL analysis, and explicit decisions. The examples use fintech-style subscription journeys, but the workflow also applies to SaaS and other digital products.

## Why experiments belong beside metric SQL

A metric describes what happened. An experiment estimates whether a controlled product change caused a different outcome. Useful experiment analysis therefore needs more than a conversion-rate query:

1. Start with a specific business problem.
2. State a falsifiable hypothesis and the mechanism behind it.
3. Define eligibility before assignment.
4. Record control and test assignment consistently.
5. Choose one primary metric and a small set of supporting metrics.
6. Protect customer and business health with guardrails.
7. Validate data before reading treatment effects.
8. Apply a pre-agreed decision rule rather than choosing one after seeing results.

## Files

- [Experiment template](experiment_template.md) provides a reusable planning and analysis structure.
- [Trial-to-paid conversion experiment](trial_to_paid_conversion_experiment.md) tests a reminder 24 hours before trial expiration.
- [Failed-payment recovery experiment](failed_payment_recovery_experiment.md) tests a three-step recovery flow.
- [`sql/conversion_by_group.sql`](sql/conversion_by_group.sql) compares trial conversion between deterministic lab groups.
- [`sql/guardrail_metrics.sql`](sql/guardrail_metrics.sql) compares payment, refund, cancellation, and support guardrails.

## Experiment data contract

In production, assignment should be written once to an immutable table before treatment exposure. A minimal contract is:

| Column | Purpose |
|---|---|
| `experiment_name` | Stable experiment identifier |
| `user_id` | Assigned user |
| `variant` | `control` or named treatment |
| `assigned_at` | Timestamp used to enforce outcome ordering |
| `eligibility_version` | Version of targeting rules |

The lab dataset has no assignment table. The included SQL uses a deterministic hash of `user_id` to create reproducible analysis groups and labels that CTE clearly. This is useful for learning query structure, but it does not create a real treatment effect. Replace the lab assignment CTE with the production assignment table when applying the pattern elsewhere.

## Recommended analysis sequence

1. Confirm assignment counts and allocation balance.
2. Run the required data-quality checks listed in the experiment plan.
3. Verify that assignment occurs before treatment and outcome events.
4. Calculate the primary metric at one row per assigned user or failed-payment episode.
5. Review secondary and guardrail metrics using the same eligible population.
6. Segment only after reading the overall result, and treat small segments cautiously.
7. Document the decision, uncertainty, limitations, and follow-up action.

## Interpretation principles

- Analyze users in their assigned group, even when treatment delivery fails, unless the plan explicitly defines another estimand.
- Avoid repeatedly checking significance and stopping as soon as a preferred result appears.
- Do not replace a primary metric after observing the results.
- Report effect size and uncertainty, not only whether a threshold was crossed.
- Guardrails can block rollout even when the primary metric improves.
- An inconclusive result is information: it may imply insufficient sample, a weak mechanism, or excessive measurement noise.

## Required Data Quality Checks Before Analysis

At minimum, verify unique assignment, eligible users, assignment before outcomes, stable event coverage, valid payment ownership, refund handling, and exclusion of known test users. The reusable checklist is in [data-quality/data_quality_checklist.md](../data-quality/data_quality_checklist.md).
