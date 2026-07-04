# Data quality for product metrics

Product metrics can be numerically correct and still be misleading when the underlying rows are duplicated, orphaned, mistimed, or classified incorrectly. A revenue query cannot repair a duplicated successful payment. A conversion query cannot distinguish customer behavior from internal test traffic unless test identities are available. A retention query cannot be trusted when lifecycle dates contradict one another.

This section turns common product-data risks into small, non-destructive PostgreSQL checks. Each SQL file returns suspicious rows for investigation. For most checks, the expected result is zero rows.

## Files

- [Data-quality rules](data_quality_rules.md) documents the rule, reason, expected result, business impact, and affected metrics.
- [Data-quality checklist](data_quality_checklist.md) provides a review sequence by data domain.
- [Anomaly examples](anomaly_examples.md) shows how plausible data defects distort business interpretation.
- [`sql/`](sql/) contains seven read-only diagnostic queries.

## How to run the checks

After loading the PostgreSQL database, run individual checks from the repository root:

```bash
psql -d fintech_metrics -f data-quality/sql/duplicate_payments.sql
psql -d fintech_metrics -f data-quality/sql/payments_without_users.sql
psql -d fintech_metrics -f data-quality/sql/events_before_registration.sql
```

Run all checks in PowerShell:

```powershell
Get-ChildItem data-quality/sql/*.sql | Sort-Object Name | ForEach-Object {
    psql -d fintech_metrics -f $_.FullName
}
```

Run all checks in a POSIX shell:

```bash
for check in data-quality/sql/*.sql; do
  psql -d fintech_metrics -f "$check"
done
```

## How to read results

- **Zero rows:** the tested condition was not found.
- **One or more rows:** investigate before publishing or acting on affected metrics.
- **Known exception:** document the owner, reason, affected period, and whether the metric excludes or repairs the row.

A returned row is evidence of a condition worth reviewing, not automatic permission to delete it. These checks never update or remove data.

The committed synthetic seed is not forced to pass every business-state rule. For example, the active-subscription check can surface modeled cases where every payment attempt failed. That result is a useful analytical finding: status-based paid metrics should not be trusted until the discrepancy is resolved or explicitly handled.

## Scope and assumptions

The checks use the repository's five-table schema. The current `users` table does not include an `is_test_user` field, so [`test_users_in_revenue.sql`](sql/test_users_in_revenue.sql) includes an empty test-user registry CTE as a clear integration point. Replace that CTE with an approved production registry or user flag.

The broader checks in [`db/sample_checks.sql`](../db/sample_checks.sql) remain useful for row counts, key integrity, event coverage, chronology, and revenue reconciliation. This directory focuses on recognizable metric failure modes and the suspicious rows behind them.

## Operating practice

Run relevant checks:

1. before experiment analysis;
2. before a recurring metric refresh;
3. after instrumentation, billing, or schema changes;
4. when a metric moves unexpectedly;
5. before backfilling historical data.

When a check fails, quantify affected rows and metric impact before deciding whether to repair source data, exclude a known population, restate a result, or pause analysis.
