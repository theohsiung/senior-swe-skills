# Load-bearing Decisions Index

Read this first when walking Step 1. Pick 2–4 candidates whose "When to choose" matches the project's Phase A constraints, then read those candidate pattern files only — don't pre-load the whole catalog.

## Available patterns

- **[tenancy.md](./tenancy.md)** — Single-tenant / pooled (`tenant_id`) / siloed (DB-per-tenant). Most B2B projects need this decision.
- **[db-choice.md](./db-choice.md)** — Postgres / MySQL / managed cloud DB / KV (Redis/Dynamo) / document store. Pick once; reversal cost is high.
- *(Future patterns: `auth.md`, `async-strategy.md`, `deployment-target.md`. Add when their first project surfaces a non-trivial decision.)*

## Most projects have 3–5 load-bearing decisions

Typical bundle for a SaaS:
1. Tenancy model
2. Primary datastore
3. Authentication approach (managed IdP vs build)
4. Async strategy (in-process / Postgres queue / broker / serverless)
5. Deployment target (PaaS / IaaS / serverless)

Don't make up extras to fill quota. If the project only has two real load-bearing choices, do two.

## When to skip this layer entirely

- Single-binary CLI / library / personal tool with no persistence — Step 1 has no real load-bearing decision.
- Throwaway prototype with explicit deletion date — defer all load-bearing decisions; just write 3 lines into architecture.md.

## Procedure for Step 1

1. Read this index.
2. Identify which sub-decisions actually apply for the project.
3. For each sub-decision, read the relevant pattern file (or 2 candidates to compare).
4. Output a recommendation per sub-decision using `RECOMMENDATION-TEMPLATE.md`.
5. Write each into `docs/architecture.md` under "## Load-bearing decisions (Step 1)". Most warrant ADRs (apply the three-criterion filter).
