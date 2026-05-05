---
name: write-plan
description: Turn a feature design into a behavior-driven TDD plan that /tdd executes one cycle at a time. Run after /design-like-senior, before /tdd. Produces docs/plans/YYYY-MM-DD-<feature-slug>.md — a list of behaviors to test, public interfaces to introduce, and anti-patterns to refuse. Does NOT contain pre-written test code (that's the bulk-writing anti-pattern /tdd refuses). Different from /to-issues — write-plan operates at TDD-cycle granularity for immediate execution; /to-issues operates at vertical-slice granularity for backlog tickets. They can chain: /write-plan first to get the behavior list, then /to-issues to group adjacent behaviors into shippable slices.
---

# Write Plan

Turn a feature design into a **behavior-driven** TDD plan. The plan tells `/tdd` _what to test_ and _what interfaces to build_, but not _how to write the tests_ — that's deliberate.

**Announce at start:** "I'm using the write-plan skill to create the behavior-driven implementation plan."

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

### Resolving the slug when invoked from an issue

If the user invokes this skill against an issue (e.g. "write a plan for #42") and you don't know the feature slug:

1. Fetch the issue body (it should reference the PRD and the design.md).
2. Look for an explicit `docs/features/<slug>/design.md` reference in the issue body.
3. If absent, list `docs/features/*/design.md` and ask the user which feature this issue belongs to. Don't guess.
4. If no design.md exists for the issue, send the user back to `/design-like-senior` first.

## Output

Save to `docs/plans/YYYY-MM-DD-<feature-slug>.md`.

## Plan header

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** Use /tdd to execute this plan. Each task is one RED→GREEN cycle. Derive the test code at execution time from the behavior description — do NOT copy or pre-write test code into this plan.

**Goal:** [One sentence describing the user-visible outcome]
**Design doc:** `docs/features/<slug>/design.md`
**Architecture context:** [2-3 sentences pulled from architecture.md]
**Tech stack:** [Test runner, primary language, key libraries]

---
```

## Task structure

Each task = one RED→GREEN cycle that an engineer would commit as one logical change (typically 5–15 minutes including the cycle, not just the test):

```markdown
### Task N: [User-visible behavior, one sentence]

**Behavior to verify**
A user can [observable thing], so that [outcome]. (Frame in the user's voice or
the caller's voice. Avoid framing in terms of internal collaborators or function calls.)

**Public interface this task introduces**
- New: `<module>.<function-or-method>(<params>) -> <return>` — [one-line purpose, copied from design.md]
- Modified: `<existing function>` — [what changes]

**Files**
- Create: `path/to/file.<ext>`
- Modify: `path/to/existing.<ext>`
- Test: `tests/path/test_file.<ext>`

**Test framing hints (NOT test code)**
- Use the project's domain glossary: refer to "<term-from-CONTEXT.md>", not generic synonyms.
- The test must drive the system through the public interface defined above.
- Do NOT mock internal collaborators (see tdd/mocking.md). Mock only at process boundaries (HTTP, DB, clock, filesystem) when needed.
- Do NOT verify by querying state behind the interface (e.g., DB queries to check writes). Verify through a paired read interface, or accept that this behavior is not testable through the public surface and flag it in design.md.

**Anti-patterns to refuse**
- "calls X.process" / "saves to database" / "returns object with field Y" — these describe HOW, not WHAT. Reframe before writing.

**Definition of done**
- One failing test that exercises the behavior through the public interface (RED)
- Minimal implementation that passes (GREEN)
- Test would survive an internal refactor that preserves the behavior
- Commit message: `feat: [behavior description]`
```

## Granularity rules

Each of these is one task:
- **One observable user-visible behavior**, end-to-end through the public interface
- **One schema increment** (one table or one migration), with the test that proves a write is retrievable through the read path
- **One new external dependency integration**, with the test that exercises it via the boundary mock + the resilience policy from architecture.md

If a "task" needs more than one new public-interface entry to be testable, split. If a task can't be tested through any public interface (only through internal state inspection), STOP and revise the design — that's a depth/leverage failure, not a plan failure. Send the user back to `/design-like-senior`.

## Review gate before saving

Show the user the **behavior list only** (task titles, no detail) first:

```
1. <Behavior>
2. <Behavior>
...
```

For each title, ask "is this user-visible? Is this stated as WHAT not HOW?" Walk the list once with the user, fixing any title that smells like implementation. Then expand into the full plan and save.

## Anti-patterns this skill refuses

- Writing test code into the plan (defeats the point — see philosophy section above)
- Including helper-function or private-method tasks (they emerge from `/tdd`'s refactor step)
- Tasks framed as "implement function X" — should be "user can observe Y"
- Skipping the review gate to save time (the gate catches imagined-behavior tasks before they pollute execution)

## After this skill

Tell the user:

> Plan saved to `docs/plans/<filename>.md` (N tasks). Next steps:
>
> - **Execute now:** run `/tdd` — it will read the plan and derive the test for each cycle from the behavior description (the plan itself contains no test code, by design).
> - **Build a backlog from this plan:** run `/to-issues` — it will group adjacent behaviors into vertical-slice tickets.
