# Resilience Patterns Index

Read this first when walking Step 7b. The skill applies sensible defaults silently; the patterns here exist for **deliberate overrides** anchored to Phase A constraints.

## Available patterns

- **[retry-policy.md](./retry-policy.md)** — Exponential backoff with jitter, retry budget, what to retry vs not (idempotent / non-idempotent / money). Default 3× retry; override when at-least-once is the headline or when money is involved.
- **[circuit-breaker.md](./circuit-breaker.md)** — Per-dependency vs per-tenant scoping, failure-rate vs latency-based tripping, half-open recovery. Default global per-dependency; override scope when multi-tenant fairness matters.
- *(Future patterns: `timeout-defaults.md`, `idempotency-keys.md`, `bulkhead.md`, `dead-letter-handling.md`. Add when a project needs the override discussion.)*

## Default policies (apply silently unless a constraint contradicts)

| Policy | Default | Override when… |
|---|---|---|
| Outbound timeout | 5s connect / 30s total | latency-sensitive (p99 < 200ms) → 1s/3s; batch/long-poll → 10s/120s |
| Retry | 3× exponential backoff with jitter, idempotent + 5xx/timeout only | money / settlement → 0 retries + idempotency keys; at-least-once headline → up to 8× over hours |
| Circuit breaker | enable for any external HTTP dependency, 50% failure / 60s window | pure batch / single-process / CLI → skip; multi-tenant → scope per-(tenant, sink) |

## When to skip Step 7b entirely

- Single-binary CLI / batch job with no outbound HTTP — there is nothing to make resilient.
- Single-process worker reading from a local queue with no external sinks.
- Throwaway prototype.

## When to grill (≤ 3 questions)

Only ask the user when Phase A genuinely lacks the input:
1. SLA target (p99 latency or availability) — drives outbound timeout policy
2. Money / settlement involvement — drives retry policy on payment paths
3. Multi-tenant on shared infrastructure — drives circuit breaker scoping

If Phase A has these, apply the default + override silently and write the result into architecture.md.

## Procedure for Step 7b

1. Read this index.
2. For each policy, check whether Phase A contradicts the default.
3. For policies needing override, read the relevant pattern file and apply the 5-section template.
4. For policies that match the default, apply silently — one-line summary in architecture.md is enough.
5. ADRs only for genuinely surprising overrides (Stripe 0-retries, per-tenant breaker scoping, etc.). Don't ADR the defaults.
