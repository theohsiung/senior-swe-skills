---
name: design-like-senior
description: Per-feature design pass that runs between `/to-prd` (which produces the feature's PRD) and `/to-issues` (which splits it into vertical slices). Walks application architecture (where the feature plugs in), module boundaries (Ousterhout deep modules), and public-interface design (signatures, not implementations) — anchoring every recommendation to the project's `docs/architecture.md` and ADRs from `/think-like-senior`. Use proactively whenever the user has a PRD or issue and is asking "where does this go", "what should the API look like", "should this be a new module", "how do I structure this feature", "what files do I create", or describing the work as "feature design", "tech design doc", "design review before coding". Run once per feature before `/to-issues`. Does NOT make project-level decisions (those are `/think-like-senior`) and does NOT design class internals (those emerge from `/tdd`'s refactor step).
---

<what-to-do>

For one feature, walk application architecture, module boundaries, and public-interface design. Anchor every recommendation to the project's `docs/architecture.md` and ADRs — don't re-decide what was decided at project level.

Stop at interfaces. Class internals (private methods, control flow, state machines inside a class) are TDD's job, not yours. Over-specifying internals here freezes the design before red-green-refactor has any say.

Ask one question at a time. When a layer doesn't apply (e.g., a typo fix doesn't need application architecture), say so and skip — over-designing small features is a junior move.

If the feature seems to require revising the project-level architecture (new datastore, new tenancy model, new system shape), STOP and tell the user to re-run `/think-like-senior` first. Don't quietly contradict the architecture.md.

</what-to-do>

<supporting-info>

## Inputs to read first

Before doing anything else, read whichever of these exist:

1. **`docs/architecture.md`** — the project-level snapshot from `/think-like-senior`. Extract the decisions that constrain this feature: tenancy model, system shape (modular monolith / etc.), primary store, module list, observability stack, code style. If this file doesn't exist, recommend running `/think-like-senior` first; ask the user whether to proceed without it (the design will be ungrounded).
2. **`docs/adr/*.md`** — the ADRs from `/think-like-senior`. Skim titles; read the bodies of any whose subject matter overlaps the feature.
3. **The PRD for this feature** — usually at `docs/prd/<feature>.md` or as the most recent `/to-prd` output in the conversation. Extract: feature scope, success criteria, explicit out-of-scope list.
4. **`CONTEXT.md`** (or `CONTEXT-MAP.md` + per-context files) — the domain language. Use the canonical terms; don't invent new ones.

If multiple bounded contexts exist (`CONTEXT-MAP.md`), figure out which context this feature lives in. If unclear, ask before continuing.

## Output artifacts

Create lazily — only when there's something to write:

- **`docs/features/<feature-slug>/design.md`** — the design snapshot for this feature: which architectural decisions apply, the per-layer walk-through, public interfaces, schema increments, feature-level failure modes.
- **Increment ADR(s)** at `docs/adr/NNNN-*.md` only when this feature introduces a load-bearing decision that wasn't in `/think-like-senior`'s output and that passes the same triple test (hard to reverse, surprising without context, real trade-off).
- **`CONTEXT.md` updates** when a new domain term emerges. Use the format in `../grill-with-docs/CONTEXT-FORMAT.md`. Don't bloat CONTEXT.md with feature-local jargon.

Do NOT generate skeleton code, empty interface stubs, or folder scaffolding. The design document defines the *shape*; `/tdd` evolves the *implementation*. Producing both here is over-prescription.

## Scope split with `/think-like-senior` and `/tdd`

| Step | Layer | This skill | Other |
|---|---|---|---|
| 0 | Constraints | inherited from architecture.md | `/think-like-senior` owns |
| 1 | Load-bearing decisions | inherited from ADRs | `/think-like-senior` owns |
| 2 | System architecture | inherited | `/think-like-senior` owns |
| 3a | Data model patterns (project-level) | inherited | `/think-like-senior` owns |
| 3b | Domain entities | defer to `/grill-with-docs` | `/grill-with-docs` |
| **3'** | **Schema increments for this feature** | ✅ | — |
| **4** | **Application architecture (where this feature plugs in)** | ✅ | — |
| **5** | **Module / package design** | ✅ | — |
| **6** | **Public class / function interfaces** | ✅ | — |
| 6-internal | Class internals, control flow, helpers | — | `/tdd` (red-green-refactor) |
| 7a | Observability stack | inherited | `/think-like-senior` owns |
| **7'** | **Feature-level failure modes** | ✅ | — |
| 8 | Code style | inherited | `/think-like-senior` owns |

If a question is project-level (tenancy, datastore, system shape), redirect to `/think-like-senior`. If it's about implementation details inside a class, redirect to `/tdd`.

## The three phases

### Phase A — Read context, no grilling

Read the inputs listed above. Capture in `design.md` under a "Project context" section:

- The architecture decisions most relevant to this feature (1–3 bullets, not a copy-paste of architecture.md)
- The ADRs directly constraining this feature
- The feature scope from the PRD, distilled to one paragraph

If anything is missing or contradictory between architecture.md and the PRD, surface it now — don't paper over it.

### Phase B — Pick which feature-design layers matter

Apply this filter:

| Feature shape | Layers that usually apply |
|---|---|
| New end-to-end capability (new entity, new screen, new API) | 3', 4, 5, 6, 7' (full set) |
| Extension of existing module (new endpoint, new field) | 3' (sometimes), 6 (interface change), maybe 5 |
| Cross-cutting concern (auth on existing endpoints, new audit field) | 4 (placement), 6 |
| Visible-only change (copy edit, UI tweak with no backend) | 6 (component prop signature), and that's it |
| Bug fix that's truly local | None — go straight to `/tdd` |

Tell the user the proposed layer list, anchored to the feature's shape from the PRD. Let them adjust.

### Phase C — Walk each layer in scope

For each layer kept, output a recommendation using [`../think-like-senior/RECOMMENDATION-TEMPLATE.md`](../think-like-senior/RECOMMENDATION-TEMPLATE.md). The same five sections apply: Recommendation, Driven by, Considered & rejected, What would change my mind, Push back. Anchor "Driven by" to the architecture.md decisions and PRD constraints — not to "best practice".

## Layer-by-layer

### Step 4 — Application architecture (where this feature plugs in)

Three questions:

1. **Which existing module(s) does this feature belong to?** Check the module list in architecture.md. Force a single primary owner; cross-module features need an explicit owner module that orchestrates.
2. **Does the feature respect the existing dependency direction?** If architecture.md says `billing → identity` (billing depends on identity, not the reverse), and the feature wants `identity → billing`, that's an architecture violation — surface it.
3. **Does the feature need a new module?** Only if no existing module is a sensible fit and the feature has its own bounded domain. Adding modules is cheap, but each new module is a new public surface to maintain.

Output: a one-paragraph placement statement and (if introducing a new module) a one-paragraph charter for it.

### Step 5 — Module / package design

For the owning module(s), apply Ousterhout's "deep modules":

- **Public surface should be narrow** — one or two functions / types other modules call. If you're exposing five entry points for one feature, the module is too shallow.
- **Implementation may be thick** — depth (functions doing real work behind a small API) is a virtue, not a problem.
- **No leaking internals** — other modules don't import internal types, transactions, or DB models. They get the public surface and that's it.

Output: a list of the public additions to the owning module's surface (function signatures, exported types). For each addition, a one-line note on why it's at the public surface vs internal.

### Step 6 — Public class / function interfaces

Design the *signatures* of the public functions and the *shapes* of the types crossing module boundaries. Stop at signatures.

Capture for each public function:

- Signature (parameters + return type)
- Pre-conditions / invariants the caller must respect
- Post-conditions / what it guarantees
- Error modes (what it throws / returns on failure)

Capture for each public type:

- Field list with types
- Invariants enforced by the type's constructor (if any)
- Mutation semantics (immutable / mutable / how)

**Do NOT design**: the function body, the algorithm choice, helper functions, control flow, internal class hierarchies. Those emerge during `/tdd` and are evaluated by the red-green-refactor loop, not by design-doc review.

### Step 3' — Schema increments

Only if this feature touches the schema. Capture:

- New tables, with column list + types + indexes
- New columns added to existing tables (with default + nullability + migration plan)
- Foreign keys (and their ON DELETE behaviour)
- Whether row-level `tenant_id` is honoured (if architecture.md chose pooled multitenancy)
- Whether the change is forward-only or requires expand-then-contract migration

If the feature would require denormalising in a way that fights the project's data model patterns (Step 3a in architecture.md), surface the conflict — don't quietly diverge.

### Step 7' — Feature-level failure modes

Only if this feature introduces a new external dependency or significantly changes one. Capture:

- New external services this feature calls (with the existing resilience defaults from architecture.md applied)
- Override discussion if the defaults don't fit (e.g., this feature's outbound is money-handling, so 0 retries + idempotency)
- What happens to user-visible behaviour when the dependency is down? (Hard fail / graceful degradation / queue and retry?)
- Idempotency strategy for state-changing calls

