"""Generate a deterministic, internally consistent fintech subscription dataset."""

from __future__ import annotations

import random
from datetime import datetime, timedelta
from pathlib import Path

import numpy as np
import pandas as pd

SEED = 42
N_USERS = 5_000
DATA_DIR = Path(__file__).resolve().parents[1] / "data"
AS_OF = datetime(2026, 1, 1)

random.seed(SEED)
np.random.seed(SEED)

CHANNELS = [
    (1, "Telegram", "social", "organic"),
    (2, "Instagram", "social", "paid"),
    (3, "YouTube", "content", "organic"),
    (4, "Referral", "referral", "organic"),
    (5, "Organic Search", "search", "organic"),
    (6, "Paid Ads", "performance", "paid"),
    (7, "App Store", "marketplace", "organic"),
    (8, "Partner", "partnership", "paid"),
]

COUNTRIES = ["Georgia", "Kazakhstan", "Russia", "Armenia", "Turkey", "UAE", "Germany", "Poland"]
COUNTRY_WEIGHTS = [0.14, 0.14, 0.20, 0.08, 0.12, 0.08, 0.12, 0.12]
COUNTRY_META = {
    "Georgia": ("GEL", ["en", "ru", "ka"]),
    "Kazakhstan": ("KZT", ["ru", "kk", "en"]),
    "Russia": ("RUB", ["ru", "en"]),
    "Armenia": ("AMD", ["hy", "ru", "en"]),
    "Turkey": ("TRY", ["tr", "en"]),
    "UAE": ("AED", ["en", "ar"]),
    "Germany": ("EUR", ["de", "en"]),
    "Poland": ("PLN", ["pl", "en"]),
}
PLAN_PRICE = {"monthly": 12.99, "quarterly": 32.99, "yearly": 119.99}
PLAN_DAYS = {"monthly": 30, "quarterly": 90, "yearly": 365}
CANCEL_REASONS = ["too_expensive", "not_using_enough", "missing_features", "payment_issues", "switched_product", "other"]
FAILURE_REASONS = ["insufficient_funds", "card_declined", "expired_card", "provider_error", "authentication_failed"]


def weighted_choice(values, weights):
    """Return one item using the supplied probability weights."""
    return random.choices(values, weights=weights, k=1)[0]


def add_event(events, event_id, user_id, name, timestamp, source):
    events.append(
        {
            "event_id": event_id,
            "user_id": user_id,
            "event_name": name,
            "event_timestamp": timestamp.strftime("%Y-%m-%d %H:%M:%S"),
            "event_source": source,
        }
    )
    return event_id + 1


