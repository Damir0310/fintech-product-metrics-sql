# Channel Efficiency Case Study

## Problem

The product is acquiring users through several channels, but signup volume alone does not show whether a channel is efficient. A channel can bring many users while still producing weak trial starts, low paid conversion, high churn, or low lifetime revenue.

The business problem is to identify which acquisition channels bring users who are not only numerous, but also likely to convert, pay, retain, and generate durable revenue.

## SQL Used

- `sql/01_user_growth/04_users_by_channel.sql`
- `sql/02_activation/03_activation_by_channel.sql`
- `sql/03_revenue/06_revenue_by_channel.sql`
- `sql/04_retention_churn/01_monthly_churn_rate.sql`
- `sql/06_ltv_segments/01_ltv_by_channel.sql`
- `sql/07_product_insights/01_best_acquisition_channels.sql`
- `sql/07_product_insights/02_channels_with_high_churn.sql`
- `sql/07_product_insights/06_paid_vs_organic.sql`
- `sql/08_advanced/05_channel_payback_proxy.sql`

## Key Findings

Use the referenced SQL to compare:

- which channels generate the most signups
- which channels convert users from signup to trial and paid subscription
- which channels produce the most revenue
- which channels have weaker retention or higher churn
- which channels have stronger average revenue per user and LTV proxy
- whether paid and organic channels differ in downstream user quality

Run the SQL files above to reproduce the numbers. The synthetic dataset intentionally separates channel volume from channel quality, so both views matter.

## Business Interpretation

A high-volume channel is not automatically a high-quality channel. If a channel produces many signups but weak paid conversion, it may be attracting users with low purchase intent or users whose expectations do not match the product experience.

A smaller channel may be more valuable if users from that source convert at a higher rate, retain longer, and produce higher revenue per user. For product and growth teams, the goal is not simply to maximize traffic. The goal is to increase the number of users who understand the product value and continue paying.

For finance-oriented analysis, the channel payback proxy is useful but limited. The dataset does not include exact marketing spend, so it cannot calculate true acquisition cost or payback period. It can still help compare channel quality using conversion, revenue, churn, and LTV-style signals.

## Recommended Action

- Compare channels by signup volume, paid conversion, revenue, churn, and LTV proxy in one review.
- Improve onboarding for channels with high signups but weak trial-to-paid conversion.
- Reduce or pause spend on paid channels with weak conversion, low revenue per user, or high churn.
- Study the messaging and user intent behind channels with strong retention and revenue.
- Use organic, referral, and partner channels as benchmarks for quality, not only volume.
- Review country and device mix within each channel before making budget decisions.

## Expected Impact

Better channel efficiency analysis should help the team move resources toward acquisition sources that produce durable subscription revenue. The expected business effect is stronger paid conversion, lower waste in paid acquisition, better retention, and improved revenue quality.
