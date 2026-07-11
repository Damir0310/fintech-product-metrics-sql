# Retention and Churn Insights

## Context

These notes explain how to read retention and churn patterns in the synthetic fintech subscription dataset. Run the SQL queries in `sql/04_retention_churn/`, `sql/07_product_insights/`, and `sql/08_advanced/03_churn_risk_segments.sql` to reproduce exact values.

Retention analysis connects acquisition quality, onboarding quality, plan choice, payment reliability, and user satisfaction.

## Key Observations

- Churn should be viewed by month, signup cohort, country, acquisition channel, and plan.
- Cohort retention is more useful than a single retention number because it shows how user behavior changes over time.
- Cancellation reasons can point to product, pricing, onboarding, or payment friction.
- Reactivation can partially offset churn, but it should not hide the reasons users left.
- Plan-level retention can reveal whether longer-term plans attract more committed users.

## Business Interpretation

Churn is rarely caused by one factor. In a fintech subscription product, churn can be connected to weak onboarding, unclear value, payment failures, price sensitivity, limited product usage, or poor fit between acquisition messaging and user expectations.

Cohort retention helps show whether newer users are becoming more or less durable than earlier users. If newer cohorts retain better, product or onboarding changes may be working. If newer cohorts retain worse, acquisition quality may have declined or the product may be reaching less suitable segments.

Plan-level retention should be interpreted with care. Yearly plans may show stronger retention because users are more committed upfront, but pushing yearly plans too early can create friction if users have not yet experienced value.

## Recommended Next Steps

- Run monthly churn and cohort retention queries before making channel or plan decisions.
- Compare retention by acquisition channel to identify sources of durable users.
- Review cancellation reasons by plan and country to find repeated friction points.
- Track reactivation rate separately from churn so win-back performance is visible.
- Use churn-risk segmentation to flag users with failed payments, old payment activity, prior cancellation, or repeated support contact.
- Promote longer-term plans only after users have reached meaningful activation milestones.
- Treat retention as a product-quality metric, not only a billing outcome.
