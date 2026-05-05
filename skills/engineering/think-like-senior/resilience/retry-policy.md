# Retry Policy

The default — 3× exponential backoff with jitter, only retry idempotent operations on 5xx / timeout — is correct for ~80% of projects. The override discussion is when the default is *too aggressive* (money) or *too timid* (at-least-once headline).

## Default profile

- 3 attempts total (1 initial + 2 retries)
- Exponential backoff: 1s, 2s, 4s with ±30% jitter
- Retry on: connection error, timeout, HTTP 5xx, HTTP 429 (respect `Retry-After`)
- Do NOT retry on: HTTP 4xx (except 429), parse errors, business-logic rejections
- Only retry idempotent operations (GET, PUT, DELETE, requests with idempotency keys)

## When to override toward more retries

- "At-least-once delivery" or "no dropped events" is a stated headline → 6–8 attempts, exponential backoff capped at 1h, max age 24h, then dead-letter
- Downstream is known-flaky (third-party APIs that throttle for hours: Slack, Discord, Twilio, etc.)
- Latency does not matter (the brief explicitly says seconds-to-hours OK)

In these cases the override usually pairs with:
- Persistent retry state (outbox table, not in-memory) so retries survive process restarts
- Idempotency keys forwarded to the downstream so duplicates are absorbed
- A dead-letter destination after the budget is exhausted, with a manual replay path

## When to override toward fewer (or zero) retries

- **Money / settlement / charge calls** → 0 retries, idempotency key mandatory, recovery via reconciliation
- **State-changing non-idempotent calls without idempotency support** → 0 retries; surface the failure
- **Strict SLA budget** where retries would push the user-visible response past the SLA → reduce to 1 retry or disable

For money specifically:
- Use a deterministic idempotency key (e.g., `tenant:T:invoice:I:attempt:N`)
- Recovery is *reconciliation*, not retry — a periodic job lists charges from the provider and matches against local state
- Mismatches page ops, not trigger automatic remediation

## When to keep the default

If Phase A lacks a stated SLA, no money handling, no at-least-once requirement — the default is right. Apply silently in architecture.md without grilling.

## What an override signs you up for

- Persistent retry state (DB row or outbox)
- Idempotency keys at every layer of the call chain
- Dead-letter inspection and replay tooling
- Metrics on retry-attempt distribution and dead-letter inflow rate
- Alerts on dead-letter inflow rate increasing > N/hour

## Anti-patterns to refuse

- **In-memory retry that doesn't survive process restart** — retries should outlive the process for any retry budget > 1
- **Retrying non-idempotent calls without idempotency keys** — the retry succeeds but creates a duplicate; classic "I got charged twice" bug
- **Same retry policy for read calls and write calls** — reads can retry aggressively; writes need idempotency
- **Retry budget without a dead-letter** — you're just hiding the failure; eventually the operation must surface
- **Hardcoded retry counts** — every retry policy needs a config knob and a metric

## Quick check before recommending

- Does Phase A actually contradict the default? If not, apply default silently — don't grill.
- For money: is there an idempotency key strategy already, or do you need to introduce one?
- For at-least-once: where does retry state live? In-memory is wrong; outbox is right.
- Where do retries that exhaust the budget go? "Just log them" is wrong; they need a dead-letter and an alert.
- Is there a metric for "retry attempts per success"? Without it, retry-storm regressions are invisible.
