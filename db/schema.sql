-- PostgreSQL schema for the synthetic fintech product analytics dataset.

DROP TABLE IF EXISTS events, payments, subscriptions, users, acquisition_channels CASCADE;

CREATE TABLE acquisition_channels (
    acquisition_channel_id SMALLINT PRIMARY KEY,
    channel_name VARCHAR(50) NOT NULL UNIQUE,
    channel_type VARCHAR(30) NOT NULL,
    paid_or_organic VARCHAR(10) NOT NULL CHECK (paid_or_organic IN ('paid', 'organic'))
);
COMMENT ON TABLE acquisition_channels IS 'Lookup table describing user acquisition sources.';

CREATE TABLE users (
    user_id BIGINT PRIMARY KEY,
    signup_date DATE NOT NULL,
    country VARCHAR(50) NOT NULL,
    acquisition_channel_id SMALLINT NOT NULL REFERENCES acquisition_channels(acquisition_channel_id),
    device_type VARCHAR(20) NOT NULL CHECK (device_type IN ('ios', 'android', 'web')),
    language VARCHAR(10) NOT NULL,
    age_group VARCHAR(10) NOT NULL
);
COMMENT ON TABLE users IS 'One row per registered product user.';

CREATE TABLE subscriptions (
    subscription_id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(user_id),
    plan_name VARCHAR(20) NOT NULL CHECK (plan_name IN ('monthly', 'quarterly', 'yearly')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('trial', 'active', 'canceled', 'expired')),
    started_at DATE NOT NULL,
    canceled_at DATE,
    cancellation_reason VARCHAR(50),
    trial_started_at DATE,
    trial_ended_at DATE,
    UNIQUE (subscription_id, user_id),
    CHECK (canceled_at IS NULL OR canceled_at >= started_at),
    CHECK (status <> 'canceled' OR canceled_at IS NOT NULL),
    CHECK (trial_ended_at IS NULL OR trial_started_at IS NULL OR trial_ended_at >= trial_started_at)
);
COMMENT ON TABLE subscriptions IS 'Trial and paid subscription lifecycles, including cancellation context.';

CREATE TABLE payments (
    payment_id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(user_id),
    subscription_id BIGINT NOT NULL,
    payment_date DATE NOT NULL,
    amount_usd NUMERIC(10, 2) NOT NULL CHECK (amount_usd >= 0),
    currency CHAR(3) NOT NULL,
    payment_status VARCHAR(20) NOT NULL CHECK (payment_status IN ('success', 'failed', 'refunded')),
    payment_provider VARCHAR(30) NOT NULL CHECK (payment_provider IN ('card', 'crypto', 'bank_transfer', 'apple_pay', 'google_pay')),
    failure_reason VARCHAR(50),
    FOREIGN KEY (subscription_id, user_id) REFERENCES subscriptions(subscription_id, user_id),
    CHECK (
        (payment_status = 'failed' AND failure_reason IS NOT NULL)
        OR (payment_status <> 'failed' AND failure_reason IS NULL)
    )
);
COMMENT ON TABLE payments IS 'Payment attempts, successful charges, and refund records in USD-equivalent amounts.';

CREATE TABLE events (
    event_id BIGINT PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(user_id),
    event_name VARCHAR(50) NOT NULL CHECK (event_name IN (
        'signup',
        'trial_started',
        'subscription_started',
        'payment_success',
        'payment_failed',
        'subscription_canceled',
        'subscription_expired',
        'support_contacted',
        'plan_upgraded',
        'plan_downgraded',
        'reactivated'
    )),
    event_timestamp TIMESTAMP NOT NULL,
    event_source VARCHAR(30) NOT NULL
);
COMMENT ON TABLE events IS 'Timestamped user and billing lifecycle events used for behavioral analysis.';

CREATE INDEX idx_users_signup_date ON users(signup_date);
CREATE INDEX idx_users_country ON users(country);
CREATE INDEX idx_users_channel ON users(acquisition_channel_id);
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_started ON subscriptions(started_at);
CREATE INDEX idx_payments_user_date ON payments(user_id, payment_date);
CREATE INDEX idx_payments_subscription ON payments(subscription_id);
CREATE INDEX idx_payments_status_date ON payments(payment_status, payment_date);
CREATE INDEX idx_events_user_time ON events(user_id, event_timestamp);
CREATE INDEX idx_events_name_time ON events(event_name, event_timestamp);
