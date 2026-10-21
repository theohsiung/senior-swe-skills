# System Architectures Index

Read this first when walking Step 2. Pick 2–3 candidates whose "When to choose" matches the project's Phase A constraints, then read those candidate pattern files only — don't pre-load the whole catalog.

## Available patterns

- **[modular-monolith.md](./modular-monolith.md)** — One deployable, enforced internal module boundaries. The default for 3–8 devs with persistence and more than one bounded context.
- *(Future patterns: `monolith.md`, `microservices.md`, `serverless.md`, `hybrid-edge-core.md`. Add when their first project surfaces a non-trivial decision.)*

Until a pattern file exists, recommend that candidate from first principles using the one-line guide below, and still fill every section of `RECOMMENDATION-TEMPLATE.md`. A missing file is not a reason to drop a candidate from "Considered & rejected".

| Candidate | When it usually wins |
|---|---|
| Plain monolith | 1–2 devs, one obvious context, MVP / internal tool |
| Modular monolith | 3–8 devs, several bounded contexts sharing one database |
| Microservices | ≥ 10 devs in independent teams, sub-systems with radically different SLAs or scaling profiles |
| Serverless | Spiky or low steady-state traffic, event-driven workloads, team already fluent in the platform |
| Hybrid edge-core | Latency-critical edge reads (CDN / edge functions) in front of a conventional core |

## When to skip this layer entirely

- Single-binary CLI, library, or single-process tool — there is no system shape to choose.
- Throwaway prototype with explicit deletion date — write one line ("single process, no persistence") into `architecture.md` and move on.

## Procedure for Step 2

1. Read this index.
2. Shortlist 2–3 candidates from Phase A constraints (team size, scale, SLA, compliance, deadline).
3. Read the pattern files that exist for the shortlist.
4. Output one recommendation using `RECOMMENDATION-TEMPLATE.md` — at least one rejected candidate must be a whole-shape alternative.
5. Write it into `docs/architecture.md` under "## System architecture (Step 2)". The system shape almost always warrants an ADR.
