# Pricing Plan Case Study

## Problem

The product offers monthly, quarterly, and yearly subscription plans. Each plan can attract different user behavior: monthly plans may be easier to start, while longer plans may improve revenue predictability and retention.

The business problem is to compare plans by revenue, churn, retention, and LTV proxy so the team can understand which plans create durable value and when to promote them.

## SQL Used

- `sql/02_activation/06_plan_selection_after_trial.sql`
- `sql/03_revenue/05_revenue_by_plan.sql`
- `sql/04_retention_churn/01_monthly_churn_rate.sql`
- `sql/04_retention_churn/02_cohort_retention.sql`
- `sql/04_retention_churn/03_paid_user_retention.sql`
- `sql/04_retention_churn/04_cancellation_reasons.sql`
- `sql/06_ltv_segments/03_ltv_by_plan.sql`
- `sql/07_product_insights/04_plan_performance_summary.sql`
- `sql/08_advanced/02_user_lifetime_revenue_rank.sql`

## Key Findings

Use the referenced SQL to compare:

- which plans users choose after trial
- revenue contribution by plan
- retention differences across plan types
- churn patterns by plan
- cancellation reasons that may differ by plan
- LTV proxy by plan
- whether high-value users are concentrated in specific plans

Run the SQL files above to reproduce the results. The dataset supports plan-level comparison across acquisition, revenue, retention, and lifetime value logic.

## Business Interpretation

Monthly plans can reduce signup friction because the commitment is lower, but they may also be more exposed to churn. Yearly plans can improve revenue predictability and retention, but promoting them too early may create hesitation if users have not yet experienced the product value.

Quarterly plans can act as a middle option. They may be useful for users who are not ready for a yearly commitment but are more serious than a month-to-month subscriber.

Plan performance should be interpreted through several metrics at once. A plan with high revenue but high cancellation may need better expectation-setting. A plan with lower adoption but strong retention may be a good candidate for targeted promotion after activation.

## Recommended Action

- Compare plan selection after trial to understand user commitment patterns.
- Promote yearly plans to users who have already started a trial, completed activation steps, or made a successful payment.
- Use monthly plans as an accessible entry point, but monitor churn closely.
- Test quarterly plan messaging for users who show intent but hesitate on yearly commitment.
- Review cancellation reasons by plan to identify pricing, value, or expectation issues.
- Use LTV proxy and retention together before changing pricing or plan promotion strategy.

## Expected Impact

Better plan analysis should help the team improve revenue predictability, reduce churn, and promote the right plan at the right moment in the user lifecycle. The expected effect is stronger retention, higher lifetime revenue, and less pressure on acquisition to compensate for plan-level churn.
