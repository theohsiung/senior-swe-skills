---
name: grill-with-docs
description: Domain-first grilling session — stress-test a plan against the project's domain language and documented decisions, sharpening terminology and updating CONTEXT.md/ADRs inline. Run before /to-prd or /design-like-senior whenever new domain concepts emerge or existing terminology gets fuzzy. Focus is business/domain language and load-bearing decisions, not technical module design — for module/interface design use /design-like-senior.
---

<what-to-do>

Interview me relentlessly about every aspect of this plan **at the domain level** until we reach a shared understanding of the business concepts and their relationships. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

**Scope guardrail:** focus on domain meaning (what an "Order" is, when it gets "cancelled", what "tenant" means here). Stop at terminology and load-bearing domain decisions — module placement, interface design, and schema details belong in `/design-like-senior`.

</what-to-do>

<supporting-info>

## Inputs to read first

1. **`CONTEXT.md`** (or `CONTEXT-MAP.md` + per-context files) — the canonical glossary. If it exists, every term you propose must reconcile with it. If it doesn't, you'll create it lazily as the first term resolves.
2. **`docs/adr/*.md`** — past load-bearing decisions. Don't re-litigate them without surfacing the existing ADR first.
3. **The codebase** — when a domain claim can be answered by reading code (e.g., "are Orders cancelled atomically?"), read code instead of asking.

## Outputs

Created lazily — only when there's something to write:

- **`CONTEXT.md`** updates: one entry per resolved term. Use [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md). Append in place; don't batch at the end.
- **`docs/adr/NNNN-*.md`**: one ADR per load-bearing _domain_ decision that passes the triple test (hard to reverse, surprising without context, real trade-off). Use [ADR-FORMAT.md](./ADR-FORMAT.md).

This skill does NOT write to `docs/architecture.md`, `docs/features/*/design.md`, or `docs/plans/*` — those belong to `/think-like-senior`, `/design-like-senior`, and `/write-plan` respectively.

## Domain awareness

During codebase exploration, also look for existing documentation:

### File structure

Most repos have a single context:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has multiple contexts. The map points to where each one lives:

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

Create files lazily — only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved. If no `docs/adr/` exists, create it when the first ADR is needed.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch these up — capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

Don't couple `CONTEXT.md` to implementation details. Only include terms that are meaningful to domain experts.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).

## After this skill

Once alignment is reached, tell the user:

> CONTEXT.md and ADRs updated. The vocabulary is now stable enough to continue with whatever brought us here:
>
> - If we were aligning before writing a PRD → run `/to-prd`.
> - If we were aligning before technical design → run `/design-like-senior`.
> - If we were aligning during a refactor → resume `/improve-codebase-architecture`.

This skill doesn't pick the next step on its own — what comes next depends on the original intent.

</supporting-info>
