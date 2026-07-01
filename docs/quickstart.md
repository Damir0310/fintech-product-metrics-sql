# Quickstart

This guide takes the project from a fresh checkout to runnable PostgreSQL analysis. The committed CSV files are ready to load; generating them again is optional.

## 1. Prerequisites

Install:

- Python 3.10 or newer
- PostgreSQL with the `createdb` and `psql` command-line tools
- Python packages `pandas` and `numpy`

Confirm the tools are available:

```bash
python --version
psql --version
createdb --version
```

## 2. Create a Python environment

From the repository root:

```bash
python -m venv .venv
```

macOS or Linux:

```bash
source .venv/bin/activate
```

Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Install the two generator dependencies:

```bash
python -m pip install pandas numpy
```

## 3. Generate the data (optional)

```bash
python scripts/generate_synthetic_data.py
```

Expected output begins with:

```text
Validation passed
Wrote acquisition_channels.csv: 8 rows
Wrote users.csv: 5,000 rows
Wrote subscriptions.csv: 3,663 rows
Wrote payments.csv: 5,571 rows
Wrote events.csv: 19,297 rows
```

The fixed seed makes the output deterministic. The generator validates identifiers, ownership relationships, signup events, cancellation fields, and failed-payment events before writing files.

## 4. Create the PostgreSQL database

```bash
createdb fintech_metrics
```

If your PostgreSQL user requires an explicit username or host:

```bash
createdb -h localhost -U postgres fintech_metrics
```

## 5. Create tables and load CSV files

Run these commands from the repository root:

```bash
psql -d fintech_metrics -f db/schema.sql
psql -d fintech_metrics -f db/load_data.sql
```

With explicit connection options:

```bash
psql -h localhost -U postgres -d fintech_metrics -f db/schema.sql
psql -h localhost -U postgres -d fintech_metrics -f db/load_data.sql
```

The loader uses `\copy`, which reads files from the computer running `psql`. If a CSV path cannot be found, either return to the repository root or replace the relative paths in `db/load_data.sql` with absolute paths.

Running `db/schema.sql` drops and recreates the project tables. Do not point it at a database containing data you need to preserve.

## 6. Run data quality checks

```bash
psql -d fintech_metrics -f db/sample_checks.sql
```

Expected profile:

| Entity | Expected rows |
|---|---:|
| `acquisition_channels` | 8 |
| `users` | 5,000 |
| `subscriptions` | 3,663 |
| `payments` | 5,571 |
| `events` | 19,297 |

Diagnostic counts should be zero. The revenue section intentionally returns gross revenue, refunds, and net revenue rather than zero.

## 7. Run an analysis

Start with a simple growth query:

```bash
psql -d fintech_metrics -f sql/01_user_growth/02_monthly_signups.sql
```

Then try one query from each major metric family:

```bash
psql -d fintech_metrics -f sql/02_activation/02_trial_to_paid_conversion.sql
psql -d fintech_metrics -f sql/03_revenue/02_mrr.sql
psql -d fintech_metrics -f sql/04_retention_churn/01_monthly_churn_rate.sql
psql -d fintech_metrics -f sql/05_payments/04_recovered_payments.sql
psql -d fintech_metrics -f sql/06_ltv_segments/01_ltv_by_channel.sql
psql -d fintech_metrics -f sql/07_product_insights/04_plan_performance_summary.sql
```

You can also enter an interactive session:

```bash
psql -d fintech_metrics
```

Useful psql commands:

```text
\dt                   list tables
\d payments           describe the payments table
\i sql/03_revenue/01_monthly_revenue.sql
\q                     exit
```

## 8. Choose the right first query

| Goal | Suggested query |
|---|---|
| Check acquisition scale | `sql/01_user_growth/04_users_by_channel.sql` |
| Understand funnel conversion | `sql/02_activation/03_activation_by_channel.sql` |
| Review recurring revenue | `sql/03_revenue/02_mrr.sql` |
| Compare paid cohorts | `sql/04_retention_churn/03_paid_user_retention.sql` |
| Diagnose payment reliability | `sql/05_payments/03_failed_payments_by_provider.sql` |
| Compare user value | `sql/06_ltv_segments/01_ltv_by_channel.sql` |
| Build a plan scorecard | `sql/07_product_insights/04_plan_performance_summary.sql` |

## Troubleshooting

### `psql` is not recognized

Add PostgreSQL's `bin` directory to your system path, or call `psql` using its full path.

### Authentication fails

Pass the intended host and user explicitly with `-h` and `-U`. PostgreSQL may prompt for a password depending on local authentication settings.

### `data/users.csv` cannot be opened

Run the loader from the repository root. `\copy` resolves relative paths from the current client working directory.

### Tables already exist or contain old data

Run `db/schema.sql` again only if it is safe to drop the five project tables, then rerun `db/load_data.sql`.

### Results differ after editing the generator

The documentation numbers describe seed `42` and the committed generator. Regenerate all CSVs together, rerun the quality checks, and update any documented findings affected by the model change.

## Next reading

- [Metrics glossary](metrics_glossary.md) for definitions and denominators
- [Data dictionary](data_dictionary.md) for table and column details
- [Business questions](business_questions.md) for analysis prompts
- [SQL notes](sql_notes.md) for implementation patterns
- [Analysis summary](analysis_summary.md) for example interpretation
