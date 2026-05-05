---
name: write-plan
description: Turn a feature design into a behavior-driven TDD plan that /tdd executes one cycle at a time. Run after /design-like-senior, before /tdd. Produces docs/plans/<feature-slug>.md — a master plan listing cycles to test (with stable T-NNN IDs), public interfaces to introduce, and anti-patterns to refuse. Does NOT contain pre-written test code (that's the bulk-writing anti-pattern /tdd refuses). When invoked against an issue (e.g. "write a plan for #42"), runs in **filter mode** — reads the master plan and prints only the cycles the issue references; never regenerates a divergent plan. Different from /to-issues which groups adjacent cycles into hours-to-days vertical slices for the backlog. The two chain: /write-plan first to expose the cycle list, then /to-issues to group them into shippable slices.
---

# Write Plan

Turn a feature design into a **behavior-driven** TDD plan. The plan tells `/tdd` _what to test_ and _what interfaces to build_, but not _how to write the tests_ — that's deliberate.

**Announce at start:** "I'm using the write-plan skill to create the behavior-driven implementation plan." (Or, in filter mode: "…to filter the master plan for issue #N.")

This skill operates in two modes:

- **Author mode** — given a feature slug (or invoked from `/design-like-senior`'s handoff), produce the master plan at `docs/plans/<feature-slug>.md`.
- **Filter mode** — given an issue reference, read the master plan and print only the cycles the issue covers. **Never write a second plan file.** See [Filter mode](#filter-mode) below.

This skill follows the cross-skill agreements in [`docs/skill-contracts.md`](../../../docs/skill-contracts.md): three granularities (feature / slice / cycle — see §2), public-interface levels (system-public vs module-public — see §3), master plan with stable task IDs (see §5).

## Why behavior-driven, not test-driven-by-bulk

The temptation is to pre-write all the test code in the plan and let `/tdd` run mechanically. Don't. From the `/tdd` skill:

> "Tests written in bulk test _imagined_ behavior, not _actual_ behavior. You outrun your headlights, committing to test structure before understanding the implementation."

Pre-writing test code in a plan IS bulk-writing — even if execution happens one task at a time. This skill produces a **behavior list with public interfaces and anti-pattern reminders**. The actual test code is written by `/tdd` at execution time, when the agent can see the just-passed code from the previous cycle.

See [BEHAVIOR-FORMAT.md](./BEHAVIOR-FORMAT.md) for what good behavior descriptions look like (and what anti-patterns to flag).

## Inputs to read first

1. **`docs/features/<slug>/design.md`** — public interfaces, module placement, schema increments, failure modes from `/design-like-senior`. Required. If missing, stop and recommend `/design-like-senior` first.
2. **`docs/architecture.md`** — tech stack, code style, module list, observability, resilience defaults from `/think-like-senior`. Read for implementation context. **If missing** (trivial project that skipped `/think-like-senior`), proceed but: (a) note this in the plan header, (b) infer tech stack from the codebase (package manifest + test runner config), and (c) keep tasks minimal — no resilience/observability tasks unless the user asks.
3. **`CONTEXT.md`** — domain vocabulary. Use canonical terms in every behavior description. If missing, fall back to the vocabulary already used in the design.md or PRD; don't invent new terms.
4. **`skills/engineering/tdd/tests.md` and `mocking.md`** (if present in the consumer repo's skill bundle) — Matt's reference for what behavior-driven tests look like. Use these examples as the standard for "good behavior" framing.

### Resolving the slug when invoked from an issue → switches to filter mode

If the user invokes this skill against an issue (e.g. "write a plan for #42") and you don't know the feature slug:

1. Fetch the issue body. Look for the `## Plan tasks` section (written by `/to-issues`):
   ```
   ## Plan tasks
   - master plan: docs/plans/<slug>.md
   - this slice covers: T-004 .. T-008
   ```
2. If that section exists → switch to **filter mode** (jump to [Filter mode](#filter-mode) below). Do not regenerate the plan.
3. If the issue references a `docs/features/<slug>/design.md` but no master plan exists yet → run **author mode** for that feature, then suggest the user re-run `/to-issues` so the new task IDs get linked to issues.
4. If neither plan nor design exists → send the user back to `/design-like-senior` first.

## Output (author mode)

Save to `docs/plans/<feature-slug>.md` (no date prefix — slugs are stable, dates added churn for nothing). If a legacy `YYYY-MM-DD-<slug>.md` plan exists, treat it as the master plan and migrate by renaming on the next write.

## Plan header

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** Use /tdd to execute this plan. Each task is one RED→GREEN cycle with a stable ID (`T-NNN`). Derive the test code at execution time from the behavior description — do NOT copy or pre-write test code into this plan.

**Goal:** [One sentence describing the user-visible outcome]
**Design doc:** `docs/features/<slug>/design.md`
**Architecture context:** [2-3 sentences pulled from architecture.md]
**Tech stack:** [Test runner, primary language, key libraries]
**Task IDs:** assigned in creation order, never reused. Withdrawn tasks marked `~~T-NNN~~ Withdrawn`.

---
```

## Task structure

Each task = one **cycle** (one RED→GREEN pass on a single behavior — see [`docs/skill-contracts.md` §2](../../../docs/skill-contracts.md)). One logical change, one commit. Don't put a time bound on it; a cycle that includes a schema migration and its read interface is still one cycle, just a longer one.

Tasks have **stable IDs** (`T-001`, `T-002`, …) assigned in creation order. IDs are **never reused**: if a task is removed, mark it `~~T-NNN~~ Withdrawn` rather than deleting, so existing slice references in issues don't dangle. See [`docs/skill-contracts.md` §5](../../../docs/skill-contracts.md).

```markdown
### T-NNN: [User-visible behavior, one sentence]

**Behavior to verify**
A user can [observable thing], so that [outcome]. (Frame in the user's voice or
the caller's voice. Avoid framing in terms of internal collaborators or function calls.)

**Public interface this task introduces**
- Level: system-public | module-public  (see skill-contracts.md §3 — default system-public)
- New: `<entry-point>(<params>) -> <return>` — [one-line purpose, copied from design.md]
- Modified: `<existing entry point>` — [what changes]

**Files**
- Create: `path/to/file.<ext>`
- Modify: `path/to/existing.<ext>`
- Test: `tests/path/test_file.<ext>`

**Test framing hints (NOT test code)**
- Use the project's domain glossary: refer to "<term-from-CONTEXT.md>", not generic synonyms.
- The test must drive the system at the **level** declared above. If system-public, the test exercises the HTTP/CLI/event entry point, not an internal class.
- Do NOT mock internal collaborators (see tdd/mocking.md). Mock only at process boundaries (HTTP, DB, clock, filesystem) when needed.
- Do NOT verify by querying state behind the interface (e.g., DB queries to check writes). Verify through a paired read interface, or accept that this behavior is not testable through the public surface and flag it in design.md.

**Anti-patterns to refuse**
- "calls X.process" / "saves to database" / "returns object with field Y" — these describe HOW, not WHAT. Reframe before writing.

**Definition of done**
- One failing test that exercises the behavior through the declared public interface level (RED)
- Minimal implementation that passes (GREEN)
- Test would survive an internal refactor that preserves the behavior
- Commit message: `feat: [behavior description]`
```

## Granularity rules

Each of these is one cycle (= one task):
- **One observable user-visible behavior**, end-to-end through the declared public-interface level
- **One schema increment** (one table or one migration), with the test that proves a write is retrievable through the read path
- **One new external dependency integration**, with the test that exercises it via the boundary mock + the resilience policy from architecture.md

If a cycle needs more than one new public-interface entry to be testable, split. If a cycle can't be tested through any public interface (only through internal state inspection), STOP and revise the design — that's a depth/leverage failure, not a plan failure. Send the user back to `/design-like-senior`.

## Review gate before saving

Show the user the **behavior list only** (task IDs + titles, no detail) first:

```
T-001 <Behavior>
T-002 <Behavior>
...
```

For each title, ask "is this user-visible? Is this stated as WHAT not HOW?" Walk the list once with the user, fixing any title that smells like implementation. Then expand into the full plan and save.

## Filter mode

Triggered when the user invokes `/write-plan <issue#>` and the issue body contains a `## Plan tasks` block referencing a master plan.

1. Read the issue's `## Plan tasks` section. Extract the master plan path and the task ID range (`T-004 .. T-008`) or list (`T-004, T-006, T-009`).
2. Read the master plan at the referenced path.
3. Print **only** the matching tasks (full task body, IDs preserved). Print the plan header above them so `/tdd` has the goal and design context.
4. **Do not write a new plan file.** The master plan is the single source of truth.
5. If the implementer discovers a missing cycle while working the slice, append a new task to the master plan (with a fresh ID — never renumber) and ask whether to update the issue's "covers" range.

If the master plan is missing the referenced IDs (drift), surface it: "Issue #42 references T-006, but the master plan stops at T-005 — has someone removed it? Should I append it?" Don't silently invent.

## Anti-patterns this skill refuses

- Writing test code into the plan (defeats the point — see philosophy section above)
- Including helper-function or private-method tasks (they emerge from `/tdd`'s refactor step)
- Tasks framed as "implement function X" — should be "user can observe Y"
- Skipping the review gate to save time (the gate catches imagined-behavior tasks before they pollute execution)

## After this skill

**Author mode:**

> Master plan saved to `docs/plans/<slug>.md` (N tasks: T-001..T-NNN). Next steps:
>
> - **Execute now:** run `/tdd` — it will read the master plan and derive the test for each cycle from the behavior description.
> - **Build a backlog from this plan:** run `/to-issues` — it will group adjacent cycles into shippable slices, each issue referencing its `T-NNN` range so the plan stays the single source of truth.

**Filter mode:**

> Filtered cycles for issue #N (T-XXX..T-YYY) above. Run `/tdd` to execute them — the master plan at `docs/plans/<slug>.md` remains the canonical task list.
