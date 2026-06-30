# SQL notes

The project uses PostgreSQL syntax and keeps each query independently runnable after the schema and data are loaded.

## Joins

Foreign-key joins connect acquisition context, subscription state, payments, and events. `LEFT JOIN` is used when non-converting or zero-revenue users must remain in the denominator; `INNER JOIN` is used when the metric explicitly requires a related record.

## Common table expressions

CTEs separate metric stages such as user-level features, cohort assignment, monthly aggregation, and final rate calculation. This makes denominator choices visible and prevents repeated logic.

## Date truncation and date arithmetic

`DATE_TRUNC('month', ...)` converts dates and timestamps into reporting months. `GENERATE_SERIES` creates a complete month spine for churn calculations. Cohort month numbers use year and month differences so activity can be aligned to lifecycle age.

## Aggregation

`COUNT(DISTINCT user_id)` prevents multiple payments or events from inflating user metrics. Revenue is aggregated with explicit status logic: success adds value, refund subtracts value, and failure contributes zero.

## Conditional aggregation

PostgreSQL's `FILTER` clause keeps related numerators and denominators readable:

```sql
COUNT(*) FILTER (WHERE payment_status = 'success')
```

`CASE` expressions are used when categories contribute different signed or normalized values.

## Window functions

The query library uses:

- `LAG` for month-over-month signup growth;
- rolling `AVG` for a seven-day signup trend;
- cumulative `SUM` for total user growth;
- `NTILE` for high-value user deciles;
- `DENSE_RANK` for acquisition-channel ranking.

## Cohort logic

Signup cohorts use first registration month and any later event as the activity definition. Paid cohorts use first successful-payment month and later successful-payment months. Month 0 represents the cohort's starting month. The later cohorts are right-censored because the dataset ends on 2025-12-31.

## Revenue calculations

Net revenue is:

```text
successful charge value - refunded value
```

Collected MRR normalizes each successful charge by its plan term: 1 for monthly, 3 for quarterly, and 12 for yearly. ARR is the resulting monthly run rate multiplied by twelve. Observed LTV sums net revenue within the dataset window and is not a forecast.

## Defensive SQL

Rates use `NULLIF(denominator, 0)` to avoid division-by-zero errors. Primary keys, foreign keys, checks, and the queries in `db/sample_checks.sql` provide complementary validation at load and analysis time.
