---
name: think-like-senior
description: Senior-style architecture pass for a new project (or a major architectural pivot). Walks constraints → load-bearing decisions → system architecture → data model → resilience defaults → code style, producing `docs/architecture.md` and ADRs. Use proactively whenever the user is starting a new project, evaluating a tech stack from scratch, planning a major refactor or rewrite, weighing monolith vs microservices, asking "is this going to scale", "how should we structure this", "what's the right architecture for X", or describing work as "system design" / "architecture review" / "I'm thinking about how to lay this out" — even when they don't say the word "architecture" outright. Run this once per project, typically after `/grill-with-docs` (so vocabulary is solid) and before `/to-prd` — not per feature; per-feature design is `/design-like-senior`. Skip entirely for one-shot tech questions like "Postgres or MySQL" or trivial throwaway scripts — those don't need the full pass.
---

<what-to-do>

Walk a senior architect's design pass on this project. Cover six layers: constraints, load-bearing decisions, system architecture, data model patterns, resilience defaults, code style. For each layer, **recommend an answer with explicit reasoning** rather than asking the user to invent it from scratch — the user's job is to confirm, modify, or push back.

Ask one question at a time. When constraints make a layer irrelevant (a 200-line CLI doesn't need system architecture), say so and skip — over-designing tiny projects is a junior move.

Do **not** cover application-internal layering, module boundaries, or class/function design. Those belong to `/design-like-senior` and run per feature, not per project.

</what-to-do>

<supporting-info>

## Inputs to read first

For a fresh project, the only input is the conversation. For an existing project, scan before deciding anything:

1. **`docs/architecture.md`** — if present, switch to **update mode**: read it, surface what looks stale or contradicted by current code, and only discuss those gaps. Do NOT rewrite from scratch.
2. **`docs/adr/`** — read titles to know what's already been decided. Don't re-litigate without surfacing the existing ADR first.
3. **`CONTEXT.md`** — for canonical vocabulary; use the project's terms, not generic ones.
4. **The codebase top level** — language, package manager, deploy target. The Phase A constraints discussion goes faster when the obvious facts are already on the table.

## Output artifacts

Create lazily — only when there's something to write:

- `docs/architecture.md` — single snapshot of the architecture (constraints, system shape, data model patterns, resilience defaults).
- `docs/adr/NNNN-*.md` — one ADR per load-bearing decision. File via the protocol in [grill-with-docs/ADR-FORMAT.md](../grill-with-docs/ADR-FORMAT.md) (number allocation goes through `scripts/next-adr-number.sh`).
- Linter / formatter config files for the detected language (Step 8, mechanical).
- Observability stack boilerplate for the detected language (Step 7a, mechanical).

If `docs/architecture.md` already exists when the skill starts, this is not a fresh project — switch to update mode: read the existing file, surface what looks stale or contradicted by current code, and discuss only those gaps.

## Scope split with `/design-like-senior`

| Step | Layer | This skill | `/design-like-senior` |
|---|---|---|---|
| 0 | Constraints / quality attributes | ✅ | uses outputs |
| 1 | Load-bearing decisions | ✅ | uses outputs |
| 2 | System architecture | ✅ | uses outputs |
| 3a | Data model **patterns** | ✅ (project-level invariants) | increments per feature |
| 3b | Domain entities | defer to `/grill-with-docs` | defer to `/grill-with-docs` |
| 4 | Application architecture | — | ✅ |
| 5 | Module / package design | — | ✅ |
| 6 | Class / function design | — | ✅ (or surfaces during TDD) |
| 7a | Observability stack | ✅ (canonical, auto) | uses outputs |
| 7b | Resilience policies (system-wide) | ✅ (defaults + ≤3 questions) | per-feature exceptions |
| 8 | Code style | ✅ (canonical, auto) | uses outputs |

If a question is about how a *specific feature* fits into the architecture, that's `/design-like-senior`. Send the user there.

## The three phases

### Phase A — Size the project (always)

Cover Step 0 with a short grill. Six questions max, one at a time:

1. Team size now and projected over the next 6 months
2. Deadline / scope of the first release
3. Expected scale (users / requests / data volume), order-of-magnitude
4. Latency or availability targets, if any
5. Compliance or data-residency constraints
6. Cost ceiling or runtime budget, if known

Skip any question that doesn't apply — a personal CLI tool has no team, no SLA, no compliance. Capture answers in the **Constraints** section of `docs/architecture.md`. Don't recommend anything yet — these are facts only the user knows.

### Phase B — Pick which layers matter

Based on Phase A, propose a short list of which remaining layers (1, 2, 3a, 7, 8) actually need a serious pass for this project. Examples:

- A 500-line personal CLI: **skip 2, skip 3a, skip 7b**. Run 1 (CLI flag conventions), 7a (logging only), 8.
- A B2B SaaS MVP for 50 trial customers: run all of 1, 2, 3a, 7, 8.
- A migration of an existing monolith: focus on 1 and 2, treat 3a as already-decided unless the migration touches the data model.

Tell the user the proposed list **with reasons tied to specific Phase A constraints**. Let them add or drop layers before continuing.

### Phase C — Walk each layer in scope

For each layer the user kept, do this loop:

1. Read the layer's `INDEX.md` to see available patterns.
2. Pick the 2–3 candidates whose "When to choose" matches the constraints.
3. Read those candidate pattern files only (don't pull in the rest).
4. Output a recommendation using [RECOMMENDATION-TEMPLATE.md](./RECOMMENDATION-TEMPLATE.md). All five sections required: Recommendation, Driven by, Considered & rejected, What would change my mind, Push back.
5. The user accepts, modifies, or pushes back.
6. If they push back with new information about a constraint, update Phase A and re-recommend. If they push back with vibes only ("feels wrong", "I don't like it"), reply by asking which constraint would have to change for the recommendation to change. Don't capitulate to vibes — that's sycophancy, not collaboration.
7. When the decision lands, write to `docs/architecture.md` and create an ADR if the decision passes the three-criterion filter (see ADR section below).

## Layer-by-layer specifics

### Step 1 — Load-bearing decisions

Read [load-bearing/INDEX.md](./load-bearing/INDEX.md). Typical members of this category: tenancy model, authn / authz approach, primary datastore choice, async strategy (in-process / queue / cron / serverless).

Most projects have 3–5 load-bearing decisions total. Don't make up extras to fill quota — if only two apply, do two.

### Step 2 — System architecture

Read [architectures/INDEX.md](./architectures/INDEX.md). Always-recommended candidates if 3+ devs and any persistence: monolith, modular monolith, microservices, serverless, hybrid edge-core. For pure CLI / library / single-process: skip.

### Step 3a — Data model patterns

Read [data-models/INDEX.md](./data-models/INDEX.md). This step is about **structural patterns** (event sourcing, CQRS, soft delete vs archive, versioning, multi-tenancy isolation). It is **not** about what the entities are — that's `/grill-with-docs`. If the user asks about specific entities here, redirect.

### Step 7a — Observability stack (auto, no grill)

Detect the project's primary language(s) and apply the canonical stack:

| Language / Runtime | Structured logging | Error tracking | Metrics + Tracing |
|---|---|---|---|
| Python | `structlog` | Sentry SDK | OpenTelemetry SDK |
| Node / TypeScript | `pino` | Sentry | OpenTelemetry |
| Go | `log/slog` (stdlib, 1.21+) | Sentry Go | OpenTelemetry |
| Rust | `tracing` + `tracing-subscriber` (JSON) | Sentry Rust | `tracing` + OTel exporter |
| Java / Spring | SLF4J + Logback (JSON encoder) | Sentry Java | Micrometer + OTel |
| Kotlin / Ktor | SLF4J + Logback | Sentry | Micrometer + OTel |
| Swift | OSLog + JSON adapter | Sentry Swift | OTel Swift |
| Ruby | `lograge` (Rails) / stdlib JSON | Sentry | OTel Ruby |
| PHP | Monolog (JSON handler) | Sentry | OTel PHP |

Universal conventions (all languages, write into `docs/architecture.md`):

- Structured JSON log to **stdout**, never to file (12-factor).
- All logs carry `request_id` / `trace_id` for correlation.
- For services: `/health` (liveness) and `/ready` (readiness) endpoints.
- Graceful shutdown on SIGTERM.

Don't ask the user about these — they're industry consensus. Only grill if the project is cross-language (which row to apply?) or the user has a pre-existing observability stack (read it, don't replace it).

**Context-aware deviation.** The conventions above assume a multi-user service deployed somewhere. They don't all apply to every project — and forcing them on a project they don't fit is over-engineering, not rigour. Common deviations:

- **Personal CLIs / single-user tools** — skip Sentry / OpenTelemetry. There is no central error-tracking target for a one-user tool, and the SaaS overhead is junior-move material.
- **CLIs whose stdout IS the payload** (a command that prints a report or pipes to another tool) — logs go to **stderr**, not stdout. The user shouldn't have to `2>/dev/null` to consume the actual output.
- **Internal one-off batch jobs** — structured stdout logs still help, but `/health` / `/ready` endpoints and SIGTERM graceful-shutdown hooks don't apply.

When deviating, write the reason in `docs/architecture.md` so the next reader understands the intentional gap. Don't deviate silently.

### Step 7b — Resilience policies (defaults + at most 3 questions)

Read [resilience/INDEX.md](./resilience/INDEX.md). Apply these defaults; only ask about the ones where Phase A constraints contradict the default:

| Question | Default | Override when |
|---|---|---|
| Default outbound timeout | 5s connect / 30s total | latency-sensitive (p99 < 200ms) → 1s/3s; batch jobs → 10s/120s |
| Default retry policy | 3× exponential backoff with jitter, only idempotent + 5xx/timeout | money / settlement → 0 retries + idempotency keys |
| Circuit breaker | enable for any external HTTP dependency, 50% failure rate / 60s window | pure batch / single-process / CLI → skip |

Each override question must cite the Phase A constraint that triggered it. If the constraint isn't there, apply the default silently.

### Step 8 — Code style (auto, no grill)

Detect the project's primary language and apply the canonical style. Generate config files. Add a one-line note to `docs/architecture.md` like "Code style: PEP 8 enforced via ruff."

| Language | Standard | Tools | Config files |
|---|---|---|---|
| Python | PEP 8 | `ruff` (lint+format) | `pyproject.toml` |
| TypeScript / JS | Prettier de facto | `biome` (preferred) or `prettier` + `eslint` | `biome.json` or `.prettierrc` + `.eslintrc` |
| Go | `gofmt` (stdlib) | `gofmt` + `golangci-lint` | `.golangci.yml` |
| Rust | `rustfmt` (stdlib) | `rustfmt` + `clippy` | `rustfmt.toml` |
| Java | Google Java Style | `spotless` + `checkstyle` | pom/gradle plugin config |
| Kotlin | Kotlin Coding Conventions | `ktlint` or `detekt` | `.editorconfig` + plugin |
| Swift | Swift API Design Guidelines | `swiftformat` + `swiftlint` | `.swiftformat`, `.swiftlint.yml` |
| Ruby | Ruby Style Guide | `rubocop` | `.rubocop.yml` |
| PHP | PSR-12 | `php-cs-fixer` | `.php-cs-fixer.php` |
| C++ | Google or LLVM | `clang-format` | `.clang-format` |

Always also add `.editorconfig` regardless of language.

Only ask the user when:

- Multi-language monorepo (apply per package or globally?)
- Pre-existing config conflicts with the canonical default (replace or keep?)
- The user explicitly asks for a deviation (line length, quote style)

## When to offer an ADR

Apply the triple test and follow the protocol in [`../grill-with-docs/ADR-FORMAT.md`](../grill-with-docs/ADR-FORMAT.md). Don't restate the test here.

In this skill specifically, candidates that almost always pass:

- The Step 1 load-bearing decisions (auth model, tenancy, primary store).
- The Step 2 system shape choice (monolith vs services etc.).
- Resilience default overrides driven by SLA or money handling.
- Pre-existing tech-stack constraints from Phase A (compliance, vendor lock-in).

Step 7a observability stack and Step 8 code style are almost never ADR-worthy — they're industry defaults, not trade-offs.

## Pushback discipline

When the user pushes back on a recommendation:

- If they cite a **new constraint or fact** ("oh, I forgot — we have to be HIPAA-compliant"), update Phase A's constraints section in `architecture.md`, then re-recommend from the new state.
- If they cite **a different mapping of an existing constraint** ("I don't think 3 devs is too few for microservices"), engage on the merits — show the operational tax (services count, mesh, tracing, deploy pipelines) and let them weigh it.
- If they only cite **vibes** ("feels wrong", "I want services"), reply with: "Which Phase A constraint would have to be different for me to recommend that?" — don't change the recommendation until they answer.

Senior architects defend recommendations with reasoning, not by capitulating. So does this skill.

## Skipping layers gracefully

The biggest failure mode of an architecture-design skill is over-engineering small projects. Apply this filter at Phase B:

- **Single-file or single-binary CLI**: only run Step 1 (CLI conventions), 7a (logging), 8.
- **Personal weekend project (1 dev, no users)**: run Step 1 only if there's a real load-bearing choice; run 8.
- **Internal tool used by < 10 people**: skip Step 7b circuit-breaker / retry beyond defaults.
- **Throwaway prototype with explicit deletion date**: skip ADRs entirely; just write 3 lines into `architecture.md` and stop.

When skipping, say so out loud with the constraint that drove the skip. The user can override.

## After this skill

Tell the user:

> Architecture pass complete. `docs/architecture.md` and N ADRs are now the project anchor. Next steps:
>
> - **Per feature work** — start with `/to-prd` to capture product intent, then `/design-like-senior` for the technical shape.
> - **Domain alignment** — if business terminology still feels fuzzy, run `/grill-with-docs` before `/to-prd`.
> - **Update mode** — re-run this skill if the project takes on a major architectural pivot.

</supporting-info>
