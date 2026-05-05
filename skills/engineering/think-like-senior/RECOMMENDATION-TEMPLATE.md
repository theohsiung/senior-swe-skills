# Recommendation Format

Every architectural recommendation produced by this skill uses the same five sections. The format exists so the user can verify the reasoning at a glance — without it, recommendations turn into vibes-based assertions ("use Postgres") that are impossible to push back on productively.

## Template

```md
### Recommendation
{One or two sentences. The chosen option, no waffle.}

### Driven by
- {Phase A constraint or earlier decision} → {what it implies}
- {…}

### Considered & rejected
- **{Alternative 1}** — {why rejected, in terms of a Phase A constraint or knock-on cost}
- **{Alternative 2}** — {…}

### What would change my mind
- {Specific constraint change → which alternative would win}
- {…}

### Push back?
{Invitation for the user to confirm, modify, or surface a missing constraint.}
```

## Why each section exists

**Recommendation** comes first because the user reads top-down. They should see the conclusion before the reasoning, not after it. Senior engineers state the answer, then justify — not the reverse.

**Driven by** is the most important section. Every bullet must cite a *concrete* Phase A constraint or an earlier accepted decision. If a bullet reads like "best practice" or "industry standard", delete it — that's hallucination dressed as reasoning. Without "Driven by", the recommendation is unfalsifiable.

**Considered & rejected** forces the recommendation through a real comparison. At least one alternative must appear, even if you reject it in one line. This is what stops the LLM from locking onto its first idea. It also gives the user a free menu — sometimes they'll see a rejected option and say "actually that one fits, here's why".

**What would change my mind** is the user's escape hatch. They don't have to reject the whole recommendation — they can say "constraint X is actually different" and the skill knows what to do. Without this, push-back gets stuck on "I disagree" → "okay, sorry, here's a different recommendation", which is sycophancy.

**Push back?** is a literal prompt. The skill doesn't move on until the user replies.

## Worked example

Phase A captured these constraints:

- 3 engineers, no plans to grow past 6 in 12 months
- 6-week MVP deadline
- B2B SaaS, expect 50 trial customers in first 3 months, 500 within 12 months
- No compliance scope yet (plain B2B, no PHI / PII regulations beyond GDPR)
- Tech stack already chosen: TypeScript + Postgres

Step 2 (system architecture) recommendation:

```md
### Recommendation
Modular monolith deployed as a single service. One Postgres instance, one application binary.

### Driven by
- team_size = 3, no growth planned past 6 → operational cost of multiple services would consume more than 20% of capacity
- deadline = 6w → microservice bootstrap (mesh, tracing, deploy pipelines, service discovery) eats 1–2w of that
- scale = 500 customers in 12 months → single Postgres comfortably handles this, no need to shard or split read paths
- stack already TS + Postgres → no language polyglot pressure forcing service split

### Considered & rejected
- **Plain monolith (no module boundaries)** — cheap now, but with 3 devs working in parallel the codebase will tangle within 3 months. The marginal cost of enforced module boundaries is low (a linter rule and a folder convention), so this rejection is cheap to make.
- **Microservices** — team_size and deadline both veto. Operational tax exceeds the benefit at this scale.
- **Serverless (e.g., Lambda + RDS)** — viable for the scale, but the team has no operational experience with it (implied by stack choice). Adds learning curve that breaks the deadline.

### What would change my mind
- team_size grows past 8 within the year → start carving out the most independent module as a service
- A single subsystem develops radically different SLA (e.g., a real-time feed at p99 < 50ms) → that subsystem goes independent
- Compliance forces data isolation between tenants beyond what row-level security provides → split data plane

### Push back?
Confirm, or surface a constraint we haven't captured.
```

Notice every "Driven by" bullet names a number or fact from Phase A. No bullet says "monoliths are simpler" — that's an assertion, not a constraint-driven argument. Notice "Considered & rejected" includes a defensive reason for picking modular over plain monolith (the marginal cost is low) — because that's a real trade-off the user might question.

## Edge cases

**Only one viable alternative.** If you genuinely can't think of one, write the section anyway and call it out: "**No real alternative** — given the constraints, every other approach is worse on multiple dimensions. If you see one I missed, surface it." This is honest and invites pushback.

**Recommendation isn't constraint-driven, it's just a default.** Step 7a (observability) and Step 8 (code style) skip this template entirely — they're auto-applied. If you find yourself producing a "Driven by: it's the industry standard" bullet, you're in the wrong template; move that to a one-liner in `docs/architecture.md`.

**The user pushes back with vibes only.** Don't fold. Reply with: "Which Phase A constraint would have to change for me to recommend that?" Then wait. Once they answer, treat their reply as a new constraint and re-run.

**The user agrees too quickly.** If the user accepts the recommendation without engaging with any of the sections, briefly probe one alternative: "Just to test — if your team grew to 10 next quarter, which of these decisions would you reverse first?" This is a senior tell — checking that the user has internalised which decisions are reversible and which are sticky.
