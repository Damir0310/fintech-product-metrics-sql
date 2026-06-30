# Analysis summary

## Executive view

The synthetic product shows a healthy top-of-funnel trial rate, but meaningful variation appears after signup. Acquisition quality, payment reliability, and continued paid activity are more informative than signup volume alone. The strongest opportunities are to improve monetization in scaled but lower-value channels and reduce provider-specific payment friction.

## Findings

1. **Trial entry is broad.** Of 5,000 registered users, 73.26% start a trial. The generator gives referral and search traffic modestly stronger intent, so channel-level queries are more useful than the blended rate.

2. **Roughly half of trial users become paid.** Trial-to-paid conversion is 51.13%, while 37.46% of all signups make a successful payment. The difference highlights the value of separating trial activation from paid activation.

3. **Net revenue remains close to gross revenue.** Successful charges total $115,354.01. Refunds of $1,670.61 produce $113,683.40 in net collected revenue, a refund drag of about 1.45% of gross charges.

4. **Organic-intent channels lead monetization.** Referral generates $27.18 in observed net revenue per signup and Organic Search generates $26.75. These channels combine above-average paid conversion with realized customer value.

5. **Paid Ads provides scale but weaker value.** Its observed revenue per signup is $17.29, below the leading channels. This does not establish poor economics without acquisition cost data, but it identifies a segment where landing, trial, and checkout steps deserve inspection.

6. **Payment reliability varies by provider.** The blended failed-attempt rate is 7.00%. Crypto is highest at 10.18%, followed by bank transfer at 8.01%; card is lowest at 6.49% in this modeled dataset. Routing and recovery should be evaluated alongside provider mix.

7. **Monthly plans drive the largest revenue pool.** Monthly subscriptions contribute $51,143.33 of net revenue, yearly plans $37,412.47, and quarterly plans $25,127.60. Plan comparisons should combine revenue with normalization and cancellation rather than relying only on booked charge size.

8. **Paid retention differs across markets.** Kazakhstan and Georgia lead the share of paid users with successful charges in at least two distinct months, both at about 62%. Armenia is lowest at 53.69%. Later signup cohorts have shorter observation windows, so these comparisons remain descriptive.

9. **Reactivation is material but not large.** Forty of 508 users with a cancellation event later reactivate, a 7.87% rate. Cancellation reasons and payment-failure history can help identify where recovery messages may be most relevant.

## Recommended analytical next steps

- Add acquisition cost by channel and campaign before judging channel efficiency.
- Compare failure reasons within provider and country to separate mix from provider performance.
- Build complete subscription-history periods for plan changes and reactivations.
- Use equal observation windows when comparing recent and mature cohorts.
- Track dunning sequence outcomes to distinguish recovered value from permanently lost value.

All findings describe deterministic synthetic data. They are examples of interpretation, not market evidence or operational recommendations for a real financial product.
