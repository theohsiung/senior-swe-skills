# Primary Database Choice

Five viable options. Reversal cost is high — pick once, change only on a major scale or compliance event.

- **Postgres** — relational, transactional, mature. The default unless something specific rules it out.
- **MySQL / MariaDB** — relational, transactional, slightly different feature set; pick when an existing team's expertise dominates.
- **Managed cloud DB** (Aurora, Cloud SQL, RDS, Supabase, Neon) — usually Postgres or MySQL underneath; the trade-off is operational vs vendor lock-in.
- **Key-value / NoSQL** (DynamoDB, Redis, Cassandra) — pick when the access pattern is genuinely key-only and the relational features aren't useful.
- **Document store** (MongoDB, Firestore) — pick when schema flexibility is structurally required, not when "we don't want to design schemas yet".

## When to choose Postgres

- B2B / B2C SaaS, CRUD with transactions, GDPR or other compliance with audit needs
- Team has ≥ 1 person with deep relational experience
- Need RLS, JSONB, full-text search, or extensions (PostGIS, pg_trgm, etc.)
- Workload is < ~10TB and write rate < ~5K/sec (single Postgres handles this comfortably)

## When to choose managed cloud DB

- Solo or small team without ops capacity for self-managed Postgres
- Compliance requires audit logs, point-in-time recovery, automated backups out of the box
- Cost of operational time exceeds the managed-DB premium

## When to choose KV / NoSQL

- Access pattern is genuinely "get by key" or "get by composite key" only — no joins, no ad-hoc queries
- Throughput requirements (>100K writes/sec) exceed what Postgres can sustain on a single instance
- Specific feature need: globally-distributed writes (DynamoDB Global Tables), in-memory speed (Redis), wide-column at scale (Cassandra)

## When to choose document

- Genuinely heterogeneous documents per tenant or per use-case (multi-tenant CMS, form-builder where users define their own fields)
- Schema migration cost > schemaless data integrity cost (rare)

## When to NOT choose

- **Postgres is wrong** when the workload is truly key-only at extreme scale — the relational features are dead weight
- **MySQL is wrong** when you need RLS, JSONB-heavy queries, or PostGIS — Postgres dominates on ergonomics here
- **Managed cloud DB is wrong** when budget rules out the per-month fee and the team has Postgres operational experience
- **KV is wrong** when ad-hoc reporting will eventually be needed — KV scans for analytics are painful
- **Document is wrong** when you "want flexibility" but every document actually has the same shape — that's just a schema with extra steps

## What Postgres signs you up for

- Schema migrations (Alembic, Flyway, Prisma Migrate, ActiveRecord — pick one, don't custom)
- Connection pool management (PgBouncer for serverless, native pool for long-running processes)
- Index strategy: every join column, every WHERE column with selectivity, every ORDER BY
- Backup + PITR strategy (managed: free; self-hosted: pg_basebackup + WAL archiving)
- Vacuum / autovacuum tuning (long-tail issue, surfaces around table size > 100GB)

## Migration paths

- **Postgres → managed cloud DB (e.g., RDS, Neon)**: pg_dump + restore, repoint connection string. ~1 day for small DBs, multi-day for large with logical replication for cutover.
- **Postgres → KV / split out hot path**: identify the hot table, dual-write for a period, cutover. Multi-week project.
- **MySQL → Postgres**: pgloader handles most schema/data; review query SQL, JSON column behavior, sequence/identity differences. Multi-sprint project on a meaningful codebase.

## Anti-patterns to refuse

- **"We picked NoSQL because we're moving fast"** — schema flexibility is rarely the actual problem; data integrity discipline is. NoSQL doesn't remove the discipline, it removes the database's help with it.
- **Multiple primary stores in v1** — "Postgres for transactions, Mongo for docs, Redis for cache" before there's a real reason. Pick one, add others when there's evidence.
- **Document store for relational data** — "every Order document embeds its Items" works until you need a report across all Items, and now you're writing complicated map-reduces.
- **Choosing the DB based on the ORM** — backwards. Pick the data store first; pick the ORM that fits.

## Quick check before recommending

- Does the workload actually need the chosen DB's distinguishing feature, or are you picking based on familiarity / hype?
- What's the team's operational expertise? Self-managed Postgres at scale needs someone who can read pg_stat_activity and EXPLAIN plans.
- Will the chosen DB still be the right answer at 10× scale, or are you trading future pain for current convenience?
- Is there a compliance constraint (data residency, encryption-at-rest, audit) that some options can't meet?