If no new dependencies and the feature inherits the project defaults silently — write one line in design.md and move on.

## When a feature requires revising the project-level architecture

This is the most important "stop" rule for this skill.

If walking the feature surfaces that the project-level architecture is wrong for this work — for example:
- The feature genuinely needs a different datastore than architecture.md picked
- The feature breaks the dependency direction in a way that can't be fixed by re-placing it
- The feature's scale assumptions are 10× higher than architecture.md's Phase A captured
- The feature requires compliance scope that architecture.md didn't account for

**Stop.** Don't quietly revise the architecture inside a feature design doc. The project-level skill exists for a reason.

The right move: tell the user, name the specific architecture decision that's wrong, and recommend re-running `/think-like-senior` (in update mode if architecture.md already exists). Then come back to this feature.

## When to file an ADR

Same triple test as `/grill-with-docs` and `/think-like-senior`. All three must be true:

1. Hard to reverse — the cost of changing your mind later is meaningful
2. Surprising without context — a future reader will wonder why
3. The result of a real trade-off — there were genuine alternatives

For this skill specifically, candidates that often pass:

- A new module's charter (its responsibility and what it explicitly does NOT own)
- An interface choice with a non-obvious shape (e.g., async + outbox where one would expect sync)
- A schema decision that materially constrains future features (e.g., partition key choice on a new table)
- A feature-level deviation from project-level resilience defaults

