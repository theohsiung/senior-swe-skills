# Circuit Breaker

A breaker tracks failures against a dependency and "opens" when the failure rate crosses a threshold, short-circuiting calls until a probe succeeds. The default — global per-dependency — is right for most projects. The override discussion is about **scoping**: per-tenant, per-(tenant, sink), or per-region.

## Default profile

- **Scope**: per external HTTP dependency (one breaker per third-party service)
- **Trip condition**: 50% failure rate over a 60-second sliding window, minimum 10 requests
- **Open duration**: 30 seconds
- **Half-open**: 5 probe requests; if ≥ 80% succeed, close. If not, re-open.
- **Counts as failure**: 5xx, timeouts, connection errors. Does NOT count: 4xx (caller error), 429 (handle separately with `Retry-After`).

## When to use the default

- Single-tenant service or non-shared infrastructure
- One external dependency at a time matters most
- "Noisy tenant problem" doesn't exist (no shared workers across tenants)

## When to override scope to per-tenant or per-(tenant, sink)

- **Multi-tenant on shared workers** — one tenant's broken sink must not exhaust workers and starve other tenants
- **Per-tenant SLAs differ materially** — a high-tier tenant's circuit recovery shouldn't be coupled to a free-tier tenant
- **Sinks are tenant-configured** (e.g., webhook router where each tenant points at their own URLs) — failures are inherently per-tenant per-sink

In these cases the breaker key becomes `(tenant_id, sink_id)` or just `tenant_id` depending on how dependencies are addressed.

## When to skip circuit breakers entirely

- Pure batch / single-process / CLI — there's no incoming traffic to protect
- No external HTTP dependencies — internal-only systems
- Throwaway prototype where downtime during a downstream outage is acceptable

## What enabling a breaker signs you up for

- Library choice: `pybreaker` (Python), `resilience4j` (JVM), `Polly` (.NET), `gobreaker` (Go), or framework-built-in
- Metrics: breaker state per key (closed / open / half-open), trip rate, time-to-recovery
- Alerts: breaker open for > N minutes (signals a downstream is genuinely down)
- Behaviour during open: usually 503 to caller with `Retry-After`, OR enqueue to outbox for later retry
- Tests: chaos test that simulates downstream failure and verifies breaker trips, recovers, doesn't false-trip

## Combining with retry policy

Breaker and retry interact subtly. Apply this order:

1. **Retry policy** runs *inside* the breaker call: when retrying, the breaker still counts attempts.
2. **Breaker open** means retries are also short-circuited — don't bypass.
3. **Breaker half-open**: limit retry count to 1 during probes (don't burn through the probe budget on retries).
4. **Backoff** between retries should be *less than* the breaker open duration to give the breaker a chance to test recovery.

## Anti-patterns to refuse

- **Global breaker across all tenants on shared infrastructure** — one tenant's failures trip the breaker for everyone. Either scope per-tenant or skip the breaker.
- **Counting 4xx as failures** — a misbehaving caller trips the breaker for *everyone*. Only 5xx and timeouts count.
- **Counting 429 as failure** — rate-limit responses are intentional throttling; honor `Retry-After`, don't trip breakers.
- **No half-open recovery** — a breaker that stays open until manually reset means every recovery requires human intervention.
- **Breaker without metrics or alerts** — invisible breaker tripping looks like "the system just got slow"; ops can't diagnose.
- **Breaker with timeout = backoff = retry** — three independent knobs all set to the same number means none of them is doing what you think.

## Quick check before recommending

- Is the system multi-tenant on shared workers? If yes, scope per-tenant or per-(tenant, sink).
- Are 429s explicitly excluded from failure counting?
- What happens to in-flight requests when the breaker opens — do they fail fast (correct) or queue up (defeats the breaker)?
- Is there a metric for "breaker state per key over time" so a partial outage shows up in dashboards before pages fire?
- Does the half-open recovery probe count match the typical retry policy? Mismatches cause false re-trips.
