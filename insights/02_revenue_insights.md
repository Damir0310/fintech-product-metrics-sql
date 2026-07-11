# Revenue Insights

## Context

These notes explain how to read revenue patterns in the synthetic fintech subscription dataset. Run the SQL queries in `sql/03_revenue/`, `sql/06_ltv_segments/`, and `sql/08_advanced/` to reproduce exact values.

The revenue model is based on successful subscription payments, while refunds and failed payments require separate treatment depending on the metric being calculated.

## Key Observations

- Monthly revenue, MRR, ARR, and ARPU answer related but different questions.
- Revenue by plan helps show whether monthly, quarterly, or yearly plans contribute most to monetization.
- Revenue by country can reveal markets with stronger willingness to pay or better payment completion.
- Revenue by acquisition channel helps separate signup volume from commercial quality.
- LTV-style metrics are more useful when combined with churn and retention, not viewed in isolation.

## Business Interpretation

MRR and ARR are useful directional metrics for a subscription product, but they depend heavily on consistent payment logic. If refunded payments are counted as successful revenue, or if duplicate successful payments are present, revenue metrics can be overstated.

Plan-level revenue analysis can show whether yearly plans provide stronger monetization and retention, while monthly plans may offer easier entry but higher churn risk. Quarterly plans can act as a middle ground, but their value depends on conversion and renewal patterns.

Revenue by country and channel helps identify where growth is not only active but economically meaningful. A channel with lower signup volume but higher ARPU or LTV proxy may deserve more attention than a high-volume channel with weak paid conversion.

## Recommended Next Steps

- Run monthly revenue and MRR queries before interpreting growth quality.
- Compare gross revenue, refunds, and net revenue separately.
- Use revenue by plan to understand whether plan mix is helping or limiting revenue growth.
- Compare revenue by channel with paid conversion and churn rate to identify durable acquisition sources.
- Use LTV segmentation to separate high-value users from regular and low-value users.
- Review countries with strong revenue per user for possible localized growth opportunities.
- Validate payment consistency before reporting MRR, ARR, ARPU, or LTV.
