# ADR Writing Protocol

**This file is the single source of truth for ADRs in this plugin.** Other skills (`think-like-senior`, `design-like-senior`, `improve-codebase-architecture`, `grill-with-docs`) link here rather than restating the format or the triple test. See [`docs/skill-contracts.md` §4](../../../docs/skill-contracts.md) for the cross-skill agreement.

ADRs live under the `adr_root` resolved from `docs/agents/paths.md` (default: `docs/adr/`). Filename: `NNNN-slug.md`, e.g. `0007-event-sourced-orders.md`.

---

## When to file an ADR — the triple test

All three must be true. If any is missing, skip the ADR.

1. **Hard to reverse** — the cost of changing your mind later is meaningful.
2. **Surprising without context** — a future reader will look at the code and wonder "why on earth did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons.

If a decision is easy to reverse, skip — you'll just reverse it. If it's not surprising, nobody will wonder why. If there was no real alternative, there's nothing to record beyond "we did the obvious thing."

### What typically qualifies

- **Architectural shape.** "We're using a monorepo." "The write model is event-sourced; the read model is projected into Postgres."
- **Integration patterns between contexts.** "Ordering and Billing communicate via domain events, not synchronous HTTP."
- **Technology choices that carry lock-in.** Database, message bus, auth provider, deployment target. Not every library — only the ones that would take a quarter to swap out.
- **Boundary and scope decisions.** "Customer data is owned by the Customer context; other contexts reference it by ID only." The explicit no-s are as valuable as the yes-s.
- **Deliberate deviations from the obvious path.** "We're using manual SQL instead of an ORM because X." Anything where a reasonable reader would assume the opposite. Stops the next engineer from "fixing" something that was deliberate.
- **Constraints not visible in the code.** "We can't use AWS because of compliance requirements." "Response times must be under 200ms because of the partner API contract."
- **Rejected alternatives when the rejection is non-obvious.** If you considered GraphQL and picked REST for subtle reasons, record it — otherwise someone will suggest GraphQL again in six months.

---

## How to file one — the protocol

All ADR-writing skills follow these four steps. None of them allocate numbers or scan for existing ADRs on their own.

### Step 1 — Allocate the number

Run the helper script (it acquires a lock so parallel sessions can't collide):

```bash
scripts/next-adr-number.sh "${ADR_ROOT:-docs/adr}"
```

It prints the next zero-padded number, e.g. `0007`, and creates the directory if it doesn't exist. Don't roll your own `find max` — it's a race.

### Step 2 — Check for near-duplicates

Before writing, grep the proposed title across existing ADRs:

```bash
grep -li "<keyword from title>" "${ADR_ROOT:-docs/adr}"/*.md 2>/dev/null
```

If you find a hit on the same subject, surface it to the user: "ADR-0003 already covers `<title>` — should we update it instead of filing a new one?" Don't silently create parallel ADRs on the same decision; that's how teams end up with three contradictory ADRs on auth.

### Step 3 — Write the file

Use the template below. Save to `<adr_root>/NNNN-<slug>.md` where `<slug>` is kebab-case derived from the title.

```md
# {Short title of the decision}

{1–3 sentences: what's the context, what did we decide, and why.}
```

That's it. An ADR can be a single paragraph. The value is in recording *that* a decision was made and *why* — not in filling out sections.

### Step 4 — Tell the user

Report back in the form: "Filed as ADR-0007: <title>." The number is now stable; future ADRs that supersede this one reference it by number.

---

## Optional sections

Only include these when they add genuine value. Most ADRs won't need them.

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — useful when decisions are revisited.
- **Considered Options** — only when the rejected alternatives are worth remembering.
- **Consequences** — only when non-obvious downstream effects need to be called out.
