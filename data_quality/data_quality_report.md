# Data Quality Report

Product analytics depends on trust in the underlying data. If user, subscription, payment, event, or acquisition records are incomplete or inconsistent, the resulting metrics can look precise while still being misleading.

This report explains the purpose of the data quality checks in the `data_quality/` folder and how they protect common fintech subscription metrics.

## Why Data Quality Matters

Subscription analytics connects multiple parts of the product lifecycle:

- Users sign up through acquisition channels.
- Some users start trials.
- Some trials convert into paid subscriptions.
- Payments succeed, fail, or are refunded.
- Subscriptions may remain active, expire, cancel, or reactivate.
- Events describe user and billing behavior over time.

When these records do not line up, business interpretation becomes risky. For example, duplicate payments can create a false revenue spike, invalid cancellation dates can inflate churn, and missing payment failure reasons can hide operational problems.

The goal of these checks is not only technical correctness. The goal is to protect business decisions from being based on distorted metrics.

## Included Checks

### 1. Null Checks

File: `01_null_checks.sql`

These checks identify missing values in important fields across:

- `users`
- `subscriptions`
- `payments`
- `events`
- `acquisition_channels`

They protect against incomplete records that can break joins, segment users incorrectly, or remove rows from aggregations.

### 2. Duplicate Checks

File: `02_duplicate_checks.sql`

These checks look for duplicate IDs in:

- `user_id`
- `subscription_id`
- `payment_id`
- `event_id`
- `acquisition_channel_id`

Duplicate identifiers can inflate counts, double-count revenue, and make lifecycle analysis unreliable.

### 3. Foreign Key Checks

File: `03_foreign_key_checks.sql`

These checks identify records that cannot be connected to their parent entity, such as:

- subscriptions without users
- payments without users
- payments without subscriptions
- events without users
- users assigned to missing acquisition channels

These issues can distort funnel analysis, channel attribution, and revenue reporting.

### 4. Date Consistency Checks

File: `04_date_consistency_checks.sql`

These checks confirm that lifecycle dates follow a reasonable order:

- subscriptions should not start before signup
- cancellations should not occur before subscription start
- trial end dates should not precede trial start dates
- payments should not occur before subscription start
- events should not occur before signup
- cancellation dates and canceled status should agree

Invalid dates can distort conversion timing, retention curves, churn rates, and cohort analysis.

### 5. Payment Consistency Checks

File: `05_payment_consistency_checks.sql`

These checks validate billing logic and payment-related events:

- successful payments should have positive amounts
- failed payments should include a failure reason
- payments should include a provider
- refunded payments should be reviewed before revenue reporting
- payment success events should match successful payment records
- payment failed events should match failed payment records

These checks protect revenue, MRR, ARR, LTV, payment success rate, and failed payment analysis.

## How Bad Data Can Distort Metrics

### MRR and ARR

MRR and ARR can be overstated if duplicate successful payments are counted, refunded payments are treated as active revenue, or payments are joined incorrectly to subscriptions.

### Churn

Churn can be overstated if cancellation dates are attached to non-canceled subscriptions. It can be understated if canceled subscriptions are missing `canceled_at` values.

### LTV

LTV can be inflated by duplicate payments, refunded payments counted as revenue, or users incorrectly attributed to high-performing acquisition channels.

### Retention

Retention can be distorted by events before signup, subscriptions before registration, or inconsistent user lifecycle dates.

### Payment Success Rate

Payment success rate can be misleading if payment events do not match payment records, failed payments are missing failure reasons, or payment providers are missing.

## How to Run the Checks

After creating the PostgreSQL tables and loading the CSV files, run each SQL file from the project root or from a SQL client connected to the database.

Example using `psql`:

```bash
psql -d fintech_metrics -f data_quality/01_null_checks.sql
psql -d fintech_metrics -f data_quality/02_duplicate_checks.sql
psql -d fintech_metrics -f data_quality/03_foreign_key_checks.sql
psql -d fintech_metrics -f data_quality/04_date_consistency_checks.sql
psql -d fintech_metrics -f data_quality/05_payment_consistency_checks.sql
```

Most checks are designed to return suspicious rows only. If a query returns rows, the analyst should review whether the records are valid exceptions, data generation issues, or logic problems that should be corrected before reporting metrics.

## Recommended Workflow

1. Load the schema and sample data.
2. Run the data quality checks.
3. Investigate any returned rows.
4. Decide whether to exclude, correct, or document suspicious records.
5. Run metric queries only after the core checks are understood.

This workflow keeps the project practical: metrics are easier to trust when the assumptions behind them are visible.
