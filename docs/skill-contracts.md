# Skill Contracts

Single source of truth for the cross-skill agreements in this plugin. When two skills disagree about a term, an artifact, or a granularity, **this file wins**. Update it here once; SKILL.md files reference back.

If you're a skill author and you're tempted to redefine one of these concepts inside your SKILL.md, don't — link to the relevant section here instead. The whole point is that vocabulary stays consistent across the workflow.

---

## §1 — Artifact ownership

Each artifact has exactly one **writer skill** (the one allowed to create or rewrite the file as a whole) and any number of **reader skills**. Skills that need to *append* to an artifact owned by someone else go through the writer's documented append protocol (or call a shared helper, see §4).

| Artifact | Writer | Readers | Append-via |
|---|---|---|---|
| `docs/agents/*.md` (paths, issue tracker, triage labels, domain layout) | `setup-senior-swe-skills` | all engineering skills | re-run setup |
| `docs/architecture.md` | `think-like-senior` | `design-like-senior`, `write-plan`, `tdd`, `improve-codebase-architecture`, `where-am-i`, `to-prd` | re-run `think-like-senior` in update mode |
| `docs/adr/NNNN-*.md` | **shared ADR protocol** (see §4) | all skills | shared protocol |
| `CONTEXT.md` (or `CONTEXT-MAP.md` + per-context files) | `grill-with-docs` | all skills | append inline during `grill-with-docs`; other skills propose terms but redirect writes here |
| `docs/prd/<slug>.md` (or PRD on issue tracker) | `to-prd` | `design-like-senior`, `to-issues`, `where-am-i` | re-run `to-prd` |
| `docs/features/<slug>/design.md` | `design-like-senior` | `write-plan`, `to-issues`, `tdd`, `where-am-i` | re-run `design-like-senior` (revision mode) |
| `docs/plans/<slug>.md` (master plan) | `write-plan` | `tdd`, `to-issues`, `where-am-i` | re-run `write-plan` against same slug — append new tasks with new IDs, never renumber |
| `.out-of-scope/<slug>.md` | `triage` | `triage`, `to-prd` | re-run `triage` |
| Issues on the issue tracker | `to-prd`, `to-issues` (create); `triage` (transition) | all skills | `triage` for state changes |

**Filename normalization:** `<slug>` is always kebab-case derived from the feature title. The plan file does **not** include a date prefix anymore — see §5 (slugs are stable, dates are not). If you find a legacy `YYYY-MM-DD-<slug>.md` plan, treat it as the master plan for that slug.

**Path resolution:** the literal paths above are defaults. The actual paths come from `docs/agents/paths.md` (written by `setup-senior-swe-skills`). Skills must read `paths.md` first and fall back to the defaults only if it's missing. See §6.

---

## §2 — Granularity terms

Three granularities, three names. Don't say "vertical slice" or "tracer bullet" without first telling the reader which of these you mean. SKILL.md files should use these exact words.

| Term | Size | Skill that produces it | Output |
|---|---|---|---|
| **feature** | a complete user-facing capability — days to weeks of work | `to-prd` | one PRD |
| **slice** | a vertical, end-to-end shippable increment of a feature — hours to days | `to-issues` | one issue |
| **cycle** | one RED→GREEN→(refactor) iteration of a single behavior — minutes | `write-plan` (lists them) / `tdd` (executes them) | one task in the master plan, one commit |

A feature contains 1..N slices. A slice contains 1..M cycles. A cycle is **one logical change** — don't put a time bound on it; "5–15 minutes" was aspirational and wrong for cycles that include schema migrations or external integrations. See §5.

When write-plan and to-issues are both used (the recommended path), to-issues groups *adjacent cycles* into slices. The slice references its cycles by stable ID, not by re-listing them — see §5.

---

## §3 — "Public interface" levels

The phrase "test through the public interface" is ambiguous. This plugin uses two concrete levels:

- **system-public** — the surface a real user or external system reaches: HTTP endpoints, CLI invocations, message-bus events, scheduled job entry points, UI interactions. **Default test level for `tdd`.**
- **module-public** — a module's exported API to the rest of the system: package exports, class public methods, function signatures captured in `design.md` Step 6.

### Rules

1. `tdd` defaults to **system-public** testing. A test should drive the system the same way a real caller would.
2. `tdd` may drop to **module-public** *only when* `design.md` explicitly tags an interface as the "test surface" for a behavior — for example, a pure domain calculation that has no system-public path of its own.
3. `design-like-senior` Step 6 outputs are **module-public** by definition. A behavior that needs system-public testing maps to a system-public entry point that *uses* the module-public interface — both are real, the module-public one is just inside the system-public one.
4. `write-plan`'s "Public interface this task introduces" field must say which level applies. Default: system-public.

