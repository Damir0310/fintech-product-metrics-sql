-- Load the CSV files with psql. Run from the repository root:
--   psql -d fintech_metrics -f db/schema.sql
--   psql -d fintech_metrics -f db/load_data.sql
--
-- \copy reads files on the psql client. If you run psql elsewhere, replace the
-- relative data/ paths below with absolute paths.

\set ON_ERROR_STOP on

BEGIN;

\copy acquisition_channels FROM 'data/acquisition_channels.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy users FROM 'data/users.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy subscriptions FROM 'data/subscriptions.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy payments FROM 'data/payments.csv' WITH (FORMAT csv, HEADER true, NULL '');
\copy events FROM 'data/events.csv' WITH (FORMAT csv, HEADER true, NULL '');

COMMIT;

ANALYZE acquisition_channels;
ANALYZE users;
ANALYZE subscriptions;
ANALYZE payments;
ANALYZE events;
