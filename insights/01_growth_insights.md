# Growth Insights

## Context

These notes show how to interpret growth patterns in the synthetic fintech subscription dataset. Run the SQL queries in `sql/01_user_growth/`, `sql/02_activation/`, and `sql/07_product_insights/` to reproduce exact values.

The dataset is designed to analyze how users enter the product, which countries and acquisition channels drive signups, and whether those users later show signs of quality through trial starts, paid conversion, revenue, and retention.

## Key Observations

- Signup volume should be evaluated together with activation and paid conversion, not as a standalone success metric.
- Channels with strong top-of-funnel growth may still underperform if users do not start trials or convert to paid subscriptions.
- Organic and referral-style channels often behave differently from paid channels because user intent may be higher.
- Country-level signup differences can reflect differences in product-market fit, payment preferences, language fit, or channel mix.
- App Store, Organic Search, Referral, and Partner channels are useful to compare because they may represent different levels of purchase intent.

## Business Interpretation

High signup volume is a weak signal if it is not supported by downstream behavior. A channel that produces many registrations but weak trial-to-paid conversion may be attracting curious users rather than users with a clear need for the product.

By contrast, a smaller channel can be strategically important if users from that channel start trials, convert to paid plans, retain longer, and generate higher lifetime revenue. This is especially important for fintech subscription products, where trust, onboarding clarity, and payment reliability can matter as much as acquisition volume.

Country-level analysis should also be interpreted carefully. A country with moderate signup volume but strong retention may deserve more attention than a country with high signups and weak monetization. The best growth opportunities are usually found where acquisition quality, activation, payment success, and retention work together.

## Recommended Next Steps

- Run daily and monthly signup queries to identify growth spikes and seasonality.
- Compare acquisition channels by signup volume, trial start rate, paid conversion rate, revenue, and churn.
- Review countries with high signup volume but weak paid conversion to identify localization or onboarding gaps.
- Treat channel quality as a funnel question, not just an acquisition question.
- Use `sql/07_product_insights/01_best_acquisition_channels.sql` and `sql/08_advanced/05_channel_payback_proxy.sql` to compare channel quality beyond raw user counts.
- Investigate whether paid channels are producing durable subscription users or only short-term registration volume.
