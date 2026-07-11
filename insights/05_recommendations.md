# Recommendations

## Context

These recommendations are based on the synthetic dataset design and the SQL logic in the repository. Exact prioritization should be based on reproduced query outputs, especially channel conversion, churn, LTV proxy, payment recovery, and cohort retention results.

The goal is to turn SQL analysis into practical product, growth, payment, and retention actions.

## Key Observations

- Strong acquisition channels should be evaluated by paid conversion and retention, not only by signup volume.
- Weak trial-to-paid conversion often points to onboarding, expectation-setting, or targeting issues.
- Failed payments can act as an early warning signal for churn.
- Yearly plans can improve retention, but only when promoted to users who already understand the product value.
- Recently canceled users may still be recoverable if the cancellation reason is addressable.
- LTV and churn-risk segmentation can help teams prioritize outreach and product improvements.

## Business Interpretation

The most useful actions come from combining metrics. A channel with high signups, low conversion, high churn, and low revenue per user should be treated differently from a channel with fewer signups but strong paid conversion and retention.

Similarly, payment problems should not be treated only as finance issues. They affect user experience, subscription continuity, support demand, revenue recognition, and churn.

Retention work should focus on moments where intervention is realistic: before trial expiration, after failed payments, shortly after cancellation, and after users show signs of value but before they disengage.

## Recommended Next Steps

### Improve onboarding for channels with weak trial-to-paid conversion

Identify acquisition channels with high signup volume but low trial start or paid conversion. Review landing page promises, onboarding messages, first-session product education, and trial reminder timing.

### Reduce spend on low-quality paid channels

Use channel-level conversion, revenue, churn, and LTV proxy queries to identify paid channels that produce weak downstream outcomes. Reduce or pause spend where users register but do not convert or retain.

### Improve payment retry flows

Analyze failed payment reasons and recovery windows. Add clearer retry messages, better timing, and prompts for alternative payment providers where failed payments are common.

### Create win-back campaigns for recently canceled users

Segment canceled users by cancellation reason, plan, country, channel, and previous revenue. Prioritize users with prior successful payments or strong product engagement because they may be more likely to reactivate.

### Promote yearly plans only to activated users

Avoid pushing yearly plans too early in the lifecycle. Offer yearly plan messaging after users start a trial, complete meaningful product actions, or make a successful payment.

### Monitor failed payments as a churn-risk signal

Include failed payment count, recent failed payments, days since last successful payment, and support contact history in churn-risk segmentation.

### Segment users by LTV and retention risk

Use lifetime revenue and churn-risk segments together. High-LTV users with rising risk may deserve proactive retention support, while low-LTV users may need better onboarding or clearer product value.

### Review country-level product fit

Compare countries by paid conversion, payment success rate, retention, and revenue per user. Strong retention with modest acquisition volume may indicate a market worth deeper investigation.

### Keep data quality checks in the analytics workflow

Run data quality checks before reporting revenue, churn, LTV, retention, or payment success rate. Duplicate payments, invalid dates, missing foreign keys, and mismatched payment events can materially distort decisions.
