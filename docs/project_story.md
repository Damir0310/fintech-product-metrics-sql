# Project Story

This project models a fictional fintech subscription app that is expanding across several countries and acquisition channels. The product offers paid subscription plans after a trial period, and the team wants to understand how users move from signup to trial, paid subscription, renewal, cancellation, and possible reactivation.

The dataset is synthetic, but the analytical questions are designed to feel close to the work a real product, growth, or finance team might do when evaluating a subscription business.

## Business Context

The product is growing through a mix of organic and paid acquisition channels, including social platforms, referrals, search, app stores, partnerships, and paid campaigns. Users come from different countries, use different devices, and subscribe to monthly, quarterly, or yearly plans.

As growth increases, the team needs a clearer view of whether signups are turning into durable revenue. A large signup number is useful only if users activate, convert from trial to paid, renew their plans, and experience reliable payments. At the same time, failed payments, refunds, weak onboarding, or mismatched acquisition channels can distort surface-level growth metrics.

This SQL lab turns that business context into a structured analytics environment. It connects product behavior, billing outcomes, acquisition quality, retention, and revenue performance using PostgreSQL-style SQL.

## Core Business Questions

The project is built around questions such as:

- Which acquisition channels bring the most valuable users?
- Where do users drop off between signup, trial, and paid subscription?
- Which countries show stronger paid conversion and retention?
- Which subscription plans retain users better over time?
- How much revenue comes from monthly, quarterly, and yearly plans?
- How do failed payments affect churn and revenue recovery?
- Which channels produce high signup volume but weak monetization?
- Which user segments may benefit from better onboarding or payment recovery flows?
- Where are the most realistic revenue growth opportunities?
- What actions should product and growth teams consider based on the metrics?

## Product Lifecycle in the Dataset

The synthetic lifecycle follows a practical subscription flow:

1. A user signs up through an acquisition channel.
2. Some users start a trial.
3. Some trial users convert to paid subscriptions.
4. Payments may succeed, fail, or be refunded.
5. Users may cancel, expire, contact support, upgrade, downgrade, or reactivate.
6. Revenue, retention, churn, and payment health are analyzed across channels, countries, and plans.

This lifecycle allows analysts to connect user behavior with commercial outcomes instead of looking at isolated metrics.

## How Teams Could Use the Analysis

Product teams could use the SQL queries to identify onboarding drop-offs, compare plan performance, and evaluate retention by country or cohort.

Growth teams could compare acquisition channels not only by signup volume, but also by activation, paid conversion, churn, and lifetime value.

Payments or operations teams could investigate failed payment rates, recovery opportunities, refund patterns, and the relationship between billing friction and churn.

Finance or leadership teams could use revenue queries to monitor MRR, ARR, ARPU, LTV, and revenue concentration across customer segments.

## Example Business Interpretation

If one acquisition channel brings many signups but low trial-to-paid conversion, the team might review landing page expectations, onboarding messages, or targeting quality.

If yearly plans show stronger retention but lower initial adoption, the team might test clearer annual-plan value messaging during trial onboarding.

If failed payments are associated with higher churn, the team might improve payment retries, add wallet options, send reminder messages, or prioritize recovery flows before subscription cancellation.

If a country has strong retention but modest acquisition volume, the team might consider increasing localized growth efforts while monitoring payment reliability and customer support demand.

## Data Quality Matters

The project also includes data quality checks because product metrics can be misleading when the underlying data is inconsistent. Duplicate payments can inflate revenue, missing foreign keys can break funnel analysis, invalid dates can distort retention, and mismatched event data can misrepresent activation or payment performance.

For that reason, the analytics workflow should treat data validation as part of the analysis, not as a separate technical afterthought.

## Scope

This repository intentionally stays focused on:

- SQL analytics
- fintech-style subscription metrics
- synthetic data generation
- product and business interpretation
- data quality validation

It does not include dashboards, notebooks, web apps, backend services, or external business systems.
