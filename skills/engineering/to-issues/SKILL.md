---
name: to-issues
description: "Break a feature into independently-grabbable backlog issues on the project issue tracker using tracer-bullet vertical slices, each declaring its blocking edges. Reads PRD, design.md, and (if present) docs/plans/ to produce ticket-level issues for human/agent pickup. Use when user wants to convert a plan into backlog tickets, create implementation issues, or break down work for asynchronous pickup. Different from /write-plan, which lists TDD cycles for immediate execution; to-issues groups adjacent cycles into hours-to-days vertical slices for the backlog. They chain: /write-plan first, then /to-issues."
---

# To Issues

Break a feature into independently-grabbable issues using vertical slices (tracer bullets). Each issue is a backlog ticket sized for hours-to-days of work.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-senior-swe-skills` if not.

## Inputs to read first

Read whichever of these exist, in this order:

1. **PRD** for this feature — usually in the issue tracker (the `/to-prd` output) or in conversation context. Source of product intent and acceptance criteria.
2. **`docs/features/<slug>/design.md`** — the technical design from `/design-like-senior`. Source of module placement, public interfaces, and schema increments. Use this for the technical content of each issue.
3. **`docs/plans/<slug>.md`** — if a master plan from `/write-plan` exists, use it as the raw task list. Group adjacent **cycles** (`T-NNN`) into **slices** instead of inventing the slicing from scratch. Record each slice's task-ID range in the issue body so `/write-plan <issue#>` can run in filter mode later. (Legacy `YYYY-MM-DD-<slug>.md` plans are also valid input — treat as the master plan.)
4. The user may also pass an issue reference (number, URL, path) as an argument — fetch its body and comments.

If only the PRD exists (no design.md, no plan), proceed but the issues will be coarser; recommend running `/design-like-senior` first.

## Outputs

A set of issues on the project's issue tracker (location and command come from `docs/agents/issue-tracker.md`), each tagged with the `needs-triage` triage label and linked together via "Blocked by" where applicable. Issues are published in dependency order so blockers exist before dependents reference them.

This skill does NOT write `docs/plans/*` (use `/write-plan` for execution plans), and does NOT modify or close any parent issue.

## Process

### 1. Gather context

Read the inputs above. Use the project's domain glossary (`CONTEXT.md`) for vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to **prefactor** the code to make the implementation easier — "make the change easy, then make the easy change." Prefactoring becomes its own slice, first in the graph.

### 2. Draft slices

Break the feature into **slices** (see [`docs/skill-contracts.md` §2](../../../docs/skill-contracts.md) — slice = hours-to-days, cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer).

When a master plan exists, group adjacent cycles (`T-NNN`) into slices. Don't reinvent the breakdown — the cycles already exist; you're choosing where to draw shipping boundaries between them.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- Each slice is sized to fit in a single fresh context window — an AFK agent picking it up cold must be able to finish it without compaction
- Any prefactoring is done first
- When a master plan exists, every cycle (`T-NNN`) belongs to exactly one slice — no orphans, no double-counts. Check this mechanically with `scripts/check-plan.sh docs/plans/<slug>.md --slices "T-001..T-004" "T-005..T-009" ...` before publishing.
</slice-rules>

Give each slice its **blocking edges**: the other slices that must complete before it can start. A slice with no blockers can start immediately. Implementers work the **frontier** — any slice whose blockers are all done.

**Wide refactors are the exception to vertical slicing.** A wide refactor is one mechanical change (rename a column, retype a shared symbol) whose blast radius fans across the codebase, so no vertical slice can land green. Sequence it as **expand–contract** instead: *expand* (add the new form beside the old so nothing breaks), then *migrate* call sites in batches sized by blast radius (per package / directory, each batch its own slice blocked by the expand, CI green throughout), then *contract* (delete the old form, blocked by every migrate batch). No compatibility shims survive the contract slice.

### 3. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### 4. Publish the issues to the issue tracker

For each approved slice, publish a new issue to the issue tracker. Use the issue body template below. Apply the `needs-triage` triage label so each issue enters the normal triage flow.

Publish issues in dependency order (blockers first) so you can reference real issue identifiers in the "Blocked by" field. How depends on the tracker in `docs/agents/issue-tracker.md`:

