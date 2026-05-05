# Tenancy Model

Three options. Choose one at project init; reversing later is painful.

- **Single-tenant** — one DB and one app instance per customer; each customer gets a dedicated deploy.
- **Pooled** — single DB and single schema; every tenant table has a `tenant_id` column. Application enforces scoping; optionally Postgres RLS as defense-in-depth.
- **Siloed** — DB-per-tenant or schema-per-tenant inside a shared cluster.

## When to choose pooled

- B2B SaaS at 10K–100K tenants
- No regulatory data-isolation pressure
- Team size 1–15
- One application codebase serves all customers

## When to choose siloed

- Specific compliance demands physical isolation (HIPAA, certain PCI scopes)
- Customer demands BYO-database / BYO-region as a contractual term
- Tenant count remains low (< ~100) and per-tenant ops capacity exists

## When to choose single-tenant

- Enterprise customers willing to pay for dedicated infra
- Per-customer SLA / customization requirements
- Tenant count is in the dozens, each with significant ARR

## When to NOT choose

- **Pooled is wrong** when one missing `WHERE tenant_id = ?` is a regulatory P0 (HIPAA, finance) — you need a backstop stronger than code review.
- **Siloed is wrong** at high tenant count — N migrations and N backup pipelines exceed what a small team can sustain.
- **Single-tenant is wrong** when per-customer ARR can't cover the dedicated infra cost.

## What pooled signs you up for

- `tenant_id NOT NULL` on every tenant table; the framework wraps `SET LOCAL app.tenant_id` per request
- RLS policies as defense-in-depth (recommended) so a missed `WHERE tenant_id = ?` doesn't leak data
- Cross-tenant queries are explicit, audited, and never reachable from API handlers
- One migration applies to all tenants atomically — upside (one migration) and risk (one bad migration affects all)
- Backups operate at the cluster level; per-tenant restore needs extra plumbing

## What siloed signs you up for

- N migrations per release (where N = tenant count)
- N backup pipelines, N restore drills
- Per-tenant connection pool overhead
- Per-tenant capacity planning

## Migration paths

- **Pooled → Siloed (for one tenant)**: dump that tenant's rows, restore into a dedicated schema/DB, switch routing. ~1 sprint per migrated tenant.
- **Single-tenant → Pooled**: add `tenant_id` to every tenant table, backfill, refactor query layer. Multi-week project on a meaningful codebase.
- **Pooled → Single-tenant**: rare; usually means extracting an enterprise customer onto dedicated infra.

## Anti-patterns to refuse

- **Pooled without `tenant_id` enforcement** — app-only scoping with no NOT NULL, no RLS, no test for cross-tenant leak. One missing predicate becomes a P0.
- **Siloed for cost reasons alone** — at low tenant count, operational tax exceeds any cost savings.
- **Mixing models without explicit policy** — "most tenants pooled, top 5 siloed" can work, but only if the policy and tooling are designed for it from day 1.

## Quick check before recommending

- Is the regulatory constraint that justifies siloed real today, or imagined for a year-2 customer?
- Will the tenant count actually exceed what one Postgres instance handles? (10K tenants × 10 users = 100K MAU still fits one Postgres.)
- Does the team have ops capacity for N-times-everything if siloed is chosen?
