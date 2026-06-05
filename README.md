
# Skills For Real Engineers

My agent skills that I use every day to do real engineering - not vibe coding.

Developing real applications is hard. Approaches like GSD, BMAD, and Spec-Kit try to help by owning the process. But while doing so, they take away your control and make bugs in the process hard to resolve.

These skills are designed to be small, easy to adapt, and composable. They work with any model. They're based on decades of engineering experience. Hack around with them. Make them your own. Enjoy.

If you want to keep up with changes to these skills, and any new ones I create, you can join ~60,000 other devs on my newsletter:

[Sign Up To The Newsletter](https://www.aihero.dev/s/skills-newsletter)

## Quickstart (30-second setup)

1. Run the skills.sh installer:

```bash
npx skills@latest add theohsiung/senior-swe-skills
```

2. Pick the skills you want, and which coding agents you want to install them on. **Make sure you select `/setup-senior-swe-skills`**.

3. Run `/setup-senior-swe-skills` in your agent. It will:
   - Ask you which issue tracker you want to use (GitHub, Linear, or local files)
   - Ask you what labels you apply to ticks when you triage them (`/triage` uses labels)
   - Ask you where you want to save any docs we create

4. Bam - you're ready to go.

## How the skills compose

The senior-design skills (`/think-like-senior`, `/design-like-senior`, `/write-plan`) layer on top of the original Matt Pocock workflow. Use what fits your project's complexity. The cross-skill agreements (artifact ownership, granularity terms, public-interface levels, ADR protocol, master plan with stable task IDs) live in [`docs/skill-contracts.md`](./docs/skill-contracts.md).

```
ONCE PER REPO
  /setup-senior-swe-skills        → docs/agents/* + CLAUDE.md and/or AGENTS.md

PER NEW DOMAIN AREA  (default first step on a cold start — captures vocabulary)
  /grill-with-docs                → CONTEXT.md + domain ADRs

ONCE PER PROJECT (optional — skip for trivial projects)
  /think-like-senior              → docs/architecture.md + project ADRs

PER FEATURE
  /to-prd                         → product PRD on issue tracker
        ↓
  /design-like-senior             → docs/features/<slug>/design.md
        ↓
  /write-plan                     → docs/plans/<slug>.md  (master plan, stable T-NNN IDs)
        ↓
  /to-issues                      → backlog issues, each with `## Plan tasks: T-NNN..T-NNN`
        ↓
  (per issue, when picked up)
  /write-plan <issue#>            → filter mode: prints only that slice's cycles
        ↓
  /tdd                            → executes cycles RED→GREEN, derives tests at execution time
```

The recommended path is the full chain: **plan first, then issues**. Each issue references its `T-NNN` range from the single master plan, so when an implementer picks it up later, `/write-plan <issue#>` runs in **filter mode** — it prints the relevant cycles without writing a divergent plan. This avoids the drift you'd get from each issue spawning its own copy.

Escape hatches:

- **`/write-plan` only** — solo dev, executing now, no backlog needed. Plan → /tdd, done.
- **`/to-issues` only** — dropping straight from PRD/design.md to backlog without authoring the master plan first. The first implementer to pick up an issue authors the plan, then back-fills the `## Plan tasks` section. Use sparingly — the team-wide view of cycles only emerges when someone authors them.
- **Tiny / local change** — skip plan and issues; go straight from `/design-like-senior` (or directly from `/to-prd` for very small changes) to `/tdd` self-directed.

Note: `/write-plan` produces a **behavior list**, not pre-written test code. `/tdd` derives the actual test for each cycle at execution time, looking at the just-passed code. This is the "don't outrun your headlights" discipline — pre-writing tests in bulk is an anti-pattern.

Maintenance skills (`/diagnose`, `/triage`, `/improve-codebase-architecture`, `/zoom-out`) run ad-hoc, independent of this flow. `/diagnose` is **self-contained** — it writes its own regression test in Phase 5; don't route to `/tdd` after it.

Lost your place? Run `/where-am-i` — it reads the artifacts (`architecture.md`, ADRs, `design.md`, master plans, issues, git) and tells you which skill to run next. Read-only by design: the artifacts are the checkpoint, so there's no separate state file to drift.

## Why These Skills Exist

I built these skills as a way to fix common failure modes I see with Claude Code, Codex, and other coding agents.

### #1: The Agent Didn't Do What I Want

> "No-one knows exactly what they want"
>
> David Thomas & Andrew Hunt, [The Pragmatic Programmer](https://www.amazon.co.uk/Pragmatic-Programmer-Anniversary-Journey-Mastery/dp/B0833F1T3V)

**The Problem**. The most common failure mode in software development is misalignment. You think the dev knows what you want. Then you see what they've built - and you realize it didn't understand you at all.

This is just the same in the AI age. There is a communication gap between you and the agent. The fix for this is a **grilling session** - getting the agent to ask you detailed questions about what you're building.

**The Fix** is to use:

- [`/grill-me`](./skills/productivity/grill-me/SKILL.md) - for non-code uses
- [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) - same as [`/grill-me`](./skills/productivity/grill-me/SKILL.md), but adds more goodies (see below)

These are my most popular skills. They help you align with the agent before you get started, and think deeply about the change you're making. Use them _every_ time you want to make a change.

### #2: The Agent Is Way Too Verbose

> With a ubiquitous language, conversations among developers and expressions of the code are all derived from the same domain model.
>
> Eric Evans, [Domain-Driven-Design](https://www.amazon.co.uk/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)

**The Problem**: At the start of a project, devs and the people they're building the software for (the domain experts) are usually speaking different languages.

I felt the same tension with my agents. Agents are usually dropped into a project and asked to figure out the jargon as they go. So they use 20 words where 1 will do.

**The Fix** for this is a shared language. It's a document that helps agents decode the jargon used in the project.

<details>
<summary>
Example
</summary>

Here's an example [`CONTEXT.md`](https://github.com/mattpocock/course-video-manager/blob/076a5a7a182db0fe1e62971dd7a68bcadf010f1c/CONTEXT.md), from my `course-video-manager` repo. Which one is easier to read?

- **BEFORE**: "There's a problem when a lesson inside a section of a course is made 'real' (i.e. given a spot in the file system)"
- **AFTER**: "There's a problem with the materialization cascade"

This concision pays off session after session.

</details>

This is built into [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md). It's a grilling session, but that helps you build a shared language with the AI, and document hard-to-explain decisions in ADR's.

It's hard to explain how powerful this is. It might be the single coolest technique in this repo. Try it, and see.

> [!TIP]
> A shared language has many other benefits than reducing verbosity:
>
> - **Variables, functions and files are named consistently**, using the shared language
> - As a result, the **codebase is easier to navigate** for the agent
> - The agent also **spends fewer tokens on thinking**, because it has access to a more concise language

### #3: The Code Doesn't Work

> "Always take small, deliberate steps. The rate of feedback is your speed limit. Never take on a task that’s too big."
>
> David Thomas & Andrew Hunt, [The Pragmatic Programmer](https://www.amazon.co.uk/Pragmatic-Programmer-Anniversary-Journey-Mastery/dp/B0833F1T3V)

**The Problem**: Let's say that you and the agent are aligned on what to build. What happens when the agent _still_ produces crap?

It's time to look at your feedback loops. Without feedback on how the code it produces actually runs, the agent will be flying blind.

**The Fix**: You need the usual tranche of feedback loops: static types, browser access, and automated tests.

For automated tests, a red-green-refactor loop is critical. This is where the agent writes a failing test first, then fixes the test. This helps give the agent a consistent level of feedback that results in far better code.

I've built a **[`/tdd`](./skills/engineering/tdd/SKILL.md) skill** you can slot into any project. It encourages red-green-refactor and gives the agent plenty of guidance on what makes good and bad tests.

For debugging, I've also built a **[`/diagnose`](./skills/engineering/diagnose/SKILL.md)** skill that wraps best debugging practices into a simple loop.

### #4: We Built A Ball Of Mud

> "Invest in the design of the system _every day_."
>
> Kent Beck, [Extreme Programming Explained](https://www.amazon.co.uk/Extreme-Programming-Explained-Embrace-Change/dp/0321278658)

> "The best modules are deep. They allow a lot of functionality to be accessed through a simple interface."
>
> John Ousterhout, [A Philosophy Of Software Design](https://www.amazon.co.uk/Philosophy-Software-Design-2nd/dp/173210221X)

**The Problem**: Most apps built with agents are complex and hard to change. Because agents can radically speed up coding, they also accelerate software entropy. Codebases get more complex at an unprecedented rate.

**The Fix** for this is a radical new approach to AI-powered development: caring about the design of the code.

This is built in to every layer of these skills:

- [`/think-like-senior`](./skills/engineering/think-like-senior/SKILL.md) walks the project-level architecture pass once at the start, anchoring everything that follows
- [`/design-like-senior`](./skills/engineering/design-like-senior/SKILL.md) makes you walk module boundaries and public-interface design per feature, before any code is written
- [`/zoom-out`](./skills/engineering/zoom-out/SKILL.md) tells the agent to explain code in the context of the whole system

And crucially, [`/improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) helps you rescue a codebase that has become a ball of mud. I recommend running it on your codebase once every few days.

### Summary

Software engineering fundamentals matter more than ever. These skills are my best effort at condensing these fundamentals into repeatable practices, to help you ship the best apps of your career. Enjoy.

## Reference

### Engineering

Skills I use daily for code work.

- **[diagnose](./skills/engineering/diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions: reproduce → minimise → hypothesise → instrument → fix → regression-test.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — Domain-first grilling session that sharpens terminology and updates `CONTEXT.md` / ADRs inline. Focus is business language, not technical module design (that's `/design-like-senior`).
- **[triage](./skills/engineering/triage/SKILL.md)** — Triage issues through a state machine of triage roles.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in **existing** code (refactor). For shaping a new feature's modules before any code is written, use `/design-like-senior` instead.
- **[setup-senior-swe-skills](./skills/engineering/setup-senior-swe-skills/SKILL.md)** — Scaffold the per-repo config (project doc paths, issue tracker, triage label vocabulary, domain doc layout) that all other engineering skills consume. Run once per repo before using any of them.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Execute a TDD implementation: read the master plan from `/write-plan` (or its filtered slice) and run cycle-by-cycle with red-green-refactor, or self-direct if no plan exists. Default test level is system-public.
- **[think-like-senior](./skills/engineering/think-like-senior/SKILL.md)** — Senior-style architecture pass for a new project (or major architectural pivot). Walks constraints → load-bearing decisions → system architecture → data model → resilience → code style, producing `docs/architecture.md` and ADRs. Run once per project before `/to-prd`.
- **[design-like-senior](./skills/engineering/design-like-senior/SKILL.md)** — Per-feature design pass that runs after `/to-prd` and before any of `/write-plan`, `/to-issues`, or `/tdd`. Walks application architecture (where this feature plugs in), module boundaries, and public-interface design. Produces `docs/features/<slug>/design.md` that downstream skills read. Anchored to `architecture.md` + ADRs.
- **[to-issues](./skills/engineering/to-issues/SKILL.md)** — Group adjacent cycles from the master plan into backlog **slices** (hours/days each). Each issue carries a `## Plan tasks: T-NNN..T-NNN` reference so `/write-plan <issue#>` can filter the master plan later instead of regenerating a divergent copy.
- **[to-prd](./skills/engineering/to-prd/SKILL.md)** — Turn the current conversation context into a **product** PRD (user intent, acceptance criteria, out-of-scope). No technical design — that's `/design-like-senior`.
- **[write-plan](./skills/engineering/write-plan/SKILL.md)** — Author or filter the master plan for a feature. Author mode produces `docs/plans/<slug>.md` with stable `T-NNN` cycle IDs and behavior descriptions (no pre-written test code). Filter mode (when invoked from an issue) prints only the cycles that issue covers — never writes a divergent plan.
- **[where-am-i](./skills/engineering/where-am-i/SKILL.md)** — Read-only inspection of workflow artifacts (`architecture.md`, ADRs, `CONTEXT.md`, `design.md`, plans, issues, git) that reports project status and recommends the next skill to run. Use when resuming after a break or unsure what to run next.
- **[zoom-out](./skills/engineering/zoom-out/SKILL.md)** — Tell the agent to zoom out and give broader context or a higher-level perspective on an unfamiliar section of code.

### Productivity

General workflow tools, not code-specific.

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler while keeping full technical accuracy.
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[write-a-skill](./skills/productivity/write-a-skill/SKILL.md)** — Create new skills with proper structure, progressive disclosure, and bundled resources.

### Misc

Tools I keep around but rarely use.

- **[git-guardrails-claude-code](./skills/misc/git-guardrails-claude-code/SKILL.md)** — Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, etc.) before they execute.
- **[migrate-to-shoehorn](./skills/misc/migrate-to-shoehorn/SKILL.md)** — Migrate test files from `as` type assertions to @total-typescript/shoehorn.
- **[scaffold-exercises](./skills/misc/scaffold-exercises/SKILL.md)** — Create exercise directory structures with sections, problems, solutions, and explainers.
- **[setup-pre-commit](./skills/misc/setup-pre-commit/SKILL.md)** — Set up Husky pre-commit hooks with lint-staged, Prettier, type checking, and tests.
