# fintech_analytics — a dbt portfolio project

A dbt project modeling a fintech company's customers, accounts, and
transactions, built on Snowflake to demonstrate a staging → intermediate →
marts data warehouse pattern.

## What this project models

Synthetic fintech data (no real PII):
- **200 customers**, 1–3 accounts each
- **335 accounts** (checking, savings, credit card; active/closed/frozen)
- **10 merchants** across common spend categories
- **~6,200 transactions** across 2024 (purchases, deposits, withdrawals, transfers, fees, refunds)

## Architecture


**Design decisions worth noting:**

- **Sources, not raw refs.** Seeds land in a `raw` schema and staging models read them through `source()`, the same way they'd read a Fivetran-loaded table — swapping the seed for a real ingestion pipeline later needs no model changes.
- **Ephemeral intermediate layer.** `int_transactions_enriched` centralizes the transaction → account → customer → merchant join so every downstream mart that needs it doesn't repeat the same join logic. It's ephemeral because nothing outside the marts needs to query it directly.
- **A running-balance fact table** (`fct_daily_account_balances`) built with a window function (`SUM() OVER (PARTITION BY account_id ORDER BY transaction_date)`), filtered to `status = 'posted'` only — a common real-world ledger/balance-reporting pattern.
- **Environment-aware schema naming.** A custom `generate_schema_name` macro keeps `prod` schemas clean (e.g. `MARTS_FINANCE`) while namespacing every other target under its own schema (e.g. `DBT_DEV_MARTS_FINANCE`) so dev/CI runs never collide.

## Testing strategy

- **Generic tests** (`unique`, `not_null`, `accepted_values`, `relationships`) on every primary key, foreign key, and enum-like column — staging through marts.
- **A singular test**, `assert_no_activity_after_account_closed`, encoding a real business rule generic tests can't express: no account should have a posted transaction dated after its `closed_date`.

Run `dbt build` to run every model and test together.

## Setup

**Requirements:** a Snowflake account, `dbt-snowflake` installed.

```bash
python3 -m venv venv
source venv/bin/activate
pip install dbt-snowflake

# add your Snowflake credentials to ~/.dbt/profiles.yml (see profiles.yml.example)

dbt seed
dbt run
dbt test
dbt docs generate && dbt docs serve
```

## Possible extensions

- Orchestrate with Airflow: a scheduled DAG running `dbt seed → run → test`
- Add `snapshots/` to track slowly-changing account `status` over time
- Convert `fct_transactions` to `incremental` materialization as data volume grows
- Add CI via GitHub Actions running `dbt build` on every pull request