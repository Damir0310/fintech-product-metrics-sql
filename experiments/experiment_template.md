# Experiment template

Use this template before implementation begins. Replace bracketed prompts with test-specific decisions and keep the final document with the analysis record.

## Problem

[Describe the observed customer or business problem. Include baseline evidence, affected journey stage, and why the problem matters now.]

## Hypothesis

If [target users] receive [treatment], then [primary outcome] will [expected direction] because [behavioral or operational mechanism].

## Target segment

- Eligibility rules: [Rules evaluated before assignment]
- Exclusions: [Existing subscribers, unsupported markets, known test users, recent exposure, or other conflicts]
- Unit of randomization: [User, account, subscription, or payment episode]
- Observation window: [Start, end, and maturity requirement]

## Control group

[Describe the current experience. State whether users receive no message, the existing flow, or a neutral treatment.]

## Test group

[Describe exactly what changes, when it happens, delivery channels, and fallback behavior.]

## Primary metric

- Name: [One decision metric]
- Unit of analysis: [One row per randomized unit]
- Numerator: [Outcome definition]
- Denominator: [Eligible assigned population]
- Attribution window: [Time after assignment]

## Secondary metrics

- [Metric that explains the mechanism]
- [Metric that captures downstream value]
- [Operational or segment-level diagnostic]

## Guardrail metrics

- Payment failure or duplicate-attempt rate
- Refund rate or refunded value
- Cancellation or complaint rate
- Support-contact rate
- Delivery failure, latency, or notification opt-out rate

## SQL queries

- Assignment and conversion: [`sql/conversion_by_group.sql`](sql/conversion_by_group.sql)
- Shared guardrails: [`sql/guardrail_metrics.sql`](sql/guardrail_metrics.sql)
- Additional query: [Path and purpose]

## Decision rules

- Roll out when: [Minimum effect, uncertainty threshold, and guardrail conditions]
- Iterate when: [Promising result with a clear correctable weakness]
- Stop when: [No practical improvement, harmful guardrail, or invalid mechanism]
- Extend when: [Predefined sample or observation requirement has not been met]

Set these rules before reading the result. Include the minimum practically important effect, not only a statistical threshold.

## Risks

- Sample-ratio mismatch or assignment leakage
- Incomplete treatment delivery
- Contamination between variants
- Novelty or seasonality effects
- Multiple testing across many segments
- Right-censoring for recently assigned units
- Metric movement caused by instrumentation changes

## Expected business impact

[Describe how a successful result would affect customer experience, retained revenue, operational effort, or decision quality. Separate measured impact from assumptions used for annualization.]

## Required Data Quality Checks Before Analysis

- [ ] Each randomized unit has exactly one assignment for this experiment.
- [ ] Assignment happened after eligibility and before treatment exposure.
- [ ] Outcome events occurred after assignment.
- [ ] User, subscription, payment, and event keys are valid.
- [ ] Refunds are subtracted rather than counted as positive revenue.
- [ ] Known test users and internal traffic are excluded consistently.
- [ ] Control and test instrumentation has equivalent coverage.
- [ ] The analysis window is complete for every included unit.
- [ ] Duplicate attempts or events cannot inflate user-level metrics.

Record exceptions, affected rows, and the decision to repair, exclude, or continue before calculating the treatment effect.
