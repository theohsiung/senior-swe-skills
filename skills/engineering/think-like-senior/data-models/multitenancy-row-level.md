# Multitenancy via Row-Level `tenant_id`

The standard implementation when Step 1 chose **Pooled** tenancy. Single database, single schema, every tenant table carries `tenant_id NOT NULL`. Application enforces scoping at the repository layer; Postgres RLS provides defense-in-depth.

## When to choose

- Step 1 tenancy = Pooled
- Postgres or MySQL chosen as primary DB
- Tenant count 10 → 100K range
- No regulatory mandate for physical isolation between tenants

## When to NOT choose

- Step 1 tenancy = Siloed or Single-tenant — different implementation, different file
- Datastore doesn't have row-level security or efficient column predicates (rare; almost all relational DBs do)
- Compliance demands isolation that row-level cannot provide (HIPAA per-tenant encryption, certain PCI scopes)

## What you sign up for

- `tenant_id UUID NOT NULL REFERENCES tenants(id)` on every tenant-scoped table
- Index every `tenant_id` column; usually as the leading column of compound indexes (`(tenant_id, created_at)`, `(tenant_id, status)`, etc.)
- Repository layer wraps every query: cross-tenant access is a separate, explicit, audited path
- Postgres RLS policies as defense-in-depth: `tenant_id = current_setting('app.tenant_id')::uuid`
- Per-request middleware: `SET LOCAL app.tenant_id = $1` after authentication and before any business code
- Tests that verify tenant isolation: a request authenticated as tenant A cannot read tenant B's data, even with crafted query parameters

## Defense-in-depth layers

Three layers, each catches a different failure mode:

1. **Repository discipline** — every query goes through a repo function that takes `tenant_id` and embeds it in the WHERE. Catches: developer convenience.
2. **RLS policies on every tenant table** — DB refuses queries without `app.tenant_id` set. Catches: a missed `WHERE tenant_id = ?` in a hand-rolled query.
3. **Cross-tenant audit job** — periodically samples queries and verifies no row touches multiple `tenant_id` values. Catches: a bug in layer 1 or 2 that no test caught.

## Migration paths

**From single-tenant codebase**:
1. Add `tenants` table; one row for the existing tenant.
2. Add `tenant_id UUID NOT NULL DEFAULT '<existing-tenant-id>'` to every domain table.
3. Refactor repositories to require `tenant_id`.
4. Drop the DEFAULT, add NOT NULL.
5. Enable RLS policies.
6. Add request-scoping middleware.

This is a multi-week project on a meaningful codebase. Plan migrations forward-only with a backfill phase.

**Toward Siloed for a specific tenant**: dump that tenant's rows, restore into a dedicated schema (or DB), update routing for that tenant. Other tenants stay pooled. Hybrid models work but only with explicit policy.

## Anti-patterns to refuse

- **`tenant_id` nullable** — defeats the whole pattern; one accidental NULL becomes a leak vector.
- **Cross-tenant joins in API code paths** — cross-tenant queries belong in admin/ops paths only. If they appear in user-facing handlers, redesign.
- **Caching without tenant scope in the cache key** — a cache hit can leak across tenants. Every cache key includes `tenant_id`.
- **Soft-delete that returns deleted rows when scoped to wrong tenant** — verify the tenant predicate is *before* the deleted-at predicate, not after.
- **Tenant bypass for "internal" endpoints** — internal tools that read across tenants should go through a separate audited path with explicit logging, not bypass RLS.
- **Forgetting `tenant_id` on a new table** — add a CI check or migration linter that fails when a new table without `tenant_id` references a tenant-scoped table.

## Quick check before recommending

- Are there tables that genuinely shouldn't have `tenant_id` (e.g., `tenants` itself, system-wide config)? Document those explicitly so audits don't false-positive.
- Is there a cross-tenant query already in the codebase? If yes, audit and explicitly mark it.
- Does the cache layer (Redis, in-memory) include `tenant_id` in keys?
- Does logging redact or scope `tenant_id` correctly so support staff don't see other tenants' identifiers when debugging?
