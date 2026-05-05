---
name: improve-codebase-architecture
description: Find deepening opportunities in EXISTING code, informed by the domain language in CONTEXT.md and the decisions in docs/adr/. Use when the user wants to improve architecture, find refactoring opportunities, consolidate tightly-coupled modules, or make a codebase more testable and AI-navigable. **Different from /design-like-senior**: this skill operates on code that already exists (refactor); /design-like-senior shapes a new feature's modules before any code is written (forward design). Run periodically as the codebase grows.
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point — don't drift into "component," "service," "API," or "boundary." Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Module** — anything with an interface and an implementation (function, class, package, slice).
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** — where an interface lives; a place behaviour can be altered without editing in place. (Use this, not "boundary.")
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth: change, bugs, knowledge concentrated in one place.

Key principles (see [LANGUAGE.md](LANGUAGE.md) for the full list):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is _informed_ by the project's domain model. The domain language gives names to good seams; ADRs record decisions the skill should not re-litigate.

## Inputs to read first

1. **`CONTEXT.md`** — for domain vocabulary. Every deepening suggestion must name modules using these terms (e.g. "the Order intake module"), not generic ones ("the FooBarHandler").
2. **`docs/adr/`** — surface existing decisions before suggesting refactors that contradict them. If a candidate refactor reopens an ADR, mark it explicitly.
3. **`docs/architecture.md`** (if present) — the project-level shape. Don't suggest deepening that conflicts with the documented system architecture without flagging it.
4. **The codebase, area by area** — use the Explore agent. Don't apply rigid heuristics; explore organically.

## Outputs

Created only when the user accepts a recommendation:

- **`CONTEXT.md`** updates — when a deepened module needs a name not yet in the glossary, add it (same discipline as `/grill-with-docs`).
- **`docs/adr/NNNN-*.md`** — when the user rejects a candidate with a load-bearing reason that future explorers will need to avoid re-suggesting the same thing.

This skill does NOT itself perform refactors or write code. It surfaces opportunities and discusses them; the actual refactor goes through `/tdd` (or directly, with the user's preferred discipline) afterwards.

## Process

### 1. Explore

Read the project's domain glossary and any ADRs in the area you're touching first.

Then use the Agent tool with `subagent_type=Explore` to walk the codebase. Don't follow rigid heuristics — explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Present candidates

Present a numbered list of deepening opportunities. For each candidate:

- **Files** — which files/modules are involved
- **Problem** — why the current architecture is causing friction
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage, and also in how tests would improve

**Use CONTEXT.md vocabulary for the domain, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture.** If `CONTEXT.md` defines "Order," talk about "the Order intake module" — not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly (e.g. _"contradicts ADR-0007 — but worth reopening because…"_). Don't list every theoretical refactor an ADR forbids.

Do NOT propose interfaces yet. Ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, drop into a grilling conversation. Walk the design tree with them — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

Side effects happen inline as decisions crystallize:

- **Naming a deepened module after a concept not in `CONTEXT.md`?** Add the term to `CONTEXT.md` — same discipline as `/grill-with-docs` (see [CONTEXT-FORMAT.md](../grill-with-docs/CONTEXT-FORMAT.md)). Create the file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update `CONTEXT.md` right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing — skip ephemeral reasons ("not worth it right now") and self-evident ones. See [ADR-FORMAT.md](../grill-with-docs/ADR-FORMAT.md).
- **Want to explore alternative interfaces for the deepened module?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md).

## After this skill

Once the user accepts a deepening recommendation, tell them:

> Recommendation accepted (CONTEXT.md / ADR updated as needed). Before refactoring, decide where the safety net lives — deepening changes module-public interfaces by definition, so any existing tests at that level **will** break with it and aren't a real safety net.
>
> Pick one of:
>
> - **Tests already exist at a higher seam** (system-public — HTTP, CLI, end-to-end — see [`docs/skill-contracts.md` §3](../../../docs/skill-contracts.md)) — those survive the refactor. Run `/tdd` self-directed mode against the affected modules; existing system-public tests are the safety net.
> - **Tests only exist at module-public** — first **lift** the safety net up: write characterization tests at the system-public level (run `/tdd` self-directed to author them), confirm green, *then* perform the deepening. The module-public tests will break during the deepening; that's expected and correct.
> - **Behavior is genuinely untested** — write characterization tests at the system-public level first (run `/tdd`), then deepen.
> - **Refactor is project-level (system shape change)** — stop and re-run `/think-like-senior` in update mode; this is bigger than a deepening pass.
