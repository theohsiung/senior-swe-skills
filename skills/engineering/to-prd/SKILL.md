---
name: to-prd
description: Turn the current conversation context into a product-focused PRD and publish it to the project issue tracker. Captures user intent, success criteria, and out-of-scope — NOT technical design. Use when user wants to create a PRD from the current context. For technical design (modules, interfaces, schema), run /design-like-senior after this.
---

This skill takes the current conversation context and codebase understanding and produces a **product** PRD. Do NOT interview the user — just synthesize what you already know.

**Scope:** product intent only. Module sketches, interface design, and module deepening belong in `/design-like-senior`. The PRD answers _what users need_, not _how to build it_.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-senior-swe-skills` if not.

## Inputs to read first

1. **The current conversation** — this is the primary source. The user has already told you what they want; don't re-interview.
2. **`CONTEXT.md`** — use canonical domain vocabulary in every section.
3. **`docs/adr/`** — respect documented decisions; don't propose product behaviour that contradicts them silently.
4. **`docs/agents/issue-tracker.md`** — to know which tracker to publish to and how (e.g. `gh issue create`, `glab issue create`, or a markdown file under `.scratch/`). If this file is missing (e.g. trivial personal project that skipped `/setup-senior-swe-skills`), ask the user one question: "Where should I publish this PRD — GitHub issue, local markdown, or skip publishing?" Don't auto-create a tracker.
5. **`docs/architecture.md`** (if present) — only to ground product constraints (SLAs, compliance) in what the project already promised. Do NOT pull module/interface design from here into the PRD; that's for `/design-like-senior`.

## Outputs

A single PRD published to the project's issue tracker (the location and command come from `docs/agents/issue-tracker.md`). Apply the `needs-triage` triage label so it enters the normal triage flow.

This skill does NOT write `docs/features/*/design.md`, `docs/plans/*`, or any code. Technical design is `/design-like-senior`; execution plans are `/write-plan`.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the PRD, and respect any ADRs in the area you're touching.

2. Write the PRD using the template below, then publish it to the project issue tracker. Apply the `needs-triage` triage label so it enters the normal triage flow.

<prd-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Product Constraints

Constraints that affect _what_ the feature does, not _how_. Examples:

- Compliance / regulatory requirements
- SLAs or quality attributes the user feels (latency, availability, accuracy)
- Integration points with other products (auth source, billing provider)
- Cost ceilings that limit scope
- Deadlines or release windows

Skip if no product-level constraints apply. Do **not** list modules, interfaces, schemas, or test plans here — those belong in the technical design (`/design-like-senior` → `docs/features/<slug>/design.md`).

## Acceptance Criteria

Observable, user-facing criteria that decide whether the feature is done. Each criterion must be checkable without reading code.

- [ ] Criterion 1 — what the user sees, can do, or can verify
- [ ] Criterion 2
- [ ] Criterion 3

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

</prd-template>

## Anti-patterns to refuse

These are junior moves that pollute the PRD. Catch them before publishing:

- **Technical content sneaking in** — "Add a `cancellations` table" / "Use the OrderService". If the user has to read code to understand it, it's design, not product. Move to `/design-like-senior`.
- **Vague user stories** — "As a user, I want the system to work, so that I can use it." The user's value must be specific enough that an acceptance criterion can be derived from it.
- **Untestable acceptance criteria** — "The cancellation flow is clean." Reframe as something a non-engineer can check (e.g., "After cancelling, the user sees the Order status as 'Cancelled' within 2 seconds").
- **Missing out-of-scope** — implicit edges leak into engineering as scope creep. If you're not sure what's _out_, you don't fully understand what's _in_; ask the user one question to disambiguate, then publish.
- **Re-interviewing the user** — this skill is synthesis, not grilling. If you genuinely don't have enough context, stop and recommend `/grill-with-docs` first.

## Stop conditions

- The conversation doesn't contain enough material to write a non-trivial PRD — stop and recommend `/grill-with-docs` first.
- The proposed feature contradicts an existing ADR — stop, surface the ADR, and ask the user to confirm before producing a PRD that overrides it.
- The product constraints would invalidate decisions in `docs/architecture.md` (e.g., new SLA the architecture can't meet) — stop and recommend re-running `/think-like-senior` in update mode.

## After this skill

Tell the user:

> PRD published as <tracker reference>. Next steps:
>
> - **Recommended:** run `/design-like-senior` to design the technical shape (modules, public interfaces, schema increments) anchored to `docs/architecture.md`.
> - **Tiny change with no design needed** (e.g., copy edit, label tweak): skip design and go straight to `/tdd`.
> - **Backlog now, design later:** run `/to-issues` directly off the PRD; design will be done per ticket when picked up.