- **Real tracker (GitHub, GitLab, Linear, …)** — one issue per slice. Use the platform's **native blocking relationship** where it has one (and then omit the `## Blocked by` section); otherwise fill it in. If the source was an existing issue, make each slice its **sub-issue** using the tracker doc's operation.
- **Local files** — one file per slice under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order. Never one combined file.

<issue-template>
## Parent

A reference to the parent issue on the issue tracker (if the source was an existing issue, otherwise omit this section).

## Design context

- **Design doc:** `docs/features/<slug>/design.md` (the section relevant to this slice)
- **PRD:** [link to PRD issue, if separate from the parent]
- **ADRs in scope:** [list any ADRs the implementer must respect]

## Plan tasks

- **Master plan:** `docs/plans/<slug>.md`
- **This slice covers:** `T-NNN .. T-NNN` (or comma-separated list `T-NNN, T-NNN, T-NNN`)

If no master plan exists yet, write "Master plan: not yet — run `/write-plan` first when picking this up". The implementer authors the plan, then updates this section.

Together these two sections let a future implementer (human or AFK agent) bootstrap full context: design.md for the shape, master plan + task-ID range for the cycles to execute. `/write-plan <issue#>` reads the latter and runs in filter mode.

## What to build

A concise description of this slice. Describe the end-to-end behavior, not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

Each criterion must be checkable through observable behaviour, at evidence level 4 or 5 (see [`docs/skill-contracts.md` §8](../../../docs/skill-contracts.md)) — "the CLI prints X", "the endpoint returns 409", not "the code handles X".

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers. Omit this section when blockers were set as native edges.

</issue-template>

Do NOT close or modify any parent issue.

Avoid specific code snippets in issue bodies — they go stale fast; the master plan and `design.md` carry the technical detail. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose (state machine, schema, type shape), inline the decision-rich part and note it came from a prototype.

## Anti-patterns to refuse

These are the junior moves to catch and rewrite during the quiz step:

- **Horizontal slice** — "implement the schema migration" / "build the API endpoint" / "wire up the UI" as separate issues. None of them ship value alone. Refactor into vertical slices that each cut through all layers end-to-end.
- **Implementation-flavoured title** — "Add `cancelOrder` method to OrderService". The title should describe what a user can _do_ when the slice merges, not which function gets added. Reframe as "User can cancel a confirmed Order".
- **Unbounded slice** — "Build the whole reporting dashboard". If acceptance criteria can't be listed in 3–5 bullets, it's still a feature, not a slice. Split.
- **All-blocked-on-one** — slice graph that looks like `1 → 2,3,4,5,6` with nothing parallelisable. The slicing isn't doing its job; rework the breakdown so 2+ slices can start in parallel after slice 1.
- **Acceptance criteria that test implementation** — "the `cancel_order` function returns `OrderCancelledEvent`". Acceptance criteria must be checkable through observable behaviour by someone who can't read code.
- **Bundling unrelated changes** — "Cancel order + refund payment + email customer" as one slice. If they could ship independently, they should be separate slices linked by `Blocked by`.

## Stop conditions

Stop and surface the problem instead of producing issues, when:

- The PRD is missing acceptance criteria (you'll invent them, and they'll be wrong) — send the user back to `/to-prd`.
- The design is missing such that a slice can't be sized without making technical decisions — send the user to `/design-like-senior`.
- A proposed slice can only be verified by inspecting internal state — that's a depth/leverage problem in the design, not a slice problem; send to `/design-like-senior`.

## After this skill

Tell the user:

> N issues published to <tracker>, each tagged `needs-triage`, linked via blocking edges (native where the tracker supports them), and (when a master plan exists) carrying a `## Plan tasks` reference to the master plan + `T-NNN` range. Next steps:
>
> - **When you (or someone else) picks up an issue** — run `/write-plan <issue#>` (it runs in **filter mode** when the issue references a master plan: it reads the master, prints only this slice's cycles, never writes a divergent plan), then `/tdd` to execute.
> - **To manage the backlog** — use `/triage` for state transitions (`needs-triage` → `ready-for-agent` / `ready-for-human` / `wontfix`).
> - **If you discover gaps in the design while breaking things down** — re-run `/design-like-senior` for the affected feature. New cycles are appended to the master plan with fresh IDs (never renumber); existing slice references stay valid.
