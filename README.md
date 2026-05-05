<p>
  <a href="https://www.aihero.dev/s/skills-newsletter">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skills-repo-dark_2x.png">
      <source media="(prefers-color-scheme: light)" srcset="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skill-repo-light_2x.png">
      <img alt="Skills" src="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skill-repo-light_2x.png" width="369">
    </picture>
  </a>
</p>

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

The senior-design skills (`/think-like-senior`, `/design-like-senior`, `/write-plan`) layer on top of the original Matt Pocock workflow. Use what fits your project's complexity.

```
ONCE PER REPO
  /setup-senior-swe-skills        → docs/agents/* + AGENTS.md/CLAUDE.md

ONCE PER PROJECT (optional, skip for trivial projects)
  /think-like-senior              → docs/architecture.md + project ADRs

ANYTIME (when domain terms emerge or get fuzzy)
  /grill-with-docs                → CONTEXT.md + domain ADRs

PER FEATURE
  [conversation / brainstorm]
        ↓
  /to-prd                         → product PRD on issue tracker
        ↓
  /design-like-senior             → docs/features/<slug>/design.md
        ↓
  ┌─────────────────────────┬──────────────────────────────┐
  ↓                         ↓                              ↓
  /write-plan               /to-issues                     /write-plan
  → docs/plans/             → backlog tickets              ↓
  (behavior list,           (vertical slices,              /to-issues
   no test code)             hours/days each)               (chain)
  ↓                         ↓                              ↓
  /tdd                      (later) /write-plan → /tdd     /tdd
  (immediate execution,     (asynchronous pickup)
   derives tests at
   execution time)
```

Pick the right downstream:

- **`/write-plan` only** — small feature, you'll execute now. Behavior list → /tdd, done.
- **`/to-issues` only** — backlog work, multi-dev or AFK agent will pick it up later. Each issue gets its own /write-plan when worked on.
- **Both, chained (`/write-plan` → `/to-issues`)** — you want a TDD-cycle behavior list _and_ a shippable backlog. Plan first reveals the breakdown; issues group adjacent behaviors into vertical slices.

Note: `/write-plan` produces a **behavior list**, not pre-written test code. `/tdd` derives the actual test for each cycle at execution time, looking at the just-passed code. This is the "don't outrun your headlights" discipline from Matt's `/tdd` skill — pre-writing tests in bulk is an anti-pattern.

Maintenance skills (`/diagnose`, `/triage`, `/improve-codebase-architecture`, `/zoom-out`) run ad-hoc, independent of this flow.

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
- **[setup-senior-swe-skills](./skills/engineering/setup-senior-swe-skills/SKILL.md)** — Scaffold the per-repo config (issue tracker, triage label vocabulary, domain doc layout) that the other engineering skills consume. Run once per repo before using `to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture`, or `zoom-out`.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Execute a TDD implementation: read a plan from `/write-plan` and run task-by-task with red-green-refactor, or self-direct if no plan exists.
- **[think-like-senior](./skills/engineering/think-like-senior/SKILL.md)** — Senior-style architecture pass for a new project (or major architectural pivot). Walks constraints → load-bearing decisions → system architecture → data model → resilience → code style, producing `docs/architecture.md` and ADRs. Run once per project before `/to-prd`.
- **[design-like-senior](./skills/engineering/design-like-senior/SKILL.md)** — Per-feature design pass that runs after `/to-prd` and before any of `/write-plan`, `/to-issues`, or `/tdd`. Walks application architecture (where this feature plugs in), module boundaries, and public-interface design. Produces `docs/features/<slug>/design.md` that downstream skills read. Anchored to `architecture.md` + ADRs.
- **[to-issues](./skills/engineering/to-issues/SKILL.md)** — Break a feature into independently-grabbable backlog tickets (each = a vertical slice taking hours/days). Reads PRD + `design.md` + `docs/plans/`. Different from `/write-plan`, which produces task-level steps for immediate execution; the two can chain.
- **[to-prd](./skills/engineering/to-prd/SKILL.md)** — Turn the current conversation context into a **product** PRD (user intent, acceptance criteria, out-of-scope). No technical design — that's `/design-like-senior`.
- **[write-plan](./skills/engineering/write-plan/SKILL.md)** — Turn a feature design into a behavior-driven TDD plan. Lists behaviors, public interfaces, and anti-patterns to refuse — _not_ pre-written test code. `/tdd` derives the actual test from the behavior at execution time. For backlog tickets, use `/to-issues` instead; the two can chain.
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
