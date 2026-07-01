# Data dictionary

Dates use ISO `YYYY-MM-DD`; timestamps use `YYYY-MM-DD HH:MM:SS`. Blank optional CSV values load as SQL `NULL` through `db/load_data.sql`.

## `acquisition_channels`

One row per acquisition source. Joined to `users` by `acquisition_channel_id`.

| Column | PostgreSQL type | Description |
|---|---|---|
| `acquisition_channel_id` | `smallint` | Stable channel primary key. |
| `channel_name` | `varchar(50)` | Human-readable source: Telegram, Instagram, YouTube, Referral, Organic Search, Paid Ads, App Store, or Partner. |
| `channel_type` | `varchar(30)` | Broad grouping such as social, content, search, or partnership. |
| `paid_or_organic` | `varchar(10)` | Acquisition classification: `paid` or `organic`. |

## `users`

One row per registered user. A user may have subscriptions, payments, and events.

| Column | PostgreSQL type | Description |
|---|---|---|
| `user_id` | `bigint` | User primary key. |
| `signup_date` | `date` | Registration date. |
| `country` | `varchar(50)` | Modeled signup country. |
| `acquisition_channel_id` | `smallint` | Foreign key to `acquisition_channels`. |
| `device_type` | `varchar(20)` | Signup device: `ios`, `android`, or `web`. |
| `language` | `varchar(10)` | Modeled two-letter interface language code. |
| `age_group` | `varchar(10)` | Synthetic age band; no exact birth dates are generated. |

## `subscriptions`

One row per modeled trial/subscription lifecycle. In this version each subscribed user has one row; events describe later plan changes or reactivation.

| Column | PostgreSQL type | Description |
|---|---|---|
| `subscription_id` | `bigint` | Subscription primary key. |
| `user_id` | `bigint` | Foreign key to the subscription owner. |
| `plan_name` | `varchar(20)` | Billing term: `monthly`, `quarterly`, or `yearly`. |
| `status` | `varchar(20)` | Latest modeled status: `trial`, `active`, `canceled`, or `expired`. |
| `started_at` | `date` | Trial start for non-converters; paid start for converters. |
| `canceled_at` | `date` | Cancellation date when cancellation occurred. Remains populated after a modeled reactivation. |
| `cancellation_reason` | `varchar(50)` | Modeled reason supplied at cancellation. |
| `trial_started_at` | `date` | Trial start date. |
| `trial_ended_at` | `date` | Scheduled end of the 14-day trial. |

## `payments`

One row per charge attempt or refund. Every payment belongs to both a user and a subscription.

| Column | PostgreSQL type | Description |
|---|---|---|
| `payment_id` | `bigint` | Payment record primary key. |
| `user_id` | `bigint` | Foreign key to the paying user. |
| `subscription_id` | `bigint` | Foreign key to the related subscription. |
| `payment_date` | `date` | Attempt or refund date. |
| `amount_usd` | `numeric(10,2)` | USD-equivalent amount, always non-negative. Query logic supplies the sign. |
| `currency` | `char(3)` | Modeled local billing currency code. |
| `payment_status` | `varchar(20)` | `success`, `failed`, or `refunded`. |
| `payment_provider` | `varchar(30)` | `card`, `crypto`, `bank_transfer`, `apple_pay`, or `google_pay`. |
| `failure_reason` | `varchar(50)` | Populated for failed attempts; blank otherwise. |

## `events`

One row per timestamped lifecycle action. Events provide behavioral timing beyond table state.

| Column | PostgreSQL type | Description |
|---|---|---|
| `event_id` | `bigint` | Event primary key. |
| `user_id` | `bigint` | Foreign key to the user who generated or experienced the event. |
| `event_name` | `varchar(50)` | Lifecycle event such as `signup`, `trial_started`, `payment_success`, or `reactivated`. |
| `event_timestamp` | `timestamp` | Event date and time. |
| `event_source` | `varchar(30)` | Device or payment provider associated with the event. |

## Relationship rules

- `users.acquisition_channel_id -> acquisition_channels.acquisition_channel_id`
- `subscriptions.user_id -> users.user_id`
- `payments.user_id -> users.user_id`
- `(payments.subscription_id, payments.user_id) -> (subscriptions.subscription_id, subscriptions.user_id)`
- `events.user_id -> users.user_id`
- A payment's `user_id` matches the owner of its referenced subscription.
- Each failed payment has a corresponding `payment_failed` event on the same date.
- Each user has exactly one `signup` event at or after registration.
