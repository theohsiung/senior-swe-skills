# Data Model Patterns Index

Read this first when walking Step 3a. These are **structural patterns** — invariants and shapes that affect every table and every query path. They are NOT entity definitions (that's `/grill-with-docs`).

## Available patterns

- **[outbox-pattern.md](./outbox-pattern.md)** — Atomic persist + enqueue using a database table as the queue. Mandatory when you need at-least-once delivery without dual-write risk.
- **[multitenancy-row-level.md](./multitenancy-row-level.md)** — Row-level `tenant_id` enforcement, optionally with Postgres RLS. The standard tenancy implementation when "Pooled" is chosen in Step 1.
- *(Future patterns: `event-sourcing.md`, `cqrs.md`, `soft-delete-vs-archive.md`, `versioning.md`, `audit-log.md`. Add when a project actually needs the choice.)*

## Most projects need 2–4 of these

Typical bundle:
1. **Multitenancy implementation** (if Step 1 chose Pooled) — row-level `tenant_id`
2. **At-least-once delivery / outbound integration shape** — outbox if any external write matters
3. **Audit / event log shape** — append-only with retention policy
4. **Soft-delete or archive policy** — for user-visible entities only; never for audit logs

## When to skip this layer

- No persistence (CLI tool, pure batch script reading stdin) — no data model patterns to choose.
- Single-table workload (e.g., "save user preferences") — patterns are overkill.

## Out of scope here

- **Specific entity tables** (Customer, Order, Booking) — that's `/grill-with-docs`. This catalog is about *patterns*, not *which entities exist*.
- **Index strategy details** — bring those up in `/design-like-senior` when designing a feature against the chosen patterns.
- **ORM choice** — that's a load-bearing decision (Step 1 / `db-choice.md`), not a pattern.

## Procedure for Step 3a

1. Read this index.
2. For each pattern that applies, read its pattern file.
3. Recommend each pattern using `RECOMMENDATION-TEMPLATE.md`. Anchor every "Driven by" to a specific Phase A constraint or to a Step 1 decision.
4. Write the chosen patterns into `docs/architecture.md` under "## Data model patterns (Step 3a)". File ADRs for the patterns that pass the three-criterion filter (most do — these are usually load-bearing structural choices).
