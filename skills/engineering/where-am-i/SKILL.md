---
name: where-am-i
description: Use when resuming work after a break, starting a fresh session on an in-progress project, or unsure which senior-swe skill to run next. Scans the canonical workflow artifacts (`docs/architecture.md`, `docs/adr/`, `CONTEXT.md`, `docs/features/<slug>/design.md`, `docs/plans/<slug>.md`), open issues, and recent git activity, then reports what's done, what's partial or stale, and which skill (`/think-like-senior`, `/grill-with-docs`, `/to-prd`, `/design-like-senior`, `/write-plan`, `/to-issues`, `/tdd`, `/diagnose`) is the right next step. Read-only by design — never writes a state file, because artifacts on disk are the single source of truth. Triggered by phrases like "where did we leave off", "what should I run next", "is this feature ready for /tdd", "what's the status of <feature>".
---

<what-to-do>

Read-only inspection. Derive workflow state from the artifacts on disk, report it, recommend exactly one next skill.

Three things go in the report:
1. **Status table** — per artifact: complete / partial / missing.
2. **Recommended next skill** — one, with the gap that justifies it.
3. **Caveats** — stale or contradicted artifacts (e.g. `architecture.md` says "Postgres only" but `package.json` has `ioredis`).

If the user names a feature ("where am I on billing?"), scope to that feature. Otherwise summarise the whole project plus each feature in flight.

**Do not** create or modify any file. **Do not** write `workflow-state.md` or any other state tracker — it would drift from the artifacts and start lying. If the user asks for a checkpoint file, push back: the artifacts already are the checkpoint.

</what-to-do>

<supporting-info>

## Artifacts to scan

Project-level:

| Artifact | What it tells you |
|---|---|
| `docs/architecture.md` | `/think-like-senior` ran. Check the six layers (constraints, load-bearing, system arch, data model, resilience, code style) actually have content, not just headings. |
| `docs/adr/NNNN-*.md` | Load-bearing decisions captured. List titles. |
| `CONTEXT.md` (or `CONTEXT-MAP.md` + per-context files) | Shared domain language exists. Check for non-trivial glossary entries, not a stub. |

Per feature (one set per feature in flight — find them by listing `docs/features/*/`, `docs/plans/*.md`, `docs/prd/*.md`):

| Artifact | What it tells you |
|---|---|
| `docs/prd/<slug>.md` (or PRD on issue tracker) | `/to-prd` ran. |
| `docs/features/<slug>/design.md` | `/design-like-senior` ran. |
| `docs/plans/<slug>.md` | `/write-plan` ran. Read it and cross-reference against test files / `git log` to estimate which behaviors already have tests. Don't trust checkboxes alone — they may not be maintained. |
| Open issues with the feature label | `/to-issues` ran. Count open vs closed. |

System signals: `git status`, `git log --oneline -20`, test files matching `<slug>`.

## Decision tree

```
architecture.md missing or skeletal?           → /think-like-senior
architecture.md exists, CONTEXT.md thin?       → /grill-with-docs
feature mentioned, no PRD?                     → /to-prd <slug>
PRD exists, no design.md?                      → /design-like-senior <slug>
design.md exists, no plan, no backlog tickets? → ask: /write-plan (now) or /to-issues (later)
plan exists, behaviors not covered by tests?   → /tdd <slug>  (resume from first uncovered)
plan fully implemented, tests green?           → next feature, or /improve-codebase-architecture
hard bug surfaced?                             → /diagnose
```

If multiple features are mid-flight, give each its own row and recommendation, then ask which to pick up.

## Detecting stale artifacts

Surface these as caveats — never silently assume the artifact is current:

- `architecture.md` claims a system shape that the codebase contradicts (declared store vs installed deps, declared deploy target vs CI config).
- `design.md` references a module path that no longer exists.
- `CONTEXT.md` term doesn't appear in any source file.
- Plan has behaviors that look implemented (test exists) but the plan itself wasn't ticked.

For stale architecture, recommend `/think-like-senior` in **update mode** (it auto-detects existing `architecture.md` and only discusses gaps).

## Output format

Short. Bullets and a table. Example shape:

```
Project: <repo>
  Architecture:   ✅ docs/architecture.md (6/6 layers, last touched 12d ago)
  Domain lang:    ⚠️  CONTEXT.md present but only 2 terms — likely under-used
  ADRs:           3 (0001-postgres, 0002-modular-monolith, 0003-otel)

Features:
  billing   PRD ✅  design ✅  plan ✅ (4/7 behaviors look covered by tests)
            → /tdd billing  — resume from behavior #5
  auth      PRD ✅  design ❌
            → /design-like-senior auth

Caveats:
  - architecture.md says "Postgres only", package.json adds ioredis → /think-like-senior in update mode
```

Skip rows that don't apply. No prose paragraphs.

</supporting-info>