def main():
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    channels = pd.DataFrame(CHANNELS, columns=["acquisition_channel_id", "channel_name", "channel_type", "paid_or_organic"])

    signup_start = datetime(2025, 1, 1)
    signup_offsets = np.random.randint(0, 365, size=N_USERS)
    # A slight growth trend makes later months modestly larger without becoming artificial.
    signup_offsets = np.maximum(signup_offsets, np.random.randint(0, 365, size=N_USERS))

    users = []
    subscriptions = []
    payments = []
    events = []
    event_id = subscription_id = payment_id = 1

    channel_ids = [c[0] for c in CHANNELS]
    channel_weights = [0.14, 0.13, 0.11, 0.15, 0.17, 0.12, 0.10, 0.08]
    provider_weights = [0.49, 0.07, 0.11, 0.17, 0.16]
    providers = ["card", "crypto", "bank_transfer", "apple_pay", "google_pay"]

    for i in range(N_USERS):
        user_id = i + 1
        signup_dt = signup_start + timedelta(days=int(signup_offsets[i]), hours=random.randint(0, 23), minutes=random.randint(0, 59))
        country = weighted_choice(COUNTRIES, COUNTRY_WEIGHTS)
        currency, languages = COUNTRY_META[country]
        channel_id = weighted_choice(channel_ids, channel_weights)
        device = weighted_choice(["ios", "android", "web"], [0.38, 0.43, 0.19])
        language = weighted_choice(languages, [0.55] + [0.45 / (len(languages) - 1)] * (len(languages) - 1) if len(languages) > 1 else [1])
        age_group = weighted_choice(["18-24", "25-34", "35-44", "45-54", "55+"], [0.18, 0.39, 0.25, 0.12, 0.06])
        users.append(
            {
                "user_id": user_id,
                "signup_date": signup_dt.date().isoformat(),
                "country": country,
                "acquisition_channel_id": channel_id,
                "device_type": device,
                "language": language,
                "age_group": age_group,
            }
        )
        event_id = add_event(events, event_id, user_id, "signup", signup_dt, device)

        # Product engagement exists even for users who never start a trial.
        if random.random() < 0.22:
            event_id = add_event(events, event_id, user_id, "support_contacted", signup_dt + timedelta(days=random.randint(1, 20)), device)

        trial_probability = 0.72 + (0.05 if channel_id in [4, 5] else -0.03 if channel_id == 6 else 0)
        if random.random() >= trial_probability:
            continue

        trial_start = signup_dt + timedelta(days=random.randint(0, 5), hours=random.randint(0, 12))
        trial_end = trial_start + timedelta(days=14)
        event_id = add_event(events, event_id, user_id, "trial_started", trial_start, device)

        conversion_probability = 0.55 + (0.08 if channel_id in [4, 5] else -0.07 if channel_id == 6 else 0)
        converts = trial_end < AS_OF and random.random() < conversion_probability
        plan = weighted_choice(["monthly", "quarterly", "yearly"], [0.57, 0.25, 0.18])

        if not converts:
            subscriptions.append(
                {
                    "subscription_id": subscription_id,
                    "user_id": user_id,
                    "plan_name": plan,
                    "status": "expired" if trial_end < AS_OF else "trial",
                    "started_at": trial_start.date().isoformat(),
                    "canceled_at": "",
                    "cancellation_reason": "",
                    "trial_started_at": trial_start.date().isoformat(),
                    "trial_ended_at": trial_end.date().isoformat(),
                }
            )
            if trial_end < AS_OF:
                event_id = add_event(events, event_id, user_id, "subscription_expired", trial_end, device)
            subscription_id += 1
            continue

        paid_start = trial_end
        event_id = add_event(events, event_id, user_id, "subscription_started", paid_start, device)
        churn_probability = {"monthly": 0.39, "quarterly": 0.27, "yearly": 0.16}[plan]
        churns = random.random() < churn_probability and paid_start + timedelta(days=35) < AS_OF
        cancel_dt = None
        cancellation_reason = ""
        if churns:
            cancel_dt = min(paid_start + timedelta(days=random.randint(35, max(36, (AS_OF - paid_start).days))), AS_OF - timedelta(days=1))
            cancellation_reason = weighted_choice(CANCEL_REASONS, [0.22, 0.29, 0.15, 0.14, 0.11, 0.09])

        reactivated = bool(churns and cancel_dt and cancel_dt + timedelta(days=30) < AS_OF and random.random() < 0.16)
        if reactivated:
            reactivate_dt = cancel_dt + timedelta(days=random.randint(15, min(75, max(16, (AS_OF - cancel_dt).days - 1))))
            status = "active"
        elif churns:
            status = "canceled"
        else:
            status = "active"

        subscriptions.append(
            {
                "subscription_id": subscription_id,
                "user_id": user_id,
                "plan_name": plan,
                "status": status,
                "started_at": paid_start.date().isoformat(),
                "canceled_at": cancel_dt.date().isoformat() if cancel_dt else "",
                "cancellation_reason": cancellation_reason,
                "trial_started_at": trial_start.date().isoformat(),
                "trial_ended_at": trial_end.date().isoformat(),
            }
        )

        payment_date = paid_start
        final_date = cancel_dt if churns else AS_OF
        while payment_date < final_date:
            provider = weighted_choice(providers, provider_weights)
            amount = round(PLAN_PRICE[plan] * random.uniform(0.96, 1.04), 2)
            fail_probability = 0.075 + (0.035 if provider == "crypto" else 0.02 if provider == "bank_transfer" else 0)
            failed = random.random() < fail_probability
            if failed:
                failure = weighted_choice(FAILURE_REASONS, [0.34, 0.27, 0.13, 0.14, 0.12])
                payments.append({"payment_id": payment_id, "user_id": user_id, "subscription_id": subscription_id, "payment_date": payment_date.date().isoformat(), "amount_usd": amount, "currency": currency, "payment_status": "failed", "payment_provider": provider, "failure_reason": failure})
                payment_id += 1
                event_id = add_event(events, event_id, user_id, "payment_failed", payment_date, provider)
                # Most recoveries happen within one week and remain attached to the same subscription.
                if random.random() < 0.61 and payment_date + timedelta(days=7) < final_date:
                    recovered_date = payment_date + timedelta(days=random.randint(1, 7))
                    payments.append({"payment_id": payment_id, "user_id": user_id, "subscription_id": subscription_id, "payment_date": recovered_date.date().isoformat(), "amount_usd": amount, "currency": currency, "payment_status": "success", "payment_provider": provider, "failure_reason": ""})
                    payment_id += 1
                    event_id = add_event(events, event_id, user_id, "payment_success", recovered_date, provider)
            else:
                payments.append({"payment_id": payment_id, "user_id": user_id, "subscription_id": subscription_id, "payment_date": payment_date.date().isoformat(), "amount_usd": amount, "currency": currency, "payment_status": "success", "payment_provider": provider, "failure_reason": ""})
                payment_id += 1
                event_id = add_event(events, event_id, user_id, "payment_success", payment_date, provider)
                if random.random() < 0.018:
                    refund_date = min(payment_date + timedelta(days=random.randint(1, 14)), AS_OF - timedelta(days=1))
                    payments.append({"payment_id": payment_id, "user_id": user_id, "subscription_id": subscription_id, "payment_date": refund_date.date().isoformat(), "amount_usd": amount, "currency": currency, "payment_status": "refunded", "payment_provider": provider, "failure_reason": ""})
                    payment_id += 1

            payment_date += timedelta(days=PLAN_DAYS[plan])

        if random.random() < 0.09 and paid_start + timedelta(days=60) < final_date:
            change_dt = paid_start + timedelta(days=random.randint(30, max(31, min(180, (final_date - paid_start).days - 1))))
            event_name = "plan_upgraded" if plan != "yearly" and random.random() < 0.62 else "plan_downgraded"
            event_id = add_event(events, event_id, user_id, event_name, change_dt, device)
        if churns and cancel_dt:
            event_id = add_event(events, event_id, user_id, "subscription_canceled", cancel_dt, device)
        if reactivated:
            event_id = add_event(events, event_id, user_id, "reactivated", reactivate_dt, device)
        subscription_id += 1

    frames = {
        "acquisition_channels.csv": channels,
        "users.csv": pd.DataFrame(users),
        "subscriptions.csv": pd.DataFrame(subscriptions),
        "payments.csv": pd.DataFrame(payments),
        "events.csv": pd.DataFrame(events),
    }
    for filename, frame in frames.items():
        frame.to_csv(DATA_DIR / filename, index=False, lineterminator="\n")
        print(f"Wrote {filename}: {len(frame):,} rows")


if __name__ == "__main__":
    main()