### Why this matters

If you test only at module-public, your test suite is brittle to refactors that move responsibility between modules. If you test only at system-public, your test suite can't pin down behavior in a deep module that has no direct external trigger. Both are needed; `design.md` decides which level is right for each behavior.

---

## §4 — ADR writing protocol

**One source of truth for ADRs.** All skills delegate to this protocol — none of them allocate numbers or write ADR files independently.

The format itself lives in [`skills/engineering/grill-with-docs/ADR-FORMAT.md`](../skills/engineering/grill-with-docs/ADR-FORMAT.md). The triple test (hard to reverse, surprising without context, real trade-off) is defined there. Don't restate either inside other SKILL.md files — link to it.

### Allocating the next number

Use [`scripts/next-adr-number.sh`](../scripts/next-adr-number.sh). It scans `docs/adr/`, picks `max(NNNN) + 1`, and uses an `mkdir`-based lock so two parallel sessions can't claim the same number. Skills shell out to this script — they don't implement their own scan.

### Writing the file

After the number is allocated:

1. `grep -i "<proposed-title>"` across `docs/adr/` to catch near-duplicates. If a similar ADR exists, surface it to the user before writing — don't silently create a parallel decision.
2. Write `docs/adr/NNNN-<slug>.md` using the format in `ADR-FORMAT.md`.
3. Tell the user the number assigned, in the form "Filed as ADR-NNNN".

### Which skills propose ADRs

`think-like-senior`, `grill-with-docs`, `design-like-senior`, `improve-codebase-architecture`. Each skill applies the triple test from `ADR-FORMAT.md` to its own decisions, then runs the steps above. The skill's SKILL.md should not describe the format or triple test itself — it should describe *which kinds of decisions in its scope* tend to qualify, and link here.

---

## §5 — Master plan and slice references

The plan file is the canonical task list for a feature. There is one per feature, named `<slug>.md` (no date prefix — slugs are stable, the date in old `YYYY-MM-DD-<slug>.md` files added churn for nothing).

### Stable task IDs

Each task in the master plan gets a stable ID `T-NNN`, assigned in creation order and **never reused** even if a task is removed (mark removed tasks as `~~T-NNN~~ Withdrawn` rather than deleting them, so existing slice references don't dangle).

Plan file shape:

```markdown
# <Feature Name> Implementation Plan

> **For Claude:** Use /tdd to execute this plan. Each task is one RED→GREEN cycle. Derive the test code at execution time from the behavior description — do NOT pre-write test code into this plan.

**Goal:** ...
**Design doc:** docs/features/<slug>/design.md
...

---

### T-001: <one-sentence behavior>
**Behavior to verify** ...
...

### T-002: ...
```

### Slice references

When `to-issues` groups cycles into slices, each issue body must include:

```
## Plan tasks
- master plan: docs/plans/<slug>.md
- this slice covers: T-004 .. T-008
```

When the issue is picked up later and `/write-plan <issue#>` is invoked, the skill **does not regenerate** the plan. It reads the master plan, filters to the task IDs the issue references, and prints them for `/tdd` to consume. This avoids the plan-divergence trap where each issue spawns its own copy that drifts from the master.

If the master plan needs to grow (the implementer discovers a missing cycle while working a slice), append a new task with a fresh ID and update the slice's "covers" list. Don't fork the plan.

---

## §6 — Path configuration

`setup-senior-swe-skills` writes `docs/agents/paths.md`. All other skills read it before touching any artifact.

`paths.md` shape:

```yaml
# All paths are relative to the repo root unless absolute.
architecture: docs/architecture.md
adr_root: docs/adr/
features: docs/features/
plans: docs/plans/
prd: docs/prd/
context: CONTEXT.md            # or: CONTEXT-MAP.md (multi-context)
out_of_scope: .out-of-scope/
```

Monorepo layouts override these per-package; `setup-senior-swe-skills` asks during setup. If `paths.md` is missing, skills fall back to the defaults shown in this section so the plugin still works on repos that haven't run setup yet.

Skills must not hardcode the literal strings above when generating cross-references in their output (e.g., when `design-like-senior` writes "see `docs/architecture.md`" into a design.md, it should write whatever path `paths.md` resolves architecture to).

---

## §7 — Dual `CLAUDE.md` / `AGENTS.md` support

Claude Code reads `CLAUDE.md`. Codex / Aider / many open-source agents read `AGENTS.md`. When both tools are likely to use the repo, `setup-senior-swe-skills` writes the `## Agent skills` block into **both** files (or symlinks one to the other if the user prefers). Writing to only one would leave the other harness blind to the setup, so the older "edit whichever exists, never create the other" rule has been retired.

If only one tool is in use, only that file is touched.