Do NOT file ADRs for routine interface design, naming choices, or "we picked the obvious approach". Save ADRs for the decisions that future-you will thank present-you for documenting.

## Pushback discipline

When the user pushes back on a recommendation, the same rules as `/think-like-senior` apply:

- New constraint or fact → update Phase A's "Project context" section, then re-recommend
- Different mapping of an existing constraint → engage on the merits
- Vibes only → ask "Which architectural decision or PRD requirement would have to be different for me to recommend that?" — don't capitulate without an answer

Senior architects defend feature designs against vibes-based pushback. So does this skill.

## Skipping layers gracefully

The biggest failure mode of a feature-design skill is over-engineering small features.

- **Tiny feature (typo fix, label change, copy edit)** — skip everything except a one-line note in `design.md`. Optionally skip `design.md` entirely if `/tdd` can take the PRD directly.
- **Pure UI polish (spacing, color, motion)** — out of scope; this skill doesn't design pixels. Send to a frontend-design skill.
- **Feature that's "just like X but for Y"** — read X's existing design doc, write a one-section diff doc, don't repeat the full pattern.
- **Bug fix where the fix is local** — out of scope; go straight to `/diagnose` then `/tdd`.

When skipping, say so out loud with the constraint that drove the skip. The user can override.

</supporting-info>
