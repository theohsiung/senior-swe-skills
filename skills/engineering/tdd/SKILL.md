---
name: tdd
description: Execute test-first development cycle by cycle. In plan-mode, read a behavior plan from /write-plan and derive the test for each cycle at execution time (the plan describes WHAT to test, not the test code itself — pre-writing tests is the bulk-writing anti-pattern). In self-directed mode, plan as you go. Tests verify behavior through public interfaces; never internal collaborators. Use when user wants to build features or fix bugs test-first, mentions red-green-refactor, or asks for behavior-driven tests.
---

# Test-Driven Development

**Announce at start:** "I'm using the tdd skill to [execute the plan / build this feature test-first]."

## Workflow

### 1. Load plan (or fall back)

Look for the master plan in `docs/plans/<slug>.md` matching this feature. (Legacy `YYYY-MM-DD-<slug>.md` plans are also valid.)

**If invoked from an issue with a `## Plan tasks` section:**
- Run `/write-plan <issue#>` first to filter the master plan to this slice's `T-NNN` range. Use the filtered output as the task list.

**If a master plan exists (no issue scope):**
- Read it critically — does it match the current codebase state?
- Surface any questions or contradictions to the user before starting
- Create a todo item per task (use the `T-NNN` ID — preserved from the plan)
- Skip to **Step 2: Plan-mode execution**

**If no plan exists:**
- Tell the user: "No master plan found. I can either run `/write-plan` first, or self-direct (I'll plan as I go)."
- If they choose self-direct: skip to **Step 2': Self-directed execution**

### 2. Plan-mode execution

A `/write-plan` plan describes **behaviors**, not test code. The plan tells you _what_ to test (behavior + public interface) and _what to refuse_ (anti-patterns). You write the test yourself, at execution time, using the **Test Quality Reference** below.

Run in batches of 3 tasks. For each task:

1. Mark task as in_progress
2. Read the task: behavior description, public interface, files, anti-patterns to refuse
3. **Write a failing test that exercises the behavior through the public interface** — apply the Test Quality Reference. Refuse any test shape the task explicitly flags.
4. Run the test, confirm it fails for the right reason (RED)
5. Write the minimal implementation to pass (GREEN)
6. Run the test, confirm it passes
7. Commit with the task's commit message
8. Mark task as completed

After each batch, stop and report:
- What was implemented (one line per task)
- Test output (pass count / total)
- Say: "Ready for next batch — or any feedback?"

**The plan should NOT contain test code.** If you find pre-written test code in a plan, treat it as a draft suggestion at best — you still derive the test from the behavior description and the current codebase. Pre-baked tests are stale by design (they were written before you saw the prior cycle's GREEN code).

**Stop immediately when:**
- A test fails unexpectedly and the cause is unclear
- The plan references a file or symbol that doesn't exist
- An instruction contradicts the current codebase state
- Verification fails more than once on the same step
- **The behavior description is too vague to derive a test from** — ask the user to sharpen it (or re-run `/write-plan`'s review gate)
- **The behavior can only be verified by peeking behind the public interface** (e.g., direct DB query, spying on internal calls) — that's a design problem, not a test problem. Recommend:
  - `/improve-codebase-architecture` if the affected interface already exists in code (typical mid-feature case — code is real, the seam is too narrow)
  - `/design-like-senior` only if the interface is purely on paper and not yet implemented

Don't guess through blockers — ask.

### 2'. Self-directed execution (no plan)

When no plan exists, plan as you go:

**Plan briefly with the user:**
- What public interface needs to change?
- Which behaviors matter most? (You can't test everything — prioritize critical paths and complex logic.)
- Identify opportunities for [deep modules](deep-modules.md) (small interface, deep implementation)
- Design interfaces for [testability](interface-design.md)

Read whichever of these exist before deciding interfaces:

- **`docs/features/<slug>/design.md`** — if `/design-like-senior` ran without `/write-plan`, the design is here. Use its public-interface section as the source of truth for what to test.
- **`docs/architecture.md`** — for module list, observability, code style, resilience defaults.
- **`CONTEXT.md`** and **`docs/adr/`** — for vocabulary and prior decisions.

If the user is asking you to design new public interfaces from scratch, that's `/design-like-senior`'s job, not this skill's. Send them there and resume `/tdd` afterwards.

**Then run tracer-bullet loops, one behavior at a time:**

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:
- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests
- Apply the **Test Quality Reference** below to every test

### 3. Refactor

After all tests pass (plan mode: between batches; self-directed: after the loop), look for [refactor candidates](refactoring.md):

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first.

### 4. Finishing

When all tasks/behaviors are complete:

1. Run the full test suite
2. Report pass/fail and coverage
3. Ask the user before committing anything not already committed

After commit, suggest the next step based on what happened during the cycle:

- **A test was hard to write because the seam was wrong** → recommend `/improve-codebase-architecture` against the affected module before the next feature.
- **A test surfaced a regression elsewhere** → recommend `/diagnose` for the regression, separate from this feature's commits.
- **The behavior list completed cleanly** → next feature or ticket. Loop back to `/to-prd` (new feature) or pick the next issue from `/triage`'s `ready-for-agent` queue.

---

## Test Quality Reference

Consult this whenever writing or reviewing a test, regardless of mode.

### Behavior, not implementation

**Core principle:** Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't.

**Which "public"?** See [`docs/skill-contracts.md` §3](../../../docs/skill-contracts.md). Default to **system-public** (the surface a real caller hits — HTTP endpoint, CLI, message-bus event, scheduled job entry). Drop to **module-public** only when `design.md` or the plan task explicitly tags that level for a behavior — typically a pure domain calculation with no system-public path of its own.

**Good tests** are integration-style: they exercise real code paths through public APIs. They describe _what_ the system does, not _how_ it does it. A good test reads like a specification — "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure.

**Bad tests** are coupled to implementation. They mock internal collaborators, test private methods, or verify through external means (like querying a database directly instead of using the interface). The warning sign: your test breaks when you refactor, but behavior hasn't changed. If you rename an internal function and tests fail, those tests were testing implementation, not behavior.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

### Vertical slices, not horizontal

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" — treating RED as "write all tests" and GREEN as "write all code."

This produces crap tests:
- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, signatures) rather than user-facing behavior
- Tests become insensitive to real changes — they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach:** vertical slices via tracer bullets. One test → one implementation → repeat.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
```

In plan mode this is enforced by the plan's task granularity — each task is one RED→GREEN cycle. The plan describes the _behavior_ for each cycle; you write the test for that cycle when you reach it, not in advance. In self-directed mode, you enforce vertical slicing yourself.

### Per-test checklist

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```
