# Engineering

Skills I use daily for code work, ordered by where they fit in the typical workflow.

## Once per repo

- **[setup-senior-swe-skills](./setup-senior-swe-skills/SKILL.md)** — Scaffold the per-repo config (issue tracker, triage label vocabulary, domain doc layout) that the other engineering skills consume.

## Once per project

- **[think-like-senior](./think-like-senior/SKILL.md)** — Senior-style architecture pass for a new project: walks constraints → load-bearing decisions → system architecture → data model → resilience → code style. Produces `docs/architecture.md` and project-level ADRs.

## Anytime (domain alignment)

- **[grill-with-docs](./grill-with-docs/SKILL.md)** — Domain-first grilling: sharpen terminology and update `CONTEXT.md` / ADRs inline. Business language only — technical module design is `/design-like-senior`.

## Per feature

- **[to-prd](./to-prd/SKILL.md)** — Turn the current conversation into a **product** PRD (intent, acceptance criteria, out-of-scope). Technical design lives in `/design-like-senior`.
- **[design-like-senior](./design-like-senior/SKILL.md)** — Per-feature technical design: application architecture, module boundaries, and public-interface signatures. Produces `docs/features/<slug>/design.md`. Anchored to `architecture.md` + ADRs.
- **[write-plan](./write-plan/SKILL.md)** — Turn a feature design into a behavior-driven TDD plan: a list of behaviors to test and public interfaces to introduce. **Does not** contain pre-written test code (Matt's bulk-writing anti-pattern). `/tdd` derives tests at execution time.
- **[to-issues](./to-issues/SKILL.md)** — Break a feature into backlog tickets (vertical slices, hours/days each). Reads PRD + `design.md` + (optional) `docs/plans/`. Different from `/write-plan`: ticket-level for backlog, not behavior-level for execution. The two can chain.
- **[tdd](./tdd/SKILL.md)** — Execute test-first development cycle by cycle. In plan-mode, derives the test for each cycle from `/write-plan`'s behavior description. In self-directed mode, plans as it goes. Tests verify behavior through public interfaces only.

## Maintenance and navigation

- **[diagnose](./diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[triage](./triage/SKILL.md)** — Move existing issues through a state machine of triage roles (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`).
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in **existing** code (refactor). Pre-design module shape is `/design-like-senior`.
- **[zoom-out](./zoom-out/SKILL.md)** — Tell the agent to zoom out and give broader context or a higher-level perspective on an unfamiliar section of code.
