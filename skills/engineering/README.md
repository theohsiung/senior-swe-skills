# Engineering

Skills I use daily for code work, ordered by where they fit in the typical workflow.

## Once per repo

- **[setup-senior-swe-skills](./setup-senior-swe-skills/SKILL.md)** — Scaffold the per-repo config (project doc paths, issue tracker, triage label vocabulary, domain doc layout) that the other engineering skills consume.

## Per new domain area (default first step on a cold start)

- **[grill-with-docs](./grill-with-docs/SKILL.md)** — Domain-first grilling: sharpen terminology and update `CONTEXT.md` / ADRs inline. Business language only — technical module design is `/design-like-senior`.

## Once per project (optional)

- **[think-like-senior](./think-like-senior/SKILL.md)** — Senior-style architecture pass for a new project: walks constraints → load-bearing decisions → system architecture → data model → resilience → code style. Produces `docs/architecture.md` and project-level ADRs.

## Per feature

- **[to-prd](./to-prd/SKILL.md)** — Turn the current conversation into a **product** PRD (intent, acceptance criteria, out-of-scope). Technical design lives in `/design-like-senior`.
- **[design-like-senior](./design-like-senior/SKILL.md)** — Per-feature technical design: application architecture, module boundaries, and public-interface signatures. Produces `docs/features/<slug>/design.md`. Anchored to `architecture.md` + ADRs.
- **[write-plan](./write-plan/SKILL.md)** — Turn a feature design into a behavior-driven TDD master plan with stable `T-NNN` task IDs. **Does not** contain pre-written test code (the bulk-writing anti-pattern). When invoked against an issue, runs in **filter mode** — prints only that slice's cycles from the master plan, never writes a divergent copy.
- **[to-issues](./to-issues/SKILL.md)** — Group adjacent cycles from the master plan into backlog **slices** (hours/days each). Each issue carries a `## Plan tasks: T-NNN..T-NNN` reference so `/write-plan <issue#>` can filter it later. The master plan stays the single source of truth.
- **[tdd](./tdd/SKILL.md)** — Execute test-first development cycle by cycle. Reads the master plan (or its filtered slice) and derives the test for each cycle at execution time. Default test level is system-public; see [`docs/skill-contracts.md` §3](../../docs/skill-contracts.md).

## Maintenance and navigation

- **[diagnose](./diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test. **Self-contained** — writes its own regression test in Phase 5; do not chain to `/tdd` after.
- **[triage](./triage/SKILL.md)** — Move existing issues through a state machine of triage roles (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`).
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in **existing** code (refactor). Pre-design module shape is `/design-like-senior`.
- **[zoom-out](./zoom-out/SKILL.md)** — Tell the agent to zoom out and give broader context or a higher-level perspective on an unfamiliar section of code.
- **[where-am-i](./where-am-i/SKILL.md)** — Read-only inspection of workflow artifacts (`architecture.md`, ADRs, `CONTEXT.md`, `design.md`, plans, issues, git) that reports project status and recommends the next skill to run. Use when resuming after a break or unsure what to run next.
