# Churn Reduction Case Study

## Problem

Churn reduces revenue durability and makes growth more expensive. If new users continue to arrive but existing subscribers cancel quickly, the product may appear to grow while the paid base remains unstable.

The business problem is to identify where churn is concentrated by month, plan, channel, and cancellation reason, then recommend practical retention actions.

## SQL Used

- `sql/04_retention_churn/01_monthly_churn_rate.sql`
- `sql/04_retention_churn/02_cohort_retention.sql`
- `sql/04_retention_churn/03_paid_user_retention.sql`
- `sql/04_retention_churn/04_cancellation_reasons.sql`
- `sql/04_retention_churn/05_reactivation_rate.sql`
- `sql/07_product_insights/02_channels_with_high_churn.sql`
- `sql/07_product_insights/03_countries_with_best_retention.sql`
- `sql/08_advanced/03_churn_risk_segments.sql`
- `sql/08_advanced/06_month_over_month_growth.sql`

## Key Findings

Use the referenced SQL to inspect:

- monthly churn trends
- retention patterns by signup cohort
- paid user retention over time
- common cancellation reasons
- channels associated with higher churn
- countries with stronger retention
- users who show churn-risk signals
- whether reactivation offsets part of the cancellation problem

Run the SQL files above to reproduce the numbers. The dataset supports both high-level churn measurement and user-level risk segmentation.

## Business Interpretation

Churn should not be treated as a single number. A rising monthly churn rate may have different causes depending on plan mix, acquisition source, payment reliability, onboarding quality, and user expectations.

Cohort retention helps show whether newer users are becoming more durable or less durable than earlier cohorts. If newer cohorts decline faster, the team may need to review acquisition targeting or onboarding. If certain channels consistently have high churn, growth volume from those channels may be less valuable than it first appears.

Cancellation reasons provide qualitative context for the numbers. For example, price-related cancellation may call for packaging or plan education, while product-value cancellation may point to onboarding and feature adoption issues.

## Recommended Action

- Review churn by month to identify unusual spikes.
- Compare retention by cohort before making broad conclusions.
- Segment churn by acquisition channel, country, and plan.
- Investigate the most common cancellation reasons and link them to product actions.
- Create win-back campaigns for recently canceled users with prior successful payments.
- Use churn-risk segmentation to prioritize proactive retention outreach.
- Monitor failed payments and support contacts as churn-risk signals.

## Expected Impact

A structured churn reduction workflow should improve paid user retention, increase lifetime revenue, and reduce the pressure to replace canceled users with new acquisition. It should also help teams separate product-value problems from payment or onboarding friction.
